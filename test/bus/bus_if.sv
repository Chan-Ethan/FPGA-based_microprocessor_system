`ifndef BUS_IF_SV
`define BUS_IF_SV

interface bus_if(input clk, input rst_n);
    wire    [7:0]   BUS_DATA;
    wire    [7:0]   BUS_ADDR;
    wire            BUS_WE  ;
endinterface

`endif // BUS_IF_SV
