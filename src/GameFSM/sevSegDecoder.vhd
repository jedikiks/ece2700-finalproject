---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2013).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sevSegDecoder is
	port (input : in std_logic;
		  sevseg: out std_logic_vector (6 downto 0);
		  AN: out std_logic_vector(7 downto 0));
end sevSegDecoder;

architecture structure of sevSegDecoder is

	signal leds: std_logic_vector (6 downto 0);
	--signal enable : std_logic_vector(4 downto 0);
	
begin
-- |  a  |  b  |  c  |  d  |  e  |  f  | g  |
-- |leds6|leds5|leds4|leds3|leds2|leds1|leds0|
    --enable <= bcd;
	with input select
		leds <=   "1100111" when '0',
				  "0111011" when others;

   -- There are 4 7-seg displays that can be used. We will use only the first (from left to right):				  
	AN <= "11110000"; -- only the first 7-seg display is activated.
	              -- EN(0) goes to one 7-seg display. It goes to every LED anode.
					  -- To activate the anode, we need EN(0) to be zero (see circuit)
	sevseg <= not(leds);
end structure;

