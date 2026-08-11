from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN

def create_presentation():
    # יצירת המצגת
    prs = Presentation()

    # --- שקף 1: כותרת ---
    slide_layout_title = prs.slide_layouts[0] 
    slide_1 = prs.slides.add_slide(slide_layout_title)
    
    title_1 = slide_1.shapes.title
    subtitle_1 = slide_1.placeholders[1]
    
    title_1.text = "פיתוח מערכת מבוססת FPGA להתראת נפילה לחולי דמנציה"
    subtitle_1.text = "קליטת תמונה בזמן אמת ממצלמת OV7670 והצגתה דרך כרטיס Artix-7.\nמגיש: יוסי ברים | הנדסת חשמל שנה ד', המרכז האקדמי לב"


    # --- שקף 2: ארכיטקטורת המערכת ---
    slide_layout_content = prs.slide_layouts[1] # שקף עם כותרת ותוכן
    slide_2 = prs.slides.add_slide(slide_layout_content)
    
    slide_2.shapes.title.text = "ארכיטקטורת המערכת"
    tf_2 = slide_2.shapes.placeholders[1].text_frame
    tf_2.text = "נתוני התמונה הגולמיים נקלטים מהמצלמה ונאגרים בזיכרון ה-BRAM."
    tf_2.add_paragraph().text = "בקר ה-VGA שולף את הנתונים ומעביר לממיר D to A לקבלת אות אנלוגי פיזי למסך."
    
    # תוספת פירוט הבלוקים והאותות
    p = tf_2.add_paragraph()
    p.text = "מערכת התראת נפילה (Top Level):"
    p.level = 0
    tf_2.add_paragraph().text = "Inputs: clk, reset, ov7670_vsync, href, pclk, ov7670_data[7:0], btn[1:0], sw[1:0], scl, sda"
    tf_2.add_paragraph().text = "Outputs: VGA_HS_O, VGA_VS_O, VGA_R[3:0], G[3:0], B[3:0], ov7670_xclk, pwdn, reset, led[3:0]"
    tf_2.add_paragraph().text = "מודולים פנימיים: ov7670_capture, frame_buffer, vga_controller, D to A Converter"


    # --- שקף 3: ממשק ה-VGA (פרוטוקול) ---
    slide_3 = prs.slides.add_slide(slide_layout_content)
    slide_3.shapes.title.text = "ממשק ה-VGA: פרוטוקול ותזמונים"
    tf_3 = slide_3.shapes.placeholders[1].text_frame
    tf_3.text = "הפרוטוקול מבוסס על סריקה קווית (Raster Scan) ואותות סנכרון מדויקים (HSYNC, VSYNC)."
    # (כאן בעתיד נוסיף את התמונה של טבלת התזמונים)


    # --- שקף 4: ממשק ה-VGA (חומרה ופיזיקה) ---
    slide_4 = prs.slides.add_slide(slide_layout_content)
    slide_4.shapes.title.text = "ממשק ה-VGA: שליטה חומרתית ופיזיקה"
    tf_4 = slide_4.shapes.placeholders[1].text_frame
    tf_4.text = "שעון הפיקסל מנהל את קצב הסריקה של קרן האלקטרונים (Cathode ray) על המסך."
    tf_4.add_paragraph().text = "אותות הסנכרון שולטים בסלילי ההטיה המכוונים את מיקום הקרן."
    tf_4.add_paragraph().text = "באזור תצוגה פעיל, הלוגיקה משחררת את נתוני ה-RGB לתותחי האלקטרונים (Electron guns)."


    # --- שקף 5: ממשק ה-VGA (נתיב נתונים) ---
    slide_5 = prs.slides.add_slide(slide_layout_content)
    slide_5.shapes.title.text = "ממשק ה-VGA: מיקום בקר ה-VGA בנתיב הנתונים"
    tf_5 = slide_5.shapes.placeholders[1].text_frame
    tf_5.text = "הבקר מקבל שעון פיקסל (25MHz) מבלוק ניהול השעונים של המערכת."
    tf_5.add_paragraph().text = "המימוש הלוגי מחשב ומשדר כתובת (addrb) כדי לשלוף נתונים (doutb) ישירות מזיכרון ה-BRAM."
    # (כאן בעתיד נוסיף דיאגרמת RTL)


    # --- שקף 6: מקרה בוחן 1 ---
    slide_6 = prs.slides.add_slide(slide_layout_content)
    slide_6.shapes.title.text = "מקרה בוחן 1: תזמון ירידת שורה (Horizontal Blanking)"
    tf_6 = slide_6.shapes.placeholders[1].text_frame
    tf_6.text = "ניהול המונים (Horizontal/Vertical) ושליטה במנגנון ההחשכה (Blanking) לחזרת הקרן."
    # (כאן בעתיד נוסיף את שרטוט מונה הסנכרון האופקי)


    # --- שקף 7: מקרה בוחן 2 ---
    slide_7 = prs.slides.add_slide(slide_layout_content)
    slide_7.shapes.title.text = "מקרה בוחן 2: מ-RGB דיגיטלי ליציאה אנלוגית"
    tf_7 = slide_7.shapes.placeholders[1].text_frame
    tf_7.text = "המרת 12 ביטים של צבע (RGB) למתח פיזי רציף באמצעות רשת נגדים (DAC) ומחבר ה-VGA."
    # (כאן בעתיד נוסיף את שרטוט המעגל האנלוגי)


    # שמירת הקובץ
    output_file = r"C:\Users\USER\Desktop\לימודים\שנה ד\סמסטר א\פרוייקט ערן\clone\fall-detection-fpga\docs\presentation\output\VGA_Presentation_Yossi.pptx"
    prs.save(output_file)
    print(f"המצגת נבנתה ונשמרה בהצלחה בנתיב:\n{output_file}")

if __name__ == "__main__":
    create_presentation()