`ifndef BASE_TEST_SV
`define BASE_TEST_SV

class base_test extends uvm_test;
    my_env env;

    `uvm_component_utils(base_test)

    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
endclass

function void base_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("base_test", "base_test build_phase", UVM_MEDIUM)

    env = my_env::type_id::create("env", this);
    uvm_config_db #(uvm_object_wrapper)::set(this,
        "env.i_agt.sqr.main_phase", 
        "default_sequence", 
        my_sequence::type_id::get());
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

`endif // BASE_TEST_SV
