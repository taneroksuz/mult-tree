library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wire.all;

package libs is

	component ha is
		port(
			a : in  std_logic;
			b : in  std_logic;
			s : out std_logic;
			c : out std_logic
		);
	end component;

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

	component mutex is
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

end package;
