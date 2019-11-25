library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wire.all;

entity csa is
	generic(
		XLEN : natural := 32;
		STEP : natural := XLEN/4;
		SIZE : natural := 4
	);
	port(
		a     : in  std_logic_vector(XLEN-1 downto 0);
		b     : in  std_logic_vector(XLEN-1 downto 0);
		c_in  : in  std_logic;
		s     : out std_logic_vector(XLEN-1 downto 0);
		c_out : out std_logic
	);
end csa;

architecture behavior of csa is

	component cra is
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
	end component;

	signal cc : std_logic_vector(STEP downto 0);

begin

	cc(0) <= c_in;

	cra_for : for i in 0 to STEP-1 generate
		cra_comp : cra
			generic map(
				SIZE => 4
			)
			port map(
				a     => a(((i+1)*SIZE-1) downto (i*4)),
				b     => b(((i+1)*SIZE-1) downto (i*4)),
				c_in  => cc(i),
				s     => s(((i+1)*SIZE-1) downto (i*4)),
				c_out => cc(i+1)
			);
	end generate cra_for;

	c_out <= cc(STEP);

end architecture;
