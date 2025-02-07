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
set_property PACKAGE_PIN L1 [get_ports LED15_L]
set_property IOSTANDARD LVCMOS33 [get_ports LED15_L]

set_property PACKAGE_PIN P1 [get_ports LED14_R]
set_property IOSTANDARD LVCMOS33 [get_ports LED14_R]

set_property PACKAGE_PIN N3 [get_ports LED13_INIT_DONE]
set_property IOSTANDARD LVCMOS33 [get_ports LED13_INIT_DONE]

set_property PACKAGE_PIN P3 [get_ports {LED12_8_STATE[4]}]
set_property PACKAGE_PIN U3 [get_ports {LED12_8_STATE[3]}]
set_property PACKAGE_PIN W3 [get_ports {LED12_8_STATE[2]}]
set_property PACKAGE_PIN V3 [get_ports {LED12_8_STATE[1]}]
set_property PACKAGE_PIN V13 [get_ports {LED12_8_STATE[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED12_8_STATE[*]}]

set_property PACKAGE_PIN U16 [get_ports LED0_LOCKED]
set_property IOSTANDARD LVCMOS33 [get_ports LED0_LOCKED]


create_debug_core u_ila_0_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0_0]
set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_0_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0_0]
set_property port_width 1 [get_debug_ports u_ila_0_0/clk]
connect_debug_port u_ila_0_0/clk [get_nets [list clk_wiz_0_inst/inst/clk_out1]]
set_property port_width 24 [get_debug_ports u_ila_0_0/probe0]
connect_debug_port u_ila_0_0/probe0 [get_nets [list {seg7_control_inst/ps2pkt_data[0]} {seg7_control_inst/ps2pkt_data[1]} {seg7_control_inst/ps2pkt_data[2]} {seg7_control_inst/ps2pkt_data[3]} {seg7_control_inst/ps2pkt_data[4]} {seg7_control_inst/ps2pkt_data[5]} {seg7_control_inst/ps2pkt_data[6]} {seg7_control_inst/ps2pkt_data[7]} {seg7_control_inst/ps2pkt_data[8]} {seg7_control_inst/ps2pkt_data[9]} {seg7_control_inst/ps2pkt_data[10]} {seg7_control_inst/ps2pkt_data[11]} {seg7_control_inst/ps2pkt_data[12]} {seg7_control_inst/ps2pkt_data[13]} {seg7_control_inst/ps2pkt_data[14]} {seg7_control_inst/ps2pkt_data[15]} {seg7_control_inst/ps2pkt_data[16]} {seg7_control_inst/ps2pkt_data[17]} {seg7_control_inst/ps2pkt_data[18]} {seg7_control_inst/ps2pkt_data[19]} {seg7_control_inst/ps2pkt_data[20]} {seg7_control_inst/ps2pkt_data[21]} {seg7_control_inst/ps2pkt_data[22]} {seg7_control_inst/ps2pkt_data[23]}]]
create_debug_port u_ila_0_0 probe
set_property port_width 8 [get_debug_ports u_ila_0_0/probe1]
connect_debug_port u_ila_0_0/probe1 [get_nets [list {ps2_top_inst/ps2_rx_inst/rd_data[0]} {ps2_top_inst/ps2_rx_inst/rd_data[1]} {ps2_top_inst/ps2_rx_inst/rd_data[2]} {ps2_top_inst/ps2_rx_inst/rd_data[3]} {ps2_top_inst/ps2_rx_inst/rd_data[4]} {ps2_top_inst/ps2_rx_inst/rd_data[5]} {ps2_top_inst/ps2_rx_inst/rd_data[6]} {ps2_top_inst/ps2_rx_inst/rd_data[7]}]]
create_debug_port u_ila_0_0 probe
set_property port_width 1 [get_debug_ports u_ila_0_0/probe2]
connect_debug_port u_ila_0_0/probe2 [get_nets [list ps2_top_inst/ps2_rx_inst/PS2_CLK]]
create_debug_port u_ila_0_0 probe
set_property port_width 1 [get_debug_ports u_ila_0_0/probe3]
connect_debug_port u_ila_0_0/probe3 [get_nets [list ps2_top_inst/ps2_rx_inst/PS2_DATA]]
create_debug_port u_ila_0_0 probe
set_property port_width 1 [get_debug_ports u_ila_0_0/probe4]
connect_debug_port u_ila_0_0/probe4 [get_nets [list seg7_control_inst/ps2pkt_vld]]
create_debug_port u_ila_0_0 probe
set_property port_width 1 [get_debug_ports u_ila_0_0/probe5]
connect_debug_port u_ila_0_0/probe5 [get_nets [list ps2_top_inst/ps2_rx_inst/rd_en]]
create_debug_port u_ila_0_0 probe
set_property port_width 1 [get_debug_ports u_ila_0_0/probe6]
connect_debug_port u_ila_0_0/probe6 [get_nets [list ps2_top_inst/ps2_rx_inst/rd_vld]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_sys]
