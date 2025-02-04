`ifndef PS2_MONITOR_SV
`define PS2_MONITOR_SV

class ps2_monitor extends uvm_monitor;
	virtual ps2_if vif;
	uvm_analysis_port #(ps2_transaction) ap;

	`uvm_component_utils(ps2_monitor)
  
  	function new(string name = "ps2_monitor", uvm_component parent = null);
		super.new(name, parent);
		`uvm_info("ps2_monitor", "ps2_monitor is created", UVM_MEDIUM)
  	endfunction

	extern virtual function void build_phase(uvm_phase phase);
  	extern virtual task main_phase(uvm_phase phase);
	extern virtual task collect_one_pkt(ps2_transaction tr);
endclass

function void ps2_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("ps2_monitor", "ps2_monitor build_phase", UVM_MEDIUM)

	if (!uvm_config_db#(virtual ps2_if)::get(this, "", "vif", vif)) begin
		`uvm_fatal("ps2_monitor", "virtual interface must be set for vif!")
	end

	ap = new("ap", this);
endfunction

task ps2_monitor::main_phase(uvm_phase phase);
	ps2_transaction tr;

	while (1) begin
		// wait for valid signal
		while (1) begin
			@(posedge vif.clk);
			if (vif.valid) break;
		end
		tr = new("tr");
		collect_one_pkt(tr);
		ap.write(tr);
	end
endtask

task ps2_monitor::collect_one_pkt(ps2_transaction tr);
	bit [7:0] 	data_q[$];
	bit [7:0] 	data_array[];
	bit [7:0]	data;
	bit  		valid = 0;
	int			data_size;

	`uvm_info("ps2_monitor", "begin to collect one pkt", UVM_LOW)
	while (vif.valid) begin
		data_q.push_back(vif.data);
		@(posedge vif.clk);
	end

	// convert queue to array
	data_size = data_q.size();
	data_array = new[data_size];
	foreach (data_q[i]) begin
		data_array[i] = data_q[i];
	end

	// assign to tr
	tr.pload = new[data_size - 18]; // 18 is header size
	data_size = tr.unpack_bytes(data_array) / 8;
	`uvm_info("RECE_PKT", "collect one pkt finish", UVM_LOW)
endtask

`endif // PS2_MONITOR_SV
