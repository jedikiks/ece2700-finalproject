----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2022 11:01:27 AM
-- Design Name: 
-- Module Name: VGA_Controller - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA_Controller is
    Port ( CLK, RESET : in STD_LOGIC; -- CLK is a 50.35MHz clock signal
           --RGB_IN : in STD_LOGIC_VECTOR (2 downto 0); -- UNCOMMENT THIS LINE FOR INCOMING RGB DATA
           HSYNC, VSYNC : out STD_LOGIC;
           RGB_OUT : out STD_LOGIC_VECTOR (2 downto 0));
end VGA_Controller;

architecture Behavioral of VGA_Controller is

-- internal clock signal
signal clock : STD_LOGIC := '0';

-- delay constants
constant H : integer := 639; -- highest horizontal pixel value
constant HF : integer := 16 ; -- horizontal front porch
constant HS : integer := 96; -- horizontal sync
constant HB : integer := 48; -- horizontal back porch

constant V : integer := 479; -- highest vertical pixel value
constant VF : integer := 10 ; -- vertical front porch
constant VS : integer := 2; -- vertical sync
constant VB : integer := 33; -- vertical back porch

-- position values
signal HP, VP: integer := 0;

-- video
signal VIDEO : STD_LOGIC := '0';

begin

clock_divider: process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            clock <= not clock;            
        end if;
    end process;

-- position counters
Horizontal_Position: process (clock, RESET)
    begin
        if (RESET = '1') then
            HP <= 0;
        elsif (clock'event and clock = '1') then
            if (HP = H + HF + HS + HB) then
                HP <= 0;
            else
                HP <= HP + 1;
            end if;
        end if;
    end process;

Vertical_Position: process (clock, RESET, HP)
    begin
        if (RESET = '1') then
            VP <= 0;
        elsif (clock'event and clock = '1') then
            if (HP = H + HF + HS + HB) then   
                if (VP = V + VF + VS + VB) then
                    VP <= 0;
                else
                    VP <= VP + 1;
                end if;
            end if;
        end if;
    end process;

-- synchronizes
Horizontal_Synchronize: process (clock, RESET, HP)
    begin
        if (RESET = '1') then
            HSYNC <= '0';
        elsif (clock'event and clock = '1') then
            if ((HP <= (H +HF)) or (HP >= (H + HF + HS))) then
                HSYNC <= '1';
            else
                HSYNC <= '0';
            end if;
        end if;
    end Process;

Vertical_Synchronize: process (clock, RESET, VP)
    begin
        if (RESET = '1') then
            VSYNC <= '0';
        elsif (clock'event and clock = '1') then
            if ((VP <= (V +VF)) or (VP >= (V + VF + VS))) then
                VSYNC <= '1';
            else
                VSYNC <= '0';
            end if;
        end if;
    end Process;

-- enable video output
Video_Enable: process (clock, RESET, HP, VP)
    begin
        if (RESET = '1') then
            VIDEO <= '0';
        elsif (clock'event and clock = '1') then
            if (HP <= H and VP <= V) then
                VIDEO <= '1';
            else
                VIDEO <= '0';
            end if;
        end if;
    end process;

-- draw to screen
Draw: process (clock, RESET, HP, VP, VIDEO)
    begin
        if (RESET = '1') then
            RGB_OUT <= "000";
        elsif (clock'event and clock = '1') then
            if (VIDEO = '1') then
            
                -- FRAME DATA GOES HERE
                -- I'M UNCERTAIN HOW TO SET THE INCOMING DATA TO THE RIGHT POSITIONS
                -- I'VE PROVIDED A TEST OUTPUT BELOW TO SHOW HOW TO DRAW A STATIC BOX
                        
                -- TEST OUTPUT: BOX
                if (HP >= 10 and HP <= 60 and VP >= 10 and VP <= 60) then
                    RGB_OUT <= "111";
                else
                    RGB_OUT <= "000";
                end if;
                -- END TEST OUTPUT
                
                -- HP = HORIZONTAL POSITION (RANGE: 0 TO 639)
                -- VP = VERTICAL POSITION (RANGE: 0 TO 479)
                -- COLORS CAN BE FOUND @ ece.ualberta.ca/~elliott/ee552/studentAppNotes/1999_w/16Colors/                
                
                
            else
                RGB_OUT <= "000";
            end if;
        end if;
    end process;
    
end Behavioral;
