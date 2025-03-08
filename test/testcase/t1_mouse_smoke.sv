// construct a new sequence: Generates timed transaction
class virt_sequence extends uvm_sequence;
    ps2_nego_sequence nego_seq;
    ps2_sequencer sqr;
    ps2_transaction tr;
    
    `uvm_object_utils(virt_sequence)
    
    function new(string name = "virt_sequence");
        super.new(name);
    endfunction

    virtual task body();
        // if (starting_phase != null) begin
        //     starting_phase.raise_objection(this);
        // end

        #500us; // wait for DUT init
        nego_seq = ps2_nego_sequence::type_id::create("nego_seq");
        nego_seq.start(sqr);
        
        // send 20 data transactions
        # 100us;
        repeat (20) begin
            `uvm_do_on_with(tr, sqr, {
                tr.pkt_type == DATA;
            })
            #200us;
        end
        #100us;

        // send tr finished, drop objection
        // if (starting_phase != null) begin
        //     starting_phase.drop_objection(this);
        // end
    endtask
endclass

// Main testcase: Configures test environment
class t1_mouse_smoke extends base_test;
    `uvm_component_utils(t1_mouse_smoke)

    function new(string name = "t1_mouse_smoke", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
endclass

// Build phase: Set default sequence for target sequencer
function void t1_mouse_smoke::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("t1_mouse_smoke", "t1_mouse_smoke build_phase", UVM_MEDIUM)

    // uvm_config_db #(uvm_object_wrapper)::set(this,
    //     "env.i_agt.sqr.main_phase", 
    //     "default_sequence", 
    //     virt_sequence::type_id::get());
endfunction

// Main phase: Start the test
task t1_mouse_smoke::main_phase(uvm_phase phase);
    virt_sequence vseq;

    super.main_phase(phase);
    `uvm_info("t1_mouse_smoke", "t1_mouse_smoke main_phase", UVM_MEDIUM)

    phase.raise_objection(this);

    // Start the sequence
    vseq = virt_sequence::type_id::create("vseq");
    vseq.sqr = env.i_agt.sqr;
    vseq.start(null);

    phase.drop_objection(this);
endtask
