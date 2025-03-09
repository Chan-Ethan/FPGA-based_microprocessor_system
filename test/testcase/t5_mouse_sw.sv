// Mixing mouse and switch testing
class mouse_sequence extends uvm_sequence;
    ps2_nego_sequence nego_seq;
    ps2_sequencer sqr;
    ps2_transaction tr;
    
    `uvm_object_utils(mouse_sequence)
    
    function new(string name = "mouse_sequence");
        super.new(name);
    endfunction

    virtual task body();
        #500us; // wait for DUT init
        nego_seq = ps2_nego_sequence::type_id::create("nego_seq");
        nego_seq.start(sqr);
        
        // send data transactions
        # 100us;
        repeat (30) begin
            `uvm_do_on_with(tr, sqr, {
                tr.pkt_type == DATA;
            })
            #200us;
        end
        #100us;
    endtask
endclass

// Switch sequence: Handles slide switch inputs
class switch_sequence extends uvm_sequence;
    sw_transaction tr;
    
    `uvm_object_utils(switch_sequence)
    
    function new(string name = "switch_sequence");
        super.new(name);
    endfunction

    virtual task body();
        int wait_time;

        // send switch transactions
        # 100us;
        repeat (25) begin
            `uvm_do_with(tr, {
                // Configure different switch modes
                tr.slide_switch[15:8] inside {8'h80, 8'h40, 8'h20, 8'h00};
                // Random lower bits
                tr.slide_switch[7:0] == $urandom();
            })
            wait_time = $urandom_range(150, 350);
            repeat (wait_time) #1us;
        end
        #100us;
    endtask
endclass

// Virtual sequence to coordinate both mouse and switch sequences
class virt_sequence extends uvm_sequence;
    mouse_sequence mouse_seq;
    switch_sequence sw_seq;
    
    `uvm_object_utils(virt_sequence)
    
    function new(string name = "virt_sequence");
        super.new(name);
    endfunction

    virtual task body();
        mouse_seq = mouse_sequence::type_id::create("mouse_seq");
        sw_seq = switch_sequence::type_id::create("sw_seq");
        
        mouse_seq.sqr = env.i_agt.sqr;
        
        // Run both sequences in parallel
        fork
            mouse_seq.start(null);
            sw_seq.start(env.sw_agt.sqr;);
        join
    endtask
endclass

// Main testcase: Combines mouse and switch testing
class t5_mouse_sw extends base_test;
    `uvm_component_utils(t5_mouse_sw)

    function new(string name = "t5_mouse_sw", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("t5_mouse_sw", "t5_mouse_sw is created", UVM_MEDIUM)
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
endclass

// Build phase: Set up the test environment
function void t5_mouse_sw::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("t5_mouse_sw", "t5_mouse_sw build_phase", UVM_MEDIUM)
endfunction

// Main phase: Execute the test
task t5_mouse_sw::main_phase(uvm_phase phase);
    virt_sequence vseq;

    super.main_phase(phase);
    `uvm_info("t5_mouse_sw", "t5_mouse_sw main_phase", UVM_MEDIUM)

    phase.raise_objection(this);

    // Start the virtual sequence that coordinates both interfaces
    vseq = virt_sequence::type_id::create("vseq");
    vseq.ps2_sqr = env.i_agt.sqr;
    vseq.sw_sqr = env.sw_agt.sqr;
    vseq.start(null);

    // Allow some extra time for test completion
    #1ms;
    
    phase.drop_objection(this);
endtask