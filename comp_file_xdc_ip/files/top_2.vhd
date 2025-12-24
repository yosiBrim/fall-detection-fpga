LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY top IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        scl : INOUT STD_LOGIC;
        sda : INOUT STD_LOGIC;
        ov7670_vsync : IN STD_LOGIC;
        ov7670_href : IN STD_LOGIC;
        ov7670_pclk : IN STD_LOGIC;
        ov7670_xclk : OUT STD_LOGIC;
        ov7670_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        btn : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        sw : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        led : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);  -- Extended to 4 LEDs for posture indication
        ov7670_pwdn : OUT STD_LOGIC;
        ov7670_reset : OUT STD_LOGIC;
        VGA_HS_O : OUT STD_LOGIC;
        VGA_VS_O : OUT STD_LOGIC;
        VGA_R : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_B : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_G : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END top;

ARCHITECTURE rtl OF top IS
    SIGNAL rst : STD_LOGIC := '1';
    SIGNAL edge : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL config_finished : STD_LOGIC := '0';

    SIGNAL vga_640x480_clk : STD_LOGIC := '0';
    SIGNAL xclk_ov7670 : STD_LOGIC := '0';
    SIGNAL ena : STD_LOGIC := '1';
    SIGNAL wea : STD_LOGIC_VECTOR(0 DOWNTO 0) := (OTHERS => '0');
    SIGNAL addra : STD_LOGIC_VECTOR(18 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dina : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL enb : STD_LOGIC := '1';
    SIGNAL addrb : STD_LOGIC_VECTOR(18 DOWNTO 0) := (OTHERS => '0');
    SIGNAL doutb : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');

    SIGNAL frame_finished_in : STD_LOGIC := '0';
    
    -- Signals for posture detection
    SIGNAL pixel_valid : STD_LOGIC;
    SIGNAL pixel_x : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL pixel_y : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL posture_change_detected : STD_LOGIC:= '0';
    SIGNAL current_posture : STD_LOGIC:= '0';
    
    component clk_wiz_0 
        port
         (-- Clock in ports
          -- Clock out ports
          vga_pll          : out    std_logic;
          xclk_pll          : out    std_logic;
          -- Status and control signals
          reset             : in     std_logic;
          locked            : out    std_logic;
          clk_in1           : in     std_logic
         );
    end component;

    COMPONENT blk_mem_gen_0
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
      );
    END COMPONENT;

    -- Posture detector component
    COMPONENT posture_detector
        PORT (
            clk                    : IN STD_LOGIC;
            rst                    : IN STD_LOGIC;
            frame_finished         : IN STD_LOGIC;
            pixel_data             : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            pixel_valid            : IN STD_LOGIC;
            pixel_x                : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            pixel_y                : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			sw 					   : in STD_LOGIC;
            posture_change_detected : OUT STD_LOGIC;
            current_posture        : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN

    -- Map LEDs to status signals
    led(0) <= sw(0);
    led(1) <= config_finished;
    led(1) <= posture_change_detected;  -- LED to indicate posture change
    led(2) <= current_posture;          -- LED to indicate current posture ('0' for standing, '1' for sitting)
	ov7670_pwdn <= '0';
  
  -- Clock generator
    clk_generator: clk_wiz_0
        port map (
            vga_pll => vga_640x480_clk,
            xclk_pll => xclk_ov7670,
            reset => '0',
            locked => OPEN,
            clk_in1 => clk
        );
    
    ov7670_xclk <= xclk_ov7670;

    -- Camera configuration
    ov7670_configuration : ENTITY work.ov7670_configuration(Behavioral)
        PORT MAP(
            clk => clk,
            rst => rst,
            sda => sda,
            scl => scl,
            ov7670_reset => ov7670_reset,
            start => '1', --edge(0),
            ack_err => OPEN,
            done => open,
            config_finished => config_finished,
            reg_value => open
        );

    -- Frame buffer
    frame_buffer: blk_mem_gen_0
      PORT MAP (
        clka => clk,
        ena => ena,
        wea => wea,
        addra => addra,
        dina => dina,
        clkb => vga_640x480_clk,
        enb => enb,
        addrb => addrb,
        doutb => doutb
      );

    -- Camera capture
    ov7670_capture : ENTITY work.ov7670_capture(rtl) PORT MAP(
        clk => clk,
        rst => rst,
        config_finished => config_finished,
		ov7670_vsync => ov7670_vsync,  
		ov7670_href => ov7670_href,
		ov7670_pclk => ov7670_pclk,
		ov7670_data => ov7670_data,
        frame_finished_o => frame_finished_in,
        start => '1' ,--edge(1),

        --frame_buffer signals
        wea => wea,
        dina => dina,
        addra => addra
        );
		
    -- Address conversion to extract x,y coordinates for posture detector
    pixel_x <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(addra)) mod 640, 10));
    pixel_y <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(addra)) / 640, 10));
    
    -- Generate pixel_valid signal from wea
    pixel_valid <= wea(0);

    -- Posture detector instance
    posture_detector_inst : posture_detector
    PORT MAP(
        clk => clk,
        rst => rst,
        frame_finished => frame_finished_in,
        pixel_data => dina,
        pixel_valid => pixel_valid,
        pixel_x => pixel_x,
        pixel_y => pixel_y,
		sw => sw(1),
        posture_change_detected => posture_change_detected,
        current_posture => current_posture
    );

    -- Edge detector for buttons
    EDGE_DETECT : ENTITY work.debounce(Behavioral) PORT MAP(
        clk => clk,
        rest => rst,
        btn => btn,
        edge => edge
    );

    -- Reset button debouncer
    RET_DETECT : ENTITY work.debounce_rst(Behavioral) PORT MAP(
        clk => clk,
        btn => reset,
        edge => rst
    );

    -- VGA controller
    vga_controller : ENTITY work.vga_controller(rtl)
        PORT MAP(
            clk => clk,
            rst => rst,
            pxl_clk => vga_640x480_clk,
            start => sw(0),
            VGA_HS_O => VGA_HS_O,
            VGA_VS_O => VGA_VS_O,
            VGA_R => VFA_R,
            VGA_G => VGA_G,
            VGA_B => VGA_B,
            --frame_finished_in => frame_finished_in,
            addrb => addrb,
            doutb => doutb
        );

END ARCHITECTURE;D
