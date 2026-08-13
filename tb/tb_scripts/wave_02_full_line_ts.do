onerror {resume}
quietly WaveActivateNextPane {} 0

# פקודת הקסם שמנקה את החלון מהריצות הקודמות!
delete wave *

add wave -noupdate -divider -height 24 {1. Master Clock (25MHz = 40ns)}
add wave -noupdate -color Yellow /vga_controller_tb/DUT/pxl_clk

add wave -noupdate -divider -height 24 {2. Ts: Total Line (800 Clks / 32 us)}
add wave -noupdate -color Cyan -radix unsigned /vga_controller_tb/DUT/hsync_reg

add wave -noupdate -divider -height 24 {3. Tpw: Sync Pulse (96 Clks / 3.84 us)}
add wave -noupdate -color White /vga_controller_tb/DUT/VGA_HS_O

add wave -noupdate -divider -height 24 {4. Blanking (Tbp: 48 Clks | Tfp: 16 Clks)}
add wave -noupdate -color Gold /vga_controller_tb/DUT/in_display_area_delayed

add wave -noupdate -divider -height 24 {5. Tdisp: Active Display (640 Clks / 25.6 us)}
add wave -noupdate -color Green /vga_controller_tb/DUT/in_display_area
add wave -noupdate -color Green -radix unsigned /vga_controller_tb/DUT/display_x

add wave -noupdate -divider -height 24 {6. Physical RGB Out (Data Burst)}
add wave -noupdate -color Magenta -radix hexadecimal /vga_controller_tb/DUT/VGA_R
add wave -noupdate -color Magenta -radix hexadecimal /vga_controller_tb/DUT/VGA_G
add wave -noupdate -color Magenta -radix hexadecimal /vga_controller_tb/DUT/VGA_B

TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 380
configure wave -valuecolwidth 80
configure wave -justifyvalue left
configure wave -signalnamewidth 0

# מרסטים את הסימולציה מתוך הסקריפט כדי להיות בטוחים
restart -f

# הרצה לעומק הפריים (כדי שיהיו לנו נתונים אמיתיים להציג, מעבר ל-Vertical Blanking)
run 1050 us

# זום מדויק שמציג מחזור שורה שלם אחד במרכז המסך (כ-36 מיקרו-שניות סה"כ)
WaveRestoreZoom {1000 us} {1036 us}
