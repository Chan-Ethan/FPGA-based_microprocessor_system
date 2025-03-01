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



connect_debug_port u_ila_0/probe7 [get_nets [list {MouseTransceiver_inst/transmitter/current_state[0]} {MouseTransceiver_inst/transmitter/current_state[1]} {MouseTransceiver_inst/transmitter/current_state[2]} {MouseTransceiver_inst/transmitter/current_state[3]} {MouseTransceiver_inst/transmitter/current_state[4]} {MouseTransceiver_inst/transmitter/current_state[5]}]]
connect_debug_port u_ila_0/probe8 [get_nets [list {MouseTransceiver_inst/transmitter/clk_cnt[0]} {MouseTransceiver_inst/transmitter/clk_cnt[1]} {MouseTransceiver_inst/transmitter/clk_cnt[2]} {MouseTransceiver_inst/transmitter/clk_cnt[3]} {MouseTransceiver_inst/transmitter/clk_cnt[4]} {MouseTransceiver_inst/transmitter/clk_cnt[5]} {MouseTransceiver_inst/transmitter/clk_cnt[6]} {MouseTransceiver_inst/transmitter/clk_cnt[7]} {MouseTransceiver_inst/transmitter/clk_cnt[8]} {MouseTransceiver_inst/transmitter/clk_cnt[9]} {MouseTransceiver_inst/transmitter/clk_cnt[10]} {MouseTransceiver_inst/transmitter/clk_cnt[11]} {MouseTransceiver_inst/transmitter/clk_cnt[12]} {MouseTransceiver_inst/transmitter/clk_cnt[13]}]]
connect_debug_port u_ila_0/probe9 [get_nets [list {MouseTransceiver_inst/transmitter/next_state[0]} {MouseTransceiver_inst/transmitter/next_state[1]} {MouseTransceiver_inst/transmitter/next_state[2]} {MouseTransceiver_inst/transmitter/next_state[3]} {MouseTransceiver_inst/transmitter/next_state[4]} {MouseTransceiver_inst/transmitter/next_state[5]}]]


connect_debug_port u_ila_0/probe17 [get_nets [list {MouseTransceiver_inst/master_sm/BYTE_TO_SEND_reg_n_0_[0]}]]
connect_debug_port u_ila_0/probe18 [get_nets [list {MouseTransceiver_inst/master_sm/BYTE_TO_SEND_reg_n_0_[1]}]]
connect_debug_port u_ila_0/probe19 [get_nets [list {MouseTransceiver_inst/master_sm/BYTE_TO_SEND_reg_n_0_[2]}]]
connect_debug_port u_ila_0/probe20 [get_nets [list {MouseTransceiver_inst/master_sm/BYTE_TO_SEND_reg_n_0_[3]}]]
connect_debug_port u_ila_0/probe21 [get_nets [list {MouseTransceiver_inst/master_sm/BYTE_TO_SEND_reg_n_0_[4]}]]
connect_debug_port u_ila_0/probe22 [get_nets [list {MouseTransceiver_inst/master_sm/BYTE_TO_SEND_reg_n_0_[5]}]]
connect_debug_port u_ila_0/probe23 [get_nets [list {MouseTransceiver_inst/master_sm/BYTE_TO_SEND_reg_n_0_[6]}]]
connect_debug_port u_ila_0/probe24 [get_nets [list {MouseTransceiver_inst/master_sm/BYTE_TO_SEND_reg_n_0_[7]}]]


connect_debug_port u_ila_0/probe19 [get_nets [list clk_enable]]
connect_debug_port u_ila_0/probe24 [get_nets [list data_enable]]
connect_debug_port u_ila_0/probe27 [get_nets [list data_out]]
connect_debug_port u_ila_0/probe28 [get_nets [list MouseTransceiver_inst/transmitter/n_0_0]]
connect_debug_port u_ila_0/probe29 [get_nets [list MouseTransceiver_inst/transmitter/n_0_1]]
connect_debug_port u_ila_0/probe30 [get_nets [list MouseTransceiver_inst/transmitter/n_0_2]]

connect_debug_port u_ila_0/probe31 [get_nets [list MouseTransceiver_inst/receiver/odd_parity_err]]
connect_debug_port u_ila_0/probe40 [get_nets [list MouseTransceiver_inst/receiver/stop_bit_err]]

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
set_property port_width 6 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {MouseTransceiver_inst/transmitter/next_state[0]} {MouseTransceiver_inst/transmitter/next_state[1]} {MouseTransceiver_inst/transmitter/next_state[2]} {MouseTransceiver_inst/transmitter/next_state[3]} {MouseTransceiver_inst/transmitter/next_state[4]} {MouseTransceiver_inst/transmitter/next_state[5]}]]
create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {MouseTransceiver_inst/transmitter/tx_data[0]} {MouseTransceiver_inst/transmitter/tx_data[1]} {MouseTransceiver_inst/transmitter/tx_data[2]} {MouseTransceiver_inst/transmitter/tx_data[3]} {MouseTransceiver_inst/transmitter/tx_data[4]} {MouseTransceiver_inst/transmitter/tx_data[5]} {MouseTransceiver_inst/transmitter/tx_data[6]} {MouseTransceiver_inst/transmitter/tx_data[7]}]]
create_debug_port u_ila_0 probe
set_property port_width 6 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {MouseTransceiver_inst/transmitter/current_state[0]} {MouseTransceiver_inst/transmitter/current_state[1]} {MouseTransceiver_inst/transmitter/current_state[2]} {MouseTransceiver_inst/transmitter/current_state[3]} {MouseTransceiver_inst/transmitter/current_state[4]} {MouseTransceiver_inst/transmitter/current_state[5]}]]
create_debug_port u_ila_0 probe
set_property port_width 14 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {MouseTransceiver_inst/transmitter/clk_cnt[0]} {MouseTransceiver_inst/transmitter/clk_cnt[1]} {MouseTransceiver_inst/transmitter/clk_cnt[2]} {MouseTransceiver_inst/transmitter/clk_cnt[3]} {MouseTransceiver_inst/transmitter/clk_cnt[4]} {MouseTransceiver_inst/transmitter/clk_cnt[5]} {MouseTransceiver_inst/transmitter/clk_cnt[6]} {MouseTransceiver_inst/transmitter/clk_cnt[7]} {MouseTransceiver_inst/transmitter/clk_cnt[8]} {MouseTransceiver_inst/transmitter/clk_cnt[9]} {MouseTransceiver_inst/transmitter/clk_cnt[10]} {MouseTransceiver_inst/transmitter/clk_cnt[11]} {MouseTransceiver_inst/transmitter/clk_cnt[12]} {MouseTransceiver_inst/transmitter/clk_cnt[13]}]]
create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {MouseTransceiver_inst/master_sm/MOUSE_DX[0]} {MouseTransceiver_inst/master_sm/MOUSE_DX[1]} {MouseTransceiver_inst/master_sm/MOUSE_DX[2]} {MouseTransceiver_inst/master_sm/MOUSE_DX[3]} {MouseTransceiver_inst/master_sm/MOUSE_DX[4]} {MouseTransceiver_inst/master_sm/MOUSE_DX[5]} {MouseTransceiver_inst/master_sm/MOUSE_DX[6]} {MouseTransceiver_inst/master_sm/MOUSE_DX[7]}]]
create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {MouseTransceiver_inst/master_sm/BYTE_READ[0]} {MouseTransceiver_inst/master_sm/BYTE_READ[1]} {MouseTransceiver_inst/master_sm/BYTE_READ[2]} {MouseTransceiver_inst/master_sm/BYTE_READ[3]} {MouseTransceiver_inst/master_sm/BYTE_READ[4]} {MouseTransceiver_inst/master_sm/BYTE_READ[5]} {MouseTransceiver_inst/master_sm/BYTE_READ[6]} {MouseTransceiver_inst/master_sm/BYTE_READ[7]}]]
create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {MouseTransceiver_inst/master_sm/BYTE_TO_SEND[0]} {MouseTransceiver_inst/master_sm/BYTE_TO_SEND[1]} {MouseTransceiver_inst/master_sm/BYTE_TO_SEND[2]} {MouseTransceiver_inst/master_sm/BYTE_TO_SEND[3]} {MouseTransceiver_inst/master_sm/BYTE_TO_SEND[4]} {MouseTransceiver_inst/master_sm/BYTE_TO_SEND[5]} {MouseTransceiver_inst/master_sm/BYTE_TO_SEND[6]} {MouseTransceiver_inst/master_sm/BYTE_TO_SEND[7]}]]
create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {MouseTransceiver_inst/master_sm/MOUSE_DY[0]} {MouseTransceiver_inst/master_sm/MOUSE_DY[1]} {MouseTransceiver_inst/master_sm/MOUSE_DY[2]} {MouseTransceiver_inst/master_sm/MOUSE_DY[3]} {MouseTransceiver_inst/master_sm/MOUSE_DY[4]} {MouseTransceiver_inst/master_sm/MOUSE_DY[5]} {MouseTransceiver_inst/master_sm/MOUSE_DY[6]} {MouseTransceiver_inst/master_sm/MOUSE_DY[7]}]]
create_debug_port u_ila_0 probe
set_property port_width 2 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {MouseTransceiver_inst/master_sm/BYTE_ERROR_CODE[0]} {MouseTransceiver_inst/master_sm/BYTE_ERROR_CODE[1]}]]
create_debug_port u_ila_0 probe
set_property port_width 4 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {MouseTransceiver_inst/master_sm/MOUSE_STATUS[0]} {MouseTransceiver_inst/master_sm/MOUSE_STATUS[1]} {MouseTransceiver_inst/master_sm/MOUSE_STATUS[4]} {MouseTransceiver_inst/master_sm/MOUSE_STATUS[5]}]]
create_debug_port u_ila_0 probe
set_property port_width 2 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {MouseTransceiver_inst/master_sm/byte_cnt[0]} {MouseTransceiver_inst/master_sm/byte_cnt[1]}]]
create_debug_port u_ila_0 probe
set_property port_width 5 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {MouseTransceiver_inst/master_sm/current_state[0]} {MouseTransceiver_inst/master_sm/current_state[1]} {MouseTransceiver_inst/master_sm/current_state[2]} {MouseTransceiver_inst/master_sm/current_state[3]} {MouseTransceiver_inst/master_sm/current_state[4]}]]
create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {MouseTransceiver_inst/receiver/BYTE_READ[0]} {MouseTransceiver_inst/receiver/BYTE_READ[1]} {MouseTransceiver_inst/receiver/BYTE_READ[2]} {MouseTransceiver_inst/receiver/BYTE_READ[3]} {MouseTransceiver_inst/receiver/BYTE_READ[4]} {MouseTransceiver_inst/receiver/BYTE_READ[5]} {MouseTransceiver_inst/receiver/BYTE_READ[6]} {MouseTransceiver_inst/receiver/BYTE_READ[7]}]]
create_debug_port u_ila_0 probe
set_property port_width 7 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {MouseTransceiver_inst/master_sm/next_state[0]} {MouseTransceiver_inst/master_sm/next_state[1]} {MouseTransceiver_inst/master_sm/next_state[2]} {MouseTransceiver_inst/master_sm/next_state[3]} {MouseTransceiver_inst/master_sm/next_state[4]} {MouseTransceiver_inst/master_sm/next_state[5]} {MouseTransceiver_inst/master_sm/next_state[6]}]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list MouseTransceiver_inst/master_sm/BYTE_READY]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list MouseTransceiver_inst/receiver/BYTE_READY]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list MouseTransceiver_inst/master_sm/BYTE_SENT]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list MouseTransceiver_inst/clk_enable]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list MouseTransceiver_inst/receiver/CLK_MOUSE_IN]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list MouseTransceiver_inst/transmitter/CLK_MOUSE_IN]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {MouseTransceiver_inst/master_sm/current_state_reg_n_0_[5]}]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {MouseTransceiver_inst/master_sm/current_state_reg_n_0_[6]}]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list MouseTransceiver_inst/data_enable]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list MouseTransceiver_inst/receiver/DATA_MOUSE_IN]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list MouseTransceiver_inst/transmitter/DATA_MOUSE_IN]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list MouseTransceiver_inst/transmitter/DATA_MOUSE_OUT]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list MouseTransceiver_inst/transmitter/DATA_MOUSE_OUT_EN]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list MouseTransceiver_inst/data_out]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list MouseTransceiver_inst/transmitter/in005_out]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list {MouseTransceiver_inst/master_sm/pkt_buffer_reg_n_0_[2]}]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list {MouseTransceiver_inst/master_sm/pkt_buffer_reg_n_0_[3]}]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list {MouseTransceiver_inst/master_sm/pkt_buffer_reg_n_0_[6]}]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list {MouseTransceiver_inst/master_sm/pkt_buffer_reg_n_0_[7]}]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list MouseTransceiver_inst/transmitter/ps2_clk_vld]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list MouseTransceiver_inst/master_sm/READ_ENABLE]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe37]
connect_debug_port u_ila_0/probe37 [get_nets [list MouseTransceiver_inst/receiver/READ_ENABLE]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe38]
connect_debug_port u_ila_0/probe38 [get_nets [list MouseTransceiver_inst/master_sm/SEND_BYTE]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe39]
connect_debug_port u_ila_0/probe39 [get_nets [list MouseTransceiver_inst/master_sm/waiting_wr_done]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_sys]
