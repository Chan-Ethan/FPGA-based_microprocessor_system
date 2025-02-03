// PS2 receiver, receives data from PS/2 interace and outputs 8-bit data

module ps2_rx(
    input                   clk_sys         , // 50MHz system clock
    input                   rst_n           , // reset signal
    
    // PS2 interface input
    input                   PS2_CLK         ,
    input                   PS2_DATA        ,
    
    // receiver output interface
    input                   rd_en           ,
    output reg              rd_vld          ,
    output reg   [23:0]     rd_data         ,

    // device status debug signal, long latency
    output reg              init_done       ,
    output reg              is_mouse        ,

    // receive data debug signal, sync to rd_vld
    output reg              odd_parity_err  ,
    output reg              stop_bit_err    
);

`define FSM_IDLE       5'b00001
`define FSM_START      5'b00010
`define FSM_DATA       5'b00100
`define FSM_PARITY     5'b01000
`define FSM_STOP       5'b10000

// fsm_state FSM variable
logic   [4:0]       fsm_state;

logic   [7:0]       data;
logic   [2:0]       bit_cnt;  // 3-bit counter for data bit count
logic   [1:0]       byte_cnt; // 0~2 for 3-byte data
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


//================= Finite State Machine =================//
always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        fsm_state <= `FSM_IDLE;
    end
    else begin
        case (fsm_state)
            `FSM_IDLE: begin
                if ((ps2_clk_vld == 1'b1) && (PS2_DATA == 1'b0)) begin
                    // wait for start bit 0
                    fsm_state <= `FSM_START;
                end
                else; // stay in idle fsm_state
            end
            `FSM_START: begin
                if (ps2_clk_vld == 1'b1) begin
                    fsm_state <= `FSM_DATA;
                end
                else; // stay in start fsm_state
            end
            `FSM_DATA: begin
                if (ps2_clk_vld == 1'b1) begin
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == 7) begin
                        fsm_state <= `FSM_PARITY;
                        bit_cnt <= 0;
                    end
                end
                else; // stay in data fsm_state
            end
            `FSM_PARITY: begin
                if (ps2_clk_vld == 1'b1) begin
                    fsm_state <= `FSM_STOP;
                end
                else; // stay in parity fsm_state
            end
            `FSM_STOP: begin
                if (ps2_clk_vld == 1'b1) begin
                    fsm_state <= `FSM_IDLE;
                end
                else; // stay in stop fsm_state
            end
            default: begin
                fsm_state <= `FSM_IDLE;
            end
        endcase
    end
end

//================= Receive Data Processing =================//
always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        data <= 0;
    end
    else begin
        if (fsm_state == `FSM_DATA) begin
            data <= {data[6:0], ps2_data_dly};
        end
        else;
    end
end


always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        odd_parity_recv <= 1'b0;
    end
    else begin
        if (fsm_state == `FSM_PARITY) begin
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
        if (fsm_state == `FSM_PARITY) begin
            odd_parity_calc <= ^data;
        end
        else;
    end
end

//================= Output Data Generation =================//
always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        byte_cnt <= 0;
    end
    else begin
        if (fsm_state == `FSM_STOP) begin
            byte_cnt <= byte_cnt + 1;
            if (byte_cnt == 2) begin
                byte_cnt <= 0;
            end
            else;
        end
        else;
    end
end

always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        rd_data <= 24'b0;
    end
    else begin
        if (fsm_state == `FSM_STOP) begin
            case (byte_cnt)
                0: rd_data[7:0] <= data;
                1: rd_data[15:8] <= data;
                2: rd_data[23:16] <= data;
                default;
            endcase
        end
        else;
    end
end

always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        rd_vld <= 1'b0;
    end
    else begin
        if ((fsm_state == `FSM_STOP) && (byte_cnt == 2)) begin
            rd_vld <= 1'b1;
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
        if ((fsm_state == `FSM_STOP) && 
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
        if ((fsm_state == `FSM_STOP) && (ps2_data_dly == 1'b1)) begin
            stop_bit_err <= 1'b1;
        end
        else;
    end
end

endmodule
