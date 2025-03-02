module top(
    input           CLK100_IN       , // 100 MHz oscillator clock input, W5
    input           HARD_RST        , // active-high reset input, W6
    
    // PS2 interface
    inout           PS2_CLK         ,
    inout           PS2_DATA        ,
    
    // seven segment display
    output reg [3:0] SEG_SELECT_OUT ,
    output reg [7:0] HEX_OUT        ,
    
    // LED status indicators
    output          LED0_LOCKED     ,
    output [3:0]    MOUSE_STATUS_LED,  // L, R, X_sign, Y_sign
    output [6:0]    MOUSE_STATE_LED    // Mouse state machine state
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
logic   [1:0]   BUS_INTERRUPTS_RAISE;
logic   [1:0]   BUS_INTERRUPTS_ACK  ;
logic   [7:0]   STATE               ;

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
    .locked     (LED0_LOCKED)
);

// sync reset to 50MHz clock domain
logic    rst_n_sync;
always_ff @(posedge clk_sys) begin
    rst_n_sync <= rst_n;
end


// microcontroller subsystem
Processor Processor_inst (
    .CLK                    (clk_sys                ),
    .RESET                  (~rst_n_sync            ),

    //BUS Signals
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

    //BUS Signals
    .BUS_DATA       (BUS_DATA       ),
    .BUS_ADDR       (BUS_ADDR       ),
    .BUS_WE         (BUS_WE         ),
    
    // interrupt signals
    .SEND_INTERRUPT (BUS_INTERRUPTS_RAISE[0]),
    .INTERRUPT_ACK  (BUS_INTERRUPTS_ACK[0]  ),

    .current_state  (MOUSE_STATE_LED)
);

// Seven-segment display controller
seg7_control seg7_control_inst (
    .clk_sys        (clk_sys),
    .rst_n          (rst_n),
    
    // Mouse coordinates
    .MOUSE_DX       (MOUSE_DX),
    .MOUSE_DY       (MOUSE_DY),
    
    // Display outputs
    .SEG_SELECT_OUT (SEG_SELECT_OUT),
    .HEX_OUT        (HEX_OUT)
);

endmodule