// Base address: 0x90

module IRTop(
    // clock and reset input
    input           CLK,
    input           RESETN,

    //IO - Data Bus
    inout   [7:0]   BUS_DATA,
    input   [7:0]   BUS_ADDR,
    input           BUS_WE,

    // IR LED, connected to JB4
    output          IR_LED
);

logic [3:0]     COMMAND;

// 0x90[7:4] - reserved
// 0x90[3] - turn right (COMMAND[3])
// 0x90[2] - turn left (COMMAND[2])
// 0x90[1] - turn back (COMMAND[1])
// 0x90[0] - turn forward (COMMAND[0])

// Internal signals
logic           CLK_10HZ;       // 10Hz clock for timing
logic           SEND_PACKET;    // Signal to trigger IR transmission
logic           bus_wr_en;      // Data bus write enable

//================= Data Bus Interface =================//
// Handle writing to the command register at address 0x90
always_ff @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        COMMAND <= 4'b0000;
        bus_wr_en <= 1'b0;
    end
    else begin
        bus_wr_en <= (BUS_ADDR == 8'h90) && (BUS_WE == 1'b1);
        
        if ((BUS_ADDR == 8'h90) && (BUS_WE == 1'b1)) begin
            COMMAND <= BUS_DATA[3:0];
        end
    end
end

// write-only
assign BUS_DATA = 8'bZ;

//================= Instantiate 10Hz Counter =================//
Counter10Hz Counter10Hz_inst (
    .CLK        (CLK),
    .RESETN     (RESETN),
    .CLK_10HZ   (CLK_10HZ)
);

//================= Instantiate IR Transmitter State Machine =================//
IRTransmitterSM IRTransmitterSM_inst (
    .RESETN         (RESETN),
    .CLK            (CLK),

    .COMMAND        (COMMAND),
    .SEND_PACKET    (CLK_10HZ),    // Use 10Hz clock to trigger packet transmission
    .IR_LED         (IR_LED)
);

endmodule
