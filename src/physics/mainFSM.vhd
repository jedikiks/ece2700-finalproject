library ieee;
use ieee.std_logic_1164.all;

entity mainFSM is
	port ( clock, resetn: in std_logic;
	       RAM_DO, ps2_done, fall_done: in std_logic;
	       din: in std_logic_vector( 8 downto 0 );	-- change this if you have bigger scan codes
	       addr_sel: out std_logic_vector( 2 downto 0 );
	       E_jumpCt, posY_E, posX_E, E_addr: out std_logic;
	       check_fall, l_r, sub_sel: out std_logic
      	     );
end mainFSM;

architecture Behavioral of fallFSM is
	type state is ( S0, S1, S2 );
	signal y: state;
begin
	Transitions: process ( resetn, clock, RAM_DO, ps2_done, fall_done, din )
	begin
		if resetn = '0' then
			y <= S0;
		elsif (clock'event and clock = '1') then
			case y is
				when S0 =>
				    if ps2_done = '1' then
				        y <= S1;
				    end if;

				when S1 =>
					if fall_done='1' then y <= S2; else y <= S1; end if;
					
				when S2 =>
					if din = x"29" then y <= S0; 
					elsif din = x"23" then y <= S0;
				        elsif din = x"1C" then y <= S0;
					else y <= S2; end if;
                                    
                end case;
		end if;
		
	end process;
	
	Outputs: process ( y, RAM_DO, ps2_done, fall_done, din )
	begin		
	    E_addr <= 0; posY_E <= 0; falling <= 0; posX_E <= 0; check_fall <= 0;
	    addr_sel <= "00"; sub_sel <= 0; l_r <= 0; 	-- Default values
		case y is			
			when S0 => if ps2_done <= '1' then check_fall <= '1'; end if;
			when S1 => 
			when S2 => if din <= x"29" then addr_sel <= "10"; E_addr <= '1'; 
				   	if RAM_DO <= '0' then posY_E <= '1'; E_jumpCt <= '1';
					end if;
				   end if;
				   if din <= x"23" then E_addr <= '1';
				   	if RAM_DO <= '0' then posY_E <= '1';
					end if;
				   end if;
				   if din <= x"1C" then
					E_addr <= '1'; l_r <= '1'; addr_sel <= "01";
				   	if RAM_DO <= '0' then posY_E <= '1'; l_r <= '1';
					end if;
				   end if;
		end case;
	end process;
end;
