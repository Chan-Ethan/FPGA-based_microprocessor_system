`ifndef BUS_AGENT_SV
`define BUS_AGENT_SV

class bus_agent extends uvm_agent;
    // bus_driver       drv;
    bus_monitor      mon;
    // bus_sequencer    sqr;

    uvm_analysis_port #(bus_transaction) ap;

    `uvm_component_utils(bus_agent)

    function new(string name = "my_agent", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("my_agent", "my_agent is created", UVM_MEDIUM)
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass

function void bus_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("my_agent", "my_agent build_phase", UVM_MEDIUM)
    
    // if (is_active == UVM_ACTIVE) begin
    //     sqr = bus_sequencer::type_id::create("sqr", this);
    //     drv = bus_driver::type_id::create("drv", this);
    // end
    // else begin
        mon = bus_monitor::type_id::create("mon", this);
    // end
endfunction

function void bus_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("my_agent", "my_agent connect_phase", UVM_MEDIUM)

    // if (is_active == UVM_ACTIVE) begin
    //     drv.seq_item_port.connect(sqr.seq_item_export);
    //     ap = drv.ap;
    // end
    ap = mon.ap;
endfunction

`endif // BUS_AGENT_SV
