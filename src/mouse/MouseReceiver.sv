module MouseReceiver(
    //Standard Inputs
    input RESET,
    input CLK,
    
    //Mouse IO - CLK
    (* mark_debug = "true" *) input CLK_MOUSE_IN,
    //Mouse IO - DATA
    (* mark_debug = "true" *) input DATA_MOUSE_IN,

    //Control
    (* mark_debug = "true" *)  input               READ_ENABLE,
    (* mark_debug = "true" *)  output reg [7:0]    BYTE_READ,
    (* mark_debug = "true" *)  output reg [1:0]    BYTE_ERROR_CODE,
    (* mark_debug = "true" *)  output reg          BYTE_READY
);

`define FSM_IDLE       5'b00001
`define FSM_START      5'b00010
`define FSM_DATA       5'b00100
`define FSM_PARITY     5'b01000
`define FSM_STOP       5'b10000

logic [4:0] current_state, next_state;
logic [2:0] bit_cnt;
logic odd_parity_recv;
logic odd_parity_calc;
logic [2:0] ps2_clk_dly;
logic ps2_clk_vld;
logic ps2_data_dly;
reg odd_parity_err;
reg stop_bit_err;

//================= Signal Pre-processing =================//
always_ff @(posedge CLK or negedge RESET) begin
    if (~RESET) begin
        ps2_clk_dly <= 3'b000;
    end
    else begin
        ps2_clk_dly <= {ps2_clk_dly[1:0], CLK_MOUSE_IN};
    end
end

assign ps2_clk_vld = (ps2_clk_dly[2] == 1'b1) && (ps2_clk_dly[1] == 1'b0);

always @(posedge CLK) begin
    if (ps2_clk_vld == 1'b1) begin
        ps2_data_dly <= DATA_MOUSE_IN;
    end
end

//================= FSM =================//
always_comb begin
    if (READ_ENABLE == 1'b0) begin
        next_state = `FSM_IDLE;
    end
    else begin
        next_state = current_state;
        case (current_state)
            `FSM_IDLE: begin
                if ((ps2_clk_vld == 1'b1) && (DATA_MOUSE_IN == 1'b0))
                    next_state = `FSM_START;
            end
            `FSM_START: begin
                if (ps2_clk_vld == 1'b1)
                    next_state = `FSM_DATA;
            end
            `FSM_DATA: begin
                if ((ps2_clk_vld == 1'b1) && (bit_cnt == 7))
                    next_state = `FSM_PARITY;
            end
            `FSM_PARITY: begin
                if (ps2_clk_vld == 1'b1)
                    next_state = `FSM_STOP;
            end
            `FSM_STOP: begin
                if (ps2_clk_vld == 1'b1)
                    next_state = (DATA_MOUSE_IN == 1'b0) ? `FSM_START : `FSM_IDLE;
            end
            default:
                next_state = `FSM_IDLE;
        endcase
    end
end

always_ff @(posedge CLK or negedge RESET) begin
    if (~RESET) begin
        current_state <= `FSM_IDLE;
        bit_cnt       <= 3'b0;
    end
    else begin
        current_state <= next_state;
        if ((current_state == `FSM_DATA) && (ps2_clk_vld == 1'b1)) begin
            bit_cnt <= bit_cnt + 3'b1;
        end
    end
end

//================= Data Processing =================//
always @(posedge CLK or negedge RESET) begin
    if (~RESET) begin
        BYTE_READ <= 8'b0;
    end
    else begin
        if ((current_state == `FSM_DATA) && (ps2_clk_vld == 1'b1)) begin
            BYTE_READ <= {ps2_data_dly, BYTE_READ[7:1]};
        end
    end
end

always @(posedge CLK or negedge RESET) begin
    if (~RESET) begin
        odd_parity_recv <= 1'b0;
    end
    else begin
        if ((current_state == `FSM_PARITY) && (ps2_clk_vld == 1'b1)) begin
            odd_parity_recv <= ps2_data_dly;
        end
    end
end

//================= Parity Check =================//
always @(posedge CLK or negedge RESET) begin
    if (~RESET) begin
        odd_parity_calc <= 1'b0;
    end
    else begin
        if ((current_state == `FSM_PARITY) && (ps2_clk_vld == 1'b1)) begin
            odd_parity_calc <= ~^BYTE_READ;
        end
    end
end

//================= Output Generation =================//
always @(posedge CLK or negedge RESET) begin
    if (~RESET) begin
        BYTE_READY <= 1'b0;
    end
    else begin
        if ((current_state == `FSM_STOP) && (ps2_clk_vld == 1'b1)) begin
            BYTE_READY <= READ_ENABLE;
        end
        else begin
            BYTE_READY <= 1'b0;
        end
    end
end

always @(posedge CLK or negedge RESET) begin
    if (~RESET) begin
        odd_parity_err <= 1'b0;
    end
    else begin
        if ((current_state == `FSM_STOP) && (ps2_clk_vld == 1'b1) &&
            (odd_parity_recv != odd_parity_calc)) begin
            odd_parity_err <= 1'b1;
        end
    end
end

always @(posedge CLK or negedge RESET) begin
    if (~RESET) begin
        stop_bit_err <= 1'b0;
    end
    else begin
        if ((current_state == `FSM_STOP) && (ps2_data_dly == 1'b1)) begin
            stop_bit_err <= 1'b1;
        end
    end
end

// assign BYTE_ERROR_CODE = {stop_bit_err, odd_parity_err};
assign BYTE_ERROR_CODE = 2'b00;

endmodule
