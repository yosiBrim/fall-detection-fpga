----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.03.2021 18:46:17
-- Design Name: 
-- Module Name: debounce - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY debounce IS
    PORT (
        clk : IN STD_LOGIC;
        rest : IN STD_LOGIC;  -- הוספת אות reset
        btn : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        edge : OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
END debounce;

ARCHITECTURE Behavioral OF debounce IS
    SIGNAL c0, c1, c2 : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    CONSTANT DEBOUNCE_TIME : INTEGER := 500000; -- 5ms at 100MHz clock
    SIGNAL counter : INTEGER RANGE 0 TO DEBOUNCE_TIME := 0;
    SIGNAL btn_stable : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
    PROCESS (clk, rest)
    BEGIN
        IF rest = '1' THEN
            c0 <= (OTHERS => '0');
            c1 <= (OTHERS => '0');
            c2 <= (OTHERS => '0');
            counter <= 0;
            btn_stable <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            c0 <= btn;
            c1 <= c0;
            c2 <= c1;
            
            -- Check if button state changed
            IF c0 /= c1 THEN
                counter <= 0;
            ELSIF counter < DEBOUNCE_TIME THEN
                counter <= counter + 1;
            ELSE
                btn_stable <= c2;
            END IF;
        END IF;
    END PROCESS;

    -- Edge detection
    edge <= btn_stable AND NOT c1;
END Behavioral;