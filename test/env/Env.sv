`ifndef ENV_SV
`define ENV_SV

class Env extends uvm_env;
    ps2_agent i_agt;
    bus_agent bus_agt;
    my_model mdl;
    my_scoreboard scb;

    uvm_tlm_analysis_fifo #(ps2_transaction) mouse_mdl_fifo;
    uvm_tlm_analysis_fifo #(bus_transaction) mdl_scb_fifo;
    uvm_tlm_analysis_fifo #(bus_transaction) bus_scb_fifo;

    function new(string name = "Env", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("Env", "Env is created", UVM_MEDIUM)

        mouse_mdl_fifo = new("mouse_mdl_fifo", this);
        mdl_scb_fifo = new("mdl_scb_fifo", this);
        bus_scb_fifo = new("bus_scb_fifo", this);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

    `uvm_component_utils(Env)

endclass

function void Env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("Env", "Env build_phase", UVM_MEDIUM)
    
    i_agt = ps2_agent::type_id::create("i_agt", this);
    bus_agt = bus_agent::type_id::create("bus_agt", this);

    i_agt.is_active = UVM_ACTIVE;
    bus_agt.is_active = UVM_PASSIVE;

    mdl = my_model::type_id::create("mdl", this);
    scb = my_scoreboard::type_id::create("scb", this);

    // set default sequence for my_sequencer
    // uvm_config_db #(uvm_object_wrapper)::set(this,
    //     "i_agt.sqr.main_phase", 
    //     "default_sequence", 
    //     my_sequence::type_id::get());
endfunction

function void Env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("Env", "Env connect_phase", UVM_MEDIUM)
    
    i_agt.ap.connect(mouse_mdl_fifo.analysis_export);
    mdl.mouse_port.connect(mouse_mdl_fifo.blocking_get_export);

    bus_agt.ap.connect(mdl_scb_fifo.analysis_export);
    scb.act_port.connect(mdl_scb_fifo.blocking_get_export);

    mdl.ap.connect(bus_scb_fifo.analysis_export);
    scb.exp_port.connect(bus_scb_fifo.blocking_get_export);
endfunction

`endif // ENV_SV
