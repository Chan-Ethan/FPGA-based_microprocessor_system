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

        #500us; // wait for DUT init
        // send ack transaction (For reset)
        `uvm_do_with(tr, {
            tr.pkt_type == CMD;
            tr.cmd_byte == 8'hF4;
        })

        #100us;
        // send ID
        `uvm_do_with(tr, {
            tr.pkt_type == CMD;
            tr.cmd_byte == 8'hAA;
        })

        #400us;
        // send ack transaction (For start stream mode)
        `uvm_do_with(tr, {
            tr.pkt_type == CMD;
            tr.cmd_byte == 8'hF4;
        })

        // send 20 data transactions
        # 100us;
        repeat (20) begin
            `uvm_do_with(tr, {
                tr.pkt_type == DATA;
            })
            #200us;
        end
        #100us;

        // send tr finished, drop objection
        if (starting_phase != null) begin
            starting_phase.drop_objection(this);
        end
    endtask
endclass

// Main testcase: Configures test environment
class t1_smoke extends base_test;
    `uvm_component_utils(t1_smoke)

    function new(string name = "t1_smoke", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
endclass

// Build phase: Set default sequence for target sequencer
function void t1_smoke::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("t1_smoke", "t1_smoke build_phase", UVM_MEDIUM)

    uvm_config_db #(uvm_object_wrapper)::set(this,
        "env.i_agt.sqr.main_phase", 
        "default_sequence", 
        new_sequence::type_id::get());
endfunction
