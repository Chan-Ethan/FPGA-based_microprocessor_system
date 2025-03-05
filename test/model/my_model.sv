`ifndef MY_MODEL_SV
`define MY_MODEL_SV

parameter MOUSE_X_MAX = 8'd160;
parameter MOUSE_Y_MAX = 8'd120;

class my_model extends uvm_component;
    uvm_blocking_get_port #(ps2_transaction) mouse_port; // from ps2_agent
    uvm_analysis_port #(bus_transaction) ap; // to my_scoreboard

    bit [7:0] mouse_pos_x, mouse_pos_y;

    `uvm_component_utils(my_model)

    function new(string name = "my_model", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("my_model", "my_model is created", UVM_MEDIUM)
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual function void bus_op(bit [7:0] addr, bit [7:0] data, bit we);
    extern virtual function void cal_mouse_pos(ps2_transaction tr);
endclass

function void my_model::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("my_model", "my_model build_phase", UVM_MEDIUM)
    
    mouse_port = new("mouse_port", this);
    ap = new("ap", this);

    mouse_pos_x = 8'd0;
    mouse_pos_y = 8'd0;
endfunction

task my_model::main_phase(uvm_phase phase);
    ps2_transaction mouse_tr;

    super.main_phase(phase);

    // Processor’s init (read Mouse data)
    bus_op(8'hA0, 8'h00, 1'b0); // Read mouse status from memory to A
    bus_op(8'hC0, 8'h00, 1'b1); // write mouse status to LEDs
    bus_op(8'hA1, 8'h00, 1'b0); // Read mouse X position
    bus_op(8'hA2, 8'h00, 1'b0); // Read mouse Y position
    bus_op(8'hD0, 8'h00, 1'b1); // Write mouse X position to Seg7[3:2]
    bus_op(8'hD1, 8'h00, 1'b1); // Write mouse Y position to Seg7[1:0]

    while (1) begin
        mouse_port.get(mouse_tr);
        `uvm_info("my_model", "get a mouse transaction", UVM_LOW)
        if (mouse_tr.pkt_type == CMD) begin
            `uvm_info("my_model", "mouse transaction is CMD", UVM_LOW)
            // do nothing
        end
        else begin
            `uvm_info("my_model", "mouse transaction is DATA", UVM_LOW)
            cal_mouse_pos(mouse_tr); // calculate mouse position
            // simulate Processor's mosue interrupt handler’s service routine
            bus_op(8'hA0, mouse_tr.byte0, 1'b0); // Read mouse status from memory to A
            bus_op(8'hC0, mouse_tr.byte0, 1'b1); // write mouse status to LEDs
            bus_op(8'hA1, mouse_pos_x,    1'b0); // Read mouse X position
            bus_op(8'hA2, mouse_pos_y,    1'b0); // Read mouse Y position
            bus_op(8'hD0, mouse_pos_x,    1'b1); // Write mouse X position to Seg7[3:2]
            bus_op(8'hD1, mouse_pos_y,    1'b1); // Write mouse Y position to Seg7[1:0]
        end
    end
endtask

// Bus operates in two modes: read and write
// when WE = 0, input data is the expected returned data from the peripherals
function void my_model::bus_op(bit [7:0] addr, bit [7:0] data, bit we);
    bus_transaction bus_tr;

    bus_tr = new("bus_tr");
    bus_tr.WE = we;
    bus_tr.ADDR = addr;
    bus_tr.DATA = data;
    ap.write(bus_tr);
endfunction

// calculate mouse position
function void my_model::cal_mouse_pos(ps2_transaction tr);
    // add mouse movement to current position
    mouse_pos_x = mouse_pos_x + tr.x_mov;
    mouse_pos_y = mouse_pos_y + tr.y_mov;

    // check mouse position boundary
    if (mouse_pos_x > MOUSE_X_MAX) begin
        mouse_pos_x = (tr.x_sign == 1'b0) ? MOUSE_X_MAX : 0;
    end
    if (mouse_pos_y > MOUSE_Y_MAX) begin
        mouse_pos_y = (tr.y_sign == 1'b0) ? MOUSE_Y_MAX : 0;
    end
endfunction

`endif // MY_MODEL_SV