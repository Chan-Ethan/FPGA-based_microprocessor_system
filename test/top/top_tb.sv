module top_tb (
    
);
    logic           clk_100M        ; // 100 MHz oscillator clock
    logic           clk_50M         ; // 50 MHz force sys_clk
    logic           rst_n           ;
    
    logic           SEG_SELECT_OUT  ;
    logic           HEX_OUT         ;

    logic           MMCM_LOCKED     ;

    // my_if   input_if(clk, rst_n);
    // my_if   output_if(clk, rst_n);

    initial begin    
        clk_100M = 1'b0;
        rst_n = 1'b0;
        #1us;
        rst_n = 1'b1;

        #100us;
        rst_n = 1'b0;
        $display("rst_n active");
        
        #200us;
        rst_n = 1'b1;
        $display("reset finish");
        
        #500us;
        rst_n = 1'b0;
        #2ms;
        $finish();
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

    top top (
        .CLK100_IN      (clk_100M      ),
        .HARD_RSTN      (rst_n         ),
        .SEG_SELECT_OUT (SEG_SELECT_OUT),
        .HEX_OUT        (HEX_OUT       ),
        .MMCM_LOCKED    (MMCM_LOCKED   )
    );

    // initial begin
    //     run_test();
    //     $finish();
    // end

    // initial begin
    //     uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.// drv", "vif", input_if);
    //     uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.// mon", "vif", input_if);
    //     uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.o_agt.// mon", "vif", output_if);
    // end
endmodule
