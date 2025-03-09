// Mixing mouse and switch testing

// Virtual sequence to coordinate both mouse and switch sequences
class virt_sequence extends uvm_sequence;
    ps2_nego_sequence nego_seq;
    ps2_sequencer ps2_sqr;
    sw_sequencer sw_sqr;

    ps2_transaction ps2_tr;
    sw_transaction sw_tr;
    
    `uvm_object_utils(virt_sequence)
    
    function new(string name = "virt_sequence");
        super.new(name);
    endfunction

    virtual task body();
        #500us; // wait for DUT init
        nego_seq = ps2_nego_sequence::type_id::create("nego_seq");
        nego_seq.start(ps2_sqr);
        
        // send mosue tr and switch tr alternatively
        # 100us;
        repeat (30) begin
            `uvm_do_on_with(ps2_tr, ps2_sqr, {
                ps2_tr.pkt_type == DATA;
            })
            #100us;

            `uvm_do_on_with(sw_tr, sw_sqr, {
                // Configure different switch modes
                sw_tr.slide_switch[15:8] inside {8'h80, 8'h40, 8'h00};
            })
            #100us;
        end
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
    #200us;
    
    phase.drop_objection(this);
endtask