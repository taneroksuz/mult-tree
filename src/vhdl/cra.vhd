library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.wire.all;

entity cra is
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
end cra;

architecture behavior of cra is

	component fa is
		port(
			a   : in  std_logic;
			b   : in  std_logic;
			c_i : in  std_logic;
			s   : out std_logic;
			c_o : out std_logic;
			p   : out std_logic;
			g   : out std_logic
		);
	end component;

	component multiplexer is
		generic(
			SIZE : natural := 1
		);
		port(
			data0  : in  std_logic_vector(SIZE-1 downto 0);
			data1  : in  std_logic_vector(SIZE-1 downto 0);
			sel    : in  std_logic;
			result : out std_logic_vector(SIZE-1 downto 0)
		);
	end component;

	signal cc  : std_logic_vector(SIZE downto 0);
	signal p   : std_logic_vector(SIZE-1 downto 0);
	signal sel : std_logic;

begin

	cc(0) <= c_in;

	fa_for : for i in 0 to SIZE-1 generate
		fa_comp : fa
			port map(
				a   => a(i),
				b   => b(i),
				c_i => cc(i),
				s   => s(i),
				c_o => cc(i+1),
				p   => p(i)
			);
	end generate fa_for;

	sel <= and(p);

	multiplexer_comp : multiplexer
		generic map(
			SIZE => 1
		)
		port map(
			data0(0)  => cc(SIZE),
			data1(0)  => c_in,
			sel 			=> sel,
			result(0) => c_out
		);

end architecture;
