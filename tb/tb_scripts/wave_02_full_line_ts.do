onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider -height 22 {1. Pixel Clock (25MHz)}
add wave -noupdate -color Yellow /vga_controller_tb/DUT/pxl_clk

add wave -noupdate -divider -height 22 {2. Horizontal Counter (0 to 799)}
add wave -noupdate -color Cyan -radix unsigned /vga_controller_tb/DUT/hsync_reg

add wave -noupdate -divider -height 22 {3. Line Control Logic}
add wave -noupdate -color Gold /vga_controller_tb/DUT/line_finished

add wave -noupdate -divider -height 22 {4. Physical H-Sync Out}
add wave -noupdate -color White /vga_controller_tb/DUT/VGA_HS_O

TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 300
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0

# הרצה לתוך אזור פעיל (עוקפים את ה-Blanking של תחילת הפריים)
run 1050 us

# זום מדויק לחלון של 36 מיקרו-שניות המציג מחזור שורה שלם
WaveRestoreZoom {1000 us} {1036 us}
