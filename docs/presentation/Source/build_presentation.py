import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN
from pptx.dml.color import RGBColor

def set_rtl(paragraph):
    """פונקציית עזר להגדרת כיוון טקסט מימין לשמאל (RTL)"""
    paragraph.font.rtl = True
    paragraph.alignment = PP_ALIGN.RIGHT

def add_bullet(text_frame, text):
    """פונקציית עזר להוספת תבליט מיושר לימין"""
    p = text_frame.add_paragraph()
    p.text = text
    set_rtl(p)
    p.font.size = Pt(18)
    return p

# יצירת אובייקט מצגת
prs = Presentation()

# ==========================================
# שקף 1: שער המצגת
# ==========================================
slide1 = prs.slides.add_slide(prs.slide_layouts[0])
title1 = slide1.shapes.title
subtitle1 = slide1.placeholders[1]

title1.text = "פיתוח מערכת משובצת מחשב לזיהוי נפילות בזמן אמת"
set_rtl(title1.text_frame.paragraphs[0])
title1.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

subtitle1.text = "מימוש חומרתי על כרטיס Artix-7 (Basys 3)\nממשק VGA ותקשורת מצלמה"
set_rtl(subtitle1.text_frame.paragraphs[0])
subtitle1.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

img_path1 = "docs/presentation/assets/artix_board.png"
if os.path.exists(img_path1):
    slide1.shapes.add_picture(img_path1, Inches(3), Inches(4.5), width=Inches(4))

# ==========================================
# שקף 2: מבט-על - ארכיטקטורת המערכת
# ==========================================
slide2 = prs.slides.add_slide(prs.slide_layouts[5])
title2 = slide2.shapes.title
title2.text = "ארכיטקטורת המערכת וזרימת הנתונים"
set_rtl(title2.text_frame.paragraphs[0])
title2.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text2 = slide2.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1.5))
tf_text2 = txBox_text2.text_frame
add_bullet(tf_text2, "• איסוף נתונים: מצלמת OV7670 דוגמת את הווידאו ומעבירה אותו דרך בקר ייעודי.")
add_bullet(tf_text2, "• זיכרון מרכזי (Frame Buffer): הנתונים נשמרים בזיכרון BRAM המשמש חוצץ בין שעון המצלמה לשעון המסך.")
add_bullet(tf_text2, "• תצוגה: בקר ה-VGA קורא ברציפות מהזיכרון ומייצר את אותות הסנכרון והצבע למסך.")

# ==========================================
# שקף 3: רקע היסטורי וקונספט תותח האלקטרונים (CRT)
# ==========================================
slide3 = prs.slides.add_slide(prs.slide_layouts[5])
title3 = slide3.shapes.title
title3.text = "מבוא ל-VGA: קונספט תותח האלקטרונים (CRT)"
set_rtl(title3.text_frame.paragraphs[0])
title3.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text3 = slide3.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1.5))
tf_text3 = txBox_text3.text_frame
add_bullet(tf_text3, "• מקור הפרוטוקול: טכנולוגיית ה-VGA פותחה במקור עבור מסכי שפופרת קרן קתודית (CRT) המבוססים על פיזיקה אנלוגית.")
add_bullet(tf_text3, "• תותח אלקטרונים: המסך פועל באמצעות קרן פיזית הנורית על גבי מסך מצופה זרחן. עוצמת הזרם קובעת את עוצמת ההארה של כל פיקסל.")
add_bullet(tf_text3, "• המורשת האנלוגית: למרות שכיום המסכים מודרניים, הפרוטוקול מחייב שידור אותות השהייה שיאפשרו לקרן הפיזית זמן תנועה וחזרה.")

img_path3 = "docs/presentation/assets/vga_analog_cathode_ray_concept.png" 
if os.path.exists(img_path3):
    slide3.shapes.add_picture(img_path3, Inches(2.5), Inches(3.2), width=Inches(5.0))

# ==========================================
# שקף 4: עקרונות תצוגה – סריקה קווית (Raster Scan)
# ==========================================
slide4 = prs.slides.add_slide(prs.slide_layouts[5])
title4 = slide4.shapes.title
title4.text = "עקרונות תצוגה: סריקה קווית (Raster Scan)"
set_rtl(title4.text_frame.paragraphs[0])
title4.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text4 = slide4.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1.5))
tf_text4 = txBox_text4.text_frame
add_bullet(tf_text4, "• ציור רציף: התמונה נבנית על ידי סריקת פיקסלים משמאל לימין ומלמעלה למטה.")
add_bullet(tf_text4, "• חזרה אופקית (H-Retrace): בסיום כל שורה, על הקרן לחזור לצידו השמאלי של המסך כדי להתחיל שורה חדשה.")
add_bullet(tf_text4, "• חזרה אנכית (V-Retrace): בסיום פריים שלם, הקרן חוזרת לפינה השמאלית העליונה לפריים הבא.")

img_path4 = "docs/presentation/assets/vga_raster_scan_retrace_concept.png"
if os.path.exists(img_path4):
    slide4.shapes.add_picture(img_path4, Inches(2), Inches(3.5), width=Inches(6.0))

# ==========================================
# שקף 5: מרחב התצוגה ואזורי החשכה (Blanking)
# ==========================================
slide5 = prs.slides.add_slide(prs.slide_layouts[5])
title5 = slide5.shapes.title
title5.text = "מרחב התצוגה ואזורי החשכה"
set_rtl(title5.text_frame.paragraphs[0])
title5.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text5 = slide5.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1.5))
tf_text5 = txBox_text5.text_frame
add_bullet(tf_text5, "• אזור פעיל (Active Video): הזמן בו הקרן מציירת פיקסלים רלוונטיים על המסך.")
add_bullet(tf_text5, "• שוליים (Front/Back Porch): אזורי ביטחון (השחרה) המפרידים בין מידע הצבע לבין פולס הסנכרון.")
add_bullet(tf_text5, "• פולס סנכרון (Sync Pulse): פקודה לוגית המורה למסך לבצע את החזרה בפועל (אופקית או אנכית).")

img_path5 = "docs/presentation/assets/vga_active_vs_blanking_regions.png"
if os.path.exists(img_path5):
    slide5.shapes.add_picture(img_path5, Inches(2), Inches(3.5), width=Inches(6.0))

# ==========================================
# שקף 6: תזמונים ומונים בחומרה (VHDL)
# ==========================================
slide6 = prs.slides.add_slide(prs.slide_layouts[5])
title6 = slide6.shapes.title
title6.text = "מימוש בחומרה: מוני סנכרון ותזמונים"
set_rtl(title6.text_frame.paragraphs[0])
title6.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text6 = slide6.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1.5))
tf_text6 = txBox_text6.text_frame
add_bullet(tf_text6, "• שעון פיקסל (25MHz): קצב העבודה נגזר מדרישת התקן ל-640x480 ב-60Hz.")
add_bullet(tf_text6, "• מונה אופקי (h_count): סופר פיקסלים בשורה (0 עד 799). מאתחל את המונה האנכי בסיום שורה.")
add_bullet(tf_text6, "• מונה אנכי (v_count): סופר שורות במסך (0 עד 520).")

img_path6_1 = "docs/presentation/assets/vga_timing_waveform_and_table.png"
if os.path.exists(img_path6_1):
    slide6.shapes.add_picture(img_path6_1, Inches(0.5), Inches(3.2), width=Inches(4.5))

img_path6_2 = "docs/presentation/assets/vga_counters_rtl_schematic.png"
if os.path.exists(img_path6_2):
    slide6.shapes.add_picture(img_path6_2, Inches(5.5), Inches(3.2), width=Inches(4.0))

# ==========================================
# שקף 7: מסלול הנתונים ושליפה מ-BRAM
# ==========================================
slide7 = prs.slides.add_slide(prs.slide_layouts[5])
title7 = slide7.shapes.title
title7.text = "מסלול הנתונים (Data Path): משעון לכתובת"
set_rtl(title7.text_frame.paragraphs[0])
title7.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text7 = slide7.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1.5))
tf_text7 = txBox_text7.text_frame
add_bullet(tf_text7, "• תרגום קואורדינטות: מוני ה-X וה-Y המציינים את מיקום הקרן עוברים מניפולציה מתמטית.")
add_bullet(tf_text7, "• יצירת כתובת (Address Generation): הקואורדינטות הופכות לכתובת לינארית חד-ממדית (addrb).")
add_bullet(tf_text7, "• שליפת המידע: הכתובת מועברת ל-BRAM, שמוציא בתגובה וקטור של 12 ביטים (doutb) המייצג את צבע הפיקסל.")

img_path7 = "docs/presentation/assets/vga_address_bram_flow.png"
if os.path.exists(img_path7):
    slide7.shapes.add_picture(img_path7, Inches(2), Inches(3.5), width=Inches(6.0))

# ==========================================
# שקף 8: ניתוב RGB ובקרת Blanking
# ==========================================
slide8 = prs.slides.add_slide(prs.slide_layouts[5])
title8 = slide8.shapes.title
title8.text = "ניתוב RGB ובקרת סינון (Blanking Logic)"
set_rtl(title8.text_frame.paragraphs[0])
title8.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text8 = slide8.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1.5))
tf_text8 = txBox_text8.text_frame
add_bullet(tf_text8, "• חלוקה לערוצים: וקטור ה-12 ביט (doutb) מפוצל ל-3 וקטורים של 4 ביטים: אדום, ירוק וכחול.")
add_bullet(tf_text8, "• דגל Display Enable: האות in_display_area מזהה מתי הקרן נמצאת מחוץ לאזור הפעיל (בזמן Retrace או Porch).")
add_bullet(tf_text8, "• החשכה אקטיבית: מעגל מרבב (MUX) מאלץ את נתוני הצבע ל-0000 כאשר אנו מחוץ לתצוגה, כדי למנוע שיבושים במסך.")

img_path8 = "docs/presentation/assets/vga_rgb_video_on_logic.png"
if os.path.exists(img_path8):
    slide8.shapes.add_picture(img_path8, Inches(2.5), Inches(3.5), width=Inches(5.0))

# ==========================================
# שקף 9: סולם הנגדים ומחבר ה-VGA (DAC)
# ==========================================
slide9 = prs.slides.add_slide(prs.slide_layouts[5])
title9 = slide9.shapes.title
title9.text = "ממיר דיגיטלי לאנלוגי: מביטים לזרמים"
set_rtl(title9.text_frame.paragraphs[0])
title9.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text9 = slide9.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1.5))
tf_text9 = txBox_text9.text_frame
add_bullet(tf_text9, "• ממשק פיזי (HD-DB15): המחבר החיצוני דורש מתחים אנלוגיים (0V-0.7V) עבור כל צבע (פינים 1,2,3).")
add_bullet(tf_text9, "• DAC מבוסס נגדים: כרטיס ה-Artix-7 משתמש ברשת נגדים פסיבית (R-2R Ladder) להמרת ה-4 ביטים של כל צבע למתח.")
add_bullet(tf_text9, "• הגנת סנכרון: פיני ה-HSYNC וה-VSYNC מוגנים על ידי נגדים בטור למניעת זרם קצר.")

img_path9_1 = "docs/presentation/assets/vga_dac_resistor_network.png"
if os.path.exists(img_path9_1):
    slide9.shapes.add_picture(img_path9_1, Inches(0.5), Inches(3.5), width=Inches(4.5))

img_path9_2 = "docs/presentation/assets/vga_db15_connector_pins.png"
if os.path.exists(img_path9_2):
    slide9.shapes.add_picture(img_path9_2, Inches(5.5), Inches(3.5), width=Inches(4.0))

# ==========================================
# שקף 10: עומק הנדסי - מחלק המתח ומשקלי הביטים
# ==========================================
slide10 = prs.slides.add_slide(prs.slide_layouts[5])
title10 = slide10.shapes.title
title10.text = "עומק הנדסי: מחלק המתח ומשקלי הביטים"
set_rtl(title10.text_frame.paragraphs[0])
title10.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER

txBox_text10 = slide10.shapes.add_textbox(Inches(0.5), Inches(1.2), Inches(9), Inches(1.5))
tf_text10 = txBox_text10.text_frame
add_bullet(tf_text10, "• משקל פיזי לכל ביט (MSB לעומת LSB): ה-MSB מחובר לנגד הקטן ביותר, מזרים את הזרם הגדול ביותר ומשפיע משמעותית על הצבע.")
add_bullet(tf_text10, "• כוונון עדין: ה-LSB מחובר לנגד הגדול ביותר בסולם ומשמש לכוונון עדין של הגוון.")
add_bullet(tf_text10, "• סכימה אנלוגית על המסך: כל הזרמים מתחברים וזורמים דרך נגד הסיומת של המסך (75Ω). כך נוצר מחלק מתח המפיק 0V-0.7V.")

img_path10 = "docs/presentation/assets/vga_voltage_divider_dac.png" 
if os.path.exists(img_path10):
    slide10.shapes.add_picture(img_path10, Inches(1.5), Inches(3.2), width=Inches(7.0))

# ==========================================
# שמירת המצגת
# ==========================================
output_dir = "docs/presentation/output"
os.makedirs(output_dir, exist_ok=True)
output_path = os.path.join(output_dir, "VGA_Presentation_Yossi.pptx")
prs.save(output_path)

print(f"All 10 Slides generated and saved successfully at: {output_path}")