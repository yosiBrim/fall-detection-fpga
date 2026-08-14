####################################################################################
# Physical Pins Constraints (Nexys A7-100T)
####################################################################################
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports reset]
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports {btn[0]}]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports {btn[1]}]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {sw[0]}]

# LEDs
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {led[3]}]

# OV7670 Camera
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports {ov7670_data[0]}]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {ov7670_data[1]}]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports {ov7670_data[2]}]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {ov7670_data[3]}]
set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33} [get_ports {ov7670_data[4]}]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports {ov7670_data[5]}]
set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS33} [get_ports {ov7670_data[6]}]
set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports {ov7670_data[7]}]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports ov7670_vsync]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports ov7670_href]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports ov7670_pclk]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports ov7670_xclk]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports scl]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports sda]
set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports ov7670_pwdn]
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports ov7670_reset]

# VGA Output
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {VGA_R[0]}]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports {VGA_R[1]}]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS33} [get_ports {VGA_R[2]}]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports {VGA_R[3]}]
set_property -dict {PACKAGE_PIN C6 IOSTANDARD LVCMOS33} [get_ports {VGA_G[0]}]
set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS33} [get_ports {VGA_G[1]}]
set_property -dict {PACKAGE_PIN B6 IOSTANDARD LVCMOS33} [get_ports {VGA_G[2]}]
set_property -dict {PACKAGE_PIN A6 IOSTANDARD LVCMOS33} [get_ports {VGA_G[3]}]
set_property -dict {PACKAGE_PIN B7 IOSTANDARD LVCMOS33} [get_ports {VGA_B[0]}]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports {VGA_B[1]}]
set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS33} [get_ports {VGA_B[2]}]
set_property -dict {PACKAGE_PIN D8 IOSTANDARD LVCMOS33} [get_ports {VGA_B[3]}]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports VGA_HS_O]
set_property -dict {PACKAGE_PIN B12 IOSTANDARD LVCMOS33} [get_ports VGA_VS_O]



####################################################################################
# Configuration Options
####################################################################################
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

####################################################################################
# Clock Constraints & Timing
####################################################################################
# 100MHz System Clock
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

# OV7670 PCLK (approx 24MHz)
create_clock -period 41.670 -name ov7670_pclk_pin -waveform {0.000 20.830} -add [get_ports ov7670_pclk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets ov7670_pclk]

# Treat camera clock and system clock as asynchronous (prevents CDC timing errors)
set_clock_groups -asynchronous -group [get_clocks ov7670_pclk_pin] -group [get_clocks sys_clk_pin]
