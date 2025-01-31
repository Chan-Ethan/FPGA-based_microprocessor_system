`ifndef MY_SEQUENCE_SV
`define MY_SEQUENCE_SV

class my_sequence extends uvm_sequence #(my_transaction);
    my_transaction tr;

    `uvm_object_utils(my_sequence)

    function new(string name = "my_sequence");
        super.new(name);
    endfunction

    virtual task body();
        if (starting_phase != null) begin
            starting_phase.raise_objection(this);
        end

        // send 10 random transactions
        repeat (10) begin
            `uvm_do(tr)
        end
        #1us;

        // send tr finished, drop objection
        if (starting_phase != null) begin
            starting_phase.drop_objection(this);
        end
    endtask
endclass

`endif // MY_SEQUENCE_SV
