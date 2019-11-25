library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wire.all;

entity cla is
	generic(
		SIZE : natural := 4
	);
	port(
		a     : in  std_logic_vector(SIZE-1 downto 0);
		b     : in  std_logic_vector(SIZE-1 downto 0);
		c_in  : in  std_logic;
		s     : out std_logic_vector(SIZE-1 downto 0);
		c_out : out std_logic
	);
end cla;

architecture behavior of cla is

	signal sum : std_logic_vector(SIZE-1 downto 0);
	signal c_g : std_logic_vector(SIZE-1 downto 0);
	signal c_p : std_logic_vector(SIZE-1 downto 0);
	signal c_i : std_logic_vector(SIZE-1 downto 1);

begin

	sum <= a xor b;
	c_g <= a and b;
	c_p <= a or b;

	c_i(1) <= c_g(0) or (c_p(0) and c_in);

	for_generate : for i in 1 to SIZE-2 generate
		c_i(i+1) <= c_g(i) or (c_p(i) and c_i(i));
	end generate;

	c_out <= c_g(SIZE-1) or (c_p(SIZE-1) and c_i(SIZE-1));

	s(0) <= sum(0) xor c_in;
	s(SIZE-1 downto 1) <= sum(SIZE-1 downto 1) xor c_i(SIZE-1 downto 1);

end architecture;
