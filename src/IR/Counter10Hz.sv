module Counter10Hz(
    input           CLK,        // 100MHz clock
    input           RESETN,
    
    output reg      CLK_10HZ
);

`ifdef SIMULATION
    localparam [31:0] CNT_NUM = 32'd499; // 500 cycles for simulation
`else
    localparam [31:0] CNT_NUM = 32'd4999999; // 5,000,000 cycles to get 10Hz from 50MHz
`endif

// Internal signals
logic [31:0]      cnt;        // Counter for clock division

//================= Counter Logic =================//
always_ff @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        cnt <= 32'd0;
        CLK_10HZ <= 1'b0;
    end
    else begin
        if (cnt == CNT_NUM) begin
            cnt <= 32'd0;
            CLK_10HZ <= 1'b1;  // Generate 1-cycle pulse
        end
        else begin
            cnt <= cnt + 32'd1;
            CLK_10HZ <= 1'b0;
        end
    end
end

endmodule
