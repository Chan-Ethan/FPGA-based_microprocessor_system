`ifndef BASE_TEST_SV
`define BASE_TEST_SV

`include "global_events_pkg.svh"

class base_test extends uvm_test;
    import global_events_pkg::*;

    Env env;

    `uvm_component_utils(base_test)

    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual task mouse_negotiation();
endclass

function void base_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("base_test", "base_test build_phase", UVM_MEDIUM)

    env = Env::type_id::create("env", this);
    // uvm_config_db #(uvm_object_wrapper)::set(this,
    //     "env.i_agt.sqr.main_phase", 
    //     "default_sequence", 
    //     my_sequence::type_id::get());
endfunction

function void base_test::report_phase(uvm_phase phase);
    uvm_report_server   server;
    int                 err_num;

    super.report_phase(phase);
    `uvm_info("base_test", "base_test report_phase", UVM_MEDIUM)

    server = get_report_server();
    err_num = server.get_severity_count(UVM_ERROR);

    if (err_num != 0) begin
        $display("\n========== TEST CASE FAIL ==========\n");
    end
    else begin
        $display("\n========== TEST CASE PASS ==========\n");
    end
endfunction

task base_test::main_phase(uvm_phase phase);
    super.main_phase(phase);
    `uvm_info("base_test", "base_test main_phase", UVM_MEDIUM)

    phase.raise_objection(this);

    #1ms;

    phase.drop_objection(this);
endtask

task base_test::mouse_negotiation();
    // waiting for reset cmd
    @(reset_e);
    // send ack transaction (For reset)
    `uvm_do_with(tr, {
        tr.pkt_type == CMD;
        tr.cmd_byte == 8'hF4;
    })

    // waiting for Self Test cmd
    @(start_stream_e);
    // send Self Test transaction
    `uvm_do_with(tr, {
        tr.pkt_type == CMD;
        tr.cmd_byte == 8'hAA;
    })

    // send ID transaction
    // #100us;
    // `uvm_do_with(tr, {
    //     tr.pkt_type == CMD;
    //     tr.cmd_byte == 8'h00;
    // })

    #100us;
    // send ack transaction (For start stream mode)
    `uvm_do_with(tr, {
        tr.pkt_type == CMD;
        tr.cmd_byte == 8'hF4;
    })
endtask

`endif // BASE_TEST_SV
