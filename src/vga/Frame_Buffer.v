module Frame_Buffer(
    //Input/Outputs for Port A - Read/Write 
    input A_CLK,                 
    input [14:0] A_ADDR,//Memory which the data will be written       
    input [7:0] A_DATA_IN, //Data to be written into memory      
    output reg [7:0] A_DATA_OUT, 
    input A_WE,  //Write enable signal               

    // Port B - Read Only 
    input B_CLK,                 
    input [14:0] B_ADDR,//Memory which the data will be read from          
    output reg [7:0] B_DATA//Data read from memory        
);

    // Creating memory: 15 bit memory to contain every address  2^15-1=32767
    reg [0:0] memory [0:32767];  // ON/OFF 1 BIT

    // Port A: Write or Read
    always @(posedge A_CLK) begin
        if (A_WE) begin//If enable signal high--->write
            memory[A_ADDR] <= A_DATA_IN;  // Write pixel color to the memory
        end
        A_DATA_OUT <= memory[A_ADDR];    // Output pixel data
    end

    // Port B: Read Only
    always @(posedge B_CLK) begin//Always read(no if condition)
        B_DATA <= memory[B_ADDR];        // Read pixel data for VGA display
    end

endmodule
