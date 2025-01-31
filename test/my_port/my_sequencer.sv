`ifndef MY_SEQUENCER_SV
`define MY_SEQUENCER_SV

class my_sequencer extends uvm_sequencer #(my_transaction);
    `uvm_component_utils(my_sequencer)

    function new(string name = "my_sequencer", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("my_sequencer", "my_sequencer is created", UVM_MEDIUM)
    endfunction

    // extern virtual function void build_phase(uvm_phase phase);
    // extern virtual task main_phase(uvm_phase phase);
endclass

// task my_sequencer::main_phase(uvm_phase phase);
//     my_sequence seq;
//     
//     phase.raise_objection(this);
// 
//     // start default sequence
//     seq = my_sequence::type_id::create("seq");
//     seq.start(this);
// 
//     phase.drop_objection(this);
// endtask

`endif 
