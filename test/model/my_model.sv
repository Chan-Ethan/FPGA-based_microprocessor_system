`ifndef MY_MODEL_SV
`define MY_MODEL_SV

// `include "global_events_pkg.svh"
import global_events_pkg::*;

parameter MOUSE_X_MAX = 8'd160;
parameter MOUSE_Y_MAX = 8'd120;

class my_model extends uvm_component;
    uvm_blocking_get_port #(ps2_transaction) mouse_port; // from ps2_agent
    uvm_blocking_get_port #(sw_transaction) sw_port; // from sw_agent
    uvm_analysis_port #(bus_transaction) ap; // to my_scoreboard

    bit [7:0] mouse_pos_x, mouse_pos_y, mouse_byte0;

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
    sw_port = new("sw_port", this);
    ap = new("ap", this);

    mouse_pos_x = 8'd0;
    mouse_pos_y = 8'd0;
endfunction

task my_model::main_phase(uvm_phase phase);
    semaphore sem = new(1);
    uvm_event high_prio_event = new();

    ps2_transaction mouse_tr;
    sw_transaction sw_tr;
    bit [7:0] mode;

    super.main_phase(phase);

    // Processor’s init (read Mouse data)
    bus_op(8'h00, 8'h00, 1'b0); // Read 00 from memory to A
    bus_op(8'h20, 8'h00, 1'b0); // Read 20 from memory to B
    bus_op(8'hA0, 8'h00, 1'b0); // Read mouse status from memory to A
    bus_op(8'hC0, 8'h00, 1'b1); // write mouse status to LEDs
    bus_op(8'hA1, 8'h00, 1'b0); // Read mouse X position
    bus_op(8'hA2, 8'h00, 1'b0); // Read mouse Y position
    bus_op(8'hD0, 8'h00, 1'b1); // Write mouse X position to Seg7[3:2]
    bus_op(8'hD1, 8'h00, 1'b1); // Write mouse Y position to Seg7[1:0]

    fork
        while (1) begin
            // Mouse processing
            mouse_port.get(mouse_tr);
            high_prio_event.trigger();  // high priority event
            sem.get(1); // get semaphore

            `uvm_info("my_model", "get a mouse transaction", UVM_LOW)
            if (mouse_tr.pkt_type == CMD) begin
                `uvm_info("my_model", "mouse transaction is CMD", UVM_LOW)
                if (mouse_tr.cmd_byte == 8'hFF)
                    -> reset_e; // get a reset command
                else if (mouse_tr.cmd_byte == 8'hF4)
                    -> start_stream_e; // get a start stream command
                // else do nothing for other command
            end
            else begin
                `uvm_info("my_model", "mouse transaction is DATA", UVM_LOW)
                cal_mouse_pos(mouse_tr); // calculate mouse position
                mouse_byte0 = mouse_tr.byte0; // save mouse status
                bus_op(8'h00, 8'h00, 1'b0); // Read 00 from memory to A
                bus_op(8'h20, mode, 1'b0); // Read 20 from memory to B
                if (mode == 8'h00) begin
                    // simulate Processor's mosue interrupt handler’s service routine
                    bus_op(8'hA0, mouse_byte0, 1'b0); // Read mouse status to A
                    bus_op(8'hC0, mouse_byte0, 1'b1); // write mouse status to LEDs
                    bus_op(8'hA1, mouse_pos_x, 1'b0); // Read mouse X position
                    bus_op(8'hA2, mouse_pos_y, 1'b0); // Read mouse Y position
                    bus_op(8'hD0, mouse_pos_x, 1'b1); // Write mouse X position to Seg7[3:2]
                    bus_op(8'hD1, mouse_pos_y, 1'b1); // Write mouse Y position to Seg7[1:0]
                end
            end

            sem.put(1); // release semaphore
        end
        
        while (1) begin
            // Switch processing
            sw_port.get(sw_tr);
            if (high_prio_event.is_on()) begin
                #1;  // waiting for mouse processing
                high_prio_event.reset();
            end
            sem.get(1); // get semaphore

            `uvm_info("my_model", "get a switch transaction", UVM_LOW)
            // simulate Processor's switch interrupt handler’s service routine
            bus_op(8'hE0, sw_tr.slide_switch[15:8], 1'b0); // Read sw[15:8] to A
            bus_op(8'h01, 8'h80, 1'b0); // Read Men[0x01] to B
            if (sw_tr.slide_switch[15:8] == 8'h80) begin
                mode = sw_tr.slide_switch[15:8];
                // MODE 1: Display sw[7:0] on Seg7[1:0]
                bus_op(8'h20, sw_tr.slide_switch[15:8], 1'b1); // Write sw[15:8] to Men[0x20] (save mode)
                bus_op(8'h00, 8'h00, 1'b0); // Read 0x00 from memory to A
                bus_op(8'hE1, sw_tr.slide_switch[7:0], 1'b0); // Read sw[7:0] to A
                bus_op(8'hD0, 8'h00, 1'b1); // Write 0x00 to Seg7[3:2]
                bus_op(8'hD1, sw_tr.slide_switch[7:0], 1'b1); // Write sw[7:0] to Seg7[1:0]
                bus_op(8'h03, 8'hF0, 1'b0); // Read 0x03 from memory to A
                bus_op(8'hC0, 8'hF0, 1'b1); // write 0xF0 to LEDs
            end
            else begin
                bus_op(8'h02, 8'h40, 1'b0); // Read Men[0x02] to B
                if (sw_tr.slide_switch[15:8] == 8'h40) begin
                    mode = sw_tr.slide_switch[15:8];
                    // MODE 2: Display 0123
                    bus_op(8'h20, sw_tr.slide_switch[15:8], 1'b1); // Write sw[15:8] to Men[0x20] (save mode)
                    bus_op(8'h10, 8'h01, 1'b0); // Read 0x10 from memory to A
                    bus_op(8'h11, 8'h23, 1'b0); // Read 0x11 from memory to B
                    bus_op(8'hD0, mouse_pos_x,    1'b1); // Write 0x01 to Seg7[3:2]
                    bus_op(8'hD1, mouse_pos_y,    1'b1); // Write 0x23 to Seg7[1:0]
                    bus_op(8'h04, 8'h0F, 1'b0); // Read 0x04 from memory to A
                    bus_op(8'hC0, 8'h0F, 1'b1); // write 0xF0 to LEDs
                end
                else begin
                    // MODE 0: Display Mouse
                    mode = 8'h00;
                    bus_op(8'h00, 8'h00, 1'b0); // Read 0xx0 from memory to B
                    bus_op(8'h20, 8'h00, 1'b1); // Write 0x00 to Men[0x20] (save mode)

                    bus_op(8'hA0, mouse_byte0, 1'b0); // Read mouse status to A
                    bus_op(8'hC0, mouse_byte0, 1'b1); // write mouse status to LEDs
                    bus_op(8'hA1, mouse_pos_x, 1'b0); // Read mouse X position
                    bus_op(8'hA2, mouse_pos_y, 1'b0); // Read mouse Y position
                    bus_op(8'hD0, mouse_pos_x, 1'b1); // Write mouse X position to Seg7[3:2]
                    bus_op(8'hD1, mouse_pos_y, 1'b1); // Write mouse Y position to Seg7[1:0]
                end
            end
            
            sem.put(1); // release semaphore
        end
    join
endtask

// Bus operates in two modes: read and write
// when WE = 0, input data is the expected returned data from the peripherals
function void my_model::bus_op(bit [7:0] addr, bit [7:0] data, bit we);
    bus_transaction bus_tr;

    bus_tr = new("bus_tr");
    bus_tr.WE = we;
    bus_tr.ADDR = addr;
    bus_tr.DATA = data;
    `uvm_info("MDL_BUS_OP", $sformatf("bus operation: addr=%h, data=%h, we=%b", addr, data, we), UVM_LOW)
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
