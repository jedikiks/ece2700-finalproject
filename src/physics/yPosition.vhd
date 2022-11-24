library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity yPosition is
	port ( clock, resetn, posY_E, falling: in std_logic;
	       posX_Q: in std_logic_vector( 9 downto 0 );
	       posY_Q, fall_newPosY_addr, posY_jump_addr: out std_logic_vector( 9 downto 0 ) -- change this if address width is different
      	 );
end yPosition;

architecture Behavioral of yPosition is
	signal fall_newPosY, posY_m1, posY_D: std_logic_vector( 9 downto 0 );

	component my_rege
		generic (N: INTEGER:= 4);
		     port ( clock, resetn: in std_logic;
		            E, sclr: in std_logic; -- sclr: Synchronous clear
		     		 D: in std_logic_vector (N-1 downto 0);
		            Q: out std_logic_vector (N-1 downto 0));
	end component;

begin
	-- inferred adders --
	fall_newPosY <= std_logic_vector( to_unsigned( to_integer( unsigned( posY_Q ) ) + 5, 10 ) ); -- Assuming a height of 4
	posY_m1 <= std_logic_vector( to_unsigned( to_integer( unsigned( posY_Q ) ) - 1, 10 ) );        -- pos - 1

	-- inferred multipliers --
    fall_newPosY_addr <=  std_logic_vector( unsigned( fall_newPosY ) * 640 + unsigned( posX_Q ) );
    posY_jump_addr <= std_logic_vector( unsigned( posY_m1 ) * 640 + unsigned( posX_Q ) );

	with falling select
		posY_D <= posY_m1 when '0',
	  		      fall_newPosY when '1',
			      ( others => '-' ) when others;

	posYreg: my_rege generic map( N => 10) -- change this if bit widths for HC and VC are different
	        	     port map( clock => clock,
				               resetn => resetn,
				               E => posY_E,
				               sclr => '1', --FIXME: should this be 1?
				               D => posY_D,
				               Q => posY_Q 
				             );
end;
