onerror {resume}
quietly WaveActivateNextPane {} 0

# מנקים את החלון הקודם
delete wave *

add wave -noupdate -divider -height 24 {1. Master Clock (25MHz = 40ns)}
add wave -noupdate -color Yellow /vga_controller_tb/DUT/pxl_clk

add wave -noupdate -divider -height 24 {2. Tdisp: Active Display Flag}
add wave -noupdate -color Green /vga_controller_tb/DUT/in_display_area

add wave -noupdate -divider -height 24 {3. Active Pixel Counter (0 to 639)}
add wave -noupdate -color Green -radix unsigned /vga_controller_tb/DUT/display_x

add wave -noupdate -divider -height 24 {4. Physical RGB Out (Data Burst)}
add wave -noupdate -color Magenta -radix hexadecimal /vga_controller_tb/DUT/VGA_R
add wave -noupdate -color Magenta -radix hexadecimal /vga_controller_tb/DUT/VGA_G
add wave -noupdate -color Magenta -radix hexadecimal /vga_controller_tb/DUT/VGA_B

TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 350
configure wave -valuecolwidth 80
configure wave -justifyvalue left
configure wave -signalnamewidth 0

# ריסט והרצה לעומק הסימולציה כדי לקבל נתוני צבע אמיתיים
restart -f
run 1050 us

# זום ממוקד אל תוך האזור הפעיל (640 שעונים = 25.6us) עם קצת שוליים שחורים בצדדים
WaveRestoreZoom {990 us} {1018 us}
