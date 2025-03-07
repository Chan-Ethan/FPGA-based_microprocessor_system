`ifndef SW_SEQUENCER_SV
`define SW_SEQUENCER_SV

class sw_sequencer extends uvm_sequencer #(sw_transaction);
    `uvm_component_utils(sw_sequencer)

    function new(string name = "sw_sequencer", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("sw_sequencer", "sw_sequencer is created", UVM_MEDIUM)
    endfunction

    // extern virtual function void build_phase(uvm_phase phase);
    // extern virtual task main_phase(uvm_phase phase);
endclass

// task sw_sequencer::main_phase(uvm_phase phase);
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

`endif // SW_SEQUENCER_SV
