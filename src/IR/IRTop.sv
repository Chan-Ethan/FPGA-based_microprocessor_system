module IRTop(
    // clock and reset input
    input           CLK,
    input           RESETN,

    //IO - Data Bus
    inout   [7:0]   BUS_DATA,
    input   [7:0]   BUS_ADDR,
    input           BUS_WE,

    // IR LED
    output          IR_LED
);


endmodule
