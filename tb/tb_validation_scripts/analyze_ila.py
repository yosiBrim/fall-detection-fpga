import pandas as pd

# הגדרת "תקן הזהב" של החומרה
EXPECTED_BLANKING_CYCLES = 160
EXPECTED_LATENCY = 2

# טעינת קובץ הנתונים מה-ILA (דילוג על שורת ה-HEX)
df = pd.read_csv('waveform.csv', skiprows=[1])

# חילוץ האותות הרלוונטיים (שים לב שאם האות המושהה מופיע ב-ILA, שווה לעדכן את השם שלו כאן)
in_disp = df['vga_controller_inst/in_display_area']
doutb = df['doutb[11:0]']

# ניתוח אות הבקרה
in_disp_falls = df[in_disp == 0]['Sample in Window'].min()
in_disp_rises = df[in_disp == 0]['Sample in Window'].max() + 1
blanking_cycles = df[in_disp == 0].shape[0]

# ניתוח אפיק הנתונים ועכבת הפייפליין
doutb_falls = df[doutb == '000']['Sample in Window'].min()
doutb_rises = df[doutb == '000']['Sample in Window'].max() + 1
pipeline_latency = doutb_falls - in_disp_falls

# === בדיקת השתקה מוחלטת (Zero Tolerance) ===
# מוודאים שבתוך חלון ההשתקה של הנתונים, כל הערכים הם באמת '000'
mute_window = df.loc[doutb_falls:doutb_rises - 1, 'doutb[11:0]']
is_perfect_mute = (mute_window == '000').all()

print("========================================")
print("=== ILA Hardware Validation Report ===")
print("========================================\n")

# הדפסת נתונים ואימות מול התקן
if blanking_cycles == EXPECTED_BLANKING_CYCLES:
    print(f"[PASS] VGA Standard Check: in_display_area blanking is exactly {blanking_cycles} cycles.")
else:
    print(f"[FAIL] VGA Standard Check: Expected {EXPECTED_BLANKING_CYCLES}, got {blanking_cycles} cycles!")

if pipeline_latency == EXPECTED_LATENCY:
    print(f"[PASS] Pipeline Latency: Hardware reaction time is {pipeline_latency} clock cycles.")
else:
    print(f"[FAIL] Pipeline Latency: Expected {EXPECTED_LATENCY}, got {pipeline_latency} clock cycles!")

if is_perfect_mute:
    print(f"[PASS] Data Mute Window: doutb drops at {doutb_falls} and rises at {doutb_rises} with absolute silence (0x000).")
else:
    print(f"[FAIL] Data Mute Window: Noise detected during the blanking period!")
    
print("\n========================================")
