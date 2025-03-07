`ifndef SW_IF_SV
`define SW_IF_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

interface sw_if(input clk, input rst_n);
    logic   [15:0]  sw;
endinterface

`endif // SW_IF_SV
