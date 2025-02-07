module top(
    input                   CLK100_IN       , // 100 MHz oscillator clock input, W5
    input                   HARD_RSTN       ,

    // PS2 interface input
    input                   PS2_CLK         ,
    input                   PS2_DATA        ,

    // seven segment display
    output  reg   [3:0]     SEG_SELECT_OUT  ,
    output  reg   [7:0]     HEX_OUT         ,

    output  reg             LED15_L         ,
    output  reg             LED14_R         ,
    output  reg             LED13_INIT_DONE ,
    output  reg   [2:0]     LED12_10_STATE  ,
    output  reg             LED0_LOCKED     
);

logic           clk_sys;
logic           rst_n;

logic           HARD_RSTN_1dly;
logic           HARD_RSTN_2dly;

logic           ps2pkt_vld;
logic   [23:0]  ps2pkt_data;

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
    .locked     (LED0_LOCKED    )
 );

// instantiate the PS2 interface
ps2_top ps2_top_inst(
    .clk_sys            (clk_sys        ),
    .rst_n              (rst_n          ),

    .PS2_CLK            (PS2_CLK        ),
    .PS2_DATA           (PS2_DATA       ),

    .ps2pkt_vld         (ps2pkt_vld     ),
    .ps2pkt_data        (ps2pkt_data    ),

    .init_done          (LED13_INIT_DONE),
    .current_state      (LED12_10_STATE )
);

// instantiate the seven segment display controller
seg7_control seg7_control_inst(
    .clk_sys            (clk_sys        ),
    .rst_n              (rst_n          ),

    .ps2pkt_vld         (ps2pkt_vld     ),
    .ps2pkt_data        (ps2pkt_data    ),
    
    .SEG_SELECT_OUT     (SEG_SELECT_OUT ),
    .HEX_OUT            (HEX_OUT        ),

    .L_button           (LED15_L        ),
    .R_button           (LED14_R        )
);

endmodule
