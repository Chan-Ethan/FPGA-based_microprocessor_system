`ifndef BUS_SEQUENCER_SV
`define BUS_SEQUENCER_SV

class bus_sequencer extends uvm_sequencer #(bus_transaction);
    `uvm_component_utils(bus_sequencer)

    function new(string name = "bus_sequencer", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("bus_sequencer", "bus_sequencer is created", UVM_MEDIUM)
    endfunction

    // extern virtual function void build_phase(uvm_phase phase);
    // extern virtual task main_phase(uvm_phase phase);
endclass

// task bus_sequencer::main_phase(uvm_phase phase);
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

`endif // BUS_SEQUENCER_SV
