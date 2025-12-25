LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY vga_controller IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        pxl_clk : IN STD_LOGIC;
        VGA_HS_O : OUT STD_LOGIC;
        VGA_VS_O : OUT STD_LOGIC;
        VGA_R : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_B : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_G : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);

        start : IN STD_LOGIC;

        --frame_buffer signals
        addrb : OUT STD_LOGIC_VECTOR(18 DOWNTO 0);
        doutb : IN STD_LOGIC_VECTOR(11 DOWNTO 0) --pixel data
    );
END vga_controller;

ARCHITECTURE rtl OF vga_controller IS
    --***640x480@60Hz***--  Requires 25 MHz clock
    CONSTANT FRAME_WIDTH : NATURAL := 640;
    CONSTANT FRAME_HEIGHT : NATURAL := 480;

    -- תזמון VGA נכון עבור 640x480@60Hz
    CONSTANT H_SYNC_PULSE_WIDTH : NATURAL := 96; -- Sync pulse
    CONSTANT H_BACK_PORCH : NATURAL := 48;       -- Back porch  
    CONSTANT H_FRONT_PORCH : NATURAL := 16;      -- Front porch
    CONSTANT H_TOTAL_LINE : NATURAL := 800;      -- Total = 96+48+640+16

    CONSTANT V_SYNC_PULSE_WIDTH : NATURAL := 2;  -- Sync pulse
    CONSTANT V_BACK_PORCH : NATURAL := 29;       -- Back porch
    CONSTANT V_FRONT_PORCH : NATURAL := 10;      -- Front porch  
    CONSTANT V_MAX_LINE : NATURAL := 521;        -- Total = 2+33+480+10

    CONSTANT H_POL : STD_LOGIC := '0';
    CONSTANT V_POL : STD_LOGIC := '0';

    SIGNAL hsync_reg, hsync_next : INTEGER RANGE 0 TO H_TOTAL_LINE  := 0;
    SIGNAL vsync_reg, vsync_next : INTEGER RANGE 0 TO V_MAX_LINE  := 0;

    SIGNAL bram_address_reg, bram_address_next : unsigned(18 DOWNTO 0) := (OTHERS => '0');

    SIGNAL line_finished : STD_LOGIC := '0';
    SIGNAL frame_finished : STD_LOGIC := '0';
    
    -- תחילת אזור התצוגה (סדר: Sync -> Back Porch -> Display)
    CONSTANT H_DISPLAY_START : NATURAL := H_SYNC_PULSE_WIDTH + H_BACK_PORCH;  -- 96+48=144
    CONSTANT V_DISPLAY_START : NATURAL := V_SYNC_PULSE_WIDTH + V_BACK_PORCH;  -- 2+33=35
    
    -- משתנים עזר לחישוב מיקום הפיקסל
    SIGNAL display_x : INTEGER RANGE 0 TO FRAME_WIDTH - 1;
    SIGNAL display_y : INTEGER RANGE 0 TO FRAME_HEIGHT - 1;
    SIGNAL in_display_area : STD_LOGIC;

    SIGNAL in_display_area_delayed : STD_LOGIC := '0';
	
	SIGNAL pxl_data_reg : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
BEGIN


    
    -- חישוב מיקום הפיקסל בתוך אזור התצוגה
    display_x <= hsync_reg - H_DISPLAY_START WHEN hsync_reg >= H_DISPLAY_START AND hsync_reg < (H_DISPLAY_START + FRAME_WIDTH) ELSE 0;
    display_y <= vsync_reg - V_DISPLAY_START WHEN vsync_reg >= V_DISPLAY_START AND vsync_reg < (V_DISPLAY_START + FRAME_HEIGHT) ELSE 0;
    
    -- דגל שמציין אם אנחנו בתוך אזור התצוגה
    in_display_area <= '1' WHEN (hsync_reg >= H_DISPLAY_START AND hsync_reg < (H_DISPLAY_START + FRAME_WIDTH) AND
                                  vsync_reg >= V_DISPLAY_START AND vsync_reg < (V_DISPLAY_START + FRAME_HEIGHT)) ELSE '0';

    addrb <= STD_LOGIC_VECTOR(bram_address_reg);

    line_finished <= '1' WHEN hsync_reg = H_TOTAL_LINE - 1 ELSE '0';
    frame_finished <= '1' WHEN vsync_reg = V_MAX_LINE - 1 ELSE '0';

    -- תזמון H-Sync (Sync באמצע, לא בהתחלה!)
    VGA_HS_O <= NOT H_POL WHEN (hsync_reg >= 0 AND hsync_reg < H_SYNC_PULSE_WIDTH) ELSE H_POL;

    -- תזמון V-Sync (Sync באמצע, לא בהתחלה!)
    VGA_VS_O <= NOT V_POL WHEN (vsync_reg >= 0 AND vsync_reg < V_SYNC_PULSE_WIDTH) ELSE V_POL;

    -- עדכון מונים
    hsync_next <= 0 WHEN line_finished = '1' ELSE 
                  hsync_reg + 1 WHEN start = '1' ELSE 
                  hsync_reg;

    vsync_next <= 0 WHEN frame_finished = '1' ELSE
                  vsync_reg + 1 WHEN line_finished = '1' ELSE
                  vsync_reg;

    -- חישוב כתובת BRAM - עם סנכרון טוב יותר
-- שנה את החישוב של bram_address_next:
--	--PROCESS(hsync_reg, vsync_reg, frame_finished, start)
--		VARIABLE next_hsync : INTEGER RANGE 0 TO H_TOTAL_LINE - 1;
--		VARIABLE next_x, next_y : INTEGER;
--	BEGIN
--		IF frame_finished = '1' THEN
--			bram_address_next <= (OTHERS => '0');
--		ELSIF start = '1' THEN
--			-- חשב את המיקום של הפיקסל הבא
--			IF hsync_reg = H_TOTAL_LINE - 1 THEN
--				next_hsync := 0;
--			ELSE
--				next_hsync := hsync_reg + 1;
--			END IF;
--			
--			-- בדוק אם הפיקסל הבא יהיה באזור התצוגה
--			IF next_hsync >= H_DISPLAY_START AND next_hsync < (H_DISPLAY_START + FRAME_WIDTH) AND
--			   vsync_reg >= V_DISPLAY_START and vsync_reg < (V_DISPLAY_START + FRAME_HEIGHT) THEN
--				
--				next_x := next_hsync - H_DISPLAY_START;
--				next_y := vsync_reg - V_DISPLAY_START;
--				bram_address_next <= to_unsigned((next_y * FRAME_WIDTH) + next_x, 19);
--			ELSE
--				bram_address_next <= bram_address_reg;
--			END IF;
--		ELSE
--			bram_address_next <= bram_address_reg;
--		END IF;
--	END PROCESS;

PROCESS(hsync_reg, vsync_reg, frame_finished, start)
BEGIN
    IF frame_finished = '1' THEN
        bram_address_next <= (OTHERS => '0');
    ELSIF start = '1' THEN
        IF hsync_reg >= H_DISPLAY_START AND hsync_reg < (H_DISPLAY_START + FRAME_WIDTH) AND
           vsync_reg >= V_DISPLAY_START AND vsync_reg < (V_DISPLAY_START + FRAME_HEIGHT) THEN
            bram_address_next <= to_unsigned(((vsync_reg - V_DISPLAY_START) * FRAME_WIDTH) + (hsync_reg - H_DISPLAY_START), 19);
        ELSE
            bram_address_next <= bram_address_reg;
        END IF;
    ELSE
        bram_address_next <= bram_address_reg;
    END IF;
END PROCESS;




	PROCESS (pxl_clk)
	BEGIN
		IF rising_edge(pxl_clk) THEN
			IF start = '1' THEN
				pxl_data_reg <= doutb; -- רישום נתוני ה-BRAM
			END IF;
		END IF;
	END PROCESS;

	VGA_R <= pxl_data_reg(11 DOWNTO 8) WHEN in_display_area_delayed = '1' ELSE "0000";
	VGA_G <= pxl_data_reg(7 DOWNTO 4) WHEN in_display_area_delayed = '1' ELSE "0000";
	VGA_B <= pxl_data_reg(3 DOWNTO 0) WHEN in_display_area_delayed = '1' ELSE "0000";

    -- שנה את יציאות RGB:
    --VGA_R <= doutb(11 DOWNTO 8) WHEN in_display_area_delayed = '1' ELSE "0000";
    --VGA_G <= doutb(7 DOWNTO 4) WHEN in_display_area_delayed = '1' ELSE "0000";
    --VGA_B <= doutb(3 DOWNTO 0) WHEN in_display_area_delayed = '1' ELSE "0000";
    
PROCESS (pxl_clk, rst)
BEGIN
    IF rst = '1' THEN
        hsync_reg <= 0;
        vsync_reg <= 0;
        bram_address_reg <= (OTHERS => '0');
        in_display_area_delayed <= '0';
    ELSIF rising_edge(pxl_clk) THEN
        IF start = '1' THEN
            hsync_reg <= hsync_next;
            vsync_reg <= vsync_next;
            bram_address_reg <= bram_address_next;
            in_display_area_delayed <= in_display_area;
        END IF;
    END IF;
END PROCESS;


    
END ARCHITECTURE;