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

        // send 50 short transactions
        repeat (50) begin
            `uvm_do_with(tr, {
                tr.pload.size >= 20;
                tr.pload.size <= 48;
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
class case2 extends base_test;
    `uvm_component_utils(case2)

    function new(string name = "case2", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
endclass

// Build phase: Set default sequence for target sequencer
function void case2::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("case2", "case2 build_phase", UVM_MEDIUM)

    uvm_config_db #(uvm_object_wrapper)::set(this,
        "env.i_agt.sqr.main_phase", 
        "default_sequence", 
        new_sequence::type_id::get());
endfunction
