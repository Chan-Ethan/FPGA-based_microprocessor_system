`ifndef MY_DRIVER_SV
`define MY_DRIVER_SV

class my_driver extends uvm_driver #(my_transaction);
  	`uvm_component_utils(my_driver)
	virtual my_if vif;
  
  	function new(string name = "my_driver", uvm_component parent = null);
    	super.new(name, parent);
		`uvm_info("my_driver", "my_driver is created", UVM_MEDIUM)
  	endfunction

	extern virtual function void build_phase(uvm_phase phase);
  	extern virtual task main_phase(uvm_phase phase);
	extern virtual task drive_one_pkt(my_transaction tr);
endclass

function void my_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("my_driver", "my_driver build_phase", UVM_MEDIUM)
	if (!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif)) begin
		`uvm_fatal("my_driver", "virtual interface must be set for vif!")
	end
endfunction

task my_driver::main_phase(uvm_phase phase);
	`uvm_info("my_driver", "my_driver main_phase", UVM_MEDIUM)

	vif.data <= 8'b0;
	vif.valid <= 1'b0;
  	
	// wait for reset to be released
	while (!vif.rst_n) begin
		@(posedge vif.clk);
  	end

	// wait for transaction from sequencer and then drive it
	while (1) begin
		seq_item_port.get_next_item(req);
		drive_one_pkt(req);
		seq_item_port.item_done();
	end
endtask

// drive one packet to DUT
task my_driver::drive_one_pkt(my_transaction tr);
	bit [7:0] 	data_array[];
	int  		data_size;

	data_size = tr.pack_bytes(data_array) / 8; // pack tr to data_array

	`uvm_info("my_driver", "begin to drive one pkt", UVM_LOW)
	repeat(3) @(posedge vif.clk);

    foreach (data_array[i]) begin
		@(posedge vif.clk);
		vif.valid <= 1'b1;
		vif.data <= data_array[i];
	end

	@(posedge vif.clk);
	vif.valid <= 1'b0;
	`uvm_info("SNED_PKT", "drive one pkt done", UVM_LOW)
endtask

`endif
