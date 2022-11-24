library ieee;
use ieee.std_logic_1164.all;

entity mainFSM is
	port ( clock, resetn: in std_logic;
	       RAM_DO, ps2_done, fall_done, E_phy: in std_logic;
	       din: in std_logic_vector( 8 downto 0 );	-- change this if you have bigger scan codes
	       addr_sel: out std_logic_vector( 2 downto 0 );
	       E_jumpCt, posY_E, posX_E, E_addr: out std_logic;
	       check_fall, l_r: out std_logic
      	     );
end mainFSM;

architecture Behavioral of mainFSM is
    signal falling, jwait_zQ, jwait_EQ, jwait_sclrQ, jumpPx_EQ,
           jumpPx_sclrQ, jumpPx_zQ, mwait_zQ, mwait_EQ, mwait_sclrQ : std_logic;

	type state is ( S0, S1, S2, S3a, S3b );
	signal y: state;
begin
	Transitions: process ( resetn, clock, RAM_DO, ps2_done, fall_done, din )
	begin
		if resetn = '0' then
			y <= S0;
		elsif (clock'event and clock = '1') then
			case y is
				when S0 =>
				    if ps2_done = '1' and E_phy = '1' then
				        y <= S1;
				    end if;

				when S1 =>
					if fall_done='1' and din = x"29" then y <= S2;
                    elsif fall_done = '1' and din = x"23" and RAM_DO <= '0' then y <= S3b;
                    elsif fall_done = '1' and din = x"1C" and RAM_DO <= '0' then y <= S3b;
                    else y <= S0;
                    end if;
					
				when S2 =>
                    if RAM_DO <= '0' then y <= S3a; else y <= S0; end if;

                when S3a =>
                    if jwait_zQ <= '1' then
                        if jumpPx_zQ <= '1' then y <= S0;
                            else y <= S2;
                        end if;
                    else y <= S3a; end if;

                when S3b =>
                    if mwait_zQ <= '1' then y <= S0; else y <= S3b; end if;
                                    
                end case;
		end if;
		
	end process;
	
	Outputs: process ( y, RAM_DO, ps2_done, fall_done, din, jwait_zQ, jumpPx_zQ, mwait_zQ )
	begin		
	    E_addr <= '0'; posY_E <= '0'; falling <= '0'; posX_E <= '0'; check_fall <= '0';
	    addr_sel <= "000"; l_r <= '0'; jwait_EQ <= '0'; jwait_sclrQ <= '0'; -- Default values
        jumpPx_EQ <= '0'; jumpPx_sclrQ <= '0'; mwait_EQ <= '0'; mwait_sclrQ <= '0';
		case y is			
			when S0 => if ps2_done <= '1' then check_fall <= '1'; end if;

            when S1 => if fall_done then 
		    		        if din <= x"23" then
                                E_addr <= '1'; addr_sel <= "000"; 
		    		            if RAM_DO <= '0' then posY_E <= '1';
		    		            end if;
		    		        end if;
		    		        if din <= x"1C" then
                                E_addr <= '1'; addr_sel <= "001"; l_r <= '1';
		    		            if RAM_DO <= '0' then posX_E <= '1';
		    		            end if;
		    		        end if;
		    		   end if;

            when S2 => addr_sel <= "010"; E_addr <= '1'; 
                       if RAM_DO <= '0' then posY_E <= '1'; end if;

            when S3a => if jwait_zQ <= '1' then jwait_EQ <= '1'; jwait_sclrQ <= '1';
                             if jumpPx_zQ <= '1' then E_jumpCt <= '1'; jumpPx_EQ <= '1';
                                                      jumpPX_sclrQ <= '1';
                             else E_jumpCt <= '1'; jumpPx_EQ <= '1';
                             end if;
                         else jwait_EQ <= '1';
                         end if;
            when S3b => if mwait_zQ <= '1' then mwait_EQ <= '1'; mwait_sclrQ <= '1';
                        else mwait_EQ <= '1';
                        end if;
		end case;
	end process;
end;
