`ifndef ENV_SV
`define ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class Env extends uvm_env;
    sp2_agent i_agt;
    // my_agent o_agt;
    // my_model mdl;
    // my_scoreboard scb;

    // uvm_tlm_analysis_fifo #(my_transaction) agt_mdl_fifo;
    // uvm_tlm_analysis_fifo #(my_transaction) mdl_scb_fifo;
    // uvm_tlm_analysis_fifo #(my_transaction) oagt_scb_fifo;

    function new(string name = "Env", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("Env", "Env is created", UVM_MEDIUM)

        // agt_mdl_fifo = new("agt_mdl_fifo", this);
        // mdl_scb_fifo = new("mdl_scb_fifo", this);
        // oagt_scb_fifo = new("oagt_scb_fifo", this);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

    `uvm_component_utils(Env)

endclass

function void Env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("Env", "Env build_phase", UVM_MEDIUM)
    
    i_agt = my_agent::type_id::create("i_agt", this);
    // o_agt = my_agent::type_id::create("o_agt", this);
    i_agt.is_active = UVM_ACTIVE;
    // o_agt.is_active = UVM_PASSIVE;

    // mdl = my_model::type_id::create("mdl", this);
    // scb = my_scoreboard::type_id::create("scb", this);

    // set default sequence for my_sequencer
    // uvm_config_db #(uvm_object_wrapper)::set(this,
    //     "i_agt.sqr.main_phase", 
    //     "default_sequence", 
    //     my_sequence::type_id::get());
endfunction

function void Env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("Env", "Env connect_phase", UVM_MEDIUM)
    
    // i_agt.ap.connect(agt_mdl_fifo.analysis_export);
    // mdl.port.connect(agt_mdl_fifo.blocking_get_export);

    // mdl.ap.connect(mdl_scb_fifo.analysis_export);
    // scb.exp_port.connect(mdl_scb_fifo.blocking_get_export);
    
    // o_agt.ap.connect(oagt_scb_fifo.analysis_export);
    // scb.act_port.connect(oagt_scb_fifo.blocking_get_export);
endfunction

`endif // ENV_SV
