// Mouse moudle top, including data bus interface logic

module MouseTop(
    // clock and reset input
    input           CLK,
    input           RESETN,

    //IO - Mouse side
    inout           CLK_MOUSE,
    inout           DATA_MOUSE,

    //IO - Data Bus
    inout   [7:0]   BUS_DATA,
    input   [7:0]   BUS_ADDR,
    input           BUS_WE,

    // interrupt signals
    output          SEND_INTERRUPT,
    input           INTERRUPT_ACK,

    // debug signals
    output logic [6:0] current_state
);

logic   [7:0]   MOUSE_DX;
logic   [7:0]   MOUSE_DY;

logic   [7:0]   MOUSE_STATUS;   // address 0xA0
logic   [7:0]   MOUSE_POS_X;    // address 0xA1
logic   [7:0]   MOUSE_POS_Y;    // address 0xA2

//================= Data Bus Interface =================//
// Read only, ingore BUS_WE signal
assign BUS_DATA =   (BUS_ADDR == 8'hA0) ? MOUSE_STATUS : 
                    (BUS_ADDR == 8'hA1) ? MOUSE_POS_X  : 
                    (BUS_ADDR == 8'hA2) ? MOUSE_POS_Y  : 8'bz;


//================= Instantiate Mouse Transceiver =================//
MouseTransceiver MouseTransceiver_inst (
    .CLK            (CLK),
    .RESET          (RESETN),
    
    // PS/2 interface
    .CLK_MOUSE      (CLK_MOUSE),
    .DATA_MOUSE     (DATA_MOUSE),
    
    // Mouse data output
    .MOUSE_STATUS   (MOUSE_STATUS),
    .MOUSE_DX       (MOUSE_DX),
    .MOUSE_DY       (MOUSE_DY),

    .SEND_INTERRUPT (SEND_INTERRUPT),
    .INTERRUPT_ACK  (INTERRUPT_ACK),

    .current_state  (current_state)
);

//================= Instantiate Mouse Position Calculator =================//
MousePosCal MousePosCal_inst (
    .CLK            (CLK),
    .RESET          (RESETN),

    // Mouse data information
    .MOUSE_STATUS   (MOUSE_STATUS),
    .MOUSE_DX       (MOUSE_DX),
    .MOUSE_DY       (MOUSE_DY),
    .INTERRUPT      (SEND_INTERRUPT),

    // Mouse position
    .MOUSE_POS_X    (MOUSE_POS_X),
    .MOUSE_POS_Y    (MOUSE_POS_Y)
);

endmodule