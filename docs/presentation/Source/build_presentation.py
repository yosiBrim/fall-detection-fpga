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
# שקף 3: הסבר VGA (1/3) - פרוטוקול ותזמונים
# ==========================================

slide3 = prs.slides.add_slide(prs.slide_layouts[5])

title3 = slide3.shapes.title
title3.text = "מהו פרוטוקול VGA?"
set_rtl(title3.text_frame.paragraphs[0])
title3.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

# כותרת משנה עם הטקסט החדש וירידת שורה
txBox_text3 = slide3.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1.5))
tf_text3 = txBox_text3.text_frame
p1_s3 = tf_text3.paragraphs[0]
p1_s3.text = "הפרוטוקול מבוסס על סריקה קווית (raster scan) משמאל לימין ומלמעלה למטה.\nנתוני הצבע משודרים אך ורק באזור הפעיל (active video) ומלווים באותות סינכרון."
p1_s3.font.size = Pt(16)
p1_s3.alignment = PP_ALIGN.RIGHT
set_rtl(p1_s3)

# הוספת התמונה שמתארת את שלבי התצוגה וזמני השידור
# וודא שהקובץ קיים בנתיב זה בתיקיית ה-assets שלך
image_path3 = "docs/presentation/assets/vga_raster_scan_timing.png" 

if os.path.exists(image_path3):
    slide3.shapes.add_picture(image_path3, Inches(2.0), Inches(3.0), width=Inches(6.0))
else:
    # תיבת שגיאה למקרה שהתמונה חסרה
    error_box = slide3.shapes.add_textbox(Inches(2.0), Inches(3.0), Inches(6.0), Inches(1.0))
    error_p = error_box.text_frame.paragraphs[0]
    error_p.text = "[שגיאה: תמונת שלבי התצוגה לא נמצאה ב-assets]"
    error_p.font.color.rgb = RGBColor(255, 0, 0)
    error_p.alignment = PP_ALIGN.CENTER
# ==========================================
# שקף 4: הסבר VGA (2/3) - פיזיקה ושליטה
# ==========================================
# ==========================================
# שקף 4: ממשק ה-VGA - לוגיקה אנלוגית לדיגיטלית
# ==========================================
slide4 = prs.slides.add_slide(prs.slide_layouts[5])

title4 = slide4.shapes.title
title4.text = "ממשק ה-VGA:\nמהלוגיקה האנלוגית לדיגיטלית"
set_rtl(title4.text_frame.paragraphs[0])
title4.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

# יצירת תיבת טקסט עם 3 בולטים (נקודות)
txBox_text4 = slide4.shapes.add_textbox(Inches(0.5), Inches(1.5), Inches(9), Inches(1.5))
tf_text4 = txBox_text4.text_frame

# בולט 1
p1_s4 = tf_text4.add_paragraph()
p1_s4.text = "שעון הפיקסל מנהל את קצב הסריקה של קרן האלקטרונים על המסך."
p1_s4.font.size = Pt(16); p1_s4.alignment = PP_ALIGN.RIGHT; set_rtl(p1_s4)

# בולט 2
p2_s4 = tf_text4.add_paragraph()
p2_s4.text = "אותות הסנכרון שולטים בסלילי ההטיה המכוונים את מיקום הקרן."
p2_s4.font.size = Pt(16); p2_s4.alignment = PP_ALIGN.RIGHT; set_rtl(p2_s4)

# בולט 3
p3_s4 = tf_text4.add_paragraph()
p3_s4.text = "באזור תצוגה פעיל, הלוגיקה משחררת את נתוני ה-RGB לתותחי האלקטרונים."
p3_s4.font.size = Pt(16); p3_s4.alignment = PP_ALIGN.RIGHT; set_rtl(p3_s4)

# הוספת התמונה האנלוגית
image_path4 = "docs/presentation/assets/vga_analog_cathode_ray_concept.png"
if os.path.exists(image_path4):
    slide4.shapes.add_picture(image_path4, Inches(2.2), Inches(3.2), width=Inches(5.0))
# ==========================================
# שקף 6: מקרה בוחן 1 - תזמונים ומונים (שילוב הטבלה והמונים)
# ==========================================
slide6 = prs.slides.add_slide(prs.slide_layouts[5])

title6 = slide6.shapes.title
title6.text = "מקרה בוחן 1: תזמון ירידת שורה (Horizontal Blanking)"
set_rtl(title6.text_frame.paragraphs[0])

txBox_text6 = slide6.shapes.add_textbox(Inches(0.5), Inches(1.1), Inches(9), Inches(0.8))
tf_text6 = txBox_text6.text_frame
b1_s6 = tf_text6.add_paragraph()
b1_s6.text = "ניהול המונים (Horizontal/Vertical) ושליטה במנגנון ההחשכה (Blanking) לחזרת הקרן."
b1_s6.font.size = Pt(16); b1_s6.alignment = PP_ALIGN.RIGHT; set_rtl(b1_s6)

# שתי התמונות זו לצד זו (הטבלה והמונים)
image_path6_1 = os.path.join(base_path, "image_44207c.png") # טבלת תזמונים
image_path6_2 = os.path.join(base_path, "image_441d97.png") # דיאגרמת מונים

if os.path.exists(image_path6_1):
    slide6.shapes.add_picture(image_path6_1, Inches(0.2), Inches(2.2), width=Inches(4.4))
if os.path.exists(image_path6_2):
    slide6.shapes.add_picture(image_path6_2, Inches(5.0), Inches(2.5), width=Inches(4.8))

# ==========================================
# שקף 7: מקרה בוחן 2 - המרה D to A
# ==========================================
slide7 = prs.slides.add_slide(prs.slide_layouts[5])

title7 = slide7.shapes.title
title7.text = "מקרה בוחן 2: מ-RGB דיגיטלי ליציאה אנלוגית"
set_rtl(title7.text_frame.paragraphs[0])

txBox_text7 = slide7.shapes.add_textbox(Inches(0.5), Inches(1.1), Inches(9), Inches(0.8))
tf_text7 = txBox_text7.text_frame
b1_s7 = tf_text7.add_paragraph()
b1_s7.text = "המרת 12 ביטים של צבע (RGB) למתח פיזי רציף באמצעות רשת נגדים (DAC) ומחבר ה-VGA."
b1_s7.font.size = Pt(16); b1_s7.alignment = PP_ALIGN.RIGHT; set_rtl(b1_s7)

image_path7_1 = os.path.join(base_path, "image_441292.png")
image_path7_2 = os.path.join(base_path, "image_441cda.png")

if os.path.exists(image_path7_1):
    slide7.shapes.add_picture(image_path7_1, Inches(0.8), Inches(2.1), height=Inches(4.5))
if os.path.exists(image_path7_2):
    slide7.shapes.add_picture(image_path7_2, Inches(5.3), Inches(2.6), width=Inches(3.8))

# ==========================================
# שמירת המצגת
# ==========================================
output_path = os.path.join(base_path, 'VGA_Presentation_Yossi.pptx')
prs.save(output_path)
print(f"All 7 Slides generated and saved successfully at: {output_path}")