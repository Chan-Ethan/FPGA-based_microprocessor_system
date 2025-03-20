module IRTransmitterSM (
    // 标准信号
    input               RESETN,         // 复位信号
    input               CLK,            // 时钟信号
    // 总线接口信号 
    input       [3:0]   COMMAND,        // 4位命令信号，控制方向
    input               SEND_PACKET,    // 发送触发信号

    // IF LED signal
    output  reg         IR_LED 
);

/*
Generate the pulse signal here from the main clock running at 50MHz to generate the right frequency for
the car in question e.g. 40KHz for BLUE coded cars
*/
// ………………..
// FILL IN THIS AREA
// ……………….

/*
Simple state machine to generate the states of the packet i.e. Start, Gaps, Right Assert or De-Assert, Left
Assert or De-Assert, Backward Assert or De-Assert, and Forward Assert or De-Assert
*/
// ………………..
// FILL IN THIS AREA
// ……………….

// Finally, tie the pulse generator with the packet state to generate IR_LED
// ………………..
// FILL IN THIS AREA
// ……………….

endmodule