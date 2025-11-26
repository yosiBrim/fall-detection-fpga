LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ov7670_capture IS
    PORT (
	
	    --אותות מערכת כלליים
		
        clk : IN STD_LOGIC; --שעון המערכת הראשית (100 מגה)
        rst : IN STD_LOGIC;  -- איפוס
        config_finished : IN STD_LOGIC; --אות אישור "המצלמה הוגדרה"
		
		
        -- אותות המצלמה
        --camera signals  
		
        ov7670_vsync : IN STD_LOGIC; -- איפוס תמונה  ,סנכרון אנכי
        ov7670_href : IN STD_LOGIC; --אישור שורה,סנכרון אופקי
        ov7670_pclk : IN STD_LOGIC; --המטרונום שמכתיב את הקצב,שעון הפיקסלים
        ov7670_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --המידע הגולמי
		
		--אותות בקרה וסטטוס
		
        start : IN STD_LOGIC;
        frame_finished_o : OUT STD_LOGIC; --דגל יציאה,סיימתי תמונה
    
        --אותות לזיכרון הRAM 
        --frame_buffer signals
		
        wea : OUT STD_LOGIC_VECTOR(0 DOWNTO 0); --פקודת כתוב!
        dina : OUT STD_LOGIC_VECTOR(11 DOWNTO 0); -- הפיקסל המוכן,12 ביט
        addra : OUT STD_LOGIC_VECTOR(18 DOWNTO 0) --לאיזה כתובת
    );
	
END ov7670_capture;

ARCHITECTURE rtl OF ov7670_capture IS
ARCHITECTURE rtl OF ov7670_capture IS
ARCHITECTURE rtl OF ov7670_capture IS

    -- === 1. הגדרת המצבים (State Machine) ===
    TYPE state_type IS (
        idle,                -- מצב המתנה
        start_capturing,     -- התחלת תהליך
        wait_for_new_frame,  -- המתנה לסנכרון אנכי
        frame_finished,      -- סיום תמונה
        capture_line,        -- המתנה לתחילת שורה
        capture_rgb_byte,    -- קליטת הבית הראשון
        write_to_bram        -- קליטת הבית השני וכתיבה
    );

    -- === 2. סיגנלים לסנכרון (Synchronized Signals) ===
    -- המטרה: העברת אותות מהשעון של המצלמה לשעון של ה-FPGA
    -- כל אות עובר דרך שני פליפ-פלופים (sync1, sync2) כדי למנוע אי-יציבות
    
    -- סנכרון אות ה-VSYNC (התחלת תמונה)
    SIGNAL vsync_sync1, vsync_sync2, vsync_prev : STD_LOGIC := '0';
    
    -- סנכרון אות ה-HREF (התחלת שורה)
    SIGNAL href_sync1, href_sync2, href_prev : STD_LOGIC := '0';
    
    -- סנכרון אות ה-PCLK (שעון הפיקסלים - אנו מתייחסים אליו כאות רגיל כאן)
    SIGNAL pclk_sync1, pclk_sync2, pclk_prev : STD_LOGIC := '0';
    
    -- סנכרון אותות המידע (Data Bus) - 
    -- גם 8 החוטים של הצבע צריכים לעבור סנכרון כדי שלא נקרא "זבל" בזמן מעבר
    SIGNAL data_sync1, data_sync2 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    -- === 3. סיגנלים לגילוי שינויים (Edge Detection) ===
    -- דגלים שיעלו ל-'1' למחזור שעון אחד בדיוק כשקורה שינוי
    
    SIGNAL vsync_falling_edge, vsync_rising_edge : STD_LOGIC := '0';
    SIGNAL href_rising_edge, href_falling_edge : STD_LOGIC := '0';
    SIGNAL pclk_rising_edge : STD_LOGIC := '0'; -- הרגע הקריטי שבו דוגמים פיקסל

    -- === 4. מבנה הנתונים (Registers Record) ===
    TYPE reg_type IS RECORD
        state : state_type;
        href_cnt : INTEGER RANGE 0 TO 500;          -- מונה שורות (עד 480)
        rgb_reg : STD_LOGIC_VECTOR(15 DOWNTO 0);     -- אוגר זמני לפיקסל (16 ביט)
        pixel_reg : INTEGER RANGE 0 TO 650;         -- מונה פיקסלים בשורה (עד 640)
        bram_address : UNSIGNED(18 DOWNTO 0);        -- כתובת בזיכרון
        line_started : STD_LOGIC;                    -- דגל: האם התחלנו שורה?
    END RECORD reg_type;

	
	-- === 5. קבוע האתחול (Initialization Constant) -  ===
    -- זהו "תבנית" של המצב ההתחלתי. כשלוחצים Reset, אנחנו מעתיקים את זה לרגיסטר.
    CONSTANT INIT_REG_FILE : reg_type := (
        state => idle,                          -- מתחילים במצב מנוחה
        href_cnt => 0,                          -- איפוס מונה שורות
        rgb_reg => (OTHERS => '0'),             -- איפוס אוגר הצבע (הכל אפסים)
        pixel_reg => 0,                         -- איפוס מונה פיקסלים
        bram_address => (OTHERS => '0'),        -- איפוס כתובת הזיכרון להתחלה (0)
        line_started => '0'                     -- איפוס דגל שורה
    );

    -- === 6. האותות הראשיים (Registers) ===
    -- כאן אנחנו משתמשים בקבוע שהגדרנו למעלה כדי לאתחל את הסיגנלים כבר בהצהרה
    SIGNAL reg : reg_type := INIT_REG_FILE;      -- המצב הנוכחי
    SIGNAL reg_next : reg_type := INIT_REG_FILE; -- המצב הבא
	
	
BEGIN

-- === חיבור הכתובת לזיכרון ===
    -- לסוג STD_LOGIC_VECTOR שהרכיב החיצוני (BRAM) דורש.
    addra <= STD_LOGIC_VECTOR(reg.bram_address);

    -- === לוגיקת גילוי קצוות (Edge Detection) ===
    -- לוגיקה זו רצה במקביל (Concurrent) ומזהה שינויים באותות החיצוניים.
    -- היא משווה בין הערך הנוכחי המסונכרן (sync2) לבין הערך במחזור השעון הקודם (prev).

    -- זיהוי ירידת VSYNC (מ-1 ל-0):
    -- זהו הרגע הקריטי שבו המצלמה מסמנת שתמונה חדשה מתחילה בפועל (Active Video).
    vsync_falling_edge <= '1' WHEN vsync_prev = '1' AND vsync_sync2 = '0' ELSE '0';

    -- זיהוי עליית VSYNC (מ-0 ל-1):
    -- מסמן שהתמונה הסתיימה ונכנסים לזמן "מת" (V-Blank).
    vsync_rising_edge <= '1' WHEN vsync_prev = '0' AND vsync_sync2 = '1' ELSE '0';

    -- זיהוי עליית HREF (מ-0 ל-1):
    -- מסמן ששורה חדשה מתחילה ומתחילים להגיע פיקסלים תקפים.
    href_rising_edge <= '1' WHEN href_prev = '0' AND href_sync2 = '1' ELSE '0';

    -- זיהוי ירידת HREF (מ-1 ל-0):
    -- מסמן שהשורה הסתיימה.
    href_falling_edge <= '1' WHEN href_prev = '1' AND href_sync2 = '0' ELSE '0';

    -- זיהוי עליית PCLK (מ-0 ל-1):
    -- זהו "הדופק" של המידע. ברגע הזה בדיוק המצלמה אומרת שהמידע בקווי ה-DATA הוא יציב ונכון לקריאה.
    pclk_rising_edge <= '1' WHEN pclk_prev = '0' AND pclk_sync2 = '1' ELSE '0';

    sync : PROCESS (clk, rst)
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                reg <= INIT_REG_FILE;
                vsync_sync1 <= '0'; vsync_sync2 <= '0'; vsync_prev <= '0';
                href_sync1 <= '0'; href_sync2 <= '0'; href_prev <= '0';
                pclk_sync1 <= '0'; pclk_sync2 <= '0'; pclk_prev <= '0';
                data_sync1 <= (OTHERS => '0'); data_sync2 <= (OTHERS => '0');
            ELSE
                -- Double buffer for metastability
                vsync_sync1 <= ov7670_vsync; vsync_sync2 <= vsync_sync1; vsync_prev <= vsync_sync2;
                href_sync1 <= ov7670_href;   href_sync2 <= href_sync1;   href_prev <= href_sync2;
                pclk_sync1 <= ov7670_pclk;   pclk_sync2 <= pclk_sync1;   pclk_prev <= pclk_sync2;
                data_sync1 <= ov7670_data;   data_sync2 <= data_sync1;
                
                -- Update registers
                reg <= reg_next;
            END IF;
        END IF;
    END PROCESS;

    comb : PROCESS (reg, data_sync2, pclk_rising_edge, href_rising_edge, href_sync2, start, vsync_falling_edge, vsync_rising_edge, config_finished)
    BEGIN
        reg_next <= reg;
        frame_finished_o <= '0';
        wea <= "0";
        dina <= (OTHERS => '0');
        
        CASE reg.state IS

            WHEN idle =>
                IF start = '1' AND config_finished = '1' THEN
                    reg_next.bram_address <= (OTHERS => '0');
                    reg_next.state <= wait_for_new_frame;
                END IF;

            WHEN wait_for_new_frame =>
                IF vsync_falling_edge = '1' THEN
                    reg_next.href_cnt <= 0;
                    reg_next.bram_address <= (OTHERS => '0'); -- אפס כתובת BRAM
                    reg_next.line_started <= '0';
                    reg_next.state <= start_capturing;
                END IF;

            WHEN start_capturing =>
                -- רק אם השורה עדיין לא התחילה ו-HREF פעיל
                IF href_sync2 = '1' AND reg.line_started = '0' THEN
                    reg_next.pixel_reg <= 0;
					reg_next.bram_address <= to_unsigned(reg.href_cnt * 640, 19);
                    reg_next.line_started <= '1';
                    reg_next.state <= capture_line;
                ELSIF href_sync2 = '0' THEN
                    -- HREF לא פעיל, אפס את הדגל
                    reg_next.line_started <= '0';
                END IF;

            WHEN capture_line =>
                -- וודא ש-HREF עדיין פעיל ורק אז תקרא נתונים
                IF href_sync2 = '1' AND pclk_rising_edge = '1' AND reg.pixel_reg < 640 THEN
                    reg_next.rgb_reg(15 DOWNTO 8) <= data_sync2;
                    reg_next.state <= capture_rgb_byte;
                ELSIF href_sync2 = '0' THEN
                    -- HREF נגמר, סיים את השורה
                    reg_next.href_cnt <= reg.href_cnt + 1;
                    reg_next.line_started <= '0';
                    IF reg.href_cnt = 479 THEN
                        reg_next.state <= frame_finished;
                    ELSE
                        reg_next.state <= start_capturing;
                    END IF;
                END IF;

            WHEN capture_rgb_byte =>
                IF href_sync2 = '1' AND pclk_rising_edge = '1' AND reg.pixel_reg < 640 THEN
                    reg_next.rgb_reg(7 DOWNTO 0) <= data_sync2;
                    reg_next.pixel_reg <= reg.pixel_reg + 1;
                    reg_next.state <= write_to_bram;
                ELSIF href_sync2 = '0' THEN
                    -- HREF נגמר, סיים את השורה
                    reg_next.href_cnt <= reg.href_cnt + 1;
                    reg_next.line_started <= '0';
                    IF reg.href_cnt = 479 THEN
                        reg_next.state <= frame_finished;
                    ELSE
                        reg_next.state <= start_capturing;
                    END IF;
                END IF;
                
            WHEN write_to_bram =>
                -- כתוב רק אם זה פיקסל חוקי
                IF reg.pixel_reg <= 640 AND reg.href_cnt < 480 THEN
                    wea <= "1";
                    dina <= reg.rgb_reg(11 DOWNTO 0);
                    reg_next.bram_address <= reg.bram_address + 1;
                END IF;
                
                -- בדוק אם סיימנו את השורה
                IF reg.pixel_reg >= 640 THEN
                    reg_next.href_cnt <= reg.href_cnt + 1;
                    reg_next.line_started <= '0';
                    IF reg.href_cnt >= 479 THEN
                        reg_next.state <= frame_finished;
                    ELSE
                        reg_next.state <= start_capturing;
                    END IF;
                ELSE
                    reg_next.state <= capture_line;
                END IF;
                
            WHEN frame_finished =>
                frame_finished_o <= '1';
                reg_next.rgb_reg <= (OTHERS => '0');
				reg_next.href_cnt <= 0;
                reg_next.bram_address <= (OTHERS => '0');
                reg_next.state <= wait_for_new_frame;

            WHEN OTHERS => NULL;
        END CASE;
    END PROCESS;

END ARCHITECTURE;