`timescale 1ns / 1ps

module VGA_Sig_Gen(
    input CLK,                   // system clock 100MHz
    input [15:0] CONFIG_COLOURS, // Configuration interface
    output DPR_CLK,              // 25MHz clock to drive VGA
    output [14:0] VGA_ADDR,      // Address to read from frame buffer 
    input [7:0] VGA_DATA,        // Pixel data coming from memory depending on VGA_ADDR
    output reg VGA_HS,           // Horizontal sync signal
    output reg VGA_VS,           // Vertical sync signal
    output [7:0] VGA_COLOUR,     // VGA output color to display
    output [9:0] H_Counter1,      //for simulation purposes(COMMENT IT OUT WHILE IMPLEMENTING ON FPGA)//////////////////////////////////////
    output [9:0] V_Counter1       //for simulation purposes(COMMENT IT OUT WHILE IMPLEMENTING ON FPGA)//////////////////////////////////////
);

// Parameters for VGA timings
parameter HTs = 800;  // Total horizontal time
parameter HTpw = 96;  // Horizontal pulse width
parameter HTDisp = 640; // Horizontal display time
parameter Hbp = 48;    // Horizontal back porch
parameter Hfp = 16;    // Horizontal front porch

parameter VTs = 521;  // Total vertical time
parameter VTpw = 2;   // Vertical pulse width
parameter VTDisp = 480; // Vertical display time
parameter Vbp = 29;   // Vertical back porch
parameter Vfp = 10;   // Vertical front porch

// clock divider module for 25 MHz(div_value=1 determined from Fin/(2Fout)-1)
clock_divider #( .div_value(1) ) clk_div_inst (
    .clk(CLK),
    .divided_clk(DPR_CLK)
);

// corizontal and Vertical counters used in counter module
wire [9:0] h_count;
wire [9:0] v_count;
// wires to connect 2 counters so that v_count counts when h_count reaches to the maximum value 
wire h_trig;
wire v_trig;

//horizontal counter, counts up to 800, 10 bits are used to fully cover 800.
Counter #(10, HTs - 1) h_counter (
    .Reset(1'b0),//no reset needed
    .CLK(DPR_CLK),//use DPR_CLK(25MHz to synchronise it with VGA) 
    .ENABLE_IN(1'b1),//always count
    .COUNT(h_count),//connect counter wire to the output
    .TRIG_OUT(h_trig)//connect trigger wire to the output
);
//vertical counter, counts up to 521, 10 bits are used to fully cover 521.
Counter #(10, VTs - 1) v_counter (
    .Reset(1'b0),//no reset needed
    .CLK(h_trig), // change clock to h_trig to count per line
    .ENABLE_IN(1'b1),//always count
    .COUNT(v_count),//connect counter wire to the output
    .TRIG_OUT(v_trig)//connect trigger wire to the output
);

// generate horizontal sync (active low during sync pulse)
always @(posedge DPR_CLK) begin
    VGA_HS <= (h_count < HTpw) ? 1'b0 : 1'b1;
end

// generate vertical sync (active low during sync pulse)
always @(posedge DPR_CLK) begin
    VGA_VS <= (v_count < VTpw) ? 1'b0 : 1'b1;
end

// generate pixel address for the frame buffer
wire [9:0] h_disp_offset = h_count - HDisplayRegionStart;
wire [8:0] v_disp_offset = v_count - VDisplayRegionStart;

reg [14:0] addr_reg;
assign VGA_ADDR = addr_reg;

always @(posedge DPR_CLK) begin
    if ((h_count >= HDisplayRegionStart && h_count < HDisplayRegionEnd) &&
        (v_count >= VDisplayRegionStart && v_count < VDisplayRegionEnd)) begin

        // Ensure offset doesn't exceed bounds
        addr_reg <= {v_disp_offset[8:2], h_disp_offset[9:2]};
    end else begin
        // Assign safe value when outside display region
        addr_reg <= 15'd0; // or 15'h7FFF if you'd prefer a "black pixel" address
    end
end


assign H_Counter1=h_count[9:0]; //for simulation purposes(COMMENT IT OUT WHILE IMPLEMENTING ON FPGA)///////////////////////////////////
assign V_Counter1=v_count[9:0]; //for simulation purposes(COMMENT IT OUT WHILE IMPLEMENTING ON FPGA)/////////////////////////////////

//parameters for display boundaries
parameter HDisplayRegionStart = HTpw + Hbp;
parameter HDisplayRegionEnd = HDisplayRegionStart + HTDisp;
parameter VDisplayRegionStart = VTpw + Vbp;
parameter VDisplayRegionEnd = VDisplayRegionStart + VTDisp;
    
// output the pixel color from the frame buffer
assign VGA_COLOUR = ((h_count >= HDisplayRegionStart && h_count < HDisplayRegionEnd) &&
                     (v_count >= VDisplayRegionStart && v_count < VDisplayRegionEnd)) ? VGA_DATA : 8'b0;

endmodule
