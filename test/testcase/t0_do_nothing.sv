class t1_do_nothing extends base_test;
    `uvm_component_utils(t1_do_nothing)

    function new(string name = "t1_do_nothing", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
endclass

// Build phase: Set default sequence for target sequencer
function void t1_do_nothing::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("t1_do_nothing", "t1_do_nothing build_phase", UVM_MEDIUM)
endfunction

// Main phase: Start the test
task t1_do_nothing::main_phase(uvm_phase phase);
    virt_sequence vseq;

    super.main_phase(phase);
    `uvm_info("t1_do_nothing", "t1_do_nothing main_phase", UVM_MEDIUM)

    phase.raise_objection(this);

    // do nothing, just wait for 20 ms
    #20ms;

    phase.drop_objection(this);
endtask
