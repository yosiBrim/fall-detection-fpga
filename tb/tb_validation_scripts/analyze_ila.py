import pandas as pd

# טעינת קובץ הנתונים מה-ILA (דילוג על שורת ה-HEX)
df = pd.read_csv('waveform.csv', skiprows=[1])

# חילוץ האותות הרלוונטיים
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

print("=== ILA Hardware Validation Report ===")
print(f"[+] VGA Standard Check: in_display_area blanking is exactly {blanking_cycles} cycles.")
print(f"[+] Pipeline Latency: Hardware reaction time is {pipeline_latency} clock cycles.")
print(f"[+] Data Mute Window: doutb drops at {doutb_falls} and rises at {doutb_rises}.")
