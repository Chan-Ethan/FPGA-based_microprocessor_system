module IRTransmitterSM (
    // Standard signals
    input               RESETN,         // Active-low reset signal
    input               CLK,            // 100MHz system clock

    // Bus interface signals
    input       [3:0]   COMMAND,        // Command bits: [3] right, [2] left, [1] back, [0] forward
    input               SEND_PACKET,    // Pulse to trigger packet transmission

    // IR LED signal
    output reg          IR_LED          // Output to IR LED
);

// Parameters for blue-coded car packet (36 kHz carrier frequency)
parameter StartBurstSize = 191;     // Number of pulses in Start region
parameter GapSize = 25;             // Number of pulses in Gap region
parameter CarSelectBurstSize = 47;  // Number of pulses in CarSelect region
parameter AssertBurstSize = 47;     // Number of pulses for asserted direction
parameter DeAssertBurstSize = 22;   // Number of pulses for de-asserted direction

// FSM state definitions using one-hot encoding with 13 states
parameter [12:0] FSM_IDLE        = 13'b0000000000001; // Idle, waiting for SEND_PACKET
parameter [12:0] FSM_START       = 13'b0000000000010; // Generate Start burst
parameter [12:0] FSM_GAP1        = 13'b0000000000100; // Generate Gap after Start
parameter [12:0] FSM_CARSELECT   = 13'b0000000001000; // Generate CarSelect burst
parameter [12:0] FSM_GAP2        = 13'b0000000010000; // Generate Gap after CarSelect
parameter [12:0] FSM_RIGHT       = 13'b0000000100000; // Generate Right direction burst
parameter [12:0] FSM_GAP3        = 13'b0000001000000; // Generate Gap after Right
parameter [12:0] FSM_LEFT        = 13'b0000010000000; // Generate Left direction burst
parameter [12:0] FSM_GAP4        = 13'b0000100000000; // Generate Gap after Left
parameter [12:0] FSM_BACKWARD    = 13'b0001000000000; // Generate Backward direction burst
parameter [12:0] FSM_GAP5        = 13'b0010000000000; // Generate Gap after Backward
parameter [12:0] FSM_FORWARD     = 13'b0100000000000; // Generate Forward direction burst
parameter [12:0] FSM_GAP6        = 13'b1000000000000; // Generate Gap after Forward

// Internal signals
logic           CLK_IR;             // 36 kHz clock for IR modulation
logic           CLK_IR_enable;      // CLK_IR signal synchronized to main clock domain
logic           CLK_IR_prev;        // Previous CLK_IR value for edge detection
logic           CLK_IR_posedge;     // Positive edge of CLK_IR detected in main clock domain
logic           CLK_IR_negedge;     // Negative edge of CLK_IR detected in main clock domain

logic [12:0]    current_state;      // Current FSM state (one-hot)
logic [12:0]    next_state;         // Next FSM state (one-hot)

logic [7:0]     pulse_count;        // Counter for pulses in current burst
logic [7:0]     pulse_target;       // Target number of pulses for current state

logic           SEND_PACKET_sync;   // Synchronized SEND_PACKET signal
logic           SEND_PACKET_latched; // Latched SEND_PACKET signal
logic [3:0]     COMMAND_sync;       // Synchronized COMMAND signal

logic           ir_out;             // IR output signal (pre-modulation)

//================= Instantiate Clock Generator for 36 kHz IR carrier =================//
ClockGen #(
    .CLK_OUT_FREQ(36_000)           // 36 kHz for blue-coded car
) ClockGen_inst (
    .CLK        (CLK),
    .RESETN     (RESETN),
    .CLK_OUT    (CLK_IR)
);

//================= Synchronize cross-clock domain signals =================//
// Double-flop synchronizer for CLK_IR to main clock domain
// Clock domain synchronization logic
always_ff @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        CLK_IR_enable <= 1'b0;
        CLK_IR_prev <= 1'b0;
        CLK_IR_posedge <= 1'b0;
        CLK_IR_negedge <= 1'b0;
    end else begin
        CLK_IR_prev <= CLK_IR_enable;
        CLK_IR_enable <= CLK_IR;
        CLK_IR_posedge <= CLK_IR_enable && !CLK_IR_prev;
        CLK_IR_negedge <= !CLK_IR_enable && CLK_IR_prev;
    end
end

// Input signal synchronization
always_ff @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        SEND_PACKET_sync <= 1'b0;
        COMMAND_sync <= 4'b0000;
    end else begin
        SEND_PACKET_sync <= SEND_PACKET;
        COMMAND_sync <= COMMAND;
    end
end

// SEND_PACKET latching logic
always_ff @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        SEND_PACKET_latched <= 1'b0;
    end else begin
        if (SEND_PACKET_sync)
            SEND_PACKET_latched <= 1'b1;
        else if (current_state == FSM_START)
            SEND_PACKET_latched <= 1'b0;
    end
end

//================= State Transition Logic =================//
always_comb begin
    next_state = current_state; // Default: stay in current state
    case (1'b1) // One-hot case statement: check which bit is set
        current_state[0]: begin // FSM_IDLE
            // Only transition on CLK_IR_posedge and when SEND_PACKET has been latched
            if (CLK_IR_posedge && SEND_PACKET_latched) next_state = FSM_START;
        end
        current_state[1]: begin // FSM_START
            if (pulse_count >= StartBurstSize-1 && CLK_IR_posedge) next_state = FSM_GAP1;
        end
        current_state[2]: begin // FSM_GAP1
            if (pulse_count >= GapSize-1 && CLK_IR_posedge) next_state = FSM_CARSELECT;
        end
        current_state[3]: begin // FSM_CARSELECT
            if (pulse_count >= CarSelectBurstSize-1 && CLK_IR_posedge) next_state = FSM_GAP2;
        end
        current_state[4]: begin // FSM_GAP2
            if (pulse_count >= GapSize-1 && CLK_IR_posedge) next_state = FSM_RIGHT;
        end
        current_state[5]: begin // FSM_RIGHT
            if (pulse_count >= (COMMAND_sync[3] ? AssertBurstSize-1 : DeAssertBurstSize-1) && CLK_IR_posedge)
                next_state = FSM_GAP3;
        end
        current_state[6]: begin // FSM_GAP3
            if (pulse_count >= GapSize-1 && CLK_IR_posedge) next_state = FSM_LEFT;
        end
        current_state[7]: begin // FSM_LEFT
            if (pulse_count >= (COMMAND_sync[2] ? AssertBurstSize-1 : DeAssertBurstSize-1) && CLK_IR_posedge)
                next_state = FSM_GAP4;
        end
        current_state[8]: begin // FSM_GAP4
            if (pulse_count >= GapSize-1 && CLK_IR_posedge) next_state = FSM_BACKWARD;
        end
        current_state[9]: begin // FSM_BACKWARD
            if (pulse_count >= (COMMAND_sync[1] ? AssertBurstSize-1 : DeAssertBurstSize-1) && CLK_IR_posedge)
                next_state = FSM_GAP5;
        end
        current_state[10]: begin // FSM_GAP5
            if (pulse_count >= GapSize-1 && CLK_IR_posedge) next_state = FSM_FORWARD;
        end
        current_state[11]: begin // FSM_FORWARD
            if (pulse_count >= (COMMAND_sync[0] ? AssertBurstSize-1 : DeAssertBurstSize-1) && CLK_IR_posedge)
                next_state = FSM_GAP6;
        end
        current_state[12]: begin // FSM_GAP6
            if (pulse_count >= GapSize-1 && CLK_IR_posedge) next_state = FSM_IDLE;
        end
        default: next_state = FSM_IDLE; // Fallback to Idle on invalid state
    endcase
end

// State Register - now using main system clock
always_ff @(posedge CLK or negedge RESETN) begin
    if (!RESETN) current_state <= FSM_IDLE; // Reset to Idle state
    else current_state <= next_state;
end

//================= Pulse Target Logic =================//
always_ff @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        pulse_target <= StartBurstSize;
    end else if (current_state != next_state) begin
        // Set new target when transitioning states
        case (1'b1) // One-hot case for next_state
            next_state[1]:  pulse_target <= StartBurstSize;     // FSM_START
            next_state[2]:  pulse_target <= GapSize;            // FSM_GAP1
            next_state[3]:  pulse_target <= CarSelectBurstSize; // FSM_CARSELECT
            next_state[4]:  pulse_target <= GapSize;            // FSM_GAP2
            next_state[5]:  pulse_target <= COMMAND_sync[3] ? AssertBurstSize : DeAssertBurstSize; // FSM_RIGHT
            next_state[6]:  pulse_target <= GapSize;            // FSM_GAP3
            next_state[7]:  pulse_target <= COMMAND_sync[2] ? AssertBurstSize : DeAssertBurstSize; // FSM_LEFT
            next_state[8]:  pulse_target <= GapSize;            // FSM_GAP4
            next_state[9]:  pulse_target <= COMMAND_sync[1] ? AssertBurstSize : DeAssertBurstSize; // FSM_BACKWARD
            next_state[10]: pulse_target <= GapSize;            // FSM_GAP5
            next_state[11]: pulse_target <= COMMAND_sync[0] ? AssertBurstSize : DeAssertBurstSize; // FSM_FORWARD
            next_state[12]: pulse_target <= GapSize;            // FSM_GAP6
            default:        pulse_target <= 8'd0;               // FSM_IDLE or invalid
        endcase
    end
end

//================= Pulse Counter Logic =================//
always_ff @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        pulse_count <= 8'd0;
    end else if (current_state != next_state) begin
        // Reset counter when transitioning states
        pulse_count <= 8'd0;
    end else if (CLK_IR_posedge && (current_state != FSM_IDLE)) begin
        // Increment pulse counter while in active states
        pulse_count <= pulse_count + 8'd1;
    end
end

//================= IR_LED Output Generation =================//
always_ff @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        ir_out <= 1'b0;
    end else if (next_state == FSM_IDLE || next_state[2] || next_state[4] || 
                 next_state[6] || next_state[8] || next_state[10] || next_state[12]) begin
        ir_out <= 1'b0;
    end else if (CLK_IR_negedge) begin
        ir_out <= 1'b0;
    end else if (CLK_IR_posedge) begin
        ir_out <= 1'b1;
    end else;
end

// Modulate the output with the IR carrier frequency
always_ff @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        IR_LED <= 1'b0;
    end else begin
        // Only output high when ir_out is high AND we're on a CLK_IR pulse
        // Using CLK_IR_enable to ensure proper synchronization with the main clock domain
        IR_LED <= ir_out && CLK_IR_enable;
    end
end

endmodule