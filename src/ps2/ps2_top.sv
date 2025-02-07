// PS/2 interface top module

module ps2_top(
    input                   clk_sys         , // 50MHz system clock
    input                   rst_n           , // reset signal
    
    // PS2 interface input
    inout                   PS2_CLK         ,
    inout                   PS2_DATA        ,
    
   // PS/2 receiver data packet output
    output reg              ps2pkt_vld      ,
    output reg  [23:0]      ps2pkt_data     ,
    
    // degug signal
    output reg              init_done       ,
    output reg  [3:0]       current_state
);

logic           rd_en   ;   
logic           rd_vld  ;
logic   [7:0]   rd_data ;

logic           wr_en   ;
logic   [7:0]   wr_data ;
logic           wr_done ;

// instantiate PS2 control
ps2_control ps2_control_inst(
    .clk_sys        (clk_sys        ),
    .rst_n          (rst_n          ),
        
    .rd_en          (rd_en          ),
    .rd_vld         (rd_vld         ),
    .rd_data        (rd_data        ),
        
    .wr_en          (wr_en          ),
    .wr_data        (wr_data        ),
    .wr_done        (wr_done        ),
        
    .ps2pkt_vld     (ps2pkt_vld     ),
    .ps2pkt_data    (ps2pkt_data    ),
    
    .init_done      (init_done      ),
    .current_state  (current_state  )
);

// instantiate PS2 transmitter
ps2_tx ps2_tx_inst(
    .clk_sys        (clk_sys    ),
    .rst_n          (rst_n      ),

    .PS2_CLK        (PS2_CLK    ),
    .PS2_DATA       (PS2_DATA   ),
    
    .wr_en          (wr_en      ),
    .wr_data        (wr_data    ),
    .wr_done        (wr_done    )
);


// instantiate PS2 receiver
ps2_rx ps2_rx_inst(
    .clk_sys        (clk_sys   ),
    .rst_n          (rst_n     ),

    .PS2_CLK        (PS2_CLK   ),
    .PS2_DATA       (PS2_DATA  ),
    
    .rd_en          (rd_en     ),
    .rd_vld         (rd_vld    ),
    .rd_data        (rd_data   ),

    .odd_parity_err (          ),
    .stop_bit_err   (          )
);

endmodule
