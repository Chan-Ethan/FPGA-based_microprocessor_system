// always use do_compare() to compare two bus_transaction objects, instead of using compare() directly

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

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        bus_transaction rhs_t;
        `uvm_info("xxxxxxx", "do_compare() is call", UVM_MEDIUM)
        
        // type check
        if (!$cast(rhs_t, rhs)) begin
            `uvm_error("COMPARE", "Type mismatch in do_compare()")
            return 0;
        end

        // compare ADDR and WE
        if (ADDR != rhs_t.ADDR || WE != rhs_t.WE) begin
            return 0;
        end

        // if WE is 1, compare DATA
        if (WE == 1'b1 && DATA != rhs_t.DATA) begin
            return 0;
        end

        return 1; // all fields are matched
    endfunction
endclass

`endif // BUS_TRANSACTION_SV
