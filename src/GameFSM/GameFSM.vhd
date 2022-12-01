----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2022 09:22:30 PM
-- Design Name: 
-- Module Name: GameFSM - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity GameFSM is
    Port ( resetn : in STD_LOGIC;
           clock : in STD_LOGIC;
           pause : in STD_LOGIC;
           isPaused : out std_logic;
           segs : out std_logic_vector(6 downto 0);
           en : out std_logic_vector(7 downto 0));
end GameFSM;

architecture Behavioral of GameFSM is
    
    component sevenseg is
	port (input: in std_logic;
		  sevseg: out std_logic_vector (6 downto 0);
		  AN: out std_logic_vector(7 downto 0));
    end component;


    type state is (S1, S2);
    signal y: state;
    
    
begin
    segDecode: sevenseg port map(input => pause, sevseg => segs, AN => en);
    
    transitions: process(resetn, clock, pause)
    begin
        if resetn = '0' then
            y <= S1;
        elsif (clock'event and clock = '1') then
            case y is
                when S1 => 
                    if pause = '0' then y <= S1; 
                    else y <= S2; end if;
                when S2 => 
                    if pause  = '1' then y <= S2; 
                    else y <= S1; end if;
           end case;
       end if;
    end process;
    
    Outputs: process (y, pause)
    begin
        isPaused <= '0';
        case y is
            when S1 => isPaused <= '1';
            when S2 => isPaused <= '0';
        end case;
    end process;
             
end Behavioral;
