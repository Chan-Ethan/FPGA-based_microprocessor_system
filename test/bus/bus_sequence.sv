`ifndef BUS_SEQUENCE_SV
`define BUS_SEQUENCE_SV

class bus_sequence extends uvm_sequence #(bus_transaction);
    bus_transaction tr;

    `uvm_object_utils(bus_sequence)

    function new(string name = "bus_sequence");
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

`endif // BUS_SEQUENCE_SV
