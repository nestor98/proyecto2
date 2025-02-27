----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:02:29 04/04/2014 
-- Design Name: 
-- Module Name:    reg32 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:  Registro de 2 bits (basado en el de 4b proporcionado)
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity reg2 is
    Port ( Din : in  STD_LOGIC_VECTOR (1 downto 0);
           clk : in  STD_LOGIC;
			  reset : in  STD_LOGIC;
           load : in  STD_LOGIC;
           Dout : out  STD_LOGIC_VECTOR (1 downto 0));
end reg2;

architecture Behavioral of reg2 is

begin
SYNC_PROC: process (clk)
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then
            Dout <= "00";
         else
            if (load='1') then 
					Dout <= Din;
				end if;	
         end if;
      end if;
   end process;

end Behavioral;

