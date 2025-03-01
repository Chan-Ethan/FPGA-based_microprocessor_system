module ROM(
    //standard signals
    input CLK,
    //BUS signals
    output reg [7:0] DATA,
    input [7:0] ADDR
    );
    
    parameter RAMAddrWidth = 8;
    
    //Memory
    reg [7:0] rom [2**RAMAddrWidth-1:0];
    
    // Load program
    initial $readmemh("../../../program/Read_Mouse.txt", rom);
    
    //single port ram
    always@(posedge CLK)
        DATA <= rom[ADDR];
    
endmodule
