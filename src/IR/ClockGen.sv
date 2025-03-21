module ClockGen # (
    parameter   CLK_OUT_FREQ = 36_000
)
(
    input           CLK,
    input           RESETN,

    output reg      CLK_OUT
);

localparam  CLK_IN_FREQ = 100_000_000;

// Calculate counter values for different output frequencies
localparam  CNT_36K    = CLK_IN_FREQ / (2 * 36_000) - 1;  // 36kHz output
localparam  CNT_37_5K  = CLK_IN_FREQ / (2 * 37_500) - 1;  // 37.5kHz output
localparam  CNT_40K    = CLK_IN_FREQ / (2 * 40_000) - 1;  // 40kHz output

// Counter register
logic [31:0]      cnt;

// Determine which frequency to use based on parameter
logic [31:0]      div_value;
always_comb begin
    case (CLK_OUT_FREQ)
        37_500:     div_value = CNT_37_5K;
        40_000:     div_value = CNT_40K;
        default:    div_value = CNT_36K;  // Default to 36kHz
    endcase
end

// Clock divider implementation
always_ff @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        cnt <= 32'd0;
        CLK_OUT <= 1'b0;
    end
    else begin
        if (cnt >= div_value) begin
            cnt <= 32'd0;
            CLK_OUT <= ~CLK_OUT;
        end
        else begin
            cnt <= cnt + 32'd1;
        end
    end
end

endmodule
