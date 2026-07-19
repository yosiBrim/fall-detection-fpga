LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ov7670_capture IS
    PORT (
        clk             : IN STD_LOGIC;
        rst             : IN STD_LOGIC; 
        config_finished : IN STD_LOGIC;
        ov7670_vsync    : IN STD_LOGIC;
        ov7670_href     : IN STD_LOGIC;
        ov7670_pclk     : IN STD_LOGIC;
        ov7670_data     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        start           : IN STD_LOGIC;
        frame_finished_o: OUT STD_LOGIC;
        wea             : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        dina            : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
        addra           : OUT STD_LOGIC_VECTOR(18 DOWNTO 0)
    );
END ov7670_capture;

ARCHITECTURE rtl OF ov7670_capture IS

    TYPE state_type IS (
        idle, start_capturing, wait_for_new_frame, 
        frame_finished, capture_line, capture_rgb_byte, write_to_bram
    );

    TYPE block_sums_array IS ARRAY (0 TO 47) OF UNSIGNED(15 DOWNTO 0);

    SIGNAL vsync_sync1, vsync_sync2, vsync_prev : STD_LOGIC := '0';
    SIGNAL href_sync1, href_sync2, href_prev    : STD_LOGIC := '0';
    SIGNAL pclk_sync1, pclk_sync2, pclk_prev    : STD_LOGIC := '0';
    SIGNAL data_sync1, data_sync2               : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL vsync_falling_edge, vsync_rising_edge : STD_LOGIC := '0';
    SIGNAL href_rising_edge, href_falling_edge   : STD_LOGIC := '0';
    SIGNAL pclk_rising_edge                      : STD_LOGIC := '0';

    TYPE reg_type IS RECORD
        state        : state_type;
        href_cnt     : INTEGER RANGE 0 TO 500;
        rgb_reg      : STD_LOGIC_VECTOR(15 DOWNTO 0);
        pixel_reg    : INTEGER RANGE 0 TO 650;
        bram_address : UNSIGNED(18 DOWNTO 0);
        line_started : STD_LOGIC;
        cnt_x        : INTEGER RANGE 0 TO 80;
        blk_x        : INTEGER RANGE 0 TO 8;
        cnt_y        : INTEGER RANGE 0 TO 80;
        blk_y        : INTEGER RANGE 0 TO 6;
        block_sums   : block_sums_array;
    END RECORD reg_type;

    CONSTANT INIT_REG_FILE : reg_type := (
        state => idle, href_cnt => 0, rgb_reg => (OTHERS => '0'), pixel_reg => 0,
        bram_address => (OTHERS => '0'), line_started => '0',
        cnt_x => 0, blk_x => 0, cnt_y => 0, blk_y => 0,
        block_sums => (OTHERS => (OTHERS => '0'))
    );

    SIGNAL reg      : reg_type := INIT_REG_FILE;
    SIGNAL reg_next : reg_type := INIT_REG_FILE;

BEGIN

    addra <= STD_LOGIC_VECTOR(reg.bram_address);

    vsync_falling_edge <= '1' WHEN vsync_prev = '1' AND vsync_sync2 = '0' ELSE '0';
    vsync_rising_edge  <= '1' WHEN vsync_prev = '0' AND vsync_sync2 = '1' ELSE '0';
    href_rising_edge   <= '1' WHEN href_prev = '0' AND href_sync2 = '1' ELSE '0';
    href_falling_edge  <= '1' WHEN href_prev = '1' AND href_sync2 = '0' ELSE '0';
    pclk_rising_edge   <= '1' WHEN pclk_prev = '0' AND pclk_sync2 = '1' ELSE '0';

    sync : PROCESS (clk, rst)
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                reg <= INIT_REG_FILE;
                vsync_sync1 <= '0'; vsync_sync2 <= '0'; vsync_prev <= '0';
                href_sync1 <= '0';  href_sync2 <= '0';  href_prev <= '0';
                pclk_sync1 <= '0';  pclk_sync2 <= '0';  pclk_prev <= '0';
                data_sync1 <= (OTHERS => '0'); data_sync2 <= (OTHERS => '0');
            ELSE
                vsync_sync1 <= ov7670_vsync; vsync_sync2 <= vsync_sync1; vsync_prev <= vsync_sync2;
                href_sync1  <= ov7670_href;  href_sync2  <= href_sync1;  href_prev  <= href_sync2;
                pclk_sync1  <= ov7670_pclk;  pclk_sync2  <= pclk_sync1;  pclk_prev  <= pclk_sync2;
                data_sync1  <= ov7670_data;  data_sync2  <= data_sync1;
                reg <= reg_next;
            END IF;
        END IF;
    END PROCESS;

    comb : PROCESS (reg, data_sync2, pclk_rising_edge, href_sync2, start, vsync_falling_edge, config_finished)
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
                    reg_next.bram_address <= (OTHERS => '0');
                    reg_next.line_started <= '0';
                    reg_next.state <= start_capturing;
                END IF;

            WHEN start_capturing =>
                IF href_sync2 = '1' AND reg.line_started = '0' THEN
                    reg_next.pixel_reg <= 0;
                    reg_next.bram_address <= to_unsigned(reg.href_cnt * 640, 19);
                    reg_next.line_started <= '1';
                    reg_next.state <= capture_line;
                ELSIF href_sync2 = '0' THEN
                    reg_next.line_started <= '0';
                END IF;

            WHEN capture_line =>
                IF href_sync2 = '1' AND pclk_rising_edge = '1' AND reg.pixel_reg < 640 THEN
                    reg_next.rgb_reg(15 DOWNTO 8) <= data_sync2;
                    reg_next.state <= capture_rgb_byte;
                ELSIF href_sync2 = '0' THEN
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
                    reg_next.href_cnt <= reg.href_cnt + 1;
                    reg_next.line_started <= '0';
                    IF reg.href_cnt = 479 THEN
                        reg_next.state <= frame_finished;
                    ELSE
                        reg_next.state <= start_capturing;
                    END IF;
                END IF;
                
            WHEN write_to_bram =>
                IF reg.pixel_reg < 640 AND reg.href_cnt < 480 THEN
                    wea <= "1";
                    dina <= reg.rgb_reg(11 DOWNTO 0);
                    reg_next.bram_address <= reg.bram_address + 1;
                    
                    reg_next.block_sums(reg.blk_y * 8 + reg.blk_x) <= reg.block_sums(reg.blk_y * 8 + reg.blk_x) + unsigned(reg.rgb_reg);
                    
                    IF reg.cnt_x = 79 THEN 
                        reg_next.cnt_x <= 0;
                        IF reg.blk_x < 7 THEN 
                            reg_next.blk_x <= reg.blk_x + 1;
                        ELSE
                            reg_next.blk_x <= 0; 
                        END IF;
                    ELSE
                        reg_next.cnt_x <= reg.cnt_x + 1; 
                    END IF;
                END IF;

                IF reg.pixel_reg >= 640 THEN
                    reg_next.href_cnt <= reg.href_cnt + 1;
                    reg_next.line_started <= '0';
                    reg_next.cnt_x <= 0;
                    reg_next.blk_x <= 0;

                    IF reg.cnt_y = 79 THEN
                        reg_next.cnt_y <= 0;
                        IF reg.blk_y < 5 THEN 
                            reg_next.blk_y <= reg.blk_y + 1;
                        END IF;
                    ELSE
                        reg_next.cnt_y <= reg.cnt_y + 1; 
                    END IF;

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
                reg_next <= INIT_REG_FILE;
                reg_next.state <= wait_for_new_frame;

            WHEN OTHERS => NULL;
        END CASE;
    END PROCESS;

END ARCHITECTURE;