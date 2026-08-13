onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider -height 22 {1. Clock & Trigger}
add wave -noupdate -color Yellow /vga_controller_tb/clk
add wave -noupdate -color Green /vga_controller_tb/vga_start

add wave -noupdate -divider -height 22 {2. BRAM Read (Asynchronous)}
add wave -noupdate -color Orange -radix unsigned /vga_controller_tb/addrb
add wave -noupdate -color Orange -radix hexadecimal /vga_controller_tb/doutb

add wave -noupdate -divider -height 22 {3. Pipeline & Gatekeeper}
add wave -noupdate -color Yellow -radix hexadecimal /vga_controller_tb/DUT/pxl_data_reg
add wave -noupdate -color White /vga_controller_tb/DUT/in_display_area_delayed

add wave -noupdate -divider -height 22 {4. Physical RGB Out}
add wave -noupdate -color Magenta -radix hexadecimal /vga_controller_tb/DUT/VGA_R
add wave -noupdate -color Magenta -radix hexadecimal /vga_controller_tb/DUT/VGA_G
add wave -noupdate -color Magenta -radix hexadecimal /vga_controller_tb/DUT/VGA_B

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 280
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
update
WaveRestoreZoom {0 ps} {84 us}
