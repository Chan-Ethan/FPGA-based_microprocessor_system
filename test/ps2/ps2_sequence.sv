`ifndef PS2_SEQUENCE_SV
`define PS2_SEQUENCE_SV

class ps2_sequence extends uvm_sequence #(ps2_transaction);
    ps2_transaction tr;

    `uvm_object_utils(ps2_sequence)

    function new(string name = "ps2_sequence");
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

`endif // PS2_SEQUENCE_SV
