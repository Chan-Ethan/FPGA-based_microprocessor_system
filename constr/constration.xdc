## Clock Constraints
set_property PACKAGE_PIN W5 [get_ports CLK100_IN]
set_property IOSTANDARD LVCMOS33 [get_ports CLK100_IN]
create_clock -period 10.000 -name clk100 -waveform {0.000 5.000} [get_ports CLK100_IN]

## Reset Constraints
set_property PACKAGE_PIN U18 [get_ports HARD_RST]
set_property IOSTANDARD LVCMOS33 [get_ports HARD_RST]
## set_property PULLDOWN true [get_ports HARD_RST]

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

# Slide Switch 
set_property PACKAGE_PIN R2 [get_ports {SW[15]}]
set_property PACKAGE_PIN T1 [get_ports {SW[14]}]
set_property PACKAGE_PIN U1 [get_ports {SW[13]}]
set_property PACKAGE_PIN W2 [get_ports {SW[12]}]
set_property PACKAGE_PIN R3 [get_ports {SW[11]}]
set_property PACKAGE_PIN T2 [get_ports {SW[10]}]
set_property PACKAGE_PIN T3 [get_ports {SW[9]}]
set_property PACKAGE_PIN V2 [get_ports {SW[8]}]
set_property PACKAGE_PIN W13 [get_ports {SW[7]}]
set_property PACKAGE_PIN W14 [get_ports {SW[6]}]
set_property PACKAGE_PIN V15 [get_ports {SW[5]}]
set_property PACKAGE_PIN W15 [get_ports {SW[4]}]
set_property PACKAGE_PIN W17 [get_ports {SW[3]}]
set_property PACKAGE_PIN W16 [get_ports {SW[2]}]
set_property PACKAGE_PIN V16 [get_ports {SW[1]}]
set_property PACKAGE_PIN V17 [get_ports {SW[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[*]}]

## LED Constraints
## LED15-12
set_property PACKAGE_PIN L1 [get_ports {LED[15]}]
set_property PACKAGE_PIN P1 [get_ports {LED[14]}]
set_property PACKAGE_PIN N3 [get_ports {LED[13]}]
set_property PACKAGE_PIN P3 [get_ports {LED[12]}]
set_property PACKAGE_PIN U3 [get_ports {LED[11]}]
set_property PACKAGE_PIN W3 [get_ports {LED[10]}]
set_property PACKAGE_PIN V3  [get_ports {LED[9]}]
set_property PACKAGE_PIN V13 [get_ports {LED[8]}]
set_property PACKAGE_PIN V14 [get_ports {LED[7]}]
set_property PACKAGE_PIN U14 [get_ports {LED[6]}]
set_property PACKAGE_PIN U15 [get_ports {LED[5]}]
set_property PACKAGE_PIN W18 [get_ports {LED[4]}]
set_property PACKAGE_PIN V19 [get_ports {LED[3]}]
set_property PACKAGE_PIN U19 [get_ports {LED[2]}]
set_property PACKAGE_PIN E19 [get_ports {LED[1]}]
set_property PACKAGE_PIN U16 [get_ports {LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[*]}]

# VGA Constraints
set_property PACKAGE_PIN L18 [get_ports {VGA_COLOUR[7]}]  
set_property PACKAGE_PIN N18 [get_ports {VGA_COLOUR[6]}]
set_property PACKAGE_PIN D17 [get_ports {VGA_COLOUR[5]}]
set_property PACKAGE_PIN G17 [get_ports {VGA_COLOUR[4]}]
set_property PACKAGE_PIN H17 [get_ports {VGA_COLOUR[3]}]  
set_property PACKAGE_PIN G19 [get_ports {VGA_COLOUR[2]}]  
set_property PACKAGE_PIN J19 [get_ports {VGA_COLOUR[1]}]  
set_property PACKAGE_PIN J18 [get_ports {VGA_COLOUR[0]}]  
set_property IOSTANDARD LVCMOS33 [get_ports VGA_COLOUR[*]]

set_property PACKAGE_PIN P19 [get_ports VGA_HS]
set_property PACKAGE_PIN R19 [get_ports VGA_VS]
set_property IOSTANDARD LVCMOS33 [get_ports VGA_HS]
set_property IOSTANDARD LVCMOS33 [get_ports VGA_VS]

## IR LED Constraints
set_property PACKAGE_PIN B16 [get_ports IR_LED]
set_property IOSTANDARD LVCMOS33 [get_ports IR_LED]
