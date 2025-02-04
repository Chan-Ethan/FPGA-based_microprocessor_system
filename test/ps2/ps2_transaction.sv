`ifndef PS2_TRANSACTION_SV
`define PS2_TRANSACTION_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class ps2_transaction extends uvm_sequence_item;
    rand    bit         L_button, R_button;
    rand    bit         x_sign, y_sign;
    rand    bit         x_ovf, y_ovf;
    rand    bit [7:0]   x_mov, y_mov;

            bit [7:0]   byte0;

    `uvm_object_utils_begin(ps2_transaction)
        `uvm_field_int(L_button , UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(R_button , UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(x_sign   ,UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(y_sign   , UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(x_ovf    , UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(y_ovf    , UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(byte0    , UVM_ALL_ON)
        `uvm_field_int(x_mov    , UVM_ALL_ON)
        `uvm_field_int(y_mov    , UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "my_transaction");
        super.new(name);
    endfunction

    function post_randomize();
        byte0_pack();
    endfunction

    function void byte0_pack();
        byte0 = {y_ovf, x_ovf, y_sign, x_sign, 1'b1, 1'b0, R_button, L_button};
    endfunction

    function byte0_unpack();0
        L_button = byte0[0];
        R_button = byte0[1];
        x_sign = byte0[4];
        y_sign = byte0[5];
        x_ovf = byte0[6];
        y_ovf = byte0[7];
    endfunction
endclass

`endif // PS2_TRANSACTION_SV
