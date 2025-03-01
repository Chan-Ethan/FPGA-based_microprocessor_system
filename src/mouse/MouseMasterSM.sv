module MouseMasterSM(
input CLK,
input RESET,

//Transmitter Control
(* mark_debug = "true" *) output reg SEND_BYTE,
(* mark_debug = "true" *) output reg [7:0] BYTE_TO_SEND,
(* mark_debug = "true" *) input BYTE_SENT,

//Receiver Control
(* mark_debug = "true" *) output reg READ_ENABLE,
(* mark_debug = "true" *) input [7:0] BYTE_READ,
(* mark_debug = "true" *) input [1:0] BYTE_ERROR_CODE,
(* mark_debug = "true" *) input BYTE_READY,

//Data Registers
(* mark_debug = "true" *) output reg [7:0] MOUSE_DX,
(* mark_debug = "true" *) output reg [7:0] MOUSE_DY,
(* mark_debug = "true" *) output reg [7:0] MOUSE_STATUS,
output reg SEND_INTERRUPT,

// Debug signals
output     [4:0] current_state
);

`define FSM_RESET           7'b0000001
`define FSM_WAIT_ACK        7'b0000010
`define FSM_WAIT_SELFTST    7'b0000100
`define FSM_WAIT_ID         7'b0001000
`define FSM_STAR_STM        7'b0010000
`define FSM_WAIT_ACK2       7'b0100000
`define FSM_STREAM_MOD      7'b1000000

`ifdef SIMULATION
    `define CNT_NUM_10MS    19'd49_999
    `define CNT_NUM_20S     15'd39
`else
    `define CNT_NUM_10MS    19'd499_999
    `define CNT_NUM_20S     15'd1_999
`endif

`define CNT_BYTES       2'b10

(* mark_debug = "true" *) logic [6:0]         current_state, next_state;
(* mark_debug = "true" *) logic               waiting_wr_done;
(* mark_debug = "true" *) logic [1:0]         byte_cnt;
logic [18:0]        cnt_10ms;
// logic [14:0]        cnt_20s;
logic [23:0]        pkt_buffer;

// State Transition Logic
always_comb begin
    next_state = current_state;
    case (current_state)
        `FSM_RESET: begin
            if (BYTE_SENT) next_state = `FSM_WAIT_ACK;
        end
        `FSM_WAIT_ACK: begin
            if (BYTE_READY) begin
                if (BYTE_ERROR_CODE != 2'b00) begin
                    next_state = `FSM_RESET;
                end
                else if (BYTE_READ == 8'hFA || BYTE_READ == 8'hF4) begin
                    next_state = `FSM_WAIT_SELFTST;
                end
                else begin
                    next_state = `FSM_RESET;
                end
            end
            else if (cnt_10ms == `CNT_NUM_10MS) begin
                next_state = `FSM_RESET;
            end
        end
        `FSM_WAIT_SELFTST: begin
            if (BYTE_READY) begin
                if (BYTE_ERROR_CODE != 2'b00) begin
                    next_state = `FSM_RESET;
                end
                else if (BYTE_READ == 8'hAA) begin
                    next_state = `FSM_WAIT_ID;
                end
                else begin
                    next_state = `FSM_RESET;
                end
            end
            else;
        end
        `FSM_WAIT_ID: begin
            if (BYTE_READY) begin
                if (BYTE_ERROR_CODE != 2'b00) begin
                    next_state = `FSM_RESET;
                end
                else if (BYTE_READ == 8'h00) begin
                    next_state = `FSM_STAR_STM;
                end
                else begin
                    next_state = `FSM_RESET;
                end
            end
            else;
        end
        `FSM_STAR_STM: begin
            if (BYTE_SENT) next_state = `FSM_WAIT_ACK2;
        end
        `FSM_WAIT_ACK2: begin
            if (BYTE_READY) begin
                if (BYTE_ERROR_CODE != 2'b00) begin
                    next_state = `FSM_RESET;
                end
                else if (BYTE_READ == 8'hFA || BYTE_READ == 8'hF4) begin
                    next_state = `FSM_STREAM_MOD;
                end
                else begin
                    next_state = `FSM_RESET;
                end
            end
            else if (cnt_10ms == `CNT_NUM_10MS) begin
                next_state = `FSM_RESET;
            end
        end
        `FSM_STREAM_MOD: begin
            // do nothing
            if ((BYTE_READY == 1'b1) && (BYTE_ERROR_CODE != 2'b00)) begin
                next_state = `FSM_RESET;
            end
            else;
        end
        default: next_state = `FSM_RESET;
    endcase
end

// State Register
always_ff @(posedge CLK or negedge RESET) begin
    if (!RESET) current_state <= `FSM_RESET;
    else current_state <= next_state;
end

//================= Counters =================//
always_ff @(posedge CLK or negedge RESET) begin
    if (!RESET) begin
        cnt_10ms <= 19'd0;
    end
    else begin
        cnt_10ms <= (cnt_10ms == `CNT_NUM_10MS) ? 19'd0 : cnt_10ms + 19'd1;
    end
end

// always_ff @(posedge CLK or negedge RESET) begin
//     if (!RESET) cnt_20s <= 15'd0;
//     else if (current_state == `FSM_STREAM_MOD) begin
//         if (BYTE_READY) cnt_20s <= 15'd0;
//         else if (cnt_10ms == `CNT_NUM_10MS) begin
//             cnt_20s <= (cnt_20s == `CNT_NUM_20S) ? 15'd0 : cnt_20s + 15'd1;
//         end
//     end
//     else cnt_20s <= 15'd0;
// end

//================= Transmitter Control =================//
always_ff @(posedge CLK or negedge RESET) begin
    if (!RESET) begin
        SEND_BYTE <= 1'b0;
        waiting_wr_done <= 1'b0;
    end else begin
        if ((current_state == `FSM_STAR_STM) || (current_state == `FSM_RESET)) begin
            SEND_BYTE <= ~waiting_wr_done;
            waiting_wr_done <= 1'b1;
        end else begin
            SEND_BYTE <= 1'b0;
            waiting_wr_done <= 1'b0;
        end
    end
end

always@(posedge CLK or negedge RESET) begin
    if (!RESET) begin
        BYTE_TO_SEND <= 8'hFF;
    end
    else begin
        BYTE_TO_SEND <= (current_state == `FSM_STAR_STM) ? 8'hF4 : 8'hFF;
    end
end 

//================= Receiver Control =================//
always @(posedge CLK or negedge RESET) begin
    if (!RESET) begin
        READ_ENABLE <= 1'b0;
    end
    else begin
        READ_ENABLE <= (current_state != `FSM_RESET) && (current_state != `FSM_STAR_STM);
    end
end 

//================= Data Packing =================//
always_ff @(posedge CLK or negedge RESET) begin
    if (!RESET) begin
        pkt_buffer <= 24'b0;
    end
    else if (current_state == `FSM_STREAM_MOD) begin
        if (BYTE_READY == 1'b1) begin
            case (byte_cnt)
                2'b00: pkt_buffer[7:0] <= BYTE_READ;
                2'b01: pkt_buffer[15:8] <= BYTE_READ;
                2'b10: pkt_buffer[23:16] <= BYTE_READ;
                default: ;
            endcase
        end
        else;
    end
    else begin
        pkt_buffer <= 24'b0;
    end
end

always @(posedge CLK or negedge RESET) begin
    if (!RESET) begin
        byte_cnt <= 2'b00;
    end
    else if ((current_state == `FSM_STREAM_MOD) || (current_state == `FSM_WAIT_ACK)) begin
        if (BYTE_READY == 1'b1) begin
            byte_cnt <= (byte_cnt == `CNT_BYTES) ? 2'b00 : byte_cnt + 2'b01;
        end
        else;
    end
    else begin
        byte_cnt <= 2'b00;
    end

end


//================= Output Registers =================//
assign MOUSE_STATUS = pkt_buffer[7:0];
assign MOUSE_DX = pkt_buffer[15:8];
assign MOUSE_DY = pkt_buffer[23:16];
// assign SEND_INTERRUPT = (current_state == `FSM_STREAM_MOD) && BYTE_READY && (byte_cnt == `CNT_BYTES);
assign SEND_INTERRUPT = 1'b0;

endmodule
