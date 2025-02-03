module top(
    input                   CLK100_IN       , // 100 MHz oscillator clock input, W5
    input                   HARD_RSTN       ,

    // PS2 interface input
    input                   PS2_CLK         ,
    input                   PS2_DATA        ,

    // seven segment display
    output  reg   [3:0]     SEG_SELECT_OUT  ,
    output  reg   [7:0]     HEX_OUT         ,

    output  reg             LED15_LOCKED    
);

logic           clk_sys;
logic           rst_n;

logic           HARD_RSTN_1dly;
logic           HARD_RSTN_2dly;

logic           rd_en;
logic           rd_vld;
logic   [23:0]  rd_data;

// reset logic
always_ff @(posedge CLK100_IN) begin
    HARD_RSTN_1dly <= ~HARD_RSTN;
    HARD_RSTN_2dly <= HARD_RSTN_1dly;
    rst_n <= (HARD_RSTN_1dly | HARD_RSTN_2dly);
end

// instantiate the clock wizard
clk_wiz_0 clk_wiz_0_inst
 (
    .clk_in1    (CLK100_IN      ),
    .clk_out1   (clk_sys        ),
    .resetn     (rst_n          ),
    .locked     (LED15_LOCKED   )
 );

// instantiate the PS2 receiver
assign rd_en = 1'b1; // always enable the PS2 receiver

ps2_top ps2_top_inst(
    .clk_sys            (clk_sys        ),
    .rst_n              (rst_n          ),

    .PS2_CLK            (PS2_CLK        ),
    .PS2_DATA           (PS2_DATA       ),

    .rd_en              (rd_en          ),
    .rd_vld             (rd_vld         ),
    .rd_data            (rd_data        )
);

// instantiate the seven segment display controller
seg7_control seg7_control_inst(
    .clk_sys            (clk_sys        ),
    .rst_n              (rst_n          ),

    .rd_vld             (rd_vld         ),
    .rd_data            (rd_data        ),
    
    .SEG_SELECT_OUT     (SEG_SELECT_OUT ),
    .HEX_OUT            (HEX_OUT        )
);

endmodule
