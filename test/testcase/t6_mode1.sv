// Test IR transmitter at mode 1
class virt_sequence extends uvm_sequence;
    sw_transaction tr;
    
    `uvm_object_utils(virt_sequence)
    
    function new(string name = "virt_sequence");
        super.new(name);
    endfunction

    virtual task body();
        // send 20 switch transactions
        # 100us;
        repeat (2) begin
            `uvm_do_with(tr, {
                // Configure different switch modes
                sw_tr.slide_switch[15:8] inside {8'h80, 8'h40, 8'h00};
            })
            # 22ms;
        end
    endtask
endclass

// Main testcase: Configures test environment
class t6_mode1 extends base_test;
    `uvm_component_utils(t6_mode1)

    function new(string name = "t6_mode1", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("t6_mode1", "t6_mode1 is created", UVM_MEDIUM)
    endfunction

    extern virtual task main_phase(uvm_phase phase);
endclass

// Main phase: Start the test
task t6_mode1::main_phase(uvm_phase phase);
    virt_sequence vseq;

    super.main_phase(phase);
    `uvm_info("t6_mode1", "t6_mode1 main_phase", UVM_MEDIUM)

    phase.raise_objection(this);

    // Start the sequence
    vseq = virt_sequence::type_id::create("vseq");
    vseq.start(env.sw_agt.sqr);

    phase.drop_objection(this);
endtask
