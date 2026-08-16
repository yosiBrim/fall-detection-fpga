#set page(paper: "presentation-16-9")
#set text(lang: "he", dir: rtl, font: ("Arial", "Segoe UI"), size: 24pt)

#let slide(title, body) = {
  page[
    #align(center)[#text(size: 36pt, weight: "bold", fill: rgb("#2c3e50"), title)]
    #v(1em)
    #body
  ]
}

#slide("פיתוח מערכת מבוססת FPGA להתראת נפילה")[
  #align(center)[
    קליטת תמונה בזמן אמת ממצלמת OV7670 והצגתה דרך כרטיס Artix-7. \
    על מנת לאפשר עיבוד תמונה לזיהויי עמידה ממושכת לחולי דמנציה.
  ]
  #v(1em)
  #align(center)[
    #rect(width: 50%, height: 200pt, fill: luma(230))[
      // כאן תיכנס התמונה של הלוח
      (מקום לתמונה: artix_board.png)
    ]
  ]
  #v(1em)
  #align(center)[*מגיש: יוסי ברים | הנדסת חשמל שנה ד | המרכז האקדמי לב*]
]

#slide("ארכיטקטורת המערכת")[
  - נתוני התמונה הגולמיים נקלטים מהמצלמה ונאגרים בזיכרון ה-#text(dir: ltr)[BRAM].
  - בקר ה-#text(dir: ltr)[VGA] שולף את הנתונים ומעביר לממיר ה-#text(dir: ltr)[DAC] לקבלת אות אנלוגי פיזי למסך.
]

#slide("תזמוני VGA: הפיזיקה מאחורי המספרים")[
  #table(
    columns: (1.5fr, 1fr, 3fr, 3fr),
    fill: (col, row) => if row == 0 { rgb("#2980b9") } else { none },
    [*פרמטר*], [*מחזורי שעון*], [*הצורך הפיזיקלי המקורי*], [*המימוש שלנו (RTL)*],
    text(dir: ltr)[Active Display], [640], [הקרן מציירת את הפיקסלים הפיזיים.], [שליפת נתונים ושידור צבע פעיל.],
    text(dir: ltr)[Front Porch], [16], [מרווח זמן לקרן 'להירגע'.], [כיבוי מיידי של ה-RGB ל-0000.]
  )
]
