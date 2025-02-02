// PS/2 interface top module

module ps2_top(
    input                   clk_sys         , // 50MHz system clock
    input                   rst_n           , // reset signal
    
    // PS2 interface input
    input                   PS2_CLK         ,
    input                   PS2_DATA        ,
    
    // receiver output interface
    input                   rd_en           ,
    output reg              rd_vld          ,
    output reg   [7:0]      rd_data         
    
    // transmiter input interface
);

// instantiate PS2 receiver
ps2_rx ps2_rx_inst(
    .clk_sys    (clk_sys   ),
    .rst_n      (rst_n     ),

    .PS2_CLK    (PS2_CLK   ),
    .PS2_DATA   (PS2_DATA  ),
    
    .rd_en      (rd_en     ),
    .rd_vld     (rd_vld    ),
    .rd_data    (rd_data   )
);

endmodule
