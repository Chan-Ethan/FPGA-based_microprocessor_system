module VGA_Bus(
    input CLK,             // System clock
    input RESET,           // Reset signal

    // Processor Bus Signals
    input [7:0] ADDR,      // Address bus (from CPU)
    input [7:0] DATA,      // Data bus (from CPU)
    input BUS_WE,          // Write Enable (active when writing to VGA registers)

    // VGA Output
    output [7:0] VGA_COLOUR,
    output VGA_HS,
    output VGA_VS
);

    // Internal Registers
    reg [7:0] X_REG = 0;       // Stores X-coordinate
    reg [7:0] Y_REG = 0;       // Stores Y-coordinate
    reg [7:0] PIXEL_DATA = 0;  // Stores pixel color or on/off state

    // Frame Buffer Signals
    reg [14:0] BUFFER_ADDR;    // Pixel address for the frame buffer
    reg [7:0] BUFFER_DATA;     // Data to be written to the frame buffer
    reg BUFFER_WE;             // Write Enable for the frame buffer

    wire [14:0] VGA_READ_ADDR;  // Read address for VGA
    wire [7:0] VGA_READ_DATA;   // Data from frame buffer

    // State Machine Parameters
    parameter [7:0] WAIT_FOR_X  = 8'h00;
    parameter [7:0] WAIT_FOR_Y  = 8'h01;
    parameter [7:0] WAIT_FOR_PIXEL  = 8'h02;

    reg [7:0] STATE;  // Current state register
    wire DPR_CLK;  // VGA clock (25MHz)

    reg [6:0] Y_REG_INV; // Y_REG_INV = 120 - Y_REG

    // Instantiate Frame Buffer (Stores pixel data)
    Frame_Buffer FrameBuffer (
        .A_CLK(CLK), 
        .A_ADDR(BUFFER_ADDR), 
        .A_DATA_IN(BUFFER_DATA), 
        .A_WE(BUFFER_WE), 
        .B_CLK(DPR_CLK), 
        .B_ADDR(VGA_READ_ADDR), 
        .B_DATA(VGA_READ_DATA)
    );

    // VGA Signal Generator (Handles VGA output)
    VGA_Sig_Gen SignalGenerator (
        .CLK(CLK), 
        .CONFIG_COLOURS(16'hFFFF),
        .DPR_CLK(DPR_CLK), 
        .VGA_ADDR(VGA_READ_ADDR), 
        .VGA_DATA(VGA_READ_DATA), 
        .VGA_HS(VGA_HS), 
        .VGA_VS(VGA_VS), 
        .VGA_COLOUR(VGA_COLOUR)
    );

    // Invert Y-coordinate
    always @(posedge CLK) begin
        if (RESET) begin
            Y_REG_INV <= 7'd0;
        end else begin
            Y_REG_INV <= 7'd120 - Y_REG;
        end
    end

    // State Machine Logic
    always @(posedge CLK) begin
        if (RESET) begin
            X_REG <= 0;
            Y_REG <= 0;
            PIXEL_DATA <= 0;
            BUFFER_WE <= 0;
            STATE <= WAIT_FOR_X;
        end else if (BUS_WE) begin
            case (STATE)
                // Step 1: Waiting for X Address
                WAIT_FOR_X: begin
                    if (ADDR == 8'hB0) begin
                        X_REG <= DATA;  // Store X-coordinate
                        STATE <= WAIT_FOR_Y;
                    end
                end

                // Step 2: Waiting for Y Address
                WAIT_FOR_Y: begin
                    if (ADDR == 8'hB1) begin
                        Y_REG <= DATA;  // Store Y-coordinate
                        STATE <= WAIT_FOR_PIXEL;
                    end
                end

                // Step 3: Detect Pixel and Write
                WAIT_FOR_PIXEL: begin
                    if (ADDR == 8'hB2) begin
                        BUFFER_ADDR <= {Y_REG_INV, X_REG}; // Compute Frame Buffer Address
                        BUFFER_DATA <= DATA;   // Store Pixel Data
                        BUFFER_WE   <= 1'b1;   // Enable Write
                        STATE       <= WAIT_FOR_X; // Go back to waiting for X
                    end
                end
            endcase
        end else begin
            BUFFER_WE <= 1'b0;  // Default to no write when not writing pixel
        end
    end

endmodule
