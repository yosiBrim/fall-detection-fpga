onerror {resume}
quietly WaveActivateNextPane {} 0

delete wave *

add wave -noupdate -divider -height 24 {1. Master Clock (25MHz = 40ns)}
add wave -noupdate -color Yellow /vga_controller_tb/DUT/pxl_clk

add wave -noupdate -divider -height 24 {2. Display Flags}
add wave -noupdate -color Green /vga_controller_tb/DUT/in_display_area

add wave -noupdate -divider -height 24 {3. Sync Pulses (The Trigger)}
add wave -noupdate -color White /vga_controller_tb/DUT/VGA_HS_O

add wave -noupdate -divider -height 24 {4. Physical RGB Out (Blanking Check)}
add wave -noupdate -color Magenta -radix hexadecimal /vga_controller_tb/DUT/VGA_R
add wave -noupdate -color Magenta -radix hexadecimal /vga_controller_tb/DUT/VGA_G
add wave -noupdate -color Magenta -radix hexadecimal /vga_controller_tb/DUT/VGA_B

TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 350
configure wave -valuecolwidth 80
configure wave -justifyvalue left
configure wave -signalnamewidth 0

# נריץ 50 מיקרו-שניות - זה מספיק כדי לעבור את הריסט ולראות לפחות שורה אחת שלמה
restart -f
run 50 us
