`ifndef BUS_TRANSACTION_SV
`define BUS_TRANSACTION_SV

class bus_transaction extends uvm_sequence_item;
    rand bit [7:0]  DATA;
    rand bit [7:0]  ADDR;
    rand bit        WE  ;

    `uvm_object_utils_begin(bus_transaction)
        `uvm_field_int(DATA , UVM_ALL_ON)
        `uvm_field_int(ADDR , UVM_ALL_ON)
        `uvm_field_int(WE   , UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "bus_transaction");
        super.new(name);
    endfunction

    function void post_randomize();
        
    endfunction
endclass

`endif // BUS_TRANSACTION_SV
