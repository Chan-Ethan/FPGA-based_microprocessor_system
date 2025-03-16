`timescale 1ns / 1ps

module clock_divider #(parameter div_value = 1)( // Parameterized clock divider
    input wire clk,  // Input clock
    output reg divided_clk = 0 // Output divided clock
);

    integer counter_value = 0; // 32-bit counter register

    always @(posedge clk) begin
        if (counter_value >= div_value) begin //If counter value equal to div_value reset and toogle clock
            counter_value <= 0;
            divided_clk <= ~divided_clk;
        end else begin
            counter_value <= counter_value + 1; // Else increment counter
        end
    end

endmodule
//This way each toggling takes div_value+1 clock cycles. One period means 2 toggling. Therefore new output period=input period x 2(div_val+1).