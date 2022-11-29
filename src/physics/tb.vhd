library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture Behavioral of tb is
component physics
	port ( clock, resetn: in std_logic;
	       RAM_DO, ps2_done, E_phy: in std_logic;
	       din: in std_logic_vector( 7 downto 0 );	-- change this if you have bigger scan codes
	       E_fallCt: out std_logic;
		   posX, posY: out std_logic_vector( 9 downto 0 );
	       addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
      	     );
end component;

   --Inputs
   signal resetn, clock, RAM_DO, ps2_done, E_phy : std_logic := '0';
   signal din : std_logic_vector ( 7 downto 0 ) := (others => '0');
   
   --Outputs
   signal E_fallCt : std_logic;
   signal addr : std_logic_vector( 19 downto 0 );
   signal posX, posY: std_logic_vector( 9 downto 0 );

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: physics PORT MAP (resetn, clock, RAM_DO, ps2_done, E_phy, din, E_fallCt, posX, posY, addr);

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clock_period*2; resetn <= '1';

      -- insert stimulus here 
      din <= x"11"; wait for clock_period;
      E_phy <= '1'; wait for clock_period;
      E_phy <= '0'; din <= x"29"; wait for clock_period;
      E_phy <= '1'; wait for clock_period;
      E_phy <= '0'; wait for clock_period;
	
      wait;
   end process;

END;