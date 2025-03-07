`ifndef SW_TRANSACTION_SV
`define SW_TRANSACTION_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class sw_transaction extends uvm_sequence_item;
    rand bit [15:0] slide_switch;

    `uvm_object_utils_begin(sw_transaction)
        `uvm_field_int(slide_switch    , UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "my_transaction");
        super.new(name);
    endfunction
endclass

`endif // SW_TRANSACTION_SV
