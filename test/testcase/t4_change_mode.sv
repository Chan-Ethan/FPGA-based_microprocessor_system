// slide switch smoke test
class virt_sequence extends uvm_sequence;
    sw_transaction tr;
    
    `uvm_object_utils(virt_sequence)
    
    function new(string name = "virt_sequence");
        super.new(name);
    endfunction

    virtual task body();
        int wait_time;

        // send 20 switch transactions
        # 100us;
        repeat (20) begin
            `uvm_do_with(tr, {
                tr.slide_switch[15:8] inside {8'h80, 8'h40, 8'h00};
            })
            wait_time = $urandom_range(100, 300);
            repeat (wait_time) #1us;
        end
        #100us;
    endtask
endclass

// Main testcase: Configures test environment
class t4_change_mode extends base_test;
    `uvm_component_utils(t4_change_mode)

    function new(string name = "t4_change_mode", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("t4_change_mode", "t4_change_mode is created", UVM_MEDIUM)
    endfunction

    extern virtual task main_phase(uvm_phase phase);
endclass

// Main phase: Start the test
task t4_change_mode::main_phase(uvm_phase phase);
    virt_sequence vseq;

    super.main_phase(phase);
    `uvm_info("t4_change_mode", "t4_change_mode main_phase", UVM_MEDIUM)

    phase.raise_objection(this);

    // Start the sequence
    vseq = virt_sequence::type_id::create("vseq");
    vseq.start(env.sw_agt.sqr);

    phase.drop_objection(this);
endtask
