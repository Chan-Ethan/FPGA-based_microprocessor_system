module top(
    input                   CLK100_IN       , // 100 MHz oscillator clock input, W5
    input                   HARD_RSTN       ,

    // seven segment display
    output  reg   [3:0]     SEG_SELECT_OUT  ,
    output  reg   [7:0]     HEX_OUT         ,

    output  reg             LED15_LOCKED    ,
    output  reg             LED14_1HZ    
);

`ifdef SIMULATION
    `define CNT_NUM 26'd49
`else
    `define CNT_NUM 26'd49999999
`endif

logic           clk_sys;
logic           rst_n;

logic           HARD_RSTN_1dly;
logic           HARD_RSTN_2dly;

logic   [1:0]   seg_select;
logic   [3:0]   bin;
logic           dot;

logic   [1:0]   seg_select_in;

// reset logic
always_ff @(posedge CLK100_IN) begin
    HARD_RSTN_1dly <= HARD_RSTN;
    HARD_RSTN_2dly <= HARD_RSTN_1dly;
    rst_n <= (HARD_RSTN_1dly & HARD_RSTN_2dly);
end


// instantiate the clock wizard
clk_wiz_0 clk_wiz_0_inst
 (
    .clk_in1    (CLK100_IN      ),
    .clk_out1   (clk_sys        ),
    .resetn     (rst_n          ),
    .locked     (LED15_LOCKED   )
 );

// instantiate the seven segment decoder
seg7decoder seg7decoder_inst(
    .SEG_SELECT_IN      (seg_select_in  ),
    .BIN_IN             (bin            ),
    .DOT_IN             (dot            ),
    .SEG_SELECT_OUT     (SEG_SELECT_OUT ),
    .HEX_OUT            (HEX_OUT        )
);

always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        LED14_1HZ <= 1'b0;
    end
    else begin
        LED14_1HZ <= ~LED14_1HZ;
    end
end

// 1Hz signal generation
logic           clk_1hz;
logic [25:0]    clk_cnt;
always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        clk_cnt <= 26'b0;
    end
    else begin
        if (clk_cnt == `CNT_NUM) begin
            clk_cnt <= 26'b0;
        end
        else begin
            clk_cnt <= clk_cnt + 26'd1;
        end
    end
end

always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        clk_1hz <= 1'b0;
    end
    else begin
        if (clk_cnt == `CNT_NUM) begin
            clk_1hz <= 1'b1;
        end
        else begin
            clk_1hz <= 1'b0;
        end
    end
end

// 1Hz signal to LED14
always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        LED14_1HZ <= 1'b0;
    end
    else begin
        if (clk_1hz) begin
            LED14_1HZ <= ~LED14_1HZ;
        end
        else;
    end
end

// seven segment demo signal generation
// traverse 4 seven segment
always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        seg_select <= 2'b00;
    end else begin
        if (clk_1hz) begin
            seg_select <= seg_select + 1;
        end
    end
end

always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        bin <= 7'b0000000;
    end else begin
        case(seg_select)
            2'b00: bin <= 4'h0;
            2'b01: bin <= 4'h8;
            2'b10: bin <= 4'ha;
            2'b11: bin <= 4'hc;
            default: bin <= 4'hf;
        endcase
    end
end

always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        dot <= 1'b0;
    end else begin
        case(seg_select)
            2'b00: dot <= 1'b0;
            2'b01: dot <= 1'b1;
            2'b10: dot <= 1'b0;
            2'b11: dot <= 1'b1;
            default: dot <= 1'b0;
        endcase
    end
end

always @(posedge clk_sys or negedge rst_n) begin
    seg_select_in <= seg_select;
end

endmodule
