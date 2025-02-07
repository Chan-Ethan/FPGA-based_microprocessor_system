module seg7_control(
    input                   clk_sys         , // 50MHz system clock
    input                   rst_n           , // reset signal
    
    // from ps2_rx
    (* mark_debug = "true" *) input                   ps2pkg_vlk    ,
    (* mark_debug = "true" *) input       [23:0]      ps2pkg_data   ,   

    // seven segment display
    output  reg [3:0]       SEG_SELECT_OUT  ,
    output  reg [7:0]       HEX_OUT         ,
    
    // Button status link to LED
    output  reg             L_button        , // Left button
    output  reg             R_button          // Right button
);

`ifdef SIMULATION
    // use smaller number for faster simulation
    `define CNT_NUM_200HZ 26'd499
    `define CNT_NUM_1HZ   8'd49
`else
    `define CNT_NUM_200HZ 26'd249999
    `define CNT_NUM_1HZ   8'd199
`endif

logic   [1:0]   seg_select;
logic   [1:0]   seg_select_in;
logic   [1:0]   seg_select_dly;
logic   [3:0]   bin;
logic           dot;

logic           clk_200hz;  // 200Hz signal, for 7-segment display refresh
logic   [17:0]  clk_200hz_cnt;

logic           clk_1hz;    // 1Hz signal, for display content update
logic   [7:0]   clk_1hz_cnt;
logic           rd_data_update_rdy; // ready to update the display content (every 1 second)
logic   [7:0]   x_move, y_move;     // x and y movement
logic           x_neg, y_neg;        // x and y movement direction
logic           x_ovf, y_ovf;        // x and y movement overflow


//================= 200Hz signal generation =================//
always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        clk_200hz_cnt <= 26'b0;
    end
    else begin
        if (clk_200hz_cnt == `CNT_NUM_200HZ) begin
            clk_200hz_cnt <= 26'b0;
        end
        else begin
            clk_200hz_cnt <= clk_200hz_cnt + 26'd1;
        end
    end
end

always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        clk_200hz <= 1'b0;
    end
    else begin
        if (clk_200hz_cnt == `CNT_NUM_200HZ) begin
            clk_200hz <= 1'b1;
        end
        else begin
            clk_200hz <= 1'b0;
        end
    end
end

//================= 1Hz signal generation =================//
always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        clk_1hz_cnt <= 8'b0;
    end
    else if (clk_200hz == 1'b1) begin
        if (clk_1hz_cnt == `CNT_NUM_1HZ) begin
            clk_1hz_cnt <= 8'b0;
        end
        else begin
            clk_1hz_cnt <= clk_1hz_cnt + 8'd1;
        end
    end
    else;
end

always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        clk_1hz <= 1'b0;
    end
    else if (clk_200hz == 1'b1) begin
        if (clk_1hz_cnt == `CNT_NUM_1HZ) begin
            clk_1hz <= 1'b1;
        end
        else begin
            clk_1hz <= 1'b0;
        end
    end
    else;
end

//================= PS/2 packet latch =================//
always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        rd_data_update_rdy <= 1'b0;
    end
    else if ((ps2pkg_vlk == 1'b1) && 
             (rd_data_update_rdy == 1'b1)) begin
        rd_data_update_rdy <= 1'b0;
    end
    else if (clk_1hz) begin
        rd_data_update_rdy <= 1'b1;
    end
    else;
end

always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        x_move <= 8'b0;
        y_move <= 8'b0;
        x_neg <= 1'b0;
        y_neg <= 1'b0;
        x_ovf <= 1'b0;
        y_ovf <= 1'b0;
    end
    else if ((ps2pkg_vlk == 1'b1) && 
             (rd_data_update_rdy == 1'b1)) begin
        x_move <= ps2pkg_data[15:8];
        y_move <= ps2pkg_data[23:16];
        x_neg <= ps2pkg_data[4];
        y_neg <= ps2pkg_data[5];
        x_ovf <= ps2pkg_data[6];
        y_ovf <= ps2pkg_data[7];
    end
    else;
end

//================= 7-segment display control =================//
// traverse 4 seven segment
always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        seg_select <= 2'b00;
    end
    else if (clk_200hz) begin
        seg_select <= seg_select + 1;
    end
    else;
end

always @(posedge clk_sys) begin
    seg_select_in <= seg_select;
end

always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        bin <= 4'b0000;
        dot <= 1'b0;
    end
    else begin
        case (seg_select)
            2'b00: begin
                bin <= y_move[3:0];
                dot <= y_ovf;
            end
            2'b01: begin
                bin <= y_move[7:4];
                dot <= y_neg;
            end
            2'b10: begin
                bin <= x_move[3:0];
                dot <= x_ovf;
            end
            2'b11: begin
                bin <= x_move[7:4];
                dot <= x_neg;
            end
            default;
        endcase
    end
end

// instantiate the seven segment decoder
seg7decoder seg7decoder_inst(
    .SEG_SELECT_IN      (seg_select_in  ),
    .BIN_IN             (bin            ),
    .DOT_IN             (dot            ),
    .SEG_SELECT_OUT     (SEG_SELECT_OUT ),
    .HEX_OUT            (HEX_OUT        )
);

//================= Button status link to LED =================//
always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        L_button <= 1'b0;
    end
    else if (ps2pkg_vlk == 1'b1) begin
        // if the left button is pressed, set L_button to 1
        // the status is latched for one second
        L_button <= ps2pkg_data[0] | L_button;
    end
    else if ((ps2pkg_vlk == 1'b1) && 
             (rd_data_update_rdy == 1'b1) &&
             (ps2pkg_data[0] == 1'b0)) begin
        // if the left button is released after one second, clear L_button
        L_button <= 1'b0;
    end
    else;
end

always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        R_button <= 1'b0;
    end
    else if (ps2pkg_vlk == 1'b1) begin
        // if the right button is pressed, set R_button to 1
        // the status is latched for one second
        R_button <= ps2pkg_data[1] | R_button;
    end
    else if ((ps2pkg_vlk == 1'b1) && 
             (rd_data_update_rdy == 1'b1) &&
             (ps2pkg_data[1] == 1'b0)) begin
        // if the right button is released after one second, clear R_button
        R_button <= 1'b0;
    end
    else;
end

endmodule
