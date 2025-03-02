module seg7_control(
    input           clk_sys         , // 50MHz system clock
    input           rst_n           , // reset signal
    
    //IO - Data Bus
    inout   [7:0]   BUS_DATA,
    input   [7:0]   BUS_ADDR,
    input           BUS_WE,

    // seven segment display
    output  reg [3:0]       SEG_SELECT_OUT  ,
    output  reg [7:0]       HEX_OUT         
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

logic           clk_200hz;  // 200Hz signal, for 7-segment display refresh
logic   [17:0]  clk_200hz_cnt;

logic   [7:0]   MOUSE_POS_X;
logic   [7:0]   MOUSE_POS_Y;

//================= Data Bus Interface =================//
// write only, update MOUSE_POS_X and MOUSE_POS_Y
always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        MOUSE_POS_X <= 8'd0;
        MOUSE_POS_Y <= 8'd0;
    end
    else if (BUS_WE) begin
        case (BUS_ADDR)
            8'hD0: MOUSE_POS_X <= BUS_DATA;
            8'hD1: MOUSE_POS_Y <= BUS_DATA;
            default;
        endcase
    end
end

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
    end
    else begin
        case (seg_select)
            2'b00: bin <= MOUSE_POS_Y[3:0];
            2'b01: bin <= MOUSE_POS_Y[7:4];
            2'b10: bin <= MOUSE_POS_X[3:0];
            2'b11: bin <= MOUSE_POS_X[7:4];
            default;
        endcase
    end
end

// instantiate the seven segment decoder
seg7decoder seg7decoder_inst(
    .SEG_SELECT_IN      (seg_select_in  ),
    .BIN_IN             (bin            ),
    .DOT_IN             (1'b0           ),
    .SEG_SELECT_OUT     (SEG_SELECT_OUT ),
    .HEX_OUT            (HEX_OUT        )
);

endmodule
