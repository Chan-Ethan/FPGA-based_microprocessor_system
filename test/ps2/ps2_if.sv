`ifndef PS2_IF_SV
`define PS2_IF_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

interface ps2_if(input clk, input rst_n);
    logic   PS2_CLK;
    logic   PS2_DATA;
endinterface

`endif // PS2_IF_SV