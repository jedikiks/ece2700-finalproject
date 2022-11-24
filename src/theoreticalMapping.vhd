library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity testMap is
  generic(N: INTEGER:= 80); -- 8 rows, 10 columns, 80 total squares of size 8x6 for the grid, based off a 640x480 screen
  Port ( clock, resetn, EN, nextMap, prevMap : in STD_LOGIC;
         newMap : in STD_LOGIC_VECTOR (N-1 downto 0);
         currentMapArray : out STD_LOGIC_VECTOR (N-1 downto 0);
         nextMapArray : out STD_LOGIC_VECTOR (N-1 downto 0);
         lastMapArray : out STD_LOGIC_VECTOR (N-1 downto 0);
         currentLocation : out STD_LOGIC
         );
end testMap;

--        What it will look like           |       What the arrays will look like       --

------------------------------------------------------------------------------------------

--            1 1 1 1 1 1 1 1 1 1          |         1 1 1 1 1 1 1 1 1 1                --
--            1 1     1 1     1 1          |         1 1 0 0 1 1 0 0 1 1                --
--            1     1 1 1     1 1          |         1 0 0 1 1 1 0 0 1 1                --
--            1     1 1 1 1     1          |         1 0 0 1 1 1 1 0 0 1                --
--            1               1 1          |         1 0 0 0 0 0 0 0 1 1                --
--            1 1         1 1 1 1          |         1 1 0 0 0 0 1 1 1 1                --
--            1 1 1 1     1 1 1 1          |         1 1 1 1 0 0 1 1 1 1                --
--            1 1 1 1 1 1 1 1 1 1          |         1 1 1 1 1 1 1 1 1 1                --

------------------------------------------------------------------------------------------

-- 1111111111 1100110011 1001110011 1001111001 1000000011 110000111111 1100111111 11111111
--     r1         r2         r3         r4         r5          r6          r7        r8

------------------------------------------------------------------------------------------

architecture Behavioral of testMap is

  signal lma, nma, cma, nm : STD_LOGIC_VECTOR (N-1 downto 0);
  signal r1, r2, r3, r4, r5, r6, r7, r8 : STD_LOGIC_VECTOR ((N/8)-1 downto 0);
  signal cl : STD_LOGIC;  
  
  begin
    cma <= '11111111111100110011100111001110011110011000000011110000111111110011111111111111'

    r1 <= cma(79 downto 70)
    r2 <= cma(69 downto 60)
    r3 <= cma(59 downto 50)
    r4 <= cma(49 downto 40)
    r5 <= cma(39 downto 30)
    r6 <= cma(29 downto 20)
    r7 <= cma(19 downto 10)
    r8 <= cma(9 downto 0)

    if EN = '1' then
      if nextMap = '1' then
        if newMap = '00000000000000000000000000000000000000000000000000000000000000000000000000000000' then -- If this is saying 'entirely empty space, nothing new'
          nm <= lma -- Rotates to the next map available if new one is not provided
        end if;
        nma <= nm;
        cma <= nma;
        lma <= cma;
      elsif prevMap = '1' then
        if newMap = '00000000000000000000000000000000000000000000000000000000000000000000000000000000' then -- If this is saying 'entirely empty space, nothing new'
          nm <= nma -- Rotates to the next map available if new one is not provided
        end if;
        nma <= cma;
        cma <= lma;
        lma <= nm;
      else 
        nma <= nma;
        cma <= cma;
        lma <= lma;
      end if;
    end if;
    
    currentLocation <= cl

    nextMapArray <= nma;
    currentMapArray <= cma;
    lastMapArray <= lma;

end Behavioral;