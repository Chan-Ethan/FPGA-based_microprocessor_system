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
    // ps2_if   output_if(clk, rst_n);

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
    top top (
        .CLK100_IN          (clk_100M           ),
        .HARD_RST           (~rst_n             ), // tmp, connect to a high buttom

        .PS2_CLK            (PS2_CLK            ),
        .PS2_DATA           (PS2_DATA           ),

        .SEG_SELECT_OUT     (SEG_SELECT_OUT     ),
        .HEX_OUT            (HEX_OUT            ),

        .LED                (                   )
    );

    initial begin
        run_test();
        $finish();
    end

    initial begin
        // System run timeout
        #10ms;
        $display("\n\nTIMEOUT!\n\n");
        $finish();
    end

    initial begin
        uvm_config_db#(virtual ps2_if)::set(null, "uvm_test_top.env.i_agt.drv", "vif", input_if);
    //     uvm_config_db#(virtual ps2_if)::set(null, "uvm_test_top.env.i_agt.// mon", "vif", input_if);
    //     uvm_config_db#(virtual ps2_if)::set(null, "uvm_test_top.env.o_agt.// mon", "vif", output_if);
    end
endmodule
