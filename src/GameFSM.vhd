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
           PS2Out : in STD_LOGIC_VECTOR (7 downto 0);
           PS2Done : in STD_LOGIC;
           dout : out STD_LOGIC_VECTOR (7 downto 0);
           E_SC : out STD_LOGIC;
           E_MD : out STD_LOGIC);
end GameFSM;

architecture Behavioral of GameFSM is

    type state is (S1, S2);
    signal y: state;
    
    signal haveWon: std_logic;
begin
    dout <= PS2Out;
    
    transitions: process(resetn, clock, PS2Out, PS2Done)
    begin
        if resetn = '0' then
            y <= S1;
        elsif (clock'event and clock = '1') then
            case y is
                when S1 => 
                    if haveWon = '1' then y <= S1; end if; 
                    if PS2Done = '0' then y <= S1; end if;
                    if PS2Out = x"29" then  y <= S2;
                    elsif PS2Out = x"5A" then  y <= S2;
                    elsif PS2Out = x"76" then  y <= S2;
                    else y <= S1; end if;
                when S2 => 
                    if haveWon = '1' then y <= S1; end if;
                    if PS2Done = '0' then y <= S1; end if;
                    if PS2Out = x"76" then y <= S1;
                    else y <= S2; end if;
           end case;
       end if;
    end process;
    
    Outputs: process (y, PS2Out, PS2Done)
    begin
        haveWon <= '0'; E_SC <= '0'; E_MD <= '0';
        case y is
            when S1 => E_SC  <= '0'; E_MD <= '0';
            when S2 => E_SC  <= '1'; E_MD <= '1';
        end case;
    end process;
             
end Behavioral;
