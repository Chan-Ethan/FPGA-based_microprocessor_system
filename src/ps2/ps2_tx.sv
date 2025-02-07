// PS/2 transmitter

module ps2_tx(
    input                   clk_sys         , // 50MHz system clock
    input                   rst_n           , // reset signal
    
    // PS2 interface inout
    inout                   PS2_CLK         ,
    inout                   PS2_DATA        ,
    
    // transmitter input interface
    input                   wr_en           ,
    input       [7:0]       wr_data         ,
    output reg              wr_done                 
);

`define FSM_IDLE       6'b000001
`define FSM_CLK_LOW    6'b000010
`define FSM_START      6'b000100
`define FSM_DATA       6'b001000
`define FSM_PARITY     6'b010000
`define FSM_STOP       6'b100000

// FSM and control signals
logic [5:0]         current_state, next_state;
logic [15:0]        clk_cnt;        // 200us counter (50MHz * 200us = 10_000 cycles)
logic [3:0]         bit_cnt;        // 0-7: data bits, 8: parity
logic [7:0]         tx_data;        // data to send
logic               parity_bit;     // odd parity
logic               drive_clk;      // control PS2_CLK output
logic               drive_en;       // enable driving data line
logic               drive_data;       // value to drive on PS2_DATA

// Tri-state buffers
assign PS2_CLK  = drive_clk ? 1'b0 : 1'bz;  // 0 when driving, z otherwise
assign PS2_DATA = drive_en  ? drive_data : 1'bz; 

//================= State Machine =================//
// State Transition Logic
always_comb begin
    next_state = current_state;
    case (current_state)
        `FSM_IDLE: begin
            if (wr_en) begin
                next_state = `FSM_CLK_LOW;
            end
        end
        `FSM_CLK_LOW: begin
            if (clk_cnt == 16'd9999) begin
                // 200us elapsed
                next_state = `FSM_START;
            end
        end
        `FSM_START: begin
            if (PS2_CLK == 1'b0)  begin
                // Wait for device to release clock
                next_state = `FSM_DATA;
            end
        end
        `FSM_DATA: begin
            if (bit_cnt == 4'd8)     // 8 data bits sent
                next_state = `FSM_PARITY;
        end
        `FSM_PARITY: begin
            if (bit_cnt == 4'd9)     // Parity bit sent
                next_state = `FSM_STOP;
        end
        `FSM_STOP: begin
            next_state = `FSM_IDLE;  // Return to idle after stop
        end
        default: 
            next_state = `FSM_IDLE;
    endcase
end

// State Register Update
always_ff @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= `FSM_IDLE;
        clk_cnt       <= 16'd0;
        bit_cnt       <= 4'd0;
        tx_data       <= 8'd0;
        parity_bit    <= 1'b0;
        wr_done       <= 1'b0;
    end
    else begin
        current_state <= next_state;
        wr_done       <= 1'b0;

        case (current_state)
            `FSM_IDLE: begin
                if (wr_en) begin
                    tx_data    <= wr_data;   // latch write data
                    parity_bit <= ~^wr_data; // odd parity
                end
                else;
            end
            `FSM_CLK_LOW: begin
                clk_cnt <= (clk_cnt == 16'd9999) ? 16'd0 : clk_cnt + 16'd1;
            end
            `FSM_DATA: begin
                if (PS2_CLK == 1'b1) begin // On clock rising edge
                    bit_cnt <= bit_cnt + 4'd1;
                    tx_data <= {1'b0, tx_data[7:1]}; // right shift data
                end
                else;
            end
            `FSM_PARITY: begin
                if (PS2_CLK == 1'b1) begin
                    bit_cnt <= bit_cnt + 4'd1;
                end
                else;
            end
            `FSM_STOP: begin
                wr_done <= 1'b1; // Transmission complete
            end
        endcase
    end
end

//================= Output Logic =================//
always_comb begin
    drive_clk = 1'b0;
    drive_en  = 1'b0;
    drive_data  = 1'b1;

    case (current_state)
        `FSM_CLK_LOW: begin
            drive_clk = 1'b1;  //  200us clock low
        end
        `FSM_START: begin
            drive_en = 1'b1;  
            drive_data = 1'b0; 
        end
        `FSM_DATA: begin
            drive_en = 1'b1;
            drive_data = tx_data[0];
        end
        `FSM_PARITY: begin
            drive_en = 1'b1;
            drive_data = parity_bit;
        end
        `FSM_STOP: begin
            drive_en = 1'b0;
        end
        default: begin
            drive_clk = 1'b0;
            drive_en  = 1'b0;
        end
    endcase
end

endmodule
