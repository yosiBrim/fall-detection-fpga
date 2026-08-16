---
marp: true
theme: default
size: 16:9
style: |
  section {
    direction: rtl;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    font-size: 24px;
  }
  h1, h2, p, li, td, th { text-align: right; }
  h1 { color: #2c3e50; text-align: center; }
  .center-text { text-align: center; }
  
  /* עיצוב דיאגרמת הקופסה השחורה (I/O) - שקף 2 */
  .system-container { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; direction: ltr; font-size: 18px; }
  .io-box { background-color: #f0f0f0; border: 1px solid #ccc; padding: 15px; border-radius: 5px; font-family: monospace; text-align: left; box-shadow: 2px 2px 5px rgba(0,0,0,0.1); }
  .black-box { background-color: #2b2b2b; color: #ffffff; padding: 20px 30px; border-radius: 8px; text-align: center; font-weight: bold; font-size: 22px; direction: rtl; box-shadow: 3px 3px 10px rgba(0,0,0,0.4); line-height: 1.4; }
  .arrow-large { font-size: 35px; color: #555; }
  
  /* עיצוב הצנרת הפנימית (בלוקים) - שקף 2 */
  .block-diagram { display: flex; justify-content: space-between; align-items: center; margin-top: 40px; direction: ltr; }
  .block { background-color: #4F81BD; color: white; padding: 12px 15px; border-radius: 10px; font-size: 18px; font-weight: bold; text-align: center; box-shadow: 2px 2px 5px rgba(0,0,0,0.3); }
  .arrow { font-size: 25px; color: #4F81BD; }
---

<!-- ========================================== -->
<!-- שקף 1: שער ומטרת הפרויקט                   -->
<!-- ========================================== -->

# פיתוח מערכת מבוססת FPGA להתראת נפילה לחולי דמנציה

<div class="center-text" style="font-size: 22px; margin-bottom: 20px;">
קליטת תמונה בזמן אמת ממצלמת OV7670 והצגתה דרך כרטיס Artix-7.<br>
על מנת לאפשר עיבוד תמונה לזיהויי עמידה ממושכת לחולי דמנציה.
</div>

<div class="center-text" style="width: 100%; margin: 20px 0;">
  <img src="../assets/artix_board.png" width="450" style="border-radius: 10px; box-shadow: 2px 2px 8px rgba(0,0,0,0.2);">
</div>

<div class="center-text" style="margin-top: 30px; font-weight: bold; font-size: 26px;">
מגיש: יוסי ברים | הנדסת חשמל שנה ד' | המרכז האקדמי לב
</div>

---
<!-- ========================================== -->
<!-- שקף 2: ארכיטקטורת המערכת                   -->
<!-- ========================================== -->

# ארכיטקטורת המערכת

* נתוני התמונה הגולמיים נקלטים מהמצלמה ונאגרים בזיכרון ה-`BRAM`.
* בקר ה-`VGA` שולף את הנתונים ומעביר לממיר `D to A` לקבלת אות אנלוגי פיזי למסך.

<!-- מודל הקופסה השחורה - כניסות ויציאות -->
<div class="system-container">
  <div class="io-box">
    <strong>Inputs:</strong><br>clk, reset<br>ov7670_vsync, href, pclk<br>ov7670_data[7:0]<br>btn[1:0], sw[1:0]<br>scl, sda
  </div>
  <div class="arrow-large">➡️</div>
  <div class="black-box">
    מערכת התראת נפילה<br>מבוססת FPGA
  </div>
  <div class="arrow-large">➡️</div>
  <div class="io-box">
    <strong>Outputs:</strong><br>VGA_HS_O, VGA_VS_O<br>VGA_R[3:0], G[3:0], B[3:0]<br>ov7670_xclk, pwdn, reset<br>led[3:0]
  </div>
</div>

<!-- מודל הצנרת הפנימית -->
<div class="block-diagram">
  <div class="block">ov7670_capture</div>
  <div class="arrow">➡️</div>
  <div class="block">frame_buffer</div>
  <div class="arrow">➡️</div>
  <div class="block">vga_controller</div>
  <div class="arrow">➡️</div>
  <div class="block">D to A Converter</div>
</div>

---


<!-- ========================================== -->
<!-- שקף 3: מבוא ל-VGA - קונספט תותח האלקטרונים -->
<!-- ========================================== -->

<style scoped>
section { padding-top: 30px; }
</style>

# מבוא ל-VGA: קונספט תותח האלקטרונים (CRT)

<div class="center-text" style="width: 100%; margin: 10px 0;">
  <img src="../assets/vga_analog_cathode_ray_concept.png" height="380" style="border-radius: 8px; box-shadow: 2px 2px 8px rgba(0,0,0,0.2);">
</div>

<div style="font-size: 20px; line-height: 1.4;">

* **מקור הפרוטוקול:** טכנולוגיית ה-VGA פותחה במקור עבור מסכי שפופרת קרן קתודית (CRT) המבוססים על פיזיקה אנלוגית.
* **תותח אלקטרונים:** המסך פועל באמצעות קרן פיזית הנורית על גבי מסך מצופה זרחן. עוצמת הזרם קובעת את עוצמת ההארה של כל פיקסל.
* **המורשת האנלוגית:** למרות שכיום המסכים מודרניים, הפרוטוקול מחייב שידור אותות השהייה שיאפשרו לקרן הפיזית זמן תנועה וחזרה.

</div>

---

<!-- ========================================== -->
<!-- שקף 4: מבוא ל-VGA - סריקה קווית            -->
<!-- ========================================== -->

# מבוא ל-VGA: סריקה קווית (Raster Scan)

<div class="center-text" style="width: 100%; margin: 10px 0;">
  <img src="../assets/vga_raster_scan_retrace_concept.png" height="380" style="border-radius: 8px; box-shadow: 2px 2px 8px rgba(0,0,0,0.2);">
</div>

<div style="font-size: 20px; line-height: 1.4;">

* הציור על המסך מבוסס על קרן שסורקת את הפיקסלים משמאל לימין (שורה) ומלמעלה למטה (פריים).
* תנועת הקרן חייבת להיות רציפה, מה שיוצר מסלול בצורת 'זיגזג'.
* בכל פעם שהקרן מגיעה לקצה (אופקי או אנכי), נדרש זמן כדי להחזיר אותה לנקודת ההתחלה (`Retrace`).

</div>

---

<!-- ========================================== -->
<!-- שקף 5: תזמוני VGA - הפיזיקה מאחורי המספרים -->
<!-- ========================================== -->

# תזמוני VGA: הפיזיקה מאחורי המספרים

| פרמטר | מחזורי שעון | הצורך הפיזיקלי המקורי (CRT) | המימוש שלנו (RTL) |
| :---: | :---: | :--- | :--- |
| **Active Display** | 640 | הקרן מציירת את הפיקסלים הפיזיים על המסך משמאל לימין. | שליפת נתונים מה-`BRAM` ושידור צבע (`RGB`) פעיל. |
| **Front Porch** | 16 | מרווח זמן לקרן 'להירגע' בסוף השורה לפני שחוזרת אחורה. | כיבוי מיידי של ה-`RGB` ל-'0000' למניעת מריחות. |
| **Sync Pulse** | 96 | מכת מתח (טריגר) שמאלצת את הקרן לקפוץ חזרה שמאלה. | הורדת האות הפיזי `HSYNC` ל-'0' למשך 96 שעונים. |
| **Back Porch** | 48 | המתנה לייצוב הקרן בתחילת השורה החדשה בצד שמאל. | המשך השהיית ה-`RGB` על '0000' עד הגעה לפיקסל הראשון. |


---

<!-- ========================================== -->
<!-- שקף 6: תזמונים והחשכה בחומרה (VGA Controller) -->
<!-- ========================================== -->
<style scoped>
section { padding-top: 30px; }
</style>

# תזמונים והחשכה בחומרה (VGA Controller)

<div style="font-size: 18px; line-height: 1.1; margin-top: -10px;">

* **מחזור שלם (800 פיקסלים):** חיבור הערכים (640+16+96+48) דורש מהמונה האופקי (`h_count`) לספור מ-0 ועד 799.
* **שעון פיקסל 25MHz:** כל פיקסל שקול למחזור שעון אחד של `40ns`. סנכרון זה מבטיח קצב ריענון תקני של `60Hz`.
* **אכיפת שחור (Blanking):** מחוץ לתחום ה-640, הלוגיקה שלנו מאלצת `0000` ב-`RGB` כדי למנוע 'מריחות' צבע בעת תנועת הקרן.

</div>

<div style="display: flex; justify-content: space-around; align-items: center; margin-top: 15px;">
  <img src="../assets/vga_counters_rtl_schematic.png" width="360" style="border-radius: 8px; box-shadow: 2px 2px 8px rgba(0,0,0,0.2);">
  <img src="../assets/vga_timing_waveform_and_table.png" width="360" style="border-radius: 8px; box-shadow: 2px 2px 8px rgba(0,0,0,0.2);">
</div>

---
<!-- ========================================== -->
<!-- שקף 7: מסלול הנתונים - חישוב כתובת ושליפה מה-BRAM -->
<!-- ========================================== -->

<style scoped>
section { padding-top: 30px; }
</style>


# מסלול הנתונים מהBRAM : חישוב כתובת הפיקסל ושליפה

<div style="font-size: 15px; line-height: 1.15; max-width: 950px; margin: 0 auto 10px auto; text-align: right;">

* **מיקום הקרן (X,Y):** המונים `hsync_reg` ו-`vsync_reg` מפיקים את הקואורדינטות הדינמיות `display_x` ו-`display_y` בתוך האזור הפעיל.
* **תרגום לכתובת ליניארית:** הקואורדינטה מתורגמת מתמטית לכתובת הזיכרון `bram_address_next` ונשלחת החוצה דרך האות `addrb`.
* **שליפה מה-BRAM:** רכיב ה-`frame_buffer` מקבל את הכתובת ומשחרר את 12 הביטים של הפיקסל היישר אל האות `doutb` של בקר ה-`VGA`.

</div>

<div class="center-text" style="width: 100%;">
  <img src="../assets/vga_address_bram_flow.png" width="620" style="border-radius: 8px; box-shadow: 2px 2px 8px rgba(0,0,0,0.2);">
</div>

---
<!-- ========================================== -->
<!-- שקף 8: עיבוד הפיקסל: ניתוב ל-RGB ומנגנון ה-Blanking -->
<!-- ========================================== -->

# עיבוד הפיקסל: ניתוב ל-RGB ומנגנון ה-Blanking

<div style="font-size: 15px; line-height: 1.15; max-width: 950px; margin: 0 auto 10px auto; text-align: right;">

* **רישום ופיצול:** הנתונים מ-`doutb` ננעלים באוגר `pxl_data_reg` ומפוצלים לשגרירים: `vga_r_int` (ביטים 11:8), `vga_g_int` (7:4) ו-`vga_b_int` (3:0).
* **שומר הסף:** האות `in_display_area_delayed` משמש כדגל המזהה האם הקרן מצירת כעת על המסך או נמצאת מחוץ לתצוגה.
* **סינון דיגיטלי (Mux):** כאשר הדגל ב-'1', ערכי ה-`RGB` מועברים ליציאות `VGA_R/G/B`. בזמני ה-`Porch` וה-`Sync`, היציאות נאלצות ל-"0000" (שחור מוחלט).

</div>

<div class="center-text" style="width: 100%;">
  <img src="../assets/vga_rgb_video_on_logic.png" width="620" style="border-radius: 8px; box-shadow: 2px 2px 8px rgba(0,0,0,0.2);">
</div>

---

<!-- ========================================== -->
<!-- שקף 9: המרת DAC אנלוגית ומחבר ה-VGA         -->
<!-- ========================================== -->

<style scoped>
section { padding-top: 8px; }
</style>

# המרת DAC אנלוגית ומחבר ה-VGA

<div style="font-size: 12px; line-height: 1.15; max-width: 950px; margin: 0 auto 10px auto; text-align: right;">

* **סולם נגדים (Resistor Network):** המרת 12 ביטי ה-`RGB` למתח אנלוגי רציף באמצעות סולם נגדים (`510Ω` עד `4KΩ`).
* **אותות סנכרון (B11 / B12):** פיני היציאה מוגנים באמצעות נגדי `100Ω` ומזינים ישירות את מחבר ה-`DB15` של המסך.

</div>

<div style="display: flex; justify-content: space-between; align-items: center; margin-top: 15px; padding: 0 10px;">
  <img src="../assets/vga_dac_resistor_network.png" width="300" style="border-radius: 8px; box-shadow: 2px 2px 8px rgba(0,0,0,0.2);">
  <img src="../assets/vga_db15_connector_pins.png" width="300" style="border-radius: 8px; box-shadow: 2px 2px 8px rgba(0,0,0,0.2);">
</div>

---

<!-- ========================================== -->
<!-- שקף 10: מחלק המתח ומשקלי הביטים             -->
<!-- ========================================== -->

<style scoped>
section { padding-top: 13px; }
</style>

# מחלק המתח ומשקלי הביטים

<div style="font-size: 5px;">

<div style="font-size: 14px; line-height: 1.0; max-width: 950px; margin: 0 auto 5px auto; text-align: right;">

* **משקל פיזי לכל ביט (MSB לעומת LSB):** הביט המשמעותי ביותר (`MSB`) מחובר לנגד הקטן ביותר, ולכן מזריק את הזרם הגדול ביותר למעגל ומשפיע משמעותית על עוצמת הצבע.
* **כוונון עדין:** לעומתו, הביט הפחות משמעותי (`LSB`) מחובר לנגד הגדול ביותר בסולם. תרומתו לזרם הכולל היא מזערית ונועדה לכוונון עדין של הגוון.
* **סכימה אנלוגית על המסך:** כל הזרמים מהביטים הפעילים ('1') מתחברים וזורמים יחד דרך נגד הסיומת של המסך (`75Ω`) אל האדמה. כך נוצר מחלק מתח דינמי המפיק 0V עד 0.7V.

</div>
</div>
<div class="center-text" style="width: 100%; text-align: center;">
  <img src="../assets/vga_voltage_divider_dac.png" style="max-height: 230px; width: auto; border-radius: 8px; box-shadow: 2px 2px 8px rgba(0,0,0,0.2);">
</div>

---

<!-- ========================================== -->
<!-- שקף 11: סיכום תיאורטי: לקראת ארכיטקטורת החומרה -->
<!-- ========================================== -->

<style scoped>
section { padding-top: 13px; }
</style>

# סיכום תיאורטי: לקראת ארכיטקטורת החומרה

<div style="font-size: 8px; line-height: 1.2; max-width: 950px; margin: 0 auto 10px auto; text-align: right;">

* **האתגר הפיזיקלי:** ראינו שהמסך החיצוני דורש תזמונים מדויקים ונוקשים (Sync, Blanking) והמרת צבע רציפה (DAC) כדי לפעול כראוי.
* **המעבר פנימה (FPGA):** כדי לייצר את האותות הללו בזמן אמת ובאמינות מוחלטת, אנו נכנסים אל תוך הלוגיקה הדיגיטלית (RTL) על הכרטיס.
* **תפקיד ה-VGA Controller:** זהו רכיב הגישור הסופי במערכת. הוא שואב נתונים מהזיכרון הפנימי ומתרגם אותם לאותות הפיזיים שהמסך דורש.
* **התחנה הבאה:** נמפה את האקו-סיסטם על הכרטיס (שעונים, מצלמה, חוצץ זיכרון) ולאחר מכן נצלול פנימה אל הלוגיקה של בקר ה-VGA עצמו.

</div>

<div style="text-align: center;">

![width:500px](../assets/vga_fpga_top_architecture.png)

</div>

---

<!-- ========================================== -->
<!-- שקף 10: מבט-על - זרימת נתונים ותחומי שעון (RTL) -->
<!-- ========================================== -->

<style scoped>
section { padding-top: 13px; }
</style>

# מבט-על: זרימת נתונים ותחומי שעון (RTL)

<div style="font-size: 11px; line-height: 1.1; max-width: 1000px; margin: 0 auto 5px auto; text-align: right; opacity: 0.85;">

* **מחולל שעונים (clk_generator):** PLL המפיק שעון 25MHz ל-VGA ושעון למצלמה.
* **גישור חציית שעונים (CDC):** BRAM (Dual-Port) כחוצץ בטוח בין כתיבה לקריאה.
* **תחום אדום (Camera Domain):** קליטת פיקסלים (ov7670_capture) ודחיפה לפורט A (`clka`).
* **תחום כחול (VGA Domain):** שליפה מפורט B (`clkb`) על ידי בקר ה-VGA.

</div>

<div style="text-align: center; margin-top: 5px;">
  
  <!-- התמונה החדשה עם המסגרות, בגודל ענק ובולט -->
  ![width:850px](../assets/rtl_direct_vga_path_bounded.png)

</div>

---
<!-- ========================================== -->
<!-- שקף 11: צלילה לתכן - ניהול שעונים (Clock Generator) -->
<!-- ========================================== -->

# ניהול שעונים במערכת (Clock Generator)

<div style="font-size: 11px; line-height: 1.1; max-width: 1000px; margin: 0 auto 5px auto; text-align: right; opacity: 0.85;">

* **מקור שעון (System Clock):** כניסת `clk` מקבלת את שעון הלוח המקורי (100MHz) ומזינה את ה-PLL (`clk_wiz_0`).
* **שעון תצוגה (vga_pll):** הפקת 25MHz המזין את בקר ה-VGA (`pxl_clk`) ואת פורט הקריאה (`clkb`) ב-BRAM.
* **שעון מצלמה (xclk_pll):** הפקת שעון ייעודי של 24MHz (`xclk_ov7670`) המנותב החוצה לסנכרון המצלמה.

</div>

<center>
  ![width:900px](../assets/clk_wiz_instantiation.png)
</center>

---