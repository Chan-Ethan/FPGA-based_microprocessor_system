-y /home/Xilinx/Vivado/2015.2/data/verilog/src/unisims
-y /home/Xilinx/Vivado/2015.2/data/verilog/src/unimacro
-y /home/Xilinx/Vivado/2015.2/data/verilog/src/retarget
-y /home/Xilinx/Vivado/2015.2/data/verilog/src/
+libext+.v
/home/Xilinx/Vivado/2015.2/data/verilog/src/unisim_comp.v
// /home/Xilinx/Vivado/2015.2/data/verilog/src/glbl.v
// /home/Xilinx/Vivado/2015.2/data/verilog/src/unisims/BUFG.v
// /home/Xilinx/Vivado/2015.2/data/verilog/src/unisims/IBUF.v
// /home/Xilinx/Vivado/2015.2/data/verilog/src/unisims/MMCME2_ADV.v
// /home/Xilinx/Vivado/2015.2/data/verilog/src/unisims/LUT1.v


// simulation IP
../../sim_model/clk_wiz_0_funcsim.v

// DUT
../../../src/seg7/seg7decoder.v
../../../src/seg7/seg7_control.sv

../../../src/mouse/MouseReceiver.sv
../../../src/mouse/MouseTransmitter.sv
../../../src/mouse/MouseMasterSM.sv
../../../src/mouse/MouseTransceiver.sv
../../../src/mouse/MousePosCal.sv
../../../src/mouse/MouseTop.sv

../../../src/led/led_ctrl.sv

../../../src/mcu/ALU.v
../../../src/mcu/RAM.v
../../../src/mcu/ROM.v
../../../src/mcu/Processor.v

../../../src/timer/Timer.v

../../../src/switch/switch.sv

../../../src/top/top.sv

// UVM platform
../../top/global_events_pkg.svh

../../ps2/ps2_if.sv
../../ps2/ps2_transaction.sv
../../ps2/ps2_nego_sequence.sv
../../ps2/ps2_sequencer.sv
// ../../ps2/ps2_monitor.sv
../../ps2/ps2_driver.sv
../../ps2/ps2_agent.sv

../../bus/bus_if.sv
../../bus/bus_transaction.sv
../../bus/bus_sequence.sv
../../bus/bus_sequencer.sv
 ../../bus/bus_monitor.sv
// ../../bus/bus_driver.sv
../../bus/bus_agent.sv

../../switch/sw_if.sv
../../switch/sw_transaction.sv
../../switch/sw_sequencer.sv
../../switch/sw_driver.sv
../../switch/sw_agent.sv
 
../../model/my_model.sv
../../scoreboard/my_scoreboard.sv
../../env/Env.sv
../../top/base_test.sv
../../top/top_tb.sv
