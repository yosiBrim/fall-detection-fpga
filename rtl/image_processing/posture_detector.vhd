----------------------------------------------------------------------
--  מודול: posture_detector
--  תפקיד: זיהוי תנוחה (עמידה / ישיבה) מתוך זרם פיקסלים של מצלמת OV7670
--          על-ידי ניתוח בהירות בשלושה אזורים אנכיים (עליון / אמצעי / תחתון)
--          לאורך מספר פריימים, כדי להחליט באופן יציב על תנוחת האדם.
--
--  כניסות:
--      clk                 - שעון מערכת (למשל 100MHz)
--      rst                 - reset אסינכרוני, מאפס את כל המודול
--      frame_finished      - פולס שמסמן סיום פריים (תמונה מלאה)
--      pixel_data(11:0)    - נתוני הפיקסל בפורמט RGB444 (4 ביט לכל צבע)
--      pixel_valid         - '1' כאשר pixel_data מייצג פיקסל תקף בתוך פריים
--      pixel_x(9:0)        - קואורדינת X של הפיקסל בתמונה (לא בשימוש כאן)
--      pixel_y(9:0)        - קואורדינת Y של הפיקסל בתמונה (לחישוב אזורים)
--      sw                  - enable/disable למודול (כאשר '0' – המודול מאופס לוגית)
--
--  יציאות:
--      current_posture     - '0' = Standing, '1' = Sitting
--      posture_change_detected
--                          - פולס שנדלק (נשאר '1') למשך 2 שניות בכל מעבר
--                            בין Standing ל-Sitting או הפוך.
--
--  רעיון כללי:
--      • מחלקים את התמונה ל-3 אזורים לאורך ציר Y:
--          TOP    - שליש עליון של התמונה
--          MIDDLE - שליש אמצעי
--          BOTTOM - שליש תחתון
--      • עבור כל פיקסל תקף, מחשבים "בהירות" (Intensity) = R + G + B
--      • עבור כל אזור מצטברים:
--          - סכום הבהירות
--          - מספר הפיקסלים
--      • בסיום פריים, מחשבים ממוצע בהירות לכל אזור.
--      • לפי התפלגות הבהירות (מי יותר חזק – עליון/אמצעי/תחתון)
--        מחליטים האם הפריים "נראה כמו" עמידה או ישיבה.
--      • שומרים ספירת פריימים ברצף המתאימים לעמידה / ישיבה (FRAME_THRESHOLD),
--        כדי להימנע ממצבי רעש וקפיצה מהירה.
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity posture_detector is
    Port (
        clk                    : in  STD_LOGIC;                       -- שעון מערכת
        rst                    : in  STD_LOGIC;                       -- reset אסינכרוני
        frame_finished         : in  STD_LOGIC;                       -- פולס סיום פריים
        pixel_data             : in  STD_LOGIC_VECTOR(11 downto 0);   -- RGB444 מהמצלמה
        pixel_valid            : in  STD_LOGIC;                       -- פיקסל תקף
        pixel_x                : in  STD_LOGIC_VECTOR(9 downto 0);    -- X (לא בשימוש כאן)
        pixel_y                : in  STD_LOGIC_VECTOR(9 downto 0);    -- Y (קובע אזור)
        sw                     : in  STD_LOGIC;                       -- enable לעיבוד (sw(1))
        posture_change_detected : out STD_LOGIC;                      -- פולס שינוי תנוחה
        current_posture        : out STD_LOGIC                        -- 0=Standing, 1=Sitting
    );
end posture_detector;

architecture Behavioral of posture_detector is

    ------------------------------------------------------------------
    -- 1. קבועים גאומטריים של התמונה ועומק הזמן
    ------------------------------------------------------------------
    constant IMAGE_WIDTH      : integer := 640;                       -- רוחב התמונה בפיקסלים
    constant IMAGE_HEIGHT     : integer := 480;                       -- גובה התמונה בפיקסלים
    constant FRAME_THRESHOLD  : integer := 5;                         -- כמה פריימים רצופים נדרשים
                                                                      -- לפני קבלת החלטה על שינוי תנוחה

    ------------------------------------------------------------------
    -- 2. חלוקת הציר האנכי (Y) לשלושה אזורי-גבוה (Top/Middle/Bottom)
    ------------------------------------------------------------------
    constant TOP_REGION_START    : integer := 0;                      -- שורת Y הראשונה
    constant TOP_REGION_END      : integer := IMAGE_HEIGHT/3 - 1;     -- סוף שליש עליון

    constant MIDDLE_REGION_START : integer := IMAGE_HEIGHT/3;         -- תחילת השליש האמצעי
    constant MIDDLE_REGION_END   : integer := (2*IMAGE_HEIGHT)/3 - 1; -- סוף השליש האמצעי

    constant BOTTOM_REGION_START : integer := (2*IMAGE_HEIGHT)/3;     -- תחילת השליש התחתון
    constant BOTTOM_REGION_END   : integer := IMAGE_HEIGHT - 1;       -- שורת Y האחרונה

    ------------------------------------------------------------------
    -- 3. אותות מצטברים לכל אזור: ספירת פיקסלים וסכומי בהירות
    ------------------------------------------------------------------
    signal top_region_pix_count    : unsigned(19 downto 0) := (others => '0'); -- כמות פיקסלים באזור העליון
    signal middle_region_pix_count : unsigned(19 downto 0) := (others => '0'); -- כמות פיקסלים באזור האמצעי
    signal bottom_region_pix_count : unsigned(19 downto 0) := (others => '0'); -- כמות פיקסלים באזור התחתון

    signal top_region_intensity    : unsigned(23 downto 0) := (others => '0'); -- סכום אינטנסיביות באזור העליון\בהירות
    signal middle_region_intensity : unsigned(23 downto 0) := (others => '0'); -- סכום אינטנסיביות באזור האמצעי\בהירות
    signal bottom_region_intensity : unsigned(23 downto 0) := (others => '0'); -- \בהירות סכום אינטנסיביות באזור התחתון

    -- ממוצעי אינטנסיביות (מחושבים בסיום פריים)
    signal top_avg_intensity       : unsigned(7 downto 0) := (others => '0');  -- ממוצע בהירות אזור עליון
    signal middle_avg_intensity    : unsigned(7 downto 0) := (others => '0');  -- ממוצע בהירות אזור אמצעי
    signal bottom_avg_intensity    : unsigned(7 downto 0) := (others => '0');  -- ממוצע בהירות אזור תחתון

    ------------------------------------------------------------------
    -- 4. מעקב אחר פריימים + סטטוס מה טופל כבר
    ------------------------------------------------------------------
    signal frame_counter        : integer range 0 to 255 := 0;        -- ספירת פריימים שנותחו
    signal last_frame_processed : std_logic := '0';                   -- האם נתחנו את הפריים הנוכחי

    ------------------------------------------------------------------
    -- 5. ספירת פריימים שמתאימים לעמידה / ישיבה לצורך יציבות
    ------------------------------------------------------------------
    signal sitting_frames       : integer range 0 to 255 := 0;        -- כמה פריימים "נראים" כמו ישיבה
    signal standing_frames      : integer range 0 to 255 := 0;        -- כמה פריימים "נראים" כמו עמידה

    signal current_posture_reg  : std_logic := '0';                   -- רגיסטר פנימי: 0=Standing, 1=Sitting

    ------------------------------------------------------------------
    -- 6. מכונת מצבים (FSM) לתנוחה: Standing / Sitting / Transitioning
    ------------------------------------------------------------------
    type posture_state_type is (STANDING, SITTING, TRANSITIONING);    -- שלושת המצבים האפשריים
    signal posture_state : posture_state_type := STANDING;            -- מצב התחלתי: עומד

    ------------------------------------------------------------------
    -- 7. ניהול זמן הדלקת ה-LED בעת שינוי תנוחה
    ------------------------------------------------------------------
    constant CLK_FREQ       : integer := 100000000;                   -- תדר שעון 100MHz
    constant LED_ON_SECONDS : integer := 2;                           -- זמן הדלקת LED (2 שניות)
    constant LED_ON_CYCLES  : integer := CLK_FREQ * LED_ON_SECONDS;   -- מספר מחזורי שעון עבור 2 שניות
    signal led_counter      : integer range 0 to LED_ON_CYCLES := 0;  -- מונה מחזורי שעון ל-LED

begin

    ------------------------------------------------------------------
    -- יציאת current_posture מחוברת לרגיסטר הפנימי (שאי אפשר לשנות מבחוץ)
    ------------------------------------------------------------------
    current_posture <= current_posture_reg;

    ----------------------------------------------------------------------
    -- תהליך 1: pixel_processor
    --  • לוגיקה בזמן זרימת הפיקסלים:
    --      - איפוס מצטברים בתחילת פריים חדש
    --      - עבור כל פיקסל תקף: חישוב בהירות (R+G+B) וצבירה לפי אזור
    --      - סימון שסוף פריים הגיע (last_frame_processed = '1')
    ----------------------------------------------------------------------
    pixel_processor : process(clk, rst, sw)
        variable r, g, b         : unsigned(3 downto 0);              -- רכיבי צבע 4 ביט
        variable pixel_intensity : unsigned(7 downto 0);              -- אינטנסיביות הפיקסל איזה בהירות הפיקסל (מתוך גווני אפור שקיימים?)
        variable y_pos           : integer;                           -- Y כ-integer
    begin
        -- reset גלובלי או כיבוי המודול ע"י sw=0 → איפוס מלא של המצטברים
        if rst = '1' or sw = '0' then
            top_region_pix_count    <= (others => '0');
            middle_region_pix_count <= (others => '0');
            bottom_region_pix_count <= (others => '0');

            top_region_intensity    <= (others => '0');
            middle_region_intensity <= (others => '0');
            bottom_region_intensity <= (others => '0');

            last_frame_processed    <= '0';

        elsif rising_edge(clk) and sw = '1' then
            ------------------------------------------------------------------
            -- תחילת פריים חדש:
            -- כאשר הפריים הקודם כבר סומן כ"מטופל" (last_frame_processed='1')
            -- ועכשיו frame_finished חזר ל-'0' → זה אומר שהתחיל פריים חדש,
            -- ולכן צריך לאפס מונים למצטברים החדשים.
            ------------------------------------------------------------------
            if last_frame_processed = '1' and frame_finished = '0' then
                top_region_pix_count    <= (others => '0');
                middle_region_pix_count <= (others => '0');
                bottom_region_pix_count <= (others => '0');

                top_region_intensity    <= (others => '0');
                middle_region_intensity <= (others => '0');
                bottom_region_intensity <= (others => '0');

                last_frame_processed    <= '0';                         -- מוכנים לאיסוף פריים חדש
            end if;

            ------------------------------------------------------------------
            -- עיבוד פיקסל יחיד כאשר pixel_valid='1':
            --  • שליפת רכיבי RGB
            --  • חישוב אינטנסיביות
            --  • צבירה באזור המתאים לפי Y
            ------------------------------------------------------------------
            if pixel_valid = '1' then
                -- שליפת 4 ביט לכל צבע
                r := unsigned(pixel_data(11 downto 8));                -- אדום
                g := unsigned(pixel_data(7 downto 4));                 -- ירוק
                b := unsigned(pixel_data(3 downto 0));                 -- כחול

                -- אינטנסיביות בסיסית = R+G+B (ללא חלוקה ב-3)
				-- המרה של pixel intensity ל8 ביט
				
                pixel_intensity := resize((r + g + b), 8);

                -- המרת pixel_y מוקטור לביט signed ל-integer
                y_pos := to_integer(unsigned(pixel_y));

                -- צבירת האינטנסיביות ומספר הפיקסלים לכל אזור:
                if (y_pos >= TOP_REGION_START) and (y_pos <= TOP_REGION_END) then
                    -- אזור עליון
					--עובר פיקסל פיקסל בשליש העליון,ומוסיף את הבהירות שהתקבלה למעלה
					
                    top_region_intensity <= top_region_intensity + pixel_intensity;
                    top_region_pix_count <= top_region_pix_count + 1;    
					

                elsif (y_pos >= MIDDLE_REGION_START) and (y_pos <= MIDDLE_REGION_END) then
                    -- אזור אמצעי
					
                    middle_region_intensity <= middle_region_intensity + pixel_intensity;
                    middle_region_pix_count <= middle_region_pix_count + 1;

                elsif (y_pos >= BOTTOM_REGION_START) and (y_pos <= BOTTOM_REGION_END) then
                    -- אזור תחתון
                    bottom_region_intensity <= bottom_region_intensity + pixel_intensity;
                    bottom_region_pix_count <= bottom_region_pix_count + 1;
                end if;
            end if;

            ------------------------------------------------------------------
            -- סימון שסוף פריים הגיע (frame_finished='1'):
            --  • משמש תהליך ה-posture_analyzer כדי לדעת מתי לחשב ממוצעים
            --    ולנתח את הפריים.
            ------------------------------------------------------------------
            if frame_finished = '1' then
                last_frame_processed <= '1';
            end if;
        end if;
    end process pixel_processor;

    ----------------------------------------------------------------------
    -- תהליך 2: posture_analyzer
    --  • רץ על-פי פריימים, לא על-פי כל פיקסל.
    --  • כאשר פריים הסתיים (frame_finished='1' ו-last_frame_processed='0'):
    --      - מחשב ממוצע אינטנסיביות לכל אזור
    --      - מריץ FSM (Standing / Sitting)
    --      - מעדכן ספירת פריימים רצופים כעמידה/ישיבה
    --      - בעת שינוי תנוחה: מדליק LED (posture_change_detected) למשך 2 שניות
    ----------------------------------------------------------------------
    posture_analyzer : process(clk, rst, sw)
    begin --rabin
        -- reset גלובלי או כיבוי המודול ע"י sw=0 → איפוס FSM, מונים ו-LED
		
        if rst = '1' or sw = '0' then
            frame_counter       <= 0;
            sitting_frames      <= 0;
            standing_frames     <= 0;
            posture_state       <= STANDING;               -- ברירת מחדל: עומד
            current_posture_reg <= '0';                    -- 0 = Standing
            posture_change_detected <= '0';                -- LED כבוי

            top_avg_intensity    <= (others => '0');
            middle_avg_intensity <= (others => '0');
            bottom_avg_intensity <= (others => '0');

            led_counter <= 0;                              -- אין הדלקה פעילה ל-LED

        elsif rising_edge(clk) and sw = '1' then

            ------------------------------------------------------------------
            -- ניהול זמן הדלקת ה-LED לשינוי תנוחה:
            --  אם led_counter > 0 → posture_change_detected='1' והמונה יורד.
            --  אם הגיע ל-0 → מכבים את ה-LED (posture_change_detected='0').
            ------------------------------------------------------------------
            if led_counter > 0 then
                posture_change_detected <= '1';
                led_counter <= led_counter - 1;
            else
                posture_change_detected <= '0';
            end if;

            ------------------------------------------------------------------
            -- ניתוח פריים חדש:
            --  מתבצע רק כאשר:
            --      frame_finished='1'  (הסתיים פריים)
            --  ו-  last_frame_processed='0' (עוד לא נותח ע"י התהליך הזה)
            ------------------------------------------------------------------
            if (frame_finished = '1') and (last_frame_processed = '0') then
                frame_counter <= frame_counter + 1;        -- ספירת פריימים נותחו

                --------------------------------------------------------------
                -- חישוב ממוצעי אינטנסיביות לכל אזור:
                -- (מוגנים מחלוקה ב-0: אם אין פיקסלים באזור, משאירים את הממוצע הקודם)
                --------------------------------------------------------------
                if top_region_pix_count > 0 then
                    top_avg_intensity <= resize(top_region_intensity / top_region_pix_count, 8);
                end if;

                if middle_region_pix_count > 0 then
                    middle_avg_intensity <= resize(middle_region_intensity / middle_region_pix_count, 8);
                end if;

                if bottom_region_pix_count > 0 then
                    bottom_avg_intensity <= resize(bottom_region_intensity / bottom_region_pix_count, 8);
                end if;

                --------------------------------------------------------------
                -- מכונת המצבים (FSM) לזיהוי תנוחה:
                --  • STANDING     - מצב נוכחי "עומד"
                --  • SITTING      - מצב נוכחי "יושב"
                --  • TRANSITIONING- מצב ביניים קצר בעת מעבר
                --------------------------------------------------------------
                case posture_state is

                    ------------------------------------------------------------------
                    -- מצב: STANDING (האדם נחשב כעומד)
                    ------------------------------------------------------------------
                    when STANDING =>
                        -- לוגיקה בסיסית:
                        --  אם האזור התחתון (BOTTOM) נעשה בהיר יחסית
                        --  ביחס לממוצע של האזורים העליון+אמצעי,
                        --  זה יכול להעיד על "ירידה" של הגוף → ישיבה.
                        if bottom_avg_intensity > (middle_avg_intensity + top_avg_intensity) / 2 then
                            -- מגמה של ישיבה
                            sitting_frames  <= sitting_frames + 1;
                            standing_frames <= 0;
                        else
                            -- עדיין נראה כמו עמידה
                            standing_frames <= standing_frames + 1;
                            sitting_frames  <= 0;
                        end if;

                        -- אם ראינו מספיק פריימים רצופים כ"ישיבה"
                        -- → במעבר למצב ישיבה
                        if sitting_frames >= FRAME_THRESHOLD then
                            posture_state       <= TRANSITIONING;     -- נכנסים למצב מעבר
                            led_counter         <= LED_ON_CYCLES;     -- להדליק LED ל-2 שניות
                            current_posture_reg <= '1';               -- כעת התנוחה = Sitting
                        end if;

                    ------------------------------------------------------------------
                    -- מצב: SITTING (האדם נחשב כיושב)
                    ------------------------------------------------------------------
                    when SITTING =>
                        -- הערה: באנגלית נכתב "top intensity should be lower",
                        -- אבל התנאי פה בודק אם top_avg_intensity גדול מהממוצע
                        -- של middle+bottom. ניתן לשפר/לשנות לפי צורך הפרויקט.
                        if top_avg_intensity > (middle_avg_intensity + bottom_avg_intensity) / 2 then
                            -- מגמה של עמידה (החלק העליון בולט שוב)
                            standing_frames <= standing_frames + 1;
                            sitting_frames  <= 0;
                        else
                            -- עדיין נראה כמו ישיבה
                            sitting_frames  <= sitting_frames + 1;
                            standing_frames <= 0;
                        end if;

                        -- אם ראינו מספיק פריימים רצופים כ"עמידה" → מעבר ל-Standing
                        if standing_frames >= FRAME_THRESHOLD then
                            posture_state       <= TRANSITIONING;
                            led_counter         <= LED_ON_CYCLES;     -- הדלקת LED לשינוי
                            current_posture_reg <= '0';               -- כעת התנוחה = Standing
                        end if;

                    ------------------------------------------------------------------
                    -- מצב: TRANSITIONING (ביניים)
                    --  • משמש כדי "לנעול" את המצב החדש בפריים הבא
                    --    ולהתחיל מחדש את מוני ה-sitting/standing.
                    ------------------------------------------------------------------
                    when TRANSITIONING =>
                        if current_posture_reg = '1' then
                            posture_state <= SITTING;                 -- עוגן ל-Sitting
                        else
                            posture_state <= STANDING;                -- עוגן ל-Standing
                        end if;
                        -- מאפס מונים כדי להתחיל מחדש ספירה במצב החדש
                        sitting_frames  <= 0;
                        standing_frames <= 0;
                end case;
            end if; -- if frame_finished and not last_frame_processed
        end if; -- rising_edge(clk)
    end process posture_analyzer;

end Behavioral;
