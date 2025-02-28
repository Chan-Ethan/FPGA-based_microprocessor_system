module MouseTransmitter(
//Standard Inputs
input RESET,
input CLK,

//Mouse IO - CLK
(* mark_debug = "true" *)  input        CLK_MOUSE_IN,
(* mark_debug = "true" *)  output       CLK_MOUSE_OUT_EN, // Allows for the control of the Clock line

//Mouse IO - DATA
(* mark_debug = "true" *)  input        DATA_MOUSE_IN, 
(* mark_debug = "true" *)  output       DATA_MOUSE_OUT,
(* mark_debug = "true" *)  output       DATA_MOUSE_OUT_EN,

//Control
input       SEND_BYTE,
input [7:0] BYTE_TO_SEND,
output reg  BYTE_SENT
);

`define FSM_IDLE       6'b000001
`define FSM_CLK_LOW    6'b000010
`define FSM_START      6'b000100
`define FSM_DATA       6'b001000
`define FSM_PARITY     6'b010000
`define FSM_STOP       6'b100000

// count for 200us
`define CNT_NUM        14'd9999

// FSM and control signals
(* mark_debug = "true" *) logic [5:0]         current_state, next_state;
(* mark_debug = "true" *) logic [13:0]        clk_cnt;        // 200us counter (50MHz * 200us = 10_000 cycles)
logic [2:0]         bit_cnt;        // 0-7: data bits
logic [7:0]         tx_data;        // data to send
logic               parity_bit;     // odd parity

// CLK_MOUSE_IN positive edge detection
logic   [2:0]       ps2_clk_dly;
(* mark_debug = "true" *) logic               ps2_clk_vld;

//================= CLK_MOUSE_IN positive edge detection =================//
always_ff @(posedge CLK or negedge RESET) begin
    if (!RESET) begin
        ps2_clk_dly <= 3'b000;
    end
    else begin
        ps2_clk_dly <= {ps2_clk_dly[1:0], CLK_MOUSE_IN};
    end
end

assign ps2_clk_vld = (ps2_clk_dly[2] == 1'b0) && (ps2_clk_dly[1] == 1'b1);

//================= State Machine =================//
// State Transition Logic
always_comb begin
    next_state = current_state;
    case (current_state)
        `FSM_IDLE: begin
            if (SEND_BYTE) begin
                next_state = `FSM_CLK_LOW;
            end
        end
        `FSM_CLK_LOW: begin
            if ((clk_cnt == `CNT_NUM) && (ps2_clk_vld == 1'b1)) begin
                next_state = `FSM_START;
            end
        end
        `FSM_START: begin
            if (ps2_clk_vld == 1'b1)  begin
                next_state = `FSM_DATA;
            end
        end
        `FSM_DATA: begin
            if ((bit_cnt == 3'd7) && (ps2_clk_vld == 1'b1)) begin
                next_state = `FSM_PARITY;
            end
        end
        `FSM_PARITY: begin
            if (ps2_clk_vld == 1'b1) begin
                next_state = `FSM_STOP;
            end
        end
        `FSM_STOP: begin
            next_state = `FSM_IDLE;
        end
        default: 
            next_state = `FSM_IDLE;
    endcase
end

// State Register Update
always_ff @(posedge CLK or negedge RESET) begin
    if (!RESET) begin
        current_state <= `FSM_IDLE;
        clk_cnt       <= 14'd0;
        bit_cnt       <= 3'd0;
        tx_data       <= 8'd0;
        parity_bit    <= 1'b0;
        BYTE_SENT     <= 1'b0;
    end
    else begin
        current_state <= next_state;
        clk_cnt       <= 14'd0;
        BYTE_SENT     <= 1'b0;

        case (current_state)
            `FSM_IDLE: begin
                if (SEND_BYTE) begin
                    tx_data    <= BYTE_TO_SEND;
                    parity_bit <= ~^BYTE_TO_SEND;
                end
            end
            `FSM_CLK_LOW: begin
                clk_cnt <= (clk_cnt == `CNT_NUM) ? clk_cnt : clk_cnt + 14'd1;
            end
            `FSM_DATA: begin
                if (ps2_clk_vld == 1'b1) begin
                    bit_cnt <= bit_cnt + 3'd1;
                    tx_data <= {1'b0, tx_data[7:1]};
                end
            end
            `FSM_STOP: begin
                BYTE_SENT <= 1'b1;
            end
        endcase
    end
end

//================= Output Logic =================//
assign DATA_MOUSE_OUT = 
    (current_state == `FSM_START)   ? 1'b0 :
    (current_state == `FSM_DATA)    ? tx_data[0] :
    (current_state == `FSM_PARITY)  ? parity_bit :
    1'b1;

assign CLK_MOUSE_OUT_EN = ((current_state == `FSM_CLK_LOW) && (clk_cnt < `CNT_NUM)) ? 1'b1 : 1'b0;
assign DATA_MOUSE_OUT_EN = (current_state == `FSM_IDLE) ? 1'b0 : 1'b1;

endmodule
