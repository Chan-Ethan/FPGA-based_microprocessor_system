`ifndef MY_MODEL_SV
`define MY_MODEL_SV

class my_model extends uvm_component;
    uvm_blocking_get_port #(my_transaction) port;
    uvm_analysis_port #(my_transaction) ap;

    `uvm_component_utils(my_model)

    function new(string name = "my_model", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("my_model", "my_model is created", UVM_MEDIUM)
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
endclass

function void my_model::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("my_model", "my_model build_phase", UVM_MEDIUM)
    
    port = new("port", this);
    ap = new("ap", this);
endfunction

task my_model::main_phase(uvm_phase phase);
    my_transaction tr;
    my_transaction new_tr;

    super.main_phase(phase);

    while (1) begin
        port.get(tr);
        new_tr = new("new_tr");
        new_tr.copy(tr);
        `uvm_info("my_model", "get a transaction, copy and print:", UVM_LOW)
        new_tr.print();
        ap.write(new_tr);
    end
endtask

`endif