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
           --RGB_IN : in STD_LOGIC_VECTOR (2 downto 0);
           --INDEX_X_IN, INDEX_Y_IN : in STD_LOGIC_VECTOR (9 downto 0);
           TEST : in STD_LOGIC_VECTOR (3 downto 0); 
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

-- Boxes
--signal Box_X : integer := 80;
--signal Box_Y : integer := 80;

--signal match : STD_LOGIC := '0';
--signal INDEX_X, INDEX_Y : STD_LOGIC_VECTOR (9 downto 0);


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
Draw: process (clock, RESET, HP, VP, VIDEO) --, Box_X, Box_Y, INDEX_X_IN, INDEX_Y_IN, RGB_IN, match)
    begin
        if (RESET = '1') then
            RGB_OUT <= "000";
        elsif (clock'event and clock = '1') then
            if (VIDEO = '1') then
                        
                -- FRAME DATA GOES HERE
                -- HP = HORIZONTAL POSITION (RANGE: 0 TO 639)
                -- VP = VERTICAL POSITION (RANGE: 0 TO 479)
                -- COLORS CAN BE FOUND @ ece.ualberta.ca/~elliott/ee552/studentAppNotes/1999_w/16Colors/                
                
                -- Test
                if TEST(3) = '1' then
                    if (HP >= 0 and HP <= 29 and VP >= 0 and VP <= 29) then
                        RGB_OUT <= "100";
                    else 
                        RGB_OUT <= "000";
                    end if;
                end if; 
                
                if TEST(2) = '1' then
                    if (HP >= 30 and HP <= 59 and VP >= 0 and VP <= 29) then
                        RGB_OUT <= "010";
                    else 
                        RGB_OUT <= "000";
                    end if;
                end if;
                
                if TEST(1) = '1' then
                    if (HP >= 0 and HP <= 29 and VP >= 30 and VP <= 59) then
                        RGB_OUT <= "001";
                    else 
                        RGB_OUT <= "000";
                    end if;
                end if; 
                
                if TEST(0) = '1' then
                    if (HP >= 30 and HP <= 59 and VP >= 30 and VP <= 59) then
                        RGB_OUT <= "110";
                    else 
                        RGB_OUT <= "000";
                    end if;
                end if;
                
                if TEST = "0101" then
                    if (HP >= 60 and HP <= 199 and VP >= 60 and VP <= 199) then
                        RGB_OUT <= "011";
                    else 
                        RGB_OUT <= "000";
                    end if;
                elsif TEST = "1110" then
                    if (HP >= 400 and HP <= 639 and VP >= 300 and VP <= 479) then
                        RGB_OUT <= "111";
                    else 
                        RGB_OUT <= "000";
                    end if;
                elsif TEST = "1010" then
                    if (HP >= 200 and HP <= 499 and VP >= 0 and VP <= 255) then
                        RGB_OUT <= "101";
                    elsif (HP >= 0 and HP <= 59 and VP >= 0 and VP <= 59) then                        
                    else 
                        RGB_OUT <= "000";
                    end if;
                elsif TEST = "1111" then
                    if (HP >= 123 and HP <= 456 and VP >= 123 and VP <= 456) then
                        RGB_OUT <= "100";
                    else 
                        RGB_OUT <= "101";
                    end if; 
                end if;
                
                --for y in 0 to 79 loop
				--	for x in 0 to 79 loop
				--		INDEX_X <= STD_LOGIC_VECTOR(to_unsigned(x, INDEX_X'length));					
				--		INDEX_Y <= STD_LOGIC_VECTOR(to_unsigned(y, INDEX_Y'length));
				--												
				--		match <= '0';
				--												
				--		if (HP >= x*((H+1)/Box_X) and HP < (x+1)*((H+1)/Box_X)and VP >= y*((V+1)/Box_Y) and VP < (y+1)*((V+1)/Box_Y)) then
				--		
				--			if match = '0' then
				--	
				--				if (INDEX_X = INDEX_X_IN and INDEX_Y = INDEX_Y_IN) then
				--	
				--					RGB_OUT <= RGB_IN;
				--					match <= '1';
				--					
				--				else
				--				end if;
				--			
				--			end if;
				--			
				--		else
				--		
				--			RGB_OUT <= "000";
				--		
				--		end if;
				--	end loop;
				--end loop;
                
                
                
                
                
                
                
            else
                RGB_OUT <= "000";
            end if;
        end if;
end process;
    
end Behavioral;
