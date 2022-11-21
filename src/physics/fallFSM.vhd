LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity fallFSM is
	port ( clock, resetn: in std_logic;
	       RAM_DO, check_fall, zQ: in std_logic;
	       E_fallCt, posY_E, E_addr: out std_logic;
	       falling, falling_done, sclrQ: out std_logic
      	     );
end fallFSM;

architecture Behavioral of fallFSM is
	component pulseGen
		port();
	end component;

	type state is ( S0, S1, S2 );
	signal y: state;
begin
	pg: pulseGen generic map( );
		     port map( );

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
	    falling_done <= '0'; E_fallCt <= '0'; sclrQ <= '0';
		case y is			
			when S1 => E_addr <= '1';
				   if RAM_DO <= '1' then falling_done <= '1'; end if;
			when S2 => falling <= '1';
			    	   if zQ <= '0' then EQ <= '1';
				   else EQ <= '1'; sclrQ <= '1'; posY_E <= '1'; E_fallCt <= '1';
				   end if;
		end case;
	end process;

end;
