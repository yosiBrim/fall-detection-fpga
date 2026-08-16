---
marp: true
theme: default
size: 16:9
style: |
  section {
    direction: rtl;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    font-size: 26px;
  }
  h1, h2, p, li, td, th { text-align: right; }
  h1 { color: #2c3e50; text-align: center; }
  .center-text { text-align: center; }
---

# פיתוח מערכת מבוססת FPGA להתראת נפילה לחולי דמנציה

<div class="center-text">
קליטת תמונה בזמן אמת ממצלמת OV7670 והצגתה דרך כרטיס Artix-7.<br>
על מנת לאפשר עיבוד תמונה לזיהויי עמידה ממושכת לחולי דמנציה.
</div>

![bg right:40% fit](docs/presentation/assets/artix_board.png)

<div class="center-text" style="margin-top: 50px; font-weight: bold;">
מגיש: יוסי ברים | הנדסת חשמל שנה ד' | המרכז האקדמי לב
</div>

---

# ארכיטקטורת המערכת

* נתוני התמונה הגולמיים נקלטים מהמצלמה ונאגרים בזיכרון ה-`BRAM`.
* בקר ה-`VGA` שולף את הנתונים ומעביר לממיר `D to A` לקבלת אות אנלוגי פיזי למסך.

<br>

**Inputs:** `clk`, `reset`, `ov7670_vsync`, `href`, `pclk`
**Outputs:** `VGA_HS_O`, `VGA_VS_O`, `VGA_R/G/B`

---

# תזמוני VGA: הפיזיקה מאחורי המספרים

| פרמטר | מחזורי שעון | הצורך הפיזיקלי המקורי (CRT) | המימוש שלנו (RTL) |
| :--- | :--- | :--- | :--- |
| **Active Display** | 640 | הקרן מציירת את הפיקסלים משמאל לימין. | שליפת נתונים מה-`BRAM` ושידור צבע פעיל. |
| **Front Porch** | 16 | מרווח זמן לקרן 'להירגע' בסוף השורה. | כיבוי מיידי של ה-RGB ל-`0000` למניעת מריחות. |
| **Sync Pulse** | 96 | מכת מתח המאלצת חזרה שמאלה. | הורדת האות הפיזי `HSYNC` ל-`0` למשך 96 שעונים. |
