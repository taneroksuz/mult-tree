library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wire.all;

entity multiplexer is
	generic(
		SIZE : natural := 1
	);
	port(
		data0  : in  std_logic_vector(SIZE-1 downto 0);
		data1  : in  std_logic_vector(SIZE-1 downto 0);
		sel    : in  std_logic;
		result : out std_logic_vector(SIZE-1 downto 0)
	);
end multiplexer;

architecture behavior of multiplexer is

begin

	result <= data0 when sel = '0' else
						data1 when sel = '1';

end architecture;
