// PS/2 receiver, receives data from PS/2 interace and outputs 8-bit data

module ps2_rx(
    input                   clk_sys         , // 50MHz system clock
    input                   rst_n           , // reset signal
    
    // PS2 interface input
    (* mark_debug = "true" *) input         PS2_CLK         ,
    (* mark_debug = "true" *) input         PS2_DATA        ,
    
    // receiver output interface
    (* mark_debug = "true" *) input                   rd_en           ,
    (* mark_debug = "true" *) output reg              rd_vld          ,
    (* mark_debug = "true" *) output reg   [7:0]      rd_data         ,

    // receive data debug signal, sync to rd_vld
    output reg              odd_parity_err  ,
    output reg              stop_bit_err    
);

`define FSM_IDLE       5'b00001
`define FSM_START      5'b00010
`define FSM_DATA       5'b00100
`define FSM_PARITY     5'b01000
`define FSM_STOP       5'b10000

// current_state FSM variable
logic   [4:0]       current_state, next_state;

logic   [2:0]       bit_cnt;  // 3-bit counter for data bit count
logic               odd_parity_recv;
logic               odd_parity_calc;

logic   [2:0]       ps2_clk_dly;
logic               ps2_clk_vld;
logic               ps2_data_dly;

//================= Signal Pre-processing =================//
// ps2_clk cross-clock domain processing
always_ff @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        ps2_clk_dly <= 3'b000;
    end
    else begin
        ps2_clk_dly <= {ps2_clk_dly[1:0], PS2_CLK};
    end
end

// detect PS2_CLK falling edge
assign ps2_clk_vld = (ps2_clk_dly[2] == 1'b1) && (ps2_clk_dly[1] == 1'b0); 

// delay PS2_DATA by 1 clock cycle
always @(posedge clk_sys) begin
    if (ps2_clk_vld == 1'b1) begin
        ps2_data_dly <= PS2_DATA;
    end
    else;
end

//================= Finite State Machine (Three-Segment Style) =================//
// State Transition Logic (Combinational)
always_comb begin
    if (rd_en == 1'b0) begin
        next_state = `FSM_IDLE; // go to idle state when rd_en is low
    end
    else begin
        next_state = current_state; // Default: stay in current state
        case (current_state)
            `FSM_IDLE: begin
                if ((ps2_clk_vld == 1'b1) && (PS2_DATA == 1'b0))
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
                    next_state = (PS2_DATA == 1'b0) ? `FSM_START : `FSM_IDLE;
            end
            default: 
                next_state = `FSM_IDLE;
        endcase
    end
end

// tate Register Update (Sequential)
always_ff @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        current_state <= `FSM_IDLE;
        bit_cnt       <= 3'b0;
    end
    else begin
        current_state <= next_state;
        
        // Handle bit counter separately
        if ((current_state == `FSM_DATA) && 
            (ps2_clk_vld == 1'b1)) begin
            bit_cnt <= bit_cnt + 3'b1; // bit_cnt will return 0 after 7
        end
    end
end

//================= Receive Data Processing =================//
always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        rd_data <= 8'b0;
    end
    else begin
        if ((current_state == `FSM_DATA) && (ps2_clk_vld == 1'b1)) begin
            rd_data <= {ps2_data_dly, rd_data[7:1]}; // right shift
        end
        else;
    end
end


always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        odd_parity_recv <= 1'b0;
    end
    else begin
        if ((current_state == `FSM_PARITY) && (ps2_clk_vld == 1'b1)) begin
            odd_parity_recv <= ps2_data_dly;
        end
        else;
    end
end

//================= Parity Calculation and Check =================//
always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        odd_parity_calc <= 1'b0;
    end
    else begin
        if ((current_state == `FSM_PARITY) && (ps2_clk_vld == 1'b1)) begin
            odd_parity_calc <= ~^rd_data;
        end
        else;
    end
end

//================= Output Data Generation =================//
always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        rd_vld <= 1'b0;
    end
    else begin
        if ((current_state == `FSM_STOP) && 
            (ps2_clk_vld == 1'b1)) begin
            rd_vld <= rd_en;
        end
        else begin
            rd_vld <= 1'b0;
        end
    end
end

always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        odd_parity_err <= 1'b0;
    end
    else begin
        // odd_parity_err will stay 1 once set
        if ((current_state == `FSM_STOP) && 
            (ps2_clk_vld == 1'b1) &&
            (odd_parity_recv != odd_parity_calc)) begin
            odd_parity_err <= 1'b1;
        end
        else;
    end
end

always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        stop_bit_err <= 1'b0;
    end
    else begin
        // stop_bit_err will stay 1 once set
        if ((current_state == `FSM_STOP) && (ps2_data_dly == 1'b1)) begin
            stop_bit_err <= 1'b1;
        end
        else;
    end
end

endmodule
