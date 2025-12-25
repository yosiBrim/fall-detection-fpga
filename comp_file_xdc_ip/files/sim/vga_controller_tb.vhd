LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE std.textio.ALL;
USE std.env.finish;

ENTITY vga_controller_tb IS
END vga_controller_tb;

ARCHITECTURE sim OF vga_controller_tb IS

    CONSTANT pxclk_hz : INTEGER := 25e6;
    CONSTANT clk_period : TIME := 1 sec / pxclk_hz;

    SIGNAL clk : STD_LOGIC := '1';
    SIGNAL rst : STD_LOGIC := '1';

    SIGNAL hsync : STD_LOGIC := '0';
    SIGNAL vsync : STD_LOGIC := '0';
    SIGNAL vga_red : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL vga_blue : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL vga_green : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');

    SIGNAL addrb : STD_LOGIC_VECTOR(18 DOWNTO 0) := (OTHERS => '0');
    SIGNAL doutb : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');

    SIGNAL vga_start : STD_LOGIC := '0';

BEGIN

    doutb <= x"426" WHEN addrb = "0000000000000000000" ELSE 
		x"3a4" WHEN addrb = "0000000000000000001" ELSE 
		x"3a4" WHEN addrb = "0000000000000000010" ELSE 
		x"3a1" WHEN addrb = "0000000000000000011" ELSE 
		x"c08" WHEN addrb = "0000000000000000100" ELSE 
		x"4aa" WHEN addrb = "0000000000000000101" ELSE 
		x"778" WHEN addrb = "0000000000000000110" ELSE 
		x"e25" WHEN addrb = "0000000000000000111" ELSE 
		x"0e7" WHEN addrb = "0000000000000001000" ELSE 
		x"df8" WHEN addrb = "0000000000000001001" ELSE 
		x"ce5" WHEN addrb = "0000000000000001010" ELSE 
		x"dc9" WHEN addrb = "0000000000000001011" ELSE 
		x"376" WHEN addrb = "1001000110001010110" ELSE 
		x"eca" WHEN addrb = "1001000110001010111" ELSE 
		x"916" WHEN addrb = "1001000110001011000" ELSE 
		x"184" WHEN addrb = "1001000110001011001" ELSE 
		x"7d6" WHEN addrb = "1001000110001011010" ELSE 
		x"f8f" WHEN addrb = "1001000110001011011" ELSE 
		x"85a" WHEN addrb = "1001000110001011100" ELSE 
		x"7d1" WHEN addrb = "1001000110001011101" ELSE 
		x"49b" WHEN addrb = "1001000110001011110" ELSE 
		x"3ad" WHEN addrb = "1001000110001011111" ELSE 
		x"cf7" WHEN addrb = "1001000110001100000" ELSE 
        	(OTHERS => '0');

    clk <= NOT clk AFTER clk_period / 2;

    DUT : ENTITY work.vga_controller(rtl)
        PORT MAP(
            clk => clk,
            rst => rst,
            pxl_clk => clk,
            VGA_HS_O => hsync,
            VGA_VS_O => vsync,
            start => vga_start,
            VGA_R => vga_red,
            VGA_B => vga_blue,
            VGA_G => vga_green,
            addrb => addrb,
            doutb => doutb
        );

    vga_start <= '1';

    SEQUENCER_PROC : PROCESS
    BEGIN
        WAIT FOR clk_period * 2;

        rst <= '0';

        WAIT FOR clk_period * 10;
        WAIT ON vsync UNTIL falling_edge(vsync);

        WAIT ON vsync UNTIL rising_edge(vsync);

        WAIT FOR clk_period * 100;

    END PROCESS;

END ARCHITECTURE;