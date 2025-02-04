`ifndef PS2_SEQUENCER_SV
`define PS2_SEQUENCER_SV

class ps2_sequencer extends uvm_sequencer #(ps2_transaction);
    `uvm_component_utils(ps2_sequencer)

    function new(string name = "ps2_sequencer", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("ps2_sequencer", "ps2_sequencer is created", UVM_MEDIUM)
    endfunction

    // extern virtual function void build_phase(uvm_phase phase);
    // extern virtual task main_phase(uvm_phase phase);
endclass

// task ps2_sequencer::main_phase(uvm_phase phase);
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

`endif // PS2_SEQUENCER_SV
