module MouseTransceiver(
//Standard Inputs
input           RESET,
input           CLK,
//IO - Mouse side
inout           CLK_MOUSE,
inout           DATA_MOUSE,
// Mouse data information
output [3:0]    MOUSE_STATUS,
output [7:0]    MOUSE_DX,
output [7:0]    MOUSE_DY,
output          SEND_INTERRUPT,

// debug signals
output logic [4:0] current_state
);

parameter [7:0] MouseLimitX = 160;
parameter [7:0] MouseLimitY = 120;

// Transmitter Control Signals
wire        SEND_BYTE;
wire [7:0]  BYTE_TO_SEND;
wire        BYTE_SENT;

// Receiver Control Signals
wire        READ_ENABLE;
wire [7:0]  BYTE_READ;
wire [1:0]  BYTE_ERROR_CODE;
wire        BYTE_READY;

wire [7:0]  MOUSE_STATUS_8;

// L, R, X_sign, Y_sign
assign MOUSE_STATUS = {MOUSE_STATUS_8[0], MOUSE_STATUS_8[1], MOUSE_STATUS_8[4], MOUSE_STATUS_8[5]};

// Instantiate Master State Machine
MouseMasterSM master_sm(
    .CLK            (CLK),
    .RESET          (RESET),
    // Transmitter Control
    .SEND_BYTE      (SEND_BYTE),
    .BYTE_TO_SEND   (BYTE_TO_SEND),
    .BYTE_SENT      (BYTE_SENT),
    // Receiver Control
    .READ_ENABLE    (READ_ENABLE),
    .BYTE_READ      (BYTE_READ),
    .BYTE_ERROR_CODE(BYTE_ERROR_CODE),  // Connect error code
    .BYTE_READY     (BYTE_READY),
    // Data Output
    .MOUSE_DX       (MOUSE_DX),     
    .MOUSE_DY       (MOUSE_DY),     
    .MOUSE_STATUS   (MOUSE_STATUS_8),     
    .SEND_INTERRUPT (SEND_INTERRUPT),

    .current_state  (current_state)
);

// Instantiate Transmitter with corrected tristate
MouseTransmitter transmitter(
    .RESET              (RESET),
    .CLK                (CLK),
    // Mouse IO
    .CLK_MOUSE_IN       (CLK_MOUSE),
    .CLK_MOUSE_OUT_EN   (clk_enable),
    .DATA_MOUSE_IN      (DATA_MOUSE),
    .DATA_MOUSE_OUT     (data_out),
    .DATA_MOUSE_OUT_EN  (data_enable),
    // Control
    .SEND_BYTE          (SEND_BYTE),
    .BYTE_TO_SEND       (BYTE_TO_SEND),
    .BYTE_SENT          (BYTE_SENT)
);

// Instantiate Custom Mouse Receiver
MouseReceiver receiver(
    .RESET          (RESET),
    .CLK            (CLK),
    // Mouse IO
    .CLK_MOUSE_IN   (CLK_MOUSE),
    .DATA_MOUSE_IN  (DATA_MOUSE),
    // Control
    .READ_ENABLE    (READ_ENABLE),
    .BYTE_READ      (BYTE_READ),
    .BYTE_ERROR_CODE(BYTE_ERROR_CODE),
    .BYTE_READY     (BYTE_READY)
);

//================= Tri-state Control =================//
wire clk_enable, data_enable;
wire data_out;

// Tristate buffer control
assign CLK_MOUSE = clk_enable ? 1'b0 : 1'bz;  // Transmitter drives low
assign DATA_MOUSE = data_enable ? data_out : 1'bz;

endmodule