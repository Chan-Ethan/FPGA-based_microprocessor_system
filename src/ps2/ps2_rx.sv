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
    output reg   [7:0]      rd_data         
);



endmodule
