// LED[15:8] are controlled by Data Bus
// LED[7:0] are controlled by input signals

module led_ctrl(
    input           CLK,
    input           RESETN,

    //IO - Data Bus
    inout   [7:0]   BUS_DATA,
    input   [7:0]   BUS_ADDR,
    input           BUS_WE,

    // input signals
    input           LOCKED,
    input   [6:0]   current_state,

    // LED output
    output reg  [15:0]  LED
);

//================= Data Bus Interface =================//
// write only, update LED[15:8]
always @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        LED[15:8] <= 8'b0;
    end
    else if ((BUS_WE == 1'b1) && (BUS_ADDR == 8'hC0)) begin
        LED[15:8] <= BUS_DATA;
    end
    else;
end

//================= Other LED Control =================//
always @(posedge CLK) begin
    LED[7:1] <= current_state;
    LED[0] <= LOCKED;
end

endmodule