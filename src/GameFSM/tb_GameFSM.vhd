---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2017).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_GameFSM IS
END tb_GameFSM ;
 
ARCHITECTURE behavior OF tb_GameFSM  IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
component GameFSM is
    Port ( clock : in std_logic;
           resetn : in STD_LOGIC;
           pause : in STD_LOGIC;
           isPaused : out std_logic;
           segs : out std_logic_vector(6 downto 0);
           en : out std_logic_vector(7 downto 0));
end component; 

    
   --Inputs
    signal pause :std_logic;
    signal resetn, clock : std_logic;
 	--Outputs   
   constant T : time := 10 ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: GameFSM PORT MAP ( pause => pause, clock => clock, resetn => resetn);
   
   
   --clock
   clockProcess: process
   begin
        clock <= '0'; wait for T/2;
        clock <= '1'; wait for T/2;
   end process;
   
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
    
    pause <= '0'; resetn <= '0'; wait for 10ns;
    pause <= '0'; resetn <= '1'; wait for 10ns;
    pause <= '1';
    
    
    --DA <= "011011"; DB <= "1001"; s <= '1'; wait for 10 ns;
    --DA <= "010100"; DB <= "0111"; s <= '1'; wait for 10 ns;
    --DA <= "111110"; DB <= "1001"; s <= '1'; wait for 10 ns;
    --DA <= "111001"; DB <= "0110"; s <= '1'; wait for 10 ns;
    --DA <= "111011"; DB <= "1011"; s <= '1'; wait for 10 ns;
    --DA <= "111101"; DB <= "1101"; s <= '1'; wait for 10 ns;   
      
      -- insert stimulus here
      wait;
   end process;

END;
