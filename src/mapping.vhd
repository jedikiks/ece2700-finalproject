library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
use ieee.STD_LOGIC_ARITH.ALL;
use ieee.MATH_REAL.ALL;

entity testMap is
  generic(N: INTEGER:= 80); -- 8 rows, 10 columns, 80 total squares of size 8x6 for the grid, based off a 640x480 screen
  Port (clock, resetn, EN, nextMap, prevMap, moveLeft, moveRight, jump : in STD_LOGIC;
        newMap : in STD_LOGIC_VECTOR (N-1 downto 0);
        currentX, currentY : in INTEGER;
        
        currentMapArray, lastMapArray, nextMapArray : out STD_LOGIC_VECTOR (N-1 downto 0);
        cX, cY : out INTEGER;
        canFall, canMoveLeft, canMoveRight, canJump : out STD_LOGIC
        );
end testMap;

--                  cma                  |                  lma                  |                  nma                  | --

-----------------------------------------------------------------------------------------------------------------------------

--          1 1     1 1 1 1 1 1          |         1 1 1 1     1 1 1 1           |         1 1 1 1 1 1 1 1 1 1
--          1 1     1 1     1 1          |         1         1 1     1           |         1 1 1     1 1 1   1
--          1     1 1 1     1 1          |         1   1             1           |         1   1 1   1 1     1
--          1     1 1 1 1     1          |         1 1 1 1           1           |         1         1     1 1
--          1               1 1          |         1 1 1 1 1 1       1           |         1 1     1 1       1
--          1 1         1 1 1 1          |         1 1 1         1   1           |         1 1           1   1
--          1 1 1 1     1 1 1 1          |         1           1 1 1 1           |         1 1 1         1 1 1
--          1 1 1 1 1 1 1 1 1 1          |         1 1     1 1 1 1 1 1           |         1 1 1 1     1 1 1 1

-----------------------------------------------------------------------------------------------------------------------------

--                                      cma
-- 1100111111 1100110011 1001110011 1001111001 1000000011 110000111111 1100111111 11111111
--     rc1       rc2         rc3        rc4       rc5         rc6         rc7       rc8

--                                      lma
-- 1111001111 1000011001 1010000001 1111000001 1111110001 1110000101 1000001111 1100111111
--     rl1       rl2         rl3       rl4        rl5        rl6         rl7        rl8

--                                      nma
-- 1111111111 1110011101 1011011001 1000010011 1100110001 1100000101 1110000111 1111001111
--     rn1       rn2         rn3        rn4         rn5      rn6         rn7         rn8

------------------------------------------------------------------------------------------

architecture Behavioral of testMap is


  signal lma, nma, cma, nm : STD_LOGIC_VECTOR (N-1 downto 0);
  signal rc1, rc2, rc3, rc4, rc5, rc6, rc7, rc8 : STD_LOGIC_VECTOR ((N/8)-1 downto 0);
  signal rl1, rl2, rl3, rl4, rl5, rl6, rl7, rl8 : STD_LOGIC_VECTOR ((N/8)-1 downto 0);
  signal rn1, rn2, rn3, rn4, rn5, rn6, rn7, rn8 : STD_LOGIC_VECTOR ((N/8)-1 downto 0);
  signal current : STD_LOGIC;
  signal clX, clY, row : NATURAL;
  
  begin
    cma <= "11001111111100110011100111001110011110011000000011110000111111110011111111111111"; -- "Current Stage" array.
    lma <= "11110011111000011001101000000111110000011111110001111000010110000011111100111111"; -- "Last Stage" array. Can be hardcoded or shifted in
    nma <= "11111111111110011101101101100110000100111100110001110000010111100001111111001111"; -- "Next Stage" array. Can be hardcoded or shifted in

    rc1 <= cma(79 downto 70);
    rc2 <= cma(69 downto 60);
    rc3 <= cma(59 downto 50);
    rc4 <= cma(49 downto 40);
    rc5 <= cma(39 downto 30);
    rc6 <= cma(29 downto 20);
    rc7 <= cma(19 downto 10);
    rc8 <= cma(9 downto 0);
    
    rl1 <= lma(79 downto 70);
    rl2 <= lma(69 downto 60);
    rl3 <= lma(59 downto 50);
    rl4 <= lma(49 downto 40);
    rl5 <= lma(39 downto 30);
    rl6 <= lma(29 downto 20);
    rl7 <= lma(19 downto 10);
    rl8 <= lma(9 downto 0);

    rn1 <= nma(79 downto 70);
    rn2 <= nma(69 downto 60);
    rn3 <= nma(59 downto 50);
    rn4 <= nma(49 downto 40);
    rn5 <= nma(39 downto 30);
    rn6 <= nma(29 downto 20);
    rn7 <= nma(19 downto 10);
    rn8 <= nma(9 downto 0);

    Process (EN, nextMap, prevMap)
    begin
        if EN = '1' then
            if nextMap = '1' then
        if newMap = "00000000000000000000000000000000000000000000000000000000000000000000000000000000" then -- If this is saying 'entirely empty space, nothing new'
          nm <= lma; -- Rotates to the next map available if new one is not provided
        end if;
            nma <= nm;
            cma <= nma;
            lma <= cma;
        elsif prevMap = '1' then
        if newMap = "00000000000000000000000000000000000000000000000000000000000000000000000000000000" then -- If this is saying 'entirely empty space, nothing new'
          nm <= nma; -- Rotates to the next map available if new one is not provided
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
    end process;
    
    clX <= currentX/10;
    clY <= currentY/8;
    
    cX <= integer(clX); -- clX is the index of the current location on the X axis with respect to which column it is in
    cY <= integer(clY); -- clY is the index of the current location on the Y axis with respect to which row it is in
    -- Example on how this works - clY determines the row number, so if clY == 5, then the sprite is in rc5.
                                -- clX then determines the column number, which is just the index of it's row. So if clX was 2, the it would be the second value.
                                -- Then, since this has all been determined, we now know that the sprite is located at rc5(2).
                                
    Process (clX, clY, current, moveLeft, moveRight)
    begin
        case clY is 
            when 1 => current <= rc1(clX);
            when 2 => current <= rc2(clX);
            when 3 => current <= rc3(clX);
            when 4 => current <= rc4(clX);
            when 5 => current <= rc5(clX);
            when 6 => current <= rc6(clX);
            when 7 => current <= rc7(clX);
            when 8 => current <= rc8(clX);
            when others => current <= '1';
        end case;
        if moveLeft = '1' then -- if there is a one  in the next spot +/- 1 over (L/R respectively), send back a 0 for 1 and 1 for 0, i.e. 1 cannot move, 0 can move
            case clY is
                when 1 => canMoveLeft <= not(rc1(clX - 1));
                when 2 => canMoveLeft <= not(rc2(clX - 1));
                when 3 => canMoveLeft <= not(rc3(clX - 1));
                when 4 => canMoveLeft <= not(rc4(clX - 1));
                when 5 => canMoveLeft <= not(rc5(clX - 1));
                when 6 => canMoveLeft <= not(rc6(clX - 1));
                when 7 => canMoveLeft <= not(rc7(clX - 1));
                when 8 => canMoveLeft <= not(rc8(clX - 1));
                when others => canMoveLeft <= '0';
            end case;
        elsif moveRight = '1' then
            case clY is 
                when 1 => canMoveLeft <= not(rc1(clX + 1));
                when 2 => canMoveLeft <= not(rc2(clX + 1));
                when 3 => canMoveLeft <= not(rc3(clX + 1));
                when 4 => canMoveLeft <= not(rc4(clX + 1));
                when 5 => canMoveLeft <= not(rc5(clX + 1));
                when 6 => canMoveLeft <= not(rc6(clX + 1));
                when 7 => canMoveLeft <= not(rc7(clX + 1));
                when 8 => canMoveLeft <= not(rc8(clX + 1));
                when others => canMoveLeft <= '0';
            end case;
        end if;
        case clY is -- check one square below current one to see if available to fall - if you can (i.e. square below is a 0), return a 1, and vice-versa 
            when 1 => canFall <= not(rc2(clX));
                      canJump <= not(rn8(clX));
            when 2 => canFall <= not(rc3(clX));
                      canJump <= not(rc1(clX));
            when 3 => canFall <= not(rc4(clX));
                      canJump <= not(rc2(clX));
            when 4 => canFall <= not(rc5(clX));
                      canJump <= not(rc3(clX));
            when 5 => canFall <= not(rc6(clX));
                      canJump <= not(rc4(clX));
            when 6 => canFall <= not(rc7(clX));
                      canJump <= not(rc5(clX));
            when 7 => canFall <= not(rc8(clX));
                      canJump <= not(rc6(clX));
            when 8 => canFall <= not(rl1(clX));
                      canJump <= not(rc7(clX));
            when others => canFall <= '0';
                           canJump <= '0';
        end case;
    end process;

    nextMapArray <= nma;
    currentMapArray <= cma;
    lastMapArray <= lma;

end Behavioral;