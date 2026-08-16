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

<div class="center-text">
קליטת תמונה בזמן אמת ממצלמת OV7670 והצגתה דרך כרטיס Artix-7.<br>
על מנת לאפשר עיבוד תמונה לזיהויי עמידה ממושכת לחולי דמנציה.
</div>

![bg right:40% fit](../assets/artix_board.png)

<div class="center-text" style="margin-top: 50px; font-weight: bold; font-size: 28px;">
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

# מבוא ל-VGA: קונספט תותח האלקטרונים (CRT)

* **מקור הפרוטוקול:** טכנולוגיית ה-VGA פותחה במקור עבור מסכי שפופרת קרן קתודית (CRT) המבוססים על פיזיקה אנלוגית.
* **תותח אלקטרונים:** המסך פועל באמצעות קרן פיזית הנורית על גבי מסך מצופה זרחן. עוצמת הזרם קובעת את עוצמת ההארה של כל פיקסל.
* **המורשת האנלוגית:** למרות שכיום המסכים מודרניים, הפרוטוקול מחייב שידור אותות השהייה שיאפשרו לקרן הפיזית זמן תנועה וחזרה.

![bg right:45% fit](../assets/vga_analog_cathode_ray_concept.png)

---

<!-- ========================================== -->
<!-- שקף 4: מבוא ל-VGA - סריקה קווית            -->
<!-- ========================================== -->

# מבוא ל-VGA: סריקה קווית (Raster Scan)

* הציור על המסך מבוסס על קרן שסורקת את הפיקסלים משמאל לימין (שורה) ומלמעלה למטה (פריים).
* תנועת הקרן חייבת להיות רציפה, מה שיוצר מסלול בצורת 'זיגזג'.
* בכל פעם שהקרן מגיעה לקצה (אופקי או אנכי), נדרש זמן כדי להחזיר אותה לנקודת ההתחלה (`Retrace`).

![bg left:40% fit](../assets/vga_raster_scan_retrace_concept.png)