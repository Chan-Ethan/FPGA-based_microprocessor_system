// calculate the mouse position using the mouse direction data

module MousePosCal(
    // clock and reset input
    input               CLK,
    input               RESET,

    // Mouse data information
    input   [7:0]       MOUSE_STATUS,   // YV, XV, YS, XS, 1, 0, R, L
    input   [7:0]       MOUSE_DX,
    input   [7:0]       MOUSE_DY

    input               INTERRUPT,

    // Mouse position
    output  reg [7:0]   MOUSE_POS_X,
    output  reg [7:0]   MOUSE_POS_Y
);

`define MOUSE_X_MAX 8'd160
`define MOUSE_Y_MAX 8'd120

logic   [7:0]   next_pos_x, next_pos_y;
logic           interrupt_1dly; // 1 cycle delay of INTERRUPT
logic           pos_update;     // update mouse position at posedge of INTERRUPT


always @(posedge CLK) begin
    interrupt_1dly <= INTERRUPT;
end

// detect the posedge of INTERRUPT
always @(posedge CLK or negedge RESET) begin
    if (!RESET) begin
        pos_update <= 1'b0;
    end
    else begin
        pos_update <= (interrupt_1dly == 1'b0) && (INTERRUPT == 1'b1);
    end
end

// calculate the mouse position
always @(posedge CLK or negedge RESET) begin
    if (!RESET) begin
        next_pos_x <= 8'd0;
        next_pos_y <= 8'd0;
    end
    else if (pos_update) begin
        next_pos_x <= MOUSE_POS_X + MOUSE_DX;
        next_pos_y <= MOUSE_POS_Y + MOUSE_DY;
    end
    else begin
        next_pos_x <= MOUSE_POS_X;
        next_pos_y <= MOUSE_POS_Y;
    end
end

always @(posedge CLK or negedge RESET) begin
    if (!RESET) begin
        MOUSE_POS_X <= 8'd0;
        MOUSE_POS_Y <= 8'd0;
    end
    else begin
        if (next_pos_x > `MOUSE_X_MAX) begin
            MOUSE_POS_X <= (MOUSE_STATUS[4] == 1'b0) ? `MOUSE_X_MAX : 8'd0;
        end
        else begin
            MOUSE_POS_X <= next_pos_x;
        end

        if (next_pos_y > `MOUSE_Y_MAX) begin
            MOUSE_POS_Y <= (MOUSE_STATUS[5] == 1'b0) ? `MOUSE_Y_MAX : 8'd0;
        end
        else begin
            MOUSE_POS_Y <= next_pos_y;
        end
    end
end

endmodule