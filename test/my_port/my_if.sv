`ifndef MY_IF_SV
`define MY_IF_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

interface my_if(input clk, input rst_n);
    logic [7:0] data;
    logic       valid;
endinterface

`endif