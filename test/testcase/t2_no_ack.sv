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

        #2ms; // wait for DUT init
        // and no ack for 2ms, wait UDT resend reset cmd
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
class t2_no_ack extends base_test;
    `uvm_component_utils(t2_no_ack)

    function new(string name = "t2_no_ack", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
endclass

// Build phase: Set default sequence for target sequencer
function void t2_no_ack::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("t2_no_ack", "t2_no_ack build_phase", UVM_MEDIUM)

    uvm_config_db #(uvm_object_wrapper)::set(this,
        "env.i_agt.sqr.main_phase", 
        "default_sequence", 
        new_sequence::type_id::get());
endfunction
