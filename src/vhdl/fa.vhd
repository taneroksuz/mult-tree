library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity fa is
	port(
		a   : in  std_logic;
		b   : in  std_logic;
		c_i : in  std_logic;
		s   : out std_logic;
		c_o : out std_logic;
		p   : out std_logic;
		g   : out std_logic
	);
end fa;

architecture behavior of fa is

	signal s_1 : std_logic;
	signal c_1 : std_logic;
	signal c_2 : std_logic;

	component ha
		port(
			a : in  std_logic;
			b : in  std_logic;
			s : out std_logic;
			c : out std_logic
		);
	end component;

begin

	HA1 : ha port map(a => a, b => b, s => s_1, c => c_1);
	HA2 : ha port map(a => s_1, b => c_i, s => s, c => c_2);

	p   <= s_1;
	g   <= c_1;
	c_o <= c_1 or c_2;

end architecture;
