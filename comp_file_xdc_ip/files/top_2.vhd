LIBRARY ieee;
USE ieee.std_logic_1164.ALL; -- מאפשר שימוש ב-STD_LOGIC (סיביות 0/1)
USE ieee.numeric_std.ALL;    -- מאפשר פעולות מתמטיות על וקטורים

ENTITY top IS
    PORT (
        clk : IN STD_LOGIC;           -- שעון ראשי של הלוח (בדרך כלל 100MHz) [cite: 1
        reset : IN STD_LOGIC;         -- כפתור ריסט פיזי
        
        -- תקשורת I2C להגדרת המצלמה
        scl : INOUT STD_LOGIC;        -- שעון התקשורת
        sda : INOUT STD_LOGIC;        -- קו המידע (דו-כיווני)

        -- אותות נכנסים מהמצלמה (Inputs)
        ov7670_vsync : IN STD_LOGIC;  -- Vertical Sync: המצלמה מודיעה על התחלת תמונה חדשה
        ov7670_href : IN STD_LOGIC;   -- Horizontal Ref: המצלמה מודיעה שיש מידע בשורה הנוכחית
        ov7670_pclk : IN STD_LOGIC;   -- Pixel Clock: שעון שמגיע מהמצלמה ומסנכרן את המידע
        ov7670_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0); [cite_start]-- 8 ביטים של מידע צבע שמגיעים מהמצלמה [cite: 2]

        -- אותות יוצאים למצלמה (Outputs)
        ov7670_xclk : OUT STD_LOGIC;  -- שעון שאנחנו מייצרים עבור המצלמה כדי שתעבוד
        ov7670_pwdn : OUT STD_LOGIC;  -- Power Down: חיבור ל-'0' מפעיל את המצלמה
        ov7670_reset : OUT STD_LOGIC; -- Reset: חיבור ל-'1' מונע ריסט למצלמה

        -- ממשק משתמש (User Interface)
        btn : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- כפתורים (להתחלת הגדרה או צילום)
        sw : IN STD_LOGIC_VECTOR(0 DOWNTO 0);  -- מתג (Switch) להפעלת התצוגה
        led : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- נורות לד לחיווי סטטוס

        -- יציאות למסך VGA
        VGA_HS_O : OUT STD_LOGIC;     -- סנכרון אופקי למסך
        VGA_VS_O : OUT STD_LOGIC;     -- סנכרון אנכי למסך
        VGA_R : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); [cite_start]-- 4 ביט לצבע האדום [cite: 2-3]
        VGA_B : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- 4 ביט לצבע הכחול
        VGA_G : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)  -- 4 ביט לצבע הירוק
    );
END top;

ARCHITECTURE rtl OF top IS
    -- אותות בקרה כלליים
    SIGNAL rst : STD_LOGIC := '1';
    SIGNAL edge : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); -- מזהה לחיצת כפתור נקייה
    SIGNAL config_finished : STD_LOGIC := '0'; [cite_start]-- דגל: האם סיימנו להגדיר את המצלמה? [cite: 6]
    
    -- שעונים
    SIGNAL pxl_clk : STD_LOGIC := '0';      -- שעון פיקסלים למסך (25MHz)
    SIGNAL xclk_ov7670 : STD_LOGIC := '0';  -- שעון למצלמה (נוצר ע"י ה-PLL)
    
    -- אותות לניהול הזיכרון (RAM) - צד כתיבה (מגיע מהמצלמה)
    SIGNAL ena : STD_LOGIC := '1'; -- אפשור כללי
    SIGNAL wea : STD_LOGIC_VECTOR(0 DOWNTO 0) := (OTHERS => '0'); -- פקודת כתיבה (Write Enable)
    SIGNAL addra : STD_LOGIC_VECTOR(18 DOWNTO 0) := (OTHERS => '0'); -- כתובת לכתיבה בזיכרון [cite: 7]
    SIGNAL dina : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');  [cite_start]-- המידע (פיקסל) לכתיבה [cite: 8]
    
    -- אותות לניהול הזיכרון (RAM) - צד קריאה (הולך למסך)
    SIGNAL enb : STD_LOGIC := '1';
    SIGNAL addrb : STD_LOGIC_VECTOR(18 DOWNTO 0) := (OTHERS => '0'); [cite_start]-- כתובת לקריאה מהזיכרון [cite: 9]
    SIGNAL doutb : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0'); -- המידע (פיקסל) שקראנו מהזיכרון
    
    SIGNAL frame_finished : STD_LOGIC := '0'; -- דגל: תמונה שלמה צולמה

    -- הגדרת רכיב מחולל השעונים (Clock Wizard IP)
    component clk_wiz_0 
        port (
          vga_pll   : out std_logic; -- יציאת שעון למסך
          xclk_pll  : out std_logic; -- יציאת שעון למצלמה
		  --סיגנלים של קונטרול וסטטוס
          reset     : in  std_logic;
          locked    : out std_logic; -- סימן שהשעון יציב
          clk_in1   : in  std_logic  -- כניסת שעון ראשי
        );
    end component; 

    -- הגדרת רכיב הזיכרון (Block Memory Generator IP)
    COMPONENT blk_mem_gen_0
      PORT (
        clka : IN STD_LOGIC;  -- שעון כתיבה
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0); -- פקודת כתיבה
        addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0); -- כתובת כתיבה
        dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);  -- מידע כניסה
        clkb : IN STD_LOGIC;  -- שעון קריאה
        enb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(18 DOWNTO 0); -- כתובת קריאה
        doutb : OUT STD_LOGIC_VECTOR(11 DOWNTO 0) -- מידע יציאה
      );
    END COMPONENT; 

BEGIN
    -- הגדרות קבועות למצלמה
    ov7670_pwdn <= '0'; -- הפעלה רגילה (לא במצב חיסכון חשמל)

    -- חיווי לדים
    led(0) <= sw(0);            -- לד 0 משקף את מצב המתג
    led(1) <= config_finished;  -- לד 1 נדלק כשהגדרת המצלמה הושלמה בהצלחה

    -- 1. יצירת השעונים
    clk_generator: clk_wiz_0							
           port map (                
           vga_pll => pxl_clk,       -- מחבר את יציאת השעון לסיגנל המסך (25MHz)
           xclk_pll => xclk_ov7670,  -- מחבר את יציאת השעון לסיגנל המצלמה
           reset => '0',             -- לא עושים ריסט לשעון
           locked => OPEN,           -- (לא בשימוש בקוד זה)
           clk_in1 => clk            -- כניסת השעון הראשי 100MHz
         
    
    -- שליחת השעון למצלמה
    ov7670_xclk <= xclk_ov7670; [cite: 15]

    -- 2. מודול הגדרת המצלמה (I2C Configuration)
    ov7670_configuration : ENTITY work.ov7670_configuration(Behavioral)
        PORT MAP(
            clk => clk,
            rst => rst,
            sda => sda,      -- חיבור לקווי התקשורת הפיזיים
            scl => scl,
            ov7670_reset => ov7670_reset,
            start => edge(0),            -- מתחיל הגדרה כלוחצים על כפתור 0
            config_finished => config_finished, -- מרים דגל בסיום
            ack_err => OPEN, done => open, reg_value => open -- יציאות לא בשימוש
        

    -- 3. זיכרון הוידאו (Frame Buffer)
    frame_buffer: blk_mem_gen_0
      PORT MAP (
        -- צד A: כתיבה (מחובר למודול Capture)
        clka => clk,
        ena => ena,
        wea => wea,     -- האות שמגיע מ-Capture ואומר "לכתוב עכשיו"
        addra => addra, -- הכתובת שמגיעה מ-Capture
        dina => dina,   -- הפיקסל שמגיע מ-Capture
        
        -- צד B: קריאה (מחובר למודול VGA)
        clkb => pxl_clk, -- עובד בתדר המסך (חשוב!)
        enb => enb,
        addrb => addrb,  -- הכתובת שמגיעה מ-VGA Controller
        doutb => doutb   -- הפיקסל שיוצא ל-VGA Controller
      

    -- 4. מודול קליטת התמונה (Capture)
    ov7670_capture : ENTITY work.ov7670_capture(rtl) PORT MAP(
        clk => clk,
        rst => rst,
        config_finished => config_finished, -- מתחיל לעבוד רק אחרי שהמצלמה הוגדרה
        
        -- חיבורים למצלמה
        ov7670_vsync => ov7670_vsync,  
        ov7670_href => ov7670_href,
        ov7670_pclk => ov7670_pclk,
        ov7670_data => ov7670_data,
        
        frame_finished_o => frame_finished,
        start => edge(1), -- אפשרות להתחלה ידנית עם כפתור 1

        -- יציאות לזיכרון (המודול הזה שולט על הכתיבה ל-RAM)
        wea => wea,
        dina => dina,
        addra => addra
        

    -- 5. מודולים לניקוי רעשים מכפתורים (Debounce)
    EDGE_DETECT : ENTITY work.debounce(Behavioral) PORT MAP(
        clk => clk, rest => rst, btn => btn, edge => edge
        
        
    RET_DETECT : ENTITY work.debounce_rst(Behavioral) PORT MAP(
        clk => clk, btn => reset, edge => rst
        

    -- 6. בקר התצוגה (VGA Controller)
    vga_controller : ENTITY work.vga_controller(rtl)
        PORT MAP(
            clk => clk,
            rst => rst,
            pxl_clk => pxl_clk, -- מקבל את שעון ה-25MHz
            start => sw(0),     -- מתחיל להציג רק אם המתג דולק
            
            -- יציאות פיזיות למסך
            VGA_HS_O => VGA_HS_O,
            VGA_VS_O => VGA_VS_O,
            VGA_R => VGA_R,
            VGA_G => VGA_G,
            VGA_B => VGA_B,

            -- בקשות מהזיכרון
            addrb => addrb, -- "תן לי את הכתובת הזו"
            doutb => doutb  -- "קיבלתי את הפיקסל הזה"
        

END ARCHITECTURE;