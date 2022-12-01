library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    Port ( clock, resetn, ps2c, ps2d: in std_logic;
           HSYNC, VSYNC: out std_logic;
           RGB_OUT: out std_logic_vector( 2 downto 0 );
           sevseg: out std_logic_vector( 6 downto 0 ); 
           AN: out std_logic_vector( 7 downto 0 )
         ); 
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

    component physics
	    port ( clock, resetn: in std_logic;
	           canFall, canMoveLeft, canMoveRight, canMoveUp, ps2_done, E_phy: in std_logic;
	           din: in std_logic_vector( 7 downto 0 );	-- change this if you have bigger scan codes
	           X_immediate, Y_immediate: in std_logic_vector( 9 downto 0 );
	           E_fallCt: out std_logic;
	           posX, posY: out std_logic_vector( 9 downto 0 );
	           addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
          	 );
    end component;

    component my_ps2read is
	    port (resetn, clock: in std_logic;
	    		ps2c, ps2d: in std_logic;
                DOUT: out std_logic_vector (7 downto 0); -- FIXME: prof had this as a 10 bit signal when he meant 8bit ?
	    		done: out std_logic);
    end component;

begin

    vgaCtrl: VGA_Controller port map( CLK => clock,
                                      RESET => resetn,
                                      TEST => ( others => '0' ), --FIXME: what should this be ? 
                                      HSYNC => HSYNC,
                                      VSYNC => VSYNC,
                                      RGB_OUT => RGB_OUT
                                    );
    mymap: mapping generic map( N => 80 )
                   port map( clock => clock,
                             resetn => resetn,
                             EN => , --FIXME: what is this
                             nextMap => nextMap,
                             prevMap => prevMap,
                             moveLeft => canMoveLeft,
                             moveRight => canMoveRight,
                             jump => canMoveUp,




end;
