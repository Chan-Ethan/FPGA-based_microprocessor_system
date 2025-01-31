// construct a new sequence: Generates timed transaction
class new_sequence extends uvm_sequence #(my_transaction);
    my_transaction tr;

    `uvm_object_utils(new_sequence)

    function new(string name = "new_sequence");
        super.new(name);
    endfunction

    virtual task body();
        if (starting_phase != null) begin
            starting_phase.raise_objection(this);
        end

        // send 15 random transactions
        repeat (15) begin
            `uvm_do_with(tr, {
                tr.pload.size >= 48;
                tr.pload.size <= 1024;
            })
            #1us;
        end
        #10us;

        // send tr finished, drop objection
        if (starting_phase != null) begin
            starting_phase.drop_objection(this);
        end
    endtask
endclass

// Main testcase: Configures test environment
class case_example extends base_test;
    `uvm_component_utils(case_example)

    function new(string name = "case_example", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
endclass

// Build phase: Set default sequence for target sequencer
function void case_example::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("case_example", "case_example build_phase", UVM_MEDIUM)

    uvm_config_db #(uvm_object_wrapper)::set(this,
        "env.i_agt.sqr.main_phase", 
        "default_sequence", 
        new_sequence::type_id::get());
endfunction
