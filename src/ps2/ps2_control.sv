// PS/2 receiver and transmitter control logic

module ps2_control
(
    input                   clk_sys         , // 50MHz system clock
    input                   rst_n           , // reset signal
    
    // ps2_rx interface
    output reg              rd_en           ,
    input                   rd_vld          ,
    input       [7:0]       rd_data         ,

    // ps2_tx interface
    output reg              wr_en           ,
    output reg  [7:0]       wr_data         ,
    input                   wr_done         ,

    // connection to seven segment display
    output reg              ps2pkt_vlk      ,
    output reg  [23:0]      ps2pkt_data     ,

    // device status debug signal
    output reg              init_done       ,
    output      [2:0]       current_state   
);

`define FSM_IDLE        4'b0001
`define FSM_SEND_RST    4'b0010
`define FSM_WAIT_ACK    4'b0100
`define FSM_STREAM_MOD  4'b1000

// current_state FSM variable
logic   [2:0]       current_state, next_state;

logic               waiting_wr_done;

logic   [1:0]       byte_cnt; // from 0 to 2

//================= State Machine =================//
// State Transition Logic
always_comb begin
    next_state = current_state;
    case (current_state)
        `FSM_IDLE: begin
            if (rd_vld) begin
                // reset device what ever the data is received
                next_state = `FSM_SEND_RST;
            end
        end
        `FSM_SEND_RST: begin
            if (wr_done) begin
                next_state = `FSM_WAIT_ACK;
            end
        end
        `FSM_WAIT_ACK: begin
            // wait for device to ack
            // otherwise, reset the device again
            if (rd_vld) begin
                if (rd_data == 8'hFA) begin
                    next_state = `FSM_STREAM_MOD;
                end
                else begin
                    next_state = `FSM_SEND_RST;
                end
            end
        end
        `FSM_STREAM_MOD: ; // do nothing
        default: begin
            next_state = `FSM_IDLE;
        end
    endcase
end

// State Register
always_ff @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        current_state <= `FSM_IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

//================= Output to ps2_tx/rx =================//
// write enable control
always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        wr_en <= 1'b0;
        waiting_wr_done <= 1'b0;
    end
    else begin
        if (current_state == `FSM_SEND_RST) begin
            wr_en <= ~waiting_wr_done;
            waiting_wr_done <= 1'b1;
        end
        else begin
            wr_en <= 1'b0;
            waiting_wr_done <= 1'b0;
        end
    end
end

always @(posedge clk_sys) begin
    wr_data <= 8'hFF;
end

always @(posedge clk_sys) begin
    rd_en <= (current_state == `FSM_SEND_RST) ? 1'b0 : 1'b1;
end

always @(posedge clk_sys) begin
    init_done <= (current_state == `FSM_STREAM_MOD) ? 1'b1 : 1'b0;
end

//================= Output to seg7 =================//
// byte counter
always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        byte_cnt <= 2'b00;
    end
    else begin
        if ((current_state == `FSM_STREAM_MOD) &&
            (rd_vld == 1'b1)) begin
            byte_cnt <= (byte_cnt == 2'b10) ? 2'b00 : byte_cnt + 2'b01;
        end
        else begin
            byte_cnt <= 2'b00;
        end
    end
end

always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        ps2pkt_vlk <= 1'b0;
    end
    else begin
        if ((current_state == `FSM_STREAM_MOD) &&
            (rd_vld == 1'b1) &&
            (byte_cnt == 2'b10)) begin
            ps2pkt_vlk <= 1'b1;
        end
        else begin
            ps2pkt_vlk <= 1'b0;
        end
    end
end

always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        ps2pkt_data <= 24'b0;
    end
    else begin
        if ((current_state == `FSM_STREAM_MOD) &&
            (rd_vld == 1'b1)) begin
            case (byte_cnt)
                2'b00: ps2pkt_data[7:0]    <= rd_data;
                2'b01: ps2pkt_data[15:8]   <= rd_data;
                2'b10: ps2pkt_data[23:16]  <= rd_data;
                default;
            endcase
        end
        else begin
            ps2pkt_data <= 24'h000000;
        end
    end
end


endmodule
