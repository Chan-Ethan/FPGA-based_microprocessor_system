module top(
    input           CLK100_IN       , // 100 MHz oscillator clock input, W5
    input           HARD_RST        , // active-high reset input, W6
    
    // PS2 interface
    inout           PS2_CLK         ,
    inout           PS2_DATA        ,
    
    // seven segment display
    output reg [3:0] SEG_SELECT_OUT ,
    output reg [7:0] HEX_OUT        ,
    
    // LED output
    output reg [15:0] LED           
);

logic           clk_sys;    // 50MHz system clock
logic           rst_n;      // active-low reset

// Mouse interface signals
logic   [7:0]   MOUSE_DX;
logic   [7:0]   MOUSE_DY;

// Data Bus
wire    [7:0]   BUS_DATA;
wire    [7:0]   BUS_ADDR;
wire            BUS_WE  ;

// ROM signals
logic   [7:0]   ROM_ADDRESS ;
logic   [7:0]   ROM_DATA    ;

// INTERRUPT signals
logic   [2:0]   BUS_INTERRUPTS_RAISE;
logic   [2:0]   BUS_INTERRUPTS_ACK  ;
logic   [7:0]   STATE               ;

logic           LOCKED              ;
logic   [6:0]   current_state       ;

// Reset synchronization logic
logic HARD_RSTN_1dly, HARD_RSTN_2dly;
always_ff @(posedge CLK100_IN) begin
    HARD_RSTN_1dly <= ~HARD_RST;        // Sync reset input
    HARD_RSTN_2dly <= HARD_RSTN_1dly;   // Metastability protection
    rst_n <= HARD_RSTN_2dly;            // Generate active-low reset
end

// Clock wizard (50MHz system clock)
clk_wiz_0 clk_wiz_inst (
    .clk_in1    (CLK100_IN),
    .clk_out1   (clk_sys),   // 50MHz output
    .resetn     (rst_n),
    .locked     (LOCKED)
);

// microcontroller subsystem
Processor Processor_inst (
    .CLK                    (clk_sys                ),
    .RESET                  (~rst_n                 ),

    // IO - Data Bus
    .BUS_DATA               (BUS_DATA               ),
    .BUS_ADDR               (BUS_ADDR               ),
    .BUS_WE                 (BUS_WE                 ),

    // ROM signals
    .ROM_ADDRESS            (ROM_ADDRESS            ),
    .ROM_DATA               (ROM_DATA               ),

    // INTERRUPT signals
    .BUS_INTERRUPTS_RAISE   (BUS_INTERRUPTS_RAISE   ),
    .BUS_INTERRUPTS_ACK     (BUS_INTERRUPTS_ACK     ),
    .STATE                  (STATE                  )
);

// ROM connectted to the Processor directly
ROM ROM_inst (
    .CLK    (clk_sys    ),
    .DATA   (ROM_DATA   ),
    .ADDR   (ROM_ADDRESS)
);

// RAM connected to the Processor via data bus
RAM RAM_inst (
    .CLK        (clk_sys    ),
    .BUS_DATA   (BUS_DATA   ),
    .BUS_ADDR   (BUS_ADDR   ),
    .BUS_WE     (BUS_WE     )
);

// Mouse subsystem
MouseTop MouseTop_inst (
    .CLK            (clk_sys),
    .RESETN         (rst_n),
    
    // Mouse PS/2 interface
    .CLK_MOUSE      (PS2_CLK),
    .DATA_MOUSE     (PS2_DATA),

    // IO - Data Bus
    .BUS_DATA       (BUS_DATA       ),
    .BUS_ADDR       (BUS_ADDR       ),
    .BUS_WE         (BUS_WE         ),
    
    // interrupt signals
    .SEND_INTERRUPT (BUS_INTERRUPTS_RAISE[0]),
    .INTERRUPT_ACK  (BUS_INTERRUPTS_ACK[0]  ),

    .current_state  (current_state  )
);

// Timer connected to the Processor via data bus
Timer Timer_inst (
    .CLK        (clk_sys    ),
    .RESET      (~rst_n     ),

    // IO - Data Bus
    .BUS_DATA   (BUS_DATA   ),
    .BUS_ADDR   (BUS_ADDR   ),
    .BUS_WE     (BUS_WE     ),

    // interrupt signals
    .BUS_INTERRUPT_RAISE(BUS_INTERRUPTS_RAISE[1]),
    .BUS_INTERRUPT_ACK  (BUS_INTERRUPTS_ACK[1]  )
);

// Seven-segment display controller
seg7_control seg7_control_inst (
    .clk_sys        (clk_sys),
    .rst_n          (rst_n),
    
    // IO - Data Bus
    .BUS_DATA       (BUS_DATA       ),
    .BUS_ADDR       (BUS_ADDR       ),
    .BUS_WE         (BUS_WE         ),
    
    // Display outputs
    .SEG_SELECT_OUT (SEG_SELECT_OUT),
    .HEX_OUT        (HEX_OUT)
);

// Slide switch controller
switch switch_inst (
    .CLK                (clk_sys        ),
    .RESETN             (rst_n          ),
    
    // IO - Data Bus
    .SW                 (SW             ),

    // IO - Data Bus
    .BUS_DATA           (BUS_DATA       ),
    .BUS_ADDR           (BUS_ADDR       ),
    .BUS_WE             (BUS_WE         ),
    
    // interrupt signals
    .SEND_INTERRUPT     (BUS_INTERRUPTS_RAISE[2]),
    .INTERRUPT_ACK      (BUS_INTERRUPTS_ACK[2]  )
);

// LED controller
led_ctrl led_ctrl_inst (
    .CLK            (clk_sys),
    .RESETN         (rst_n),
    
    //IO - Data Bus
    .BUS_DATA       (BUS_DATA       ),
    .BUS_ADDR       (BUS_ADDR       ),
    .BUS_WE         (BUS_WE         ),
    
    // input signals
    .LOCKED         (LOCKED         ),
    .current_state  (current_state  ),
    
    // LED output
    .LED            (LED            )
);

endmodule