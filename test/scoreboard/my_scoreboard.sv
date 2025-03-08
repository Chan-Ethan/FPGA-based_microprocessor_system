`ifndef MY_SCOREBOARD_SV
`define MY_SCOREBOARD_SV

class my_scoreboard extends uvm_scoreboard;
    bus_transaction exp_q[$]; // expected transaction queue

    uvm_blocking_get_port #(bus_transaction) exp_port; // expected tr port
    uvm_blocking_get_port #(bus_transaction) act_port; // actual tr port

    `uvm_component_utils(my_scoreboard)

    function new(string name = "my_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("my_scoreboard", "my_scoreboard is created", UVM_MEDIUM)
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual function void check_phase(uvm_phase phase);
endclass

function void my_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("my_scoreboard", "my_scoreboard build_phase", UVM_MEDIUM)
    
    // create expected and actual ports
    exp_port = new("exp_port", this);
    act_port = new("act_port", this);
endfunction

task my_scoreboard::main_phase(uvm_phase phase);
    bus_transaction exp_tr, act_tr, tmp_tr;
    bit result;

    super.main_phase(phase);

    fork
        // collect expected transactions
        while (1) begin
            exp_port.get(exp_tr);
            `uvm_info("EXP_PKT", "expected BUS operation received", UVM_LOW)
            exp_q.push_back(exp_tr);
        end

        // collect actual transactions and compare
        while (1) begin
            act_port.get(act_tr);
            `uvm_info("ACT_PKT", "actual BUS operation received", UVM_LOW)
            if (exp_q.size() > 0) begin
                tmp_tr = exp_q.pop_front();
                result = act_tr.compare(tmp_tr); // compare two transactions
                if (result) begin
                    `uvm_info("CMP_PASS", "BUS operation matched", UVM_LOW)
                end
                else begin
                    `uvm_error("CMP_FAIL", "BUS operation mismatched")
                    $display("the expected BUS operation is:");
                    tmp_tr.print();
                    $display("the actual BUS operation is:");
                    act_tr.print();
                end
            end
            else begin
                `uvm_error("UNEXP_PKT", "detected unexpected BUS operation!")
                $display("the unexpected BUS operation is:");
                act_tr.print();
            end
        end
    join
endtask

function void my_scoreboard::check_phase(uvm_phase phase);
    super.check_phase(phase);
    `uvm_info("my_scoreboard", "my_scoreboard check_phase", UVM_MEDIUM)

    // check if all expected transactions are consumed
    if (exp_q.size() > 0) begin
        `uvm_error("EXP_TR_LEFT", "expected transactions are left!")
        foreach (exp_q[i]) begin
            $display("the left expected BUS operation is:");
            exp_q[i].print();
        end
    end
endfunction

`endif // MY_SCOREBOARD_SV
