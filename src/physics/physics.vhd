library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity physics is
	port ( clock, resetn: in std_logic;
	       RAM_DO, ps2_done: in std_logic;
	       din: in std_logic_vector( 7 downto 0 );	-- change this if you have bigger scan codes
	       E_fallCt: out std_logic;
	       addr: out std_logic_vector( 9 downto 0 ); -- change this if address width is different
      	     );
end physics;

architecture Behavioral of physics is
	signal fall_newPosY: std_logic_vector( 9 downto 0 );
	signal nofall_posY_D: std_logic_vector( 9 downto 0 );
	signal r_posX_D: std_logic_vector( 9 downto 0 );
	signal l_posX_D: std_logic_vector( 9 downto 0 );
	signal oldXl_Y: std_logic_vector( 9 downto 0 );
	signal posY_Q: std_logic_vector( 9 downto 0 );
	signal posX_Q: std_logic_vector( 9 downto 0 );
	signal posX_l: std_logic_vector( 9 downto 0 );
	signal posX_r: std_logic_vector( 9 downto 0 );
	signal newY_jump: std_logic_vector( 9 downto 0 );
	signal newX_r: std_logic_vector( 9 downto 0 );
	signal newXl_Y: std_logic_vector( 9 downto 0 );
	signal D_addr: std_logic_vector( 9 downto 0 );
	signal falling: std_logic;
	signal l_r: std_logic;
	signal sub_sel: std_logic;

	component my_rege is
		generic (N: INTEGER:= 4);
		     port ( clock, resetn: in std_logic;
		            E, sclr: in std_logic; -- sclr: Synchronous clear
		     		 D: in std_logic_vector (N-1 downto 0);
		            Q: out std_logic_vector (N-1 downto 0));
	end component;
	component fallFSM is
		port ( clock, resetn: in std_logic;
		       RAM_DO, check_fall, zQ: in std_logic;
		       E_fallCt, posY_E, E_addr: out std_logic;
		       falling, fall_done, sclrQ: out std_logic
      		     );
	end component;
	component mainFSM is
		port ( clock, resetn: in std_logic;
		       RAM_DO, ps2_done, fall_done: in std_logic;
		       din: in std_logic_vector( 8 downto 0 );	-- change this if you have bigger scan codes
		       addr_sel: out std_logic_vector( 2 downto 0 );
		       E_jumpCt, posY_E, posX_E, E_addr: out std_logic;
		       check_fall, l_r, sub_sel: out std_logic
      		     );
	end component;

begin
	-- inferred adders --
	newY_jump <= std_logic_vector( to_unsigned( to_integer( unsigned( posY_Q ) ) + 5, 10 ) ); -- Assuming a height of 4
	fall_newPosY <= std_logic_vector( to_unsigned( to_integer( unsigned( newY_jump ) ) + 1, 10 ) );
	newXl_Y <= std_logic_vector( to_unsigned( to_integer( unsigned( oldXl_Y ) ) - 1, 10 ) );

	-- ( de )Multiplexors --
	-- falling mux:
	with faling select
		posY_D <= nofall_posY_D when '0',
	  		  fall_newPosY when '1',
			  ( others => '-' ) when others;
	-- l_r mux:
	with l_r select
		posX_D <= l_posX_D when '0',
	  		  r_posX_D when '1',
			  ( others => '-' ) when others;		  
	-- l_r mux:
	with l_r select
		posX_D <= l_posX_D when '0',
	  		  r_posX_D when '1',
			  ( others => '-' ) when others;		  
	-- sub_sel mux:
	with sub_sel select
		oldXl_Y <= posY_Q when '1',
	  		   posX_l when '0',
			   ( others => '-' ) when others;		  
	-- addr mux:
	with addr_sel select
		D_addr <= newY_jump when "10",
	  		  newX_r when "01",
	  		  newXl_Y when "01",
			  ( others => '-' ) when others;		  
	-- l_r demux:
	posX_r <= posX_Q when l_r = '1', else '0';
	posX_l <= posX_Q when l_r = '0', else '0';

	-- The three registers, two for X and Y positions and one for latching the new address --
	posYreg: my_rege generic map( N <= 10); -- change this if bit widths for HC and VC are different
	        	     port map( clock <= clock,
				       resetn <= resetn,
				       E <= posY_E,
				       sclr <= '1', --FIXME: should this be 1?
				       D <= posY_D,
				       Q <= posY_Q 
				     );
	posXreg: my_rege generic map( N <= 10); -- change this if bit widths for HC and VC are different
	        	     port map( clock <= clock,
				       resetn <= resetn,
				       E <= posX_E,
				       sclr <= '1', --FIXME: should this be 1?
				       D <= posX_D,
				       Q <= posX_Q 
				     );
	addrReg: my_rege generic map( N <= 10); -- change this if bit widths for HC and VC are different
	        	     port map( clock <= clock,
				       resetn <= resetn,
				       E <= E_addr,
				       sclr <= '1', --FIXME: should this be 1?
				       D <= D_addr,
				       Q <= addr, 
				     );
	-- Two FSMs --
	fallfsm: fallFSM port map( clock <= clock,
				   resetn <= resetn,
				   RAM_DO <= RAM_DO,
				   check_fall <= check_fall,
				   E_fallCt <= E_fallCt,
				   posY_E <= posY_E, 
				   E_addr <= E_addr, 
				   falling <= falling, 
				   fall_done <= fall_done, 
			 	 );
	mainfsm: fallFSM port map( clock <= clock,
				   resetn <= resetn,
				   RAM_DO <= RAM_DO,
				   din <= din,
				   ps2_done <= ps2_done,
				   check_fall <= check_fall,
				   E_jumpCt <= E_jumpCt,
				   posY_E <= posY_E, 
				   posX_E <= posY_E, 
				   E_addr <= E_addr, 
				   falling <= falling, 
				   fall_done <= fall_done, 
				   addr_sel <= addr_sel, 
				   l_r <= l_r, 
				   sub_sel <= sub_sel, 
			 	 );
end;
