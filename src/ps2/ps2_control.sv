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
    output reg              ps2pkt_vld      ,
    output reg  [23:0]      ps2pkt_data     ,

    // device status debug signal
    output reg              init_done       ,
    output      [4:0]       current_state   
);

`define FSM_RESET       5'b00001
`define FSM_WAIT_ACK    5'b00010
`define FSM_STAR_STM    5'b00100
`define FSM_WAIT_ACK2   5'b01000
`define FSM_STREAM_MOD  5'b10000

`ifdef SIMULATION
    // for faster simulation
    `define CNT_NUM_1MS     16'd4999
    `define CNT_NUM_20S     15'd39
`else
    `define CNT_NUM_1MS     16'd49_999
    `define CNT_NUM_20S     15'd19_999
`endif

`define CNT_BYTES       2'b10

// current_state FSM variable
logic   [4:0]       current_state, next_state;

logic               waiting_wr_done;
logic   [1:0]       byte_cnt; // from 0 to 2
logic   [15:0]      cnt_1ms;  // 1ms counter, 50MHz * 1ms = 50_000 cycles
logic   [14:0]      cnt_20s;   // 20s counter = 1ms counter * 20_000


//================= State Machine =================//
// State Transition Logic
always_comb begin
    next_state = current_state;
    case (current_state)
        `FSM_RESET: begin
            if (wr_done) begin
                next_state = `FSM_WAIT_ACK;
            end
        end
        `FSM_WAIT_ACK: begin
            // wait for device to ack
            // return to FSM_RESET if waiting time is too long (1ms)
            // if (rd_vld) begin
            //     if ((rd_data == 8'hFA) || (rd_data == 8'hF4)) begin
            //         next_state = `FSM_STAR_STM;
            //     end
            // end
            if (byte_cnt == 2'd2) begin
                next_state = `FSM_STAR_STM;
            end
            else if (cnt_1ms == `CNT_NUM_1MS) begin
                next_state = `FSM_RESET;
            end
        end
        `FSM_STAR_STM: begin
            // start streaming mode
            if (wr_done) begin
                next_state = `FSM_WAIT_ACK2;
            end
        end
        `FSM_WAIT_ACK2: begin
            // wait for device to ack
            // return to FSM_RESET if waiting time is too long (1ms)
            if (rd_vld) begin
                if ((rd_data == 8'hFA) || (rd_data == 8'hF4)) begin
                    next_state = `FSM_STREAM_MOD;
                end
            end
            else if (cnt_1ms == `CNT_NUM_1MS) begin
                next_state = `FSM_RESET;
            end
        end
        `FSM_STREAM_MOD: begin
            // streaming mode
            // return to FSM_RESET if no data is received in 1s
            if (cnt_20s == `CNT_NUM_20S) begin
                next_state = `FSM_RESET;
            end
        end
        default: begin
            next_state = `FSM_RESET;
        end
    endcase
end

// State Register
always_ff @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        current_state <= `FSM_RESET;
    end
    else begin
        current_state <= next_state;
    end
end

//================= scounter =================//
always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        cnt_1ms <= 16'd0;
    end
    else if ((current_state == `FSM_WAIT_ACK) ||
             (current_state == `FSM_STREAM_MOD)) begin
        cnt_1ms <= (cnt_1ms == `CNT_NUM_1MS) ? 16'd0 : cnt_1ms + 16'd1;
    end
    else begin
        cnt_1ms <= 16'd0;
    end
end

always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        cnt_20s <= 15'd0;
    end
    else if (current_state == `FSM_STREAM_MOD) begin
        if (rd_vld) begin
            cnt_20s <= 15'd0;
        end
        else if (cnt_1ms == `CNT_NUM_1MS) begin
            cnt_20s <= (cnt_20s == `CNT_NUM_20S) ? 15'd0 : cnt_20s + 15'd1;
        end
        else;
    end
    else begin
        cnt_20s <= 15'd0;
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
        if ((current_state == `FSM_RESET) || 
            (current_state == `FSM_STAR_STM)) begin
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
    wr_data <= (current_state == `FSM_STAR_STM) ? 8'hF4: 8'hFF;
end

always @(posedge clk_sys) begin
    rd_en <= (current_state == `FSM_RESET) ? 1'b0 : 1'b1;
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
    // else if ((current_state == `FSM_STREAM_MOD) &&
    //          (rd_vld == 1'b1)) begin
    else if (((current_state == `FSM_STREAM_MOD) ||
              (current_state == `FSM_WAIT_ACK)) &&
             (rd_vld == 1'b1)) begin
        byte_cnt <= (byte_cnt == `CNT_BYTES) ? 2'b00 : byte_cnt + 2'b01;
    end
end

always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        ps2pkt_vld <= 1'b0;
    end
    else begin
        if ((current_state == `FSM_STREAM_MOD) &&
            (rd_vld == 1'b1) &&
            (byte_cnt == `CNT_BYTES)) begin
            ps2pkt_vld <= 1'b1;
        end
        else begin
            ps2pkt_vld <= 1'b0;
        end
    end
end

always @(posedge clk_sys or negedge rst_n) begin
    if (~rst_n) begin
        ps2pkt_data <= 24'b0;
    end
    else if ((current_state == `FSM_STREAM_MOD) &&
             (rd_vld == 1'b1)) begin
        case (byte_cnt)
            2'b00: ps2pkt_data[7:0]    <= rd_data;
            2'b01: ps2pkt_data[15:8]   <= rd_data;
            2'b10: ps2pkt_data[23:16]  <= rd_data;
            default;
        endcase
    end
end


endmodule
