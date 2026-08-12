from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE
from pptx.dml.color import RGBColor
import os

# פונקציה לקיבוע הטקסט לימין (RTL)
def set_rtl(paragraph):
    pPr = paragraph._p.get_or_add_pPr()
    pPr.set('rtl', '1')

# פונקציית עזר להוספת תבליט מיושר לימין (הועברה לכאן כדי למנוע שגיאות)
def add_bullet(text_frame, text):
    p = text_frame.add_paragraph()
    p.text = text
    p.font.size = Pt(16)
    p.alignment = PP_ALIGN.RIGHT
    set_rtl(p)
    return p

prs = Presentation()

base_path = r"docs\presentation\output" 
os.makedirs(base_path, exist_ok=True)

# ==========================================
# שקף 1: שער ומטרת הפרויקט
# ==========================================
slide1 = prs.slides.add_slide(prs.slide_layouts[5])

title1 = slide1.shapes.title
title1.text = "פיתוח מערכת מבוססת FPGA להתראת נפילה לחולי דמנציה"
set_rtl(title1.text_frame.paragraphs[0])
title1.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_desc = slide1.shapes.add_textbox(Inches(0.5), Inches(1.3), Inches(9), Inches(0.5))
p_desc = txBox_desc.text_frame.paragraphs[0]
p_desc.text = "קליטת תמונה בזמן אמת ממצלמת OV7670 והצגתה דרך כרטיס Artix-7."
p_desc.font.size = Pt(20)
p_desc.alignment = PP_ALIGN.CENTER
set_rtl(p_desc)

# הוספת שורה שנייה עם ירידת שורה מפורשת
p_desc2 = txBox_desc.text_frame.add_paragraph()
p_desc2.text = "על מנת לאפשר עיבוד תמונה לזיהויי עמידה ממושכת לחולי דמנציה."
p_desc2.font.size = Pt(17)
p_desc2.alignment = PP_ALIGN.CENTER
set_rtl(p_desc2)

# שליפת תמונת הבורד ישירות מהנתיב המלא בפרויקט
image_path1 = "docs/presentation/assets/artix_board.png"

if os.path.exists(image_path1):
    slide1.shapes.add_picture(image_path1, Inches(2.5), Inches(2.0), width=Inches(5))
else:
    fallback_box = slide1.shapes.add_textbox(Inches(2.5), Inches(3.0), Inches(5), Inches(1))
    fallback_p = fallback_box.text_frame.paragraphs[0]
    fallback_p.text = "[שגיאה: התמונה artix_board.png לא נמצאה]"
    fallback_p.font.size = Pt(14)
    fallback_p.font.color.rgb = RGBColor(255, 0, 0)
    fallback_p.alignment = PP_ALIGN.CENTER
    
txBox_details = slide1.shapes.add_textbox(Inches(0.5), Inches(6.3), Inches(9), Inches(0.5))
p_details = txBox_details.text_frame.paragraphs[0]
p_details.text = "מגיש: יוסי ברים | הנדסת חשמל שנה ד| המרכז האקדמי לב"
p_details.font.size = Pt(22)
p_details.font.bold = True
p_details.alignment = PP_ALIGN.CENTER
set_rtl(p_details)

# ==========================================
# שקף 2: ארכיטקטורת המערכת
# ==========================================
slide2 = prs.slides.add_slide(prs.slide_layouts[5])

title2 = slide2.shapes.title
title2.text = "ארכיטקטורת המערכת"
set_rtl(title2.text_frame.paragraphs[0])

txBox_text2 = slide2.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1))
tf_text2 = txBox_text2.text_frame

b1_s2 = tf_text2.add_paragraph()
b1_s2.text = "נתוני התמונה הגולמיים נקלטים מהמצלמה ונאגרים בזיכרון ה-BRAM."
b1_s2.font.size = Pt(18); b1_s2.alignment = PP_ALIGN.RIGHT; set_rtl(b1_s2)

b2_s2 = tf_text2.add_paragraph()
b2_s2.text = "בקר ה-VGA שולף את הנתונים ומעביר לממיר D to A לקבלת אות אנלוגי פיזי למסך."
b2_s2.font.size = Pt(18); b2_s2.alignment = PP_ALIGN.RIGHT; set_rtl(b2_s2)

top_box = slide2.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(3.8), Inches(2.4), Inches(2.2), Inches(1.8))
top_box.fill.solid(); top_box.fill.fore_color.rgb = RGBColor(0, 0, 0)
top_text = top_box.text_frame.paragraphs[0]
top_text.text = "מערכת התראת נפילה\nמבוסס FPGA"
top_text.font.color.rgb = RGBColor(255, 255, 255); top_text.alignment = PP_ALIGN.CENTER; set_rtl(top_text)

inputs_box = slide2.shapes.add_textbox(Inches(1.2), Inches(2.1), Inches(2.5), Inches(2))
inputs_box.text_frame.paragraphs[0].text = "Inputs:\nclk, reset\nov7670_vsync, href, pclk\nov7670_data[7:0]\nbtn[1:0], sw[1:0]\nscl, sda"
inputs_box.text_frame.paragraphs[0].font.size = Pt(13); inputs_box.text_frame.paragraphs[0].alignment = PP_ALIGN.RIGHT
slide2.shapes.add_shape(MSO_SHAPE.RIGHT_ARROW, Inches(3.1), Inches(3.1), Inches(0.6), Inches(0.3))

outputs_box = slide2.shapes.add_textbox(Inches(6.2), Inches(2.1), Inches(3.5), Inches(2))
outputs_box.text_frame.paragraphs[0].text = "Outputs:\nVGA_HS_O, VGA_VS_O\nVGA_R[3:0], G[3:0], B[3:0]\nov7670_xclk, pwdn, reset\nled[3:0]"
outputs_box.text_frame.paragraphs[0].font.size = Pt(13)
slide2.shapes.add_shape(MSO_SHAPE.RIGHT_ARROW, Inches(6.1), Inches(3.1), Inches(0.6), Inches(0.3))

blocks = ["ov7670_capture", "frame_buffer", "vga_controller", "D to A Converter"]
for i, b_text in enumerate(blocks):
    b = slide2.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.6 + i*2.2), Inches(5.2), Inches(1.7), Inches(0.8))
    b.fill.solid(); b.fill.fore_color.rgb = RGBColor(79, 129, 189)
    bp = b.text_frame.paragraphs[0]
    bp.text = b_text; bp.font.size = Pt(14); bp.alignment = PP_ALIGN.CENTER
    if i < 3:
        slide2.shapes.add_shape(MSO_SHAPE.RIGHT_ARROW, Inches(2.3 + i*2.2), Inches(5.5), Inches(0.5), Inches(0.2))


# ==========================================
# שקף תוספת: רקע היסטורי וקונספט תותח האלקטרונים (CRT)
# ==========================================
slide_history = prs.slides.add_slide(prs.slide_layouts[5])
title_history = slide_history.shapes.title
title_history.text = "מבוא ל-VGA: קונספט תותח האלקטרונים (CRT)"
set_rtl(title_history.text_frame.paragraphs[0])
title_history.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_history = slide_history.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1.5))
tf_history = txBox_history.text_frame

add_bullet(tf_history, "• מקור הפרוטוקול: טכנולוגיית ה-VGA פותחה במקור עבור מסכי שפופרת קרן קתודית (CRT) המבוססים על פיזיקה אנלוגית.")
add_bullet(tf_history, "• תותח אלקטרונים: המסך פועל באמצעות קרן פיזית הנורית על גבי מסך מצופה זרחן. עוצמת הזרם קובעת את עוצמת ההארה של כל פיקסל.")
add_bullet(tf_history, "• המורשת האנלוגית: למרות שכיום המסכים מודרניים, הפרוטוקול מחייב שידור אותות השהייה שיאפשרו לקרן הפיזית זמן תנועה וחזרה.")

# תמונת תותח האלקטרונים
image_path_history = "docs/presentation/assets/vga_analog_cathode_ray_concept.png" 
if os.path.exists(image_path_history):
    slide_history.shapes.add_picture(image_path_history, Inches(2.5), Inches(3.2), width=Inches(5.0))

# ==========================================
# שקף 3: צעד 1 בסיפור - הפיזיקה של הסריקה הקווית (Raster Scan)
# ==========================================
slide3 = prs.slides.add_slide(prs.slide_layouts[5])
title3 = slide3.shapes.title
title3.text = "מבוא ל-VGA: סריקה קווית (Raster Scan)"
set_rtl(title3.text_frame.paragraphs[0])
title3.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text3 = slide3.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1.5))
tf_text3 = txBox_text3.text_frame

add_bullet(tf_text3, "• הציור על המסך מבוסס על קרן שסורקת את הפיקסלים משמאל לימין (שורה) ומלמעלה למטה (פריים).")
add_bullet(tf_text3, "• תנועת הקרן חייבת להיות רציפה, מה שיוצר מסלול בצורת 'זיגזג'.")
add_bullet(tf_text3, "• בכל פעם שהקרן מגיעה לקצה (אופקי או אנכי), נדרש זמן כדי להחזיר אותה לנקודת ההתחלה (Retrace).")

# תמונת הסריקה הקווית הממחישה את הזיגזג וה-Retrace
image_path3 = "docs/presentation/assets/vga_raster_scan_retrace_concept.png" 
if os.path.exists(image_path3):
    slide3.shapes.add_picture(image_path3, Inches(2.5), Inches(3.0), width=Inches(4.5))

# ==========================================
# שקף 4: מרחב התצוגה: צלילה לערכי ה-Horizontal
# ==========================================
slide4 = prs.slides.add_slide(prs.slide_layouts[5])
title4 = slide4.shapes.title
title4.text = "מרחב התצוגה: צלילה לערכי ה-Horizontal"
set_rtl(title4.text_frame.paragraphs[0])
title4.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text4 = slide4.shapes.add_textbox(Inches(0.2), Inches(1.2), Inches(9.5), Inches(1.5))
tf_text4 = txBox_text4.text_frame

add_bullet(tf_text4, "• אזור פעיל (640 פיקסלים): המידע האקטיבי. תקן ה-VGA מקצה בדיוק 640 מחזורי שעון לציור השורה בפועל.")
add_bullet(tf_text4, "• שוליים וסנכרון (Front 16, Sync 96, Back 48): זמנים אלו נועדו במקור כדי לאפשר לקרן האלקטרונים (CRT) לכבות ולחזור שמאלה.")
add_bullet(tf_text4, "• למה זה נדרש כיום? במסכי LCD/LED מודרניים אין קרן פיזית, אך הבקרים עדיין דורשים את 'הזמנים המתים' הללו (Blanking).")
add_bullet(tf_text4, "• תאימות תקן (VESA): שמירה על תזמונים אלו היא קריטית. ללא הדיליי המדויק הזה, המסך לא יסתנכרן ויציג שגיאת 'No Signal'.")

# תמונת הגרף שמראה את האזורים הפעילים מול ה-Blanking
image_path4 = "docs/presentation/assets/vga_active_vs_blanking_regions.png" 
if os.path.exists(image_path4):
    slide4.shapes.add_picture(image_path4, Inches(2.5), Inches(3.5), width=Inches(5.0))

#cture(img2_path5, Inches(5.2), Inches(2.6), width=Inches(4.0))

# ==========================================
# שקף 5: תזמונים והחשכה בחומרה (VGA Controller)
# ==========================================
slide5 = prs.slides.add_slide(prs.slide_layouts[5])
title5 = slide5.shapes.title
title5.text = "תזמונים והחשכה בחומרה (VGA Controller)"
set_rtl(title5.text_frame.paragraphs[0])
title5.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

tx_c5 = slide5.shapes.add_textbox(Inches(0.2), Inches(1.2), Inches(9.5), Inches(1.5))
tf_c5 = tx_c5.text_frame

add_bullet(tf_c5, "• מחזור שלם (800 פיקסלים): חיבור הערכים (640+16+96+48) דורש מהמונה האופקי (h_count) לספור מ-0 ועד 799.")
add_bullet(tf_c5, "• שעון פיקסל 25MHz: כל 'פיקסל' שקול למחזור שעון אחד של 40ns. סנכרון זה מבטיח קצב ריענון תקני של 60Hz.")
add_bullet(tf_c5, "• אכיפת שחור (Blanking): מחוץ לתחום ה-640, הלוגיקה שלנו מאלצת \"0000\" ב-RGB כדי למנוע 'מריחות' צבע בעת תנועת הקרן.")

# 1. דיאגרמת הבלוקים והמונים (RTL Schematic)
img1_path5 = "docs/presentation/assets/vga_counters_rtl_schematic.png"
if os.path.exists(img1_path5):
    slide5.shapes.add_picture(img1_path5, Inches(0.5), Inches(3.2), width=Inches(4.5))

# 2. גרף התזמונים והטבלה שממנה נגזרים הערכים
img2_path5 = "docs/presentation/assets/vga_timing_waveform_and_table.png"
if os.path.exists(img2_path5):
    slide5.shapes.add_picture(img2_path5, Inches(5.2), Inches(2.8), width=Inches(4.0))

# ==========================================
# שקף 6: מסלול הנתונים - חישוב כתובת ושליפה מה-BRAM
# ==========================================
slide6 = prs.slides.add_slide(prs.slide_layouts[5])
title6 = slide6.shapes.title
title6.text = "מסלול הנתונים: חישוב כתובת הפיקסל ושליפה"
set_rtl(title6.text_frame.paragraphs[0])
title6.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text6 = slide6.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1.5))
tf_text6 = txBox_text6.text_frame

add_bullet(tf_text6, "• מיקום הקרן (X,Y): המונים hsync_reg ו-vsync_reg מפיקים את הקואורדינטות הדינמיות display_x ו-display_y בתוך האזור הפעיל.")
add_bullet(tf_text6, "• תרגום לכתובת ליניארית: הקואורדינטה מתורגמת מתמטית לכתובת הזיכרון bram_address_next ונשלחת החוצה דרך האות addrb.")
add_bullet(tf_text6, "• שליפה מה-BRAM: רכיב ה-frame_buffer מקבל את הכתובת ומשחרר את 12 הביטים של הפיקסל היישר אל האות doutb של בקר ה-VGA.")

img_path6 = "docs/presentation/assets/vga_address_bram_flow.png" 
if os.path.exists(img_path6):
    slide6.shapes.add_picture(img_path6, Inches(2.5), Inches(3.2), width=Inches(5.0))

# ==========================================
# שקף 7: פענוח הצבע ובקרת הוידאו
# ==========================================
slide7 = prs.slides.add_slide(prs.slide_layouts[5])
title7 = slide7.shapes.title
title7.text = "עיבוד הפיקסל: ניתוב ל-RGB ומנגנון ה-Blanking"
set_rtl(title7.text_frame.paragraphs[0])
title7.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text7 = slide7.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1.5))
tf_text7 = txBox_text7.text_frame

add_bullet(tf_text7, "• רישום ופיצול: הנתונים מ-doutb ננעלים באוגר pxl_data_reg ומפוצלים לשגרירים: vga_r_int (ביטים 11:8), vga_g_int (7:4) ו-vga_b_int (3:0).")
add_bullet(tf_text7, "• שומר הסף: האות in_display_area_delayed משמש כדגל המזהה האם הקרן מצוירת כעת על המסך או נמצאת מחוץ לתצוגה.")
add_bullet(tf_text7, "• סינון דיגיטלי (Mux): כאשר הדגל ב-'1', ערכי ה-RGB מועברים ליציאות VGA_R/G/B. בזמני ה-Porch וה-Sync, היציאות נאלצות ל-\"0000\" (שחור מוחלט).")

img_path7 = "docs/presentation/assets/vga_rgb_video_on_logic.png" 
if os.path.exists(img_path7):
    slide7.shapes.add_picture(img_path7, Inches(2.5), Inches(3.2), width=Inches(5.0))

# ==========================================
# שקף 8: המעבר לעולם האנלוגי ומחבר ה-VGA (DAC)
# ==========================================
slide8 = prs.slides.add_slide(prs.slide_layouts[5])
title8 = slide8.shapes.title
title8.text = "המרת DAC אנלוגית ומחבר ה-VGA"
set_rtl(title8.text_frame.paragraphs[0])
title8.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text8 = slide8.shapes.add_textbox(Inches(0.5), Inches(1.1), Inches(9), Inches(1.0))
tf_text8 = txBox_text8.text_frame

add_bullet(tf_text8, "• סולם נגדים (Resistor Network): המרת 12 ביטי ה-RGB למתח אנלוגי רציף באמצעות משקולות נגדים (510Ω עד 4KΩ).")
add_bullet(tf_text8, "• אותות סנכרון (B11 / B12): פיני היציאה מוגנים באמצעות נגדי 100Ω ומזינים ישירות את מחבר ה-DB15 של המסך.")

img_path8_1 = "docs/presentation/assets/vga_dac_resistor_network.png" 
if os.path.exists(img_path8_1):
    slide8.shapes.add_picture(img_path8_1, Inches(0.5), Inches(2.3), width=Inches(4.4))

img_path8_2 = "docs/presentation/assets/vga_db15_connector_pins.png" 
if os.path.exists(img_path8_2):
    slide8.shapes.add_picture(img_path8_2, Inches(5.1), Inches(2.5), width=Inches(4.4))

# ==========================================
# שקף 9: עומק הנדסי - הפיזיקה של מחלק המתח (MSB/LSB)
# ==========================================
slide9 = prs.slides.add_slide(prs.slide_layouts[5])
title9 = slide9.shapes.title
title9.text = "עומק הנדסי: מחלק המתח ומשקלי הביטים"
set_rtl(title9.text_frame.paragraphs[0])
title9.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text9 = slide9.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1.5))
tf_text9 = txBox_text9.text_frame

add_bullet(tf_text9, "• משקל פיזי לכל ביט (MSB לעומת LSB): הביט המשמעותי ביותר (MSB) מחובר לנגד הקטן ביותר, ולכן מזזרים את הזרם הגדול ביותר למעגל ומשפיע משמעותית על עוצמת הצבע.")
add_bullet(tf_text9, "• כוונון עדין: לעומתו, הביט הפחות משמעותי (LSB) מחובר לנגד הגדול ביותר בסולם. תרומתו לזרם הכולל היא מזערית ונועדה לכוונון עדין של הגוון.")
add_bullet(tf_text9, "• סכימה אנלוגית על המסך: כל הזרמים מהביטים הפעילים ('1') מתחברים וזורמים יחד דרך נגד הסיומת של המסך (75Ω) אל האדמה. כך נוצר מחלק מתח דינמי המפיק 0V עד 0.7V.")

img_path9 = "docs/presentation/assets/vga_voltage_divider_dac.png" 
if os.path.exists(img_path9):
    slide9.shapes.add_picture(img_path9, Inches(1.5), Inches(3.2), width=Inches(7.0))

# ==========================================
# שקף 10: מבט-על - זרימת נתונים ותחומי שעון (RTL)
# ==========================================
slide10 = prs.slides.add_slide(prs.slide_layouts[5])
title10 = slide10.shapes.title
title10.text = "מבט-על: זרימת נתונים ותחומי שעון (RTL)"
set_rtl(title10.text_frame.paragraphs[0])
title10.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text10 = slide10.shapes.add_textbox(Inches(0.2), Inches(1.2), Inches(9.5), Inches(1.5))
tf_text10 = txBox_text10.text_frame

add_bullet(tf_text10, "• מחולל שעונים (clk_generator): רכיב PLL המקבל שעון מערכת ומפיק שעון 25MHz נפרד ל-VGA ושעון ייעודי למצלמה.")
add_bullet(tf_text10, "• גישור חציית שעונים (CDC): זיכרון ה-BRAM (בתצורת Dual-Port) פועל כחוצץ בטוח בין קצב הכתיבה לקצב הקריאה.")
add_bullet(tf_text10, "• תחום אדום (Camera Domain): קליטת הפיקסלים מהמצלמה (ov7670_capture) ודחיפתם לפורט A של הזיכרון (clka).")
add_bullet(tf_text10, "• תחום כחול (VGA Domain): המיקוד שלנו – שליפת הפיקסלים מפורט B (clkb) על ידי בקר ה-VGA וייצור אותות התצוגה.")

# תמונת ה-RTL
img_path10 = "docs/presentation/assets/rtl_direct_vga_path.png"
if os.path.exists(img_path10):
    # מיקום התמונה (ממורכזת)
    slide10.shapes.add_picture(img_path10, Inches(0.5), Inches(3.0), width=Inches(9.0))
    
    # יצירת מסגרת אדומה (Camera Domain) - צד שמאל ועד אמצע הזיכרון
    red_box = slide10.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(1.0), Inches(3.2), Inches(4.0), Inches(3.8))
    red_box.fill.background() # הופך את תוכן הריבוע לשקוף
    red_box.line.color.rgb = RGBColor(255, 0, 0) # צבע אדום
    red_box.line.width = Pt(3)
    
    # יצירת מסגרת כחולה (VGA Domain - התחום שלך) - מאמצע הזיכרון ועד ימין
    blue_box = slide10.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(5.1), Inches(3.2), Inches(4.0), Inches(3.8))
    blue_box.fill.background() # הופך את תוכן הריבוע לשקוף
    blue_box.line.color.rgb = RGBColor(0, 112, 192) # צבע כחול
    blue_box.line.width = Pt(4) # קצת יותר עבה כדי להדגיש שזה התחום שלך


# ==========================================
# שקף 11: צלילה לתכן - ניהול שעונים (Clock Generator)
# ==========================================
slide11 = prs.slides.add_slide(prs.slide_layouts[5])
title11 = slide11.shapes.title
title11.text = "ניהול שעונים במערכת (Clock Generator)"
set_rtl(title11.text_frame.paragraphs[0])
title11.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text11 = slide11.shapes.add_textbox(Inches(0.2), Inches(1.2), Inches(9.5), Inches(1.5))
tf_text11 = txBox_text11.text_frame

# שימוש ממוקד במספרים ושמות האותות מתוך הלוגיקה
add_bullet(tf_text11, "• מקור שעון (System Clock): כניסת clk מקבלת את שעון הלוח המקורי (100MHz) ומזינה את ה-PLL (clk_wiz_0).")
add_bullet(tf_text11, "• שעון תצוגה (vga_pll): ה-PLL מפיק תדר של 25MHz המזין את בקר ה-VGA (pxl_clk) ואת פורט הקריאה (clkb) ב-BRAM.")
add_bullet(tf_text11, "• שעון מצלמה (xclk_pll): הפקת שעון ייעודי של 24MHz (xclk_ov7670) המנותב החוצה לסנכרון רכיב המצלמה.")

# הכנה לתמונה מתאימה (סניפט קוד או סכמת בלוק של clk_wiz_0)
img_path11 = "docs/presentation/assets/clk_wiz_instantiation.png"
if os.path.exists(img_path11):
    slide11.shapes.add_picture(img_path11, Inches(2.5), Inches(3.2), width=Inches(5.0))
    

# ==========================================
# שמירת המצגת
# ==========================================
output_path = os.path.join(base_path, 'VGA_Presentation_Yossi.pptx')
prs.save(output_path)
print(f"All {len(prs.slides)} Slides generated and saved successfully at: {output_path}")