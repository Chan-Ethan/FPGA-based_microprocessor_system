## Clock Constraints
set_property PACKAGE_PIN W5 [get_ports CLK100_IN]
set_property IOSTANDARD LVCMOS33 [get_ports CLK100_IN]
create_clock -period 10.000 -name clk100 -waveform {0.000 5.000} [get_ports CLK100_IN]

## Reset Constraints
set_property PACKAGE_PIN U18 [get_ports HARD_RSTN]
set_property IOSTANDARD LVCMOS33 [get_ports HARD_RSTN]
## set_property PULLDOWN true [get_ports HARD_RSTN]

## PS/2 Constraints
set_property PACKAGE_PIN C17 [get_ports PS2_CLK]
set_property IOSTANDARD LVCMOS33 [get_ports PS2_CLK]
set_property PULLUP true [get_ports PS2_CLK]
set_property PACKAGE_PIN B17 [get_ports PS2_DATA]
set_property IOSTANDARD LVCMOS33 [get_ports PS2_DATA]
set_property PULLUP true [get_ports PS2_DATA]


## Seven Segment Display Constraints
set_property PACKAGE_PIN U2 [get_ports {SEG_SELECT_OUT[0]}]
set_property PACKAGE_PIN U4 [get_ports {SEG_SELECT_OUT[1]}]
set_property PACKAGE_PIN V4 [get_ports {SEG_SELECT_OUT[2]}]
set_property PACKAGE_PIN W4 [get_ports {SEG_SELECT_OUT[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG_SELECT_OUT[*]}]

set_property PACKAGE_PIN V7 [get_ports {HEX_OUT[7]}]
set_property PACKAGE_PIN U7 [get_ports {HEX_OUT[6]}]
set_property PACKAGE_PIN V5 [get_ports {HEX_OUT[5]}]
set_property PACKAGE_PIN U5 [get_ports {HEX_OUT[4]}]
set_property PACKAGE_PIN V8 [get_ports {HEX_OUT[3]}]
set_property PACKAGE_PIN U8 [get_ports {HEX_OUT[2]}]
set_property PACKAGE_PIN W6 [get_ports {HEX_OUT[1]}]
set_property PACKAGE_PIN W7 [get_ports {HEX_OUT[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HEX_OUT[*]}]

## LED Constraints
## LED15-12
set_property PACKAGE_PIN L1 [get_ports {MOUSE_STATUS_LED[3]}]
set_property PACKAGE_PIN P1 [get_ports {MOUSE_STATUS_LED[2]}]
set_property PACKAGE_PIN N3 [get_ports {MOUSE_STATUS_LED[1]}]
set_property PACKAGE_PIN P3 [get_ports {MOUSE_STATUS_LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {MOUSE_STATUS_LED[*]}]

## LED11-7
set_property PACKAGE_PIN U3 [get_ports {MOUSE_STATE_LED[4]}]
set_property PACKAGE_PIN W3 [get_ports {MOUSE_STATE_LED[3]}]
set_property PACKAGE_PIN V3 [get_ports {MOUSE_STATE_LED[2]}]
set_property PACKAGE_PIN V13 [get_ports {MOUSE_STATE_LED[1]}]
set_property PACKAGE_PIN V14 [get_ports {MOUSE_STATE_LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {MOUSE_STATE_LED[*]}]

## LED0
set_property PACKAGE_PIN U16 [get_ports LED0_LOCKED]
set_property IOSTANDARD LVCMOS33 [get_ports LED0_LOCKED]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_wiz_inst/inst/clk_out1]]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {seg7_control_inst/MOUSE_DX[0]} {seg7_control_inst/MOUSE_DX[1]} {seg7_control_inst/MOUSE_DX[2]} {seg7_control_inst/MOUSE_DX[3]} {seg7_control_inst/MOUSE_DX[4]} {seg7_control_inst/MOUSE_DX[5]} {seg7_control_inst/MOUSE_DX[6]} {seg7_control_inst/MOUSE_DX[7]}]]
create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {seg7_control_inst/MOUSE_DY[0]} {seg7_control_inst/MOUSE_DY[1]} {seg7_control_inst/MOUSE_DY[2]} {seg7_control_inst/MOUSE_DY[3]} {seg7_control_inst/MOUSE_DY[4]} {seg7_control_inst/MOUSE_DY[5]} {seg7_control_inst/MOUSE_DY[6]} {seg7_control_inst/MOUSE_DY[7]}]]
create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {MouseTransceiver_inst/master_sm/BYTE_READ[0]} {MouseTransceiver_inst/master_sm/BYTE_READ[1]} {MouseTransceiver_inst/master_sm/BYTE_READ[2]} {MouseTransceiver_inst/master_sm/BYTE_READ[3]} {MouseTransceiver_inst/master_sm/BYTE_READ[4]} {MouseTransceiver_inst/master_sm/BYTE_READ[5]} {MouseTransceiver_inst/master_sm/BYTE_READ[6]} {MouseTransceiver_inst/master_sm/BYTE_READ[7]}]]
create_debug_port u_ila_0 probe
set_property port_width 24 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {MouseTransceiver_inst/master_sm/pkt_buffer[0]} {MouseTransceiver_inst/master_sm/pkt_buffer[1]} {MouseTransceiver_inst/master_sm/pkt_buffer[2]} {MouseTransceiver_inst/master_sm/pkt_buffer[3]} {MouseTransceiver_inst/master_sm/pkt_buffer[4]} {MouseTransceiver_inst/master_sm/pkt_buffer[5]} {MouseTransceiver_inst/master_sm/pkt_buffer[6]} {MouseTransceiver_inst/master_sm/pkt_buffer[7]} {MouseTransceiver_inst/master_sm/pkt_buffer[8]} {MouseTransceiver_inst/master_sm/pkt_buffer[9]} {MouseTransceiver_inst/master_sm/pkt_buffer[10]} {MouseTransceiver_inst/master_sm/pkt_buffer[11]} {MouseTransceiver_inst/master_sm/pkt_buffer[12]} {MouseTransceiver_inst/master_sm/pkt_buffer[13]} {MouseTransceiver_inst/master_sm/pkt_buffer[14]} {MouseTransceiver_inst/master_sm/pkt_buffer[15]} {MouseTransceiver_inst/master_sm/pkt_buffer[16]} {MouseTransceiver_inst/master_sm/pkt_buffer[17]} {MouseTransceiver_inst/master_sm/pkt_buffer[18]} {MouseTransceiver_inst/master_sm/pkt_buffer[19]} {MouseTransceiver_inst/master_sm/pkt_buffer[20]} {MouseTransceiver_inst/master_sm/pkt_buffer[21]} {MouseTransceiver_inst/master_sm/pkt_buffer[22]} {MouseTransceiver_inst/master_sm/pkt_buffer[23]}]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list MouseTransceiver_inst/master_sm/BYTE_READY]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list MouseTransceiver_inst/master_sm/BYTE_SENT]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list MouseTransceiver_inst/master_sm/SEND_BYTE]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_sys]
