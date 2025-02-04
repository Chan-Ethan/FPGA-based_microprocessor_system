`ifndef PS2_DRIVER_SV
`define PS2_DRIVER_SV

class ps2_driver extends uvm_driver #(ps2_transaction);
  	`uvm_component_utils(ps2_driver)
	virtual ps2_if vif;
	uvm_analysis_port #(ps2_transaction) ap;

  	function new(string name = "ps2_driver", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("ps2_driver", "ps2_driver is created",        UVM_MEDIUM)
  	endfunction

	extern virtual function void build_phase(uvm_phase phase);
  	extern virtual task main_phase(uvm_phase phase);
	extern virtual task drive_one_pkt(ps2_transaction tr);
endclass

function void ps2_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("ps2_driver", "ps2_driver build_phase", UVM_MEDIUM)
	if (!uvm_config_db#(virtual ps2_if)::get(this, "", "vif", vif)) begin
		`uvm_fatal("ps2_driver", "virtual interface must be set for vif!")
	end
    ap = new("ap", this);
endfunction

task ps2_driver::main_phase(uvm_phase phase);
    `uvm_info("ps2_driver", "ps2_driver main_phase", UVM_MEDIUM)
  	
	// wait for reset to be released
	vif.PS2_CLK <= 1'b1;
	vif.PS2_DATA <= 1'b1;
	while (!vif.rst_n) begin
		@(posedge vif.clk);
  	end
	repeat(10) @(posedge vif.clk);

	fork
		// drive PS2_CLK
		while (1) begin
			// clock period is 2us for simulation
			#1us; 	vif.PS2_CLK <= ~vif.PS2_CLK;
		end

		// wait for transaction from sequencer and then drive it
		while (1) begin
			seq_item_port.get_next_item(req);
			drive_one_pkt(req);
            ap.write(req); // send pkt to model
			seq_item_port.item_done();
		end
	join
	
endtask

// drive one packet to DUT
task ps2_driver::drive_one_pkt(ps2_transaction tr);
	bit [7:0] 	data_array[];
	int  		data_size;

	data_size = tr.pack_bytes(data_array) / 8; // pack tr to data_array

	`uvm_info("ps2_driver", "begin to drive one pkt", UVM_LOW)

	@(posedge vif.PS2_CLK);
    foreach (data_array[i]) begin
		// drive start bit
		vif.PS2_DATA <= 1'b0;
		@(posedge vif.PS2_CLK);

		// drive data bits
		foreach (data_array[i][j]) begin
			vif.PS2_DATA <= data_array[i][j];
			@(posedge vif.PS2_CLK);
		end

		// drive odd parity bit
		vif.PS2_DATA <= ^data_array[i];
		@(posedge vif.PS2_CLK);

		// drive stop bit
        vif.PS2_DATA <= 1'b1;
		@(posedge vif.PS2_CLK);
	end

	@(posedge vif.clk);
	vif.valid <= 1'b0;
	`uvm_info("SNED_PKT", "drive one pkt done:", UVM_LOW)
    tr.print();
endtask

`endif // PS2_DRIVER_SV
