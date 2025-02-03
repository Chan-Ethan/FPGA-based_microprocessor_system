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

## MMCM Locked Signal Constraints
set_property PACKAGE_PIN L1 [get_ports LED15_LOCKED]
set_property IOSTANDARD LVCMOS33 [get_ports LED15_LOCKED]
