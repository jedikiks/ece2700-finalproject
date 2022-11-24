library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xPosition is
	port ( clock, resetn, posX_E, l_r: in std_logic;
	       posY_Q: in std_logic_vector( 9 downto 0 );
	       posX_Q, newX_r_addr, newX_l_addr: out std_logic_vector( 9 downto 0 ) -- change this if address width is different
      	 );
end xPosition;

architecture Behavioral of xPosition is
	signal posX_r, posX_l, posX_r_wp1, posX_l_pm1, posX_D: std_logic_vector( 9 downto 0 );

	component my_rege
		generic (N: INTEGER:= 4);
		     port ( clock, resetn: in std_logic;
		            E, sclr: in std_logic; -- sclr: Synchronous clear
		     		 D: in std_logic_vector (N-1 downto 0);
		            Q: out std_logic_vector (N-1 downto 0));
	end component;

begin
	-- inferred adders --
	posX_r_wp1 <= std_logic_vector( to_unsigned( to_integer( unsigned( posX_r ) ) + 5, 10 ) ); -- Assuming a height of 4
	posX_l_pm1 <= std_logic_vector( to_unsigned( to_integer( unsigned( posX_l ) ) - 1, 10 ) );        -- pos - 1

	-- inferred multipliers --
    newX_r_addr <=  std_logic_vector( unsigned( posY_Q ) * 640 + unsigned( posX_r_wp1 ) );
    newX_l_addr <= std_logic_vector( unsigned( posY_Q ) * 640 + unsigned( posX_l_pm1 ) );

	with l_r select
		posX_D <= posX_l_pm1 when '0',
	  		      posX_r_wp1 when '1',
			      ( others => '-' ) when others;		  

	posX_r <= posX_Q when l_r = '1' else ( others => '0' );
	posX_l <= posX_Q when l_r = '0' else ( others => '0' );

	posYreg: my_rege generic map( N => 10) -- change this if bit widths for HC and VC are different
	        	     port map( clock => clock,
				               resetn => resetn,
				               E => posX_E,
				               sclr => '1', --FIXME: should this be 1?
				               D => posX_D,
				               Q => posX_Q 
				             );
end;
