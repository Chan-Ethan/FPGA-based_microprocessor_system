// Mouse negotiation sequence
`ifndef PS2_NEGO_SEQUENCE_SV
`define PS2_NEGO_SEQUENCE_SV

class ps2_nego_sequence extends uvm_sequence #(ps2_transaction);
    ps2_transaction tr;

    `uvm_object_utils(ps2_nego_sequence)

    function new(string name = "ps2_nego_sequence");
        super.new(name);
    endfunction

    virtual task body();
        // waiting for reset cmd
        // @(reset_e);
        #500us;
        // send ack transaction (For reset)
        `uvm_do_with(tr, {
            tr.pkt_type == CMD;
            tr.cmd_byte == 8'hF4;
        })
        
        #100us;
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

        // @(start_stream_e);
        #300us;
        // send ack transaction (For start stream mode)
        `uvm_do_with(tr, {
            tr.pkt_type == CMD;
            tr.cmd_byte == 8'hF4;
        })
    endtask
endclass

`endif // PS2_NEGO_SEQUENCE_SV
