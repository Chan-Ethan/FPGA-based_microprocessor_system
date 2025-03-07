`ifndef SW_DRIVER_SV
`define SW_DRIVER_SV

class sw_driver extends uvm_driver #(sw_transaction);
  	`uvm_component_utils(sw_driver)
	virtual sw_if vif;
	uvm_analysis_port #(sw_transaction) ap;

  	function new(string name = "sw_driver", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("sw_driver", "sw_driver is created",        UVM_MEDIUM)
  	endfunction

	extern virtual function void build_phase(uvm_phase phase);
  	extern virtual task main_phase(uvm_phase phase);
endclass

function void sw_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("sw_driver", "sw_driver build_phase", UVM_MEDIUM)
	if (!uvm_config_db#(virtual sw_if)::get(this, "", "vif", vif)) begin
		`uvm_fatal("sw_driver", "virtual interface must be set for vif!")
	end
    ap = new("ap", this);
endfunction

task sw_driver::main_phase(uvm_phase phase);
    `uvm_info("sw_driver", "sw_driver main_phase", UVM_MEDIUM)
  	
	// wait for reset to be released
	vif.sw = 16'b0;
	while (!vif.rst_n) begin
		@(posedge vif.clk);
  	end

	// change slide switch value when get a tr
	while (1) begin
		seq_item_port.get_next_item(req);
		vif.sw = req.slide_switch;
        ap.write(req); // send pkt to model
		seq_item_port.item_done();
	end	
endtask

`endif // SW_DRIVER_SV
