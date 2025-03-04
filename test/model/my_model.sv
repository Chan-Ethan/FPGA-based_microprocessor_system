`ifndef MY_MODEL_SV
`define MY_MODEL_SV

class my_model extends uvm_component;
    uvm_blocking_get_port #(ps2_transaction) mouse_port; // from ps2_agent
    uvm_analysis_port #(bus_transaction) ap; // to my_scoreboard

    `uvm_component_utils(my_model)

    function new(string name = "my_model", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("my_model", "my_model is created", UVM_MEDIUM)
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual function void bus_read(bit [7:0] addr);
    extern virtual function void bus_write(bit [7:0] addr, bit [7:0] data);
endclass

function void my_model::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("my_model", "my_model build_phase", UVM_MEDIUM)
    
    mouse_port = new("port", this);
    ap = new("ap", this);
endfunction

task my_model::main_phase(uvm_phase phase);
    ps2_transaction mouse_tr;

    super.main_phase(phase);

    while (1) begin
        port.get(mouse_tr);
        `uvm_info("my_model", "get a mouse transaction", UVM_LOW)
        if (mouse_tr.pkt_type == CMD) begin
            `uvm_info("my_model", "mouse transaction is CMD", UVM_LOW)
            // do nothing
        end
        else begin
            `uvm_info("my_model", "mouse transaction is DATA", UVM_LOW)
            
            // simulate Processor's mosue interrupt handler’s service routine
            bus_read(8'hA0); // Read mouse status from memory to A
            bus_write(8'hC0, mouse_tr.byte0); // write mouse status to LEDs
            bus_read(8'hA1); // Read mouse X position
            bus_read(8'hA2); // Read mouse Y position
            bus_write(8'hD0, mouse_tr.x_mov); // Write mouse X position to Seg7[3:2]
            bus_write(8'hD1, mouse_tr.y_mov); // Write mouse Y position to Seg7[1:0]
        end
    end
endtask

function void my_model::bus_read(bit [7:0] addr);
    bus_transaction bus_tr;

    bus_tr = new("bus_tr");
    bus_tr.WE = 0;
    bus_tr.ADDR = addr;
    ap.write(bus_tr);
endfunction

function void my_model::bus_write(bit [7:0] addr, bit [7:0] data);
    bus_transaction bus_tr;

    bus_tr = new("bus_tr");
    bus_tr.WE = 1;
    bus_tr.ADDR = addr;
    bus_tr.DATA = data;
    ap.write(bus_tr);
endfunction

`endif // MY_MODEL_SV