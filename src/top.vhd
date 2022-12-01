library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    Port ( CLK, RESET : in STD_LOGIC; -- CLK is a 50.35MHz clock signal
           --RGB_IN : in STD_LOGIC_VECTOR (2 downto 0);
           --INDEX_X_IN, INDEX_Y_IN : in STD_LOGIC_VECTOR (9 downto 0);
           TEST : in STD_LOGIC_VECTOR (3 downto 0); 
           HSYNC, VSYNC : out STD_LOGIC;
           RGB_OUT : out STD_LOGIC_VECTOR (2 downto 0));
end top;

architecture Behavioral of top is
    component VGA_Controller
       Port ( CLK, RESET : in STD_LOGIC; -- CLK is a 50.35MHz clock signal
              --RGB_IN : in STD_LOGIC_VECTOR (2 downto 0);
              --INDEX_X_IN, INDEX_Y_IN : in STD_LOGIC_VECTOR (9 downto 0);
              TEST : in STD_LOGIC_VECTOR (3 downto 0); 
              HSYNC, VSYNC : out STD_LOGIC;
              RGB_OUT : out STD_LOGIC_VECTOR (2 downto 0));
    end component;

    component mapping
        generic(N: INTEGER:= 80); -- 8 rows, 10 columns, 80 total squares of size 8x6 for the grid, based off a 640x480 screen
        Port (clock, resetn, EN, nextMap, prevMap, moveLeft, moveRight, jump : in STD_LOGIC;
              newMap : in STD_LOGIC_VECTOR (N-1 downto 0);
              currentX, currentY : in INTEGER;
              
              currentMapArray, lastMapArray, nextMapArray : out STD_LOGIC_VECTOR (N-1 downto 0);
              cX, cY : out INTEGER;
              canFall, canMoveLeft, canMoveRight, canJump : out STD_LOGIC
              );
    end component;

    component GameFSM
       Port ( resetn : in STD_LOGIC;
              clock : in STD_LOGIC;
              pause : in STD_LOGIC;
              isPaused : out std_logic;
              segs : out std_logic_vector(6 downto 0);
              en : out std_logic_vector(7 downto 0));
    end component;

    component sevSegDecoder
	    port (input : in std_logic;
	    	  sevseg: out std_logic_vector (6 downto 0);
	    	  AN: out std_logic_vector(7 downto 0));
    end component;

    component my_ps2read is
	    port (resetn, clock: in std_logic;
	    		ps2c, ps2d: in std_logic;
                DOUT: out std_logic_vector (7 downto 0); -- FIXME: prof had this as a 10 bit signal when he meant 8bit ?
	    		done: out std_logic);
    end component;

begin


end;
