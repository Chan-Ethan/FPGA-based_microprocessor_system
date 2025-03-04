`ifndef BUS_IF_SV
`define BUS_IF_SV

interface bus_if(input clk, input rst_n);
    wire    BUS_DATA;
    wire    BUS_ADDR;
    wire    BUS_WE;
endinterface

`endif // BUS_IF_SV
