// construct a new sequence: Generates timed transaction
class new_sequence extends uvm_sequence #(ps2_transaction);
    ps2_transaction tr;

    `uvm_object_utils(new_sequence)

    function new(string name = "new_sequence");
        super.new(name);
    endfunction

    virtual task body();
        if (starting_phase != null) begin
            starting_phase.raise_objection(this);
        end

        #1ms; // wait for DUT init

        // send init transaction
        `uvm_do_with(tr, {
            tr.pkt_type == CMD;
            tr.cmd_byte == 8'hAA;
        })
        #300us;

        // send ack transaction
        `uvm_do_with(tr, {
            tr.pkt_type == CMD;
            tr.cmd_byte == 8'hFA;
        })

        // send 20 data transactions
        # 100us;
        repeat (20) begin
            `uvm_do_with(tr, {
                tr.pkt_type == DATA;
            })
            #200us;
        end
        #10us;

        // send tr finished, drop objection
        if (starting_phase != null) begin
            starting_phase.drop_objection(this);
        end
    endtask
endclass

// Main testcase: Configures test environment
class case1 extends base_test;
    `uvm_component_utils(case1)

    function new(string name = "case1", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
endclass

// Build phase: Set default sequence for target sequencer
function void case1::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("case1", "case1 build_phase", UVM_MEDIUM)

    uvm_config_db #(uvm_object_wrapper)::set(this,
        "env.i_agt.sqr.main_phase", 
        "default_sequence", 
        new_sequence::type_id::get());
endfunction
