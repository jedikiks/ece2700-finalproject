library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity fallFSM is
	port ( clock, resetn: in std_logic;
	       RAM_DO, check_fall, zQ: in std_logic;
	       E_fallCt, posY_E, E_addr: out std_logic;
	       falling, fall_done, sclrQ: out std_logic
      	     );
end fallFSM;

architecture Behavioral of fallFSM is
	component my_genpulse_sclr is
		--generic (COUNT: INTEGER:= (10**8)/2); -- (10**8)/2 cycles of T = 10 ns --> 0.5 s
		generic (COUNT: INTEGER:= (10**2)/2); -- (10**2)/2 cycles of T = 10 ns --> 0.5us
		port (clock, resetn, E, sclr: in std_logic;
				Q: out std_logic_vector ( integer(ceil(log2(real(COUNT)))) - 1 downto 0);
				z: out std_logic);
	end component;

	type state is ( S0, S1, S2 );
	signal y: state;
begin
	pg: my_genpulse_sclr generic map( COUNT <= (10**2)/2 ); -- TODO: change this to non-tb value
		     	     port map( clock <= clock,
				       resetn <= resetn,
				       E <= EQ,
				       sclr <= sclrQ,
				       z <= zQ
				     );

	Transitions: process ( resetn, clock, RAM_DO, check_fall, zQ )
	begin
		if resetn = '0' then
			y <= S0;
		elsif (clock'event and clock = '1') then
			case y is
				when S0 =>
				    if check_fall = '1' then
				        y <= S1;
				    end if;

				when S1 =>
					if RAM_DO ='1' then y <= S0; else y <= S2; end if;
					
				when S2 =>
					if zQ ='1' then y <= S1; else y <= S2; end if;
                                    
                end case;
		end if;
		
	end process;
	
	Outputs: process ( y, RAM_DO, zQ )
	begin		
	    E_addr <= '0'; posY_E <= '0'; falling <= '0'; 	-- Default values
	    fall_done <= '0'; E_fallCt <= '0'; sclrQ <= '0';
		case y is			
			when S1 => E_addr <= '1';
				   if RAM_DO <= '1' then fall_done <= '1'; end if;
			when S2 => falling <= '1';
			    	   if zQ <= '0' then EQ <= '1';
				   else EQ <= '1'; sclrQ <= '1'; posY_E <= '1'; E_fallCt <= '1';
				   end if;
		end case;
	end process;

end;
