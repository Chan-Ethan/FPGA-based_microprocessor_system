module top_tb (
    
);
    logic           clk_100M        ; // 100 MHz oscillator clock
    logic           clk_50M         ; // 50 MHz force sys_clk
    logic           rst_n           ;
    
    logic   [3:0]   SEG_SELECT_OUT  ;
    logic   [7:0]   HEX_OUT         ;

    wire            PS2_CLK         ;
    wire            PS2_DATA        ;

    ps2_if   input_if(clk_50M, rst_n);
    bus_if   bus_if(clk_50M, rst_n);
    sw_if    sw_if(clk_50M, rst_n);

    initial begin    
        clk_100M = 1'b0;
        rst_n = 1'b0;
        $display("rst_n active");
        
        #200us;
        rst_n = 1'b1;
        $display("reset finish");
    end

    initial begin
        // $fsdbDumpfile("./fsdb/tb.fsdb");  //记录波形，波形名字testname.fsdb
        $fsdbDumpvars("+all"); 
        $fsdbDumpSVA();
    end

    always begin
        #5ns; clk_100M <= ~clk_100M; // 100 MHz
    end

    initial begin
        clk_50M <= 1'b0;
    end

    always begin
        #10ns; clk_50M <= ~clk_50M;
        force top.clk_sys = clk_50M;
    end


    assign (weak0, weak1) PS2_CLK  = input_if.PS2_CLK ;
    assign (weak0, weak1) PS2_DATA = input_if.PS2_DATA;

    assign bus_if.BUS_DATA = top.BUS_DATA;
    assign bus_if.BUS_ADDR = top.BUS_ADDR;
    assign bus_if.BUS_WE   = top.BUS_WE  ;

    top top (
        .CLK100_IN          (clk_100M           ),
        .HARD_RST           (~rst_n             ), // tmp, connect to a high buttom

        .PS2_CLK            (PS2_CLK            ),
        .PS2_DATA           (PS2_DATA           ),

        .SEG_SELECT_OUT     (SEG_SELECT_OUT     ),
        .HEX_OUT            (HEX_OUT            ),

        .SW                 (sw_if.SW           ),

        .LED                (                   )
    );

    initial begin
        run_test();
        $finish();
    end

    initial begin
        // System run timeout
        #100ms;
        $display("\n\nTIMEOUT!\n\n");
        $finish();
    end

    initial begin
        uvm_config_db#(virtual ps2_if)::set(null, "uvm_test_top.env.i_agt.drv", "vif", input_if);
        uvm_config_db#(virtual bus_if)::set(null, "uvm_test_top.env.bus_agt.mon", "vif", bus_if);
        uvm_config_db#(virtual sw_if)::set(null, "uvm_test_top.env.sw_agt.drv", "vif", sw_if);
    //     uvm_config_db#(virtual ps2_if)::set(null, "uvm_test_top.env.i_agt.// mon", "vif", input_if);
    //     uvm_config_db#(virtual ps2_if)::set(null, "uvm_test_top.env.o_agt.// mon", "vif", output_if);
    end
endmodule
