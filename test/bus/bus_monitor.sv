`ifndef BUS_MONITOR_SV
`define BUS_MONITOR_SV

class bus_monitor extends uvm_monitor;
	virtual bus_if vif;
	uvm_analysis_port #(bus_transaction) ap;

	`uvm_component_utils(bus_monitor)
  
  	function new(string name = "bus_monitor", uvm_component parent = null);
		super.new(name, parent);
		`uvm_info("bus_monitor", "bus_monitor is created", UVM_MEDIUM)
  	endfunction

	extern virtual function void build_phase(uvm_phase phase);
  	extern virtual task main_phase(uvm_phase phase);
endclass

function void bus_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("bus_monitor", "bus_monitor build_phase", UVM_MEDIUM)

	if (!uvm_config_db#(virtual bus_if)::get(this, "", "vif", vif)) begin
		`uvm_fatal("bus_monitor", "virtual interface must be set for vif!")
	end

	ap = new("ap", this);
endfunction

task bus_monitor::main_phase(uvm_phase phase);
	bus_transaction tr;

	while (1) begin
		@(posedge vif.clk);
		if (vif.BUS_ADDR != 8'hz) begin
			tr = new("tr");
			tr.ADDR = vif.BUS_ADDR;
			tr.WE = vif.BUS_WE;
			if (vif.BUS_WE == 1'b1) begin
				// write data
				tr.DATA = vif.BUS_DATA;
			end
			else begin
				// read data, wait for BUS_DATA
				@(posedge vif.clk);
				tr.DATA = vif.BUS_DATA;
			end
		end
		`uvm_info("GET_BUS_OP", "get a bus transaction", UVM_LOW)
		tr.print();
		ap.write(tr);
	end
endtask

`endif // BUS_MONITOR_SV
