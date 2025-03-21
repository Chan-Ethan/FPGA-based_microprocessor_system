module Counter10Hz(
    input           CLK,        // 100MHz clock
    input           RESETN,
    
    output reg      CLK_10HZ
);

`ifdef SIMULATION
    localparam [23:0] CNT_NUM = 24'd499999; // 2,000,000 cycles to get 50Hz from 100MHz
`else
    localparam [23:0] CNT_NUM = 24'd4999999; // 10,000,000 cycles to get 10Hz from 100MHz
`endif

// Internal signals
logic [23:0]      cnt;        // Counter for clock division

//================= Counter Logic =================//
always_ff @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        cnt <= 24'd0;
        CLK_10HZ <= 1'b0;
    end
    else begin
        if (cnt == CNT_NUM) begin
            cnt <= 24'd0;
            CLK_10HZ <= 1'b1;  // Generate 1-cycle pulse
        end
        else begin
            cnt <= cnt + 24'd1;
            CLK_10HZ <= 1'b0;
        end
    end
end

endmodule
