module MouseMasterSM(
input CLK,
input RESET,

//Transmitter Control
output reg SEND_BYTE,
output reg [7:0] BYTE_TO_SEND,
input BYTE_SENT,

//Receiver Control
output reg READ_ENABLE,
input [7:0] BYTE_READ,
input [1:0] BYTE_ERROR_CODE,
input BYTE_READY,

//Data Registers
output reg [7:0] MOUSE_DX,
output reg [7:0] MOUSE_DY,
output reg [7:0] MOUSE_STATUS,
output reg SEND_INTERRUPT
);

`define FSM_RESET       5'b00001
`define FSM_WAIT_ACK    5'b00010
`define FSM_STAR_STM    5'b00100
`define FSM_WAIT_ACK2   5'b01000
`define FSM_STREAM_MOD  5'b10000

`ifdef SIMULATION
    `define CNT_NUM_1MS     16'd49_999
    `define CNT_NUM_20S     15'd39
`else
    `define CNT_NUM_1MS     16'd49_999
    `define CNT_NUM_20S     15'd19_999
`endif

`define CNT_BYTES       2'b10

logic [4:0]         current_state, next_state;
logic               waiting_wr_done;
logic [1:0]         byte_cnt;
logic [15:0]        cnt_1ms;
logic [14:0]        cnt_20s;
logic [23:0]        pkt_buffer;

// State Transition Logic
always_comb begin
    next_state = current_state;
    case (current_state)
        `FSM_RESET: begin
            if (BYTE_SENT) next_state = `FSM_WAIT_ACK;
        end
        `FSM_WAIT_ACK: begin
            if (byte_cnt == 2'd2) next_state = `FSM_STAR_STM;
            else if (cnt_1ms == `CNT_NUM_1MS) next_state = `FSM_RESET;
        end
        `FSM_STAR_STM: begin
            if (BYTE_SENT) next_state = `FSM_WAIT_ACK2;
        end
        `FSM_WAIT_ACK2: begin
            if (BYTE_READY && (BYTE_READ == 8'hFA || BYTE_READ == 8'hF4)) begin
                next_state = `FSM_STREAM_MOD;
            end
            else if (cnt_1ms == `CNT_NUM_1MS) next_state = `FSM_RESET;
        end
        `FSM_STREAM_MOD: begin
            if (cnt_20s == `CNT_NUM_20S) next_state = `FSM_RESET;
        end
        default: next_state = `FSM_RESET;
    endcase
end

// State Register
always_ff @(posedge CLK or negedge RESET) begin
    if (!RESET) current_state <= `FSM_RESET;
    else current_state <= next_state;
end

//================= Counters =================//
always_ff @(posedge CLK or negedge RESET) begin
    if (!RESET) cnt_1ms <= 16'd0;
    else if (current_state inside {`FSM_WAIT_ACK, `FSM_STREAM_MOD}) begin
        cnt_1ms <= (cnt_1ms == `CNT_NUM_1MS) ? 16'd0 : cnt_1ms + 16'd1;
    end
    else cnt_1ms <= 16'd0;
end

always_ff @(posedge CLK or negedge RESET) begin
    if (!RESET) cnt_20s <= 15'd0;
    else if (current_state == `FSM_STREAM_MOD) begin
        if (BYTE_READY) cnt_20s <= 15'd0;
        else if (cnt_1ms == `CNT_NUM_1MS) begin
            cnt_20s <= (cnt_20s == `CNT_NUM_20S) ? 15'd0 : cnt_20s + 15'd1;
        end
    end
    else cnt_20s <= 15'd0;
end

//================= Transmitter Control =================//
always_ff @(posedge CLK or negedge RESET) begin
    if (!RESET) begin
        SEND_BYTE <= 1'b0;
        waiting_wr_done <= 1'b0;
    end else begin
        if (current_state inside {`FSM_RESET, `FSM_STAR_STM}) begin
            SEND_BYTE <= ~waiting_wr_done;
            waiting_wr_done <= 1'b1;
        end else begin
            SEND_BYTE <= 1'b0;
            waiting_wr_done <= 1'b0;
        end
    end
end

assign BYTE_TO_SEND = (current_state == `FSM_STAR_STM) ? 8'hF4 : 8'hFF;

//================= Receiver Control =================//
assign READ_ENABLE = (current_state != `FSM_RESET) && (current_state != `FSM_STAR_STM);

//================= Data Packing =================//
always_ff @(posedge CLK or negedge RESET) begin
    if (!RESET) begin
        pkt_buffer <= 24'b0;
    end else if (current_state == `FSM_STREAM_MOD) begin
        if (BYTE_READY == 1'b1) begin
            case (byte_cnt)
                2'b00: pkt_buffer[7:0] <= BYTE_READ;
                2'b01: pkt_buffer[15:8] <= BYTE_READ;
                2'b10: pkt_buffer[23:16] <= BYTE_READ;
                default: ;
            endcase
        end
        else;
    end
    else begin
        pkt_buffer <= 24'b0;
    end
end

always @(posedge CLK or negedge RESET) begin
    if (!RESET) begin
        byte_cnt <= 2'b00;
    end
    else if ((current_state == `FSM_STREAM_MOD) || (current_state == `FSM_WAIT_ACK2)) begin
        if (BYTE_READY == 1'b1) begin
            byte_cnt <= (byte_cnt == `CNT_BYTES) ? 2'b00 : byte_cnt + 2'b01;
        end
        else;
    end
    else begin
        byte_cnt <= 2'b00;
    end

end


//================= Output Registers =================//
assign MOUSE_STATUS = pkt_buffer[7:0];
assign MOUSE_DX = pkt_buffer[15:8];
assign MOUSE_DY = pkt_buffer[23:16];
// assign SEND_INTERRUPT = (current_state == `FSM_STREAM_MOD) && BYTE_READY && (byte_cnt == `CNT_BYTES);
assign SEND_INTERRUPT = 1'b0;

endmodule
