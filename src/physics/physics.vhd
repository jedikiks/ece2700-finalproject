library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity physics is
	port ( clock, resetn: in std_logic;
	       RAM_DO, ps2_done, E_phy: in std_logic;
	       din: in std_logic_vector( 7 downto 0 );	-- change this if you have bigger scan codes
	       E_fallCt: out std_logic;
	       posX, posY: out std_logic_vector( 9 downto 0 );
	       addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
      	     );
end physics;

architecture Behavioral of physics is
	signal e_jumpct, fall_done, check_fall, E_addr, posX_E, posY_E, falling, l_r, sub_sel: std_logic;
	signal addr_sel: std_logic_vector( 2 downto 0 );
	signal fall_newPosY, nofall_posY_D, r_posX_D, l_posX_D, oldXl_Y, 
           posY_Q, posY_D, posX_D, posX_Q, posX_l, posX_r, newY_jump, newX_r,
	       Xl_Y_addr, newXl_Y, newXl_Y_YQ, newXl_Y_Ymult, newXl_Y_Xlmult, newXl_Y_XlQ: std_logic_vector( 9 downto 0 );
	signal newX_r_addr, newX_l_addr, posY_jump_addr, fall_newPosY_addr, D_addr: std_logic_vector( 19 downto 0 );

	component xPosition 
	   port ( clock, resetn, posX_E, l_r: in std_logic;
	          posY_Q: in std_logic_vector( 9 downto 0 );
	          posX_Q : out std_logic_vector( 9 downto 0 );
	          newX_r_addr, newX_l_addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
        	);
	end component;

	component yPosition 
	   port ( clock, resetn, posY_E, falling: in std_logic;
	          posX_Q: in std_logic_vector( 9 downto 0 );
	          posY_Q: out std_logic_vector( 9 downto 0 );
	          fall_newPosY_addr, posY_jump_addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
      	     );
	end component;

	component address_select 
	   port ( fall_newPosY_addr, posY_jump_addr, newX_r_addr, newX_l_addr: in std_logic_vector( 19 downto 0 );
              addr_sel: in std_logic_vector( 2 downto 0 );
              E_addr, clock, resetn: in std_logic;
	          addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
      	     );
	end component;

	component fallFSM
	    port ( clock, resetn: in std_logic;
	           RAM_DO, check_fall: in std_logic;
	           E_fallCt, posY_E, E_addr: out std_logic;
	           falling, fall_done, sclrQ: out std_logic;
	           addr_sel: out std_logic_vector( 2 downto 0 )
          	 );
	end component;

	component mainFSM
	    port ( clock, resetn: in std_logic;
	           RAM_DO, ps2_done, fall_done, E_phy: in std_logic;
	           din: in std_logic_vector( 7 downto 0 );	-- change this if you have bigger scan codes
	           addr_sel: out std_logic_vector( 2 downto 0 );
	           E_jumpCt, posY_E, posX_E, E_addr: out std_logic;
	           check_fall, l_r: out std_logic
          	     );
	end component;

begin
    posY <= posY_Q;
    posY <= posY_Q;

	xp: xPosition port map( clock => clock,
				            resetn => resetn,
				            posX_E => posX_E,
				            l_r => l_r,
				            posY_Q => posY_Q,
				            posX_Q => posX_Q, 
				            newX_r_addr => newX_r_addr, 
				            newX_l_addr => newX_l_addr
			 	          );
	yp: yPosition port map( clock => clock,
				            resetn => resetn,
				            posY_E => posY_E,
                            falling => falling,
				            posY_Q => posY_Q,
				            posX_Q => posX_Q, 
				            fall_newPosY_addr => fall_newPosY_addr, 
				            posY_jump_addr => posY_jump_addr
			 	          );
	adrsel: address_select port map( clock => clock,
			          	             resetn => resetn,
			          	             fall_newPosY_addr => fall_newPosY_addr,
			          	             posY_jump_addr => posY_jump_addr,
			          	             newX_r_addr => newX_r_addr,
			          	             newX_l_addr => newX_l_addr, 
			          	             addr_sel => addr_sel, 
			          	             E_addr => E_addr,
                                     addr => addr
			           	           );
	-- Two FSMs --
	fallfsmd: fallFSM port map( clock => clock,
				                resetn => resetn,
				                RAM_DO => RAM_DO,
				                check_fall => check_fall,
				                E_fallCt => E_fallCt,
				                posY_E => posY_E, 
				                E_addr => E_addr, 
				                falling => falling, 
				                fall_done => fall_done
			 	              );
	mainfsmd: mainFSM port map( clock => clock,
				                resetn => resetn,
				                check_fall => check_fall,
				                ram_do => ram_do,
				                din => din,
				                ps2_done => ps2_done,
				                E_jumpct => E_jumpct,
				                E_phy => E_phy,
				                posy_E => posy_E, 
				                posx_E => posy_E, 
				                E_addr => E_addr, 
				                fall_done => fall_done, 
				                addr_sel => addr_sel, 
				                l_r => l_r 
			 	              );
end;
