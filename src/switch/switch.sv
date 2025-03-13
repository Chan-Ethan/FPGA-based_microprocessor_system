// 16 slide switches
// Base address: 0xE0

module switch (
    // clock and reset input
    input           CLK,        // 50 MHz
    input           RESETN,     // Active low

    // I - Switches input
    input   [15:0]  SW,

    // IO - Data Bus
    inout   [7:0]   BUS_DATA,
    input   [7:0]   BUS_ADDR,
    input           BUS_WE,

    // interrupt signals
    output reg      SEND_INTERRUPT,
    input           INTERRUPT_ACK
);

// count 20 ms
`ifdef SIMULATION
    localparam [19:0] CNT_NUM = 999;
`else
    localparam [19:0] CNT_NUM = 999_999;
`endif

logic           bus_rd_en;
logic   [7:0]   bus_rd_data;

logic   [19:0]  cnt;

logic   [15:0]  SW_q1;  // SW delayed by 1 clock cycle
logic   [15:0]  SW_q2;  // SW delayed by 2 clock cycle
logic   [15:0]  sw_sync;

//================= Data Bus Interface =================//
always @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        bus_rd_en <= 1'b0;
    end
    else begin
        bus_rd_en <= ((BUS_ADDR == 8'hE0) || 
                      (BUS_ADDR == 8'hE1)) && 
                      (BUS_WE == 1'b0) ? 1'b1 : 1'b0;
    end
end

always @(posedge CLK) begin
    bus_rd_data <=  (BUS_ADDR == 8'hE0) ? sw_sync[15:8] :
                    (BUS_ADDR == 8'hE1) ? sw_sync[7:0]  : 8'b0; 
end

// Read only, ingore BUS_WE signal
assign BUS_DATA =  bus_rd_en ? bus_rd_data : 8'bZ;

//================= Count 10 ms =================//
always @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        cnt <= 0;
    end
    else begin
        if (cnt == CNT_NUM) begin
            cnt <= 0;
        end
        else begin
            cnt <= cnt + 1;
        end
    end
end


//================= Synchronize Switches =================//
// SW_q1 and SW_q2 are used for switch debouncing and signal synchronization
always @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        SW_q1 <= 16'b0;
        SW_q2 <= 16'b0;
    end
    else if (cnt == CNT_NUM) begin
        SW_q1 <= SW;
        SW_q2 <= SW_q1;
    end
    else;
end

always @(posedge CLK) begin
    if (!RESETN) begin
        sw_sync <= 16'b0;
    end
    else begin
        sw_sync <= (SW_q1 == SW_q2) ? SW_q2 : sw_sync;
    end
end

//================= Interrupt Generation =================//
// Generate interrupt when the switches are stable
always @(posedge CLK or negedge RESETN) begin
    if (!RESETN) begin
        SEND_INTERRUPT <= 1'b0;
    end
    else if (INTERRUPT_ACK == 1'b1) begin
        SEND_INTERRUPT <= 1'b0;
    end
    else if ((SW_q1 == SW_q2) & (sw_sync != SW_q2)) begin
        SEND_INTERRUPT <= 1'b1;
    end
    else;
end

endmodule