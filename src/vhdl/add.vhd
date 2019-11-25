library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wire.all;

entity add is
	generic(
		XLEN : natural := 32
	);
	port(
		add_i : in  add_in_type;
		add_o : out add_out_type
	);
end add;

architecture behavior of add is

	component cla
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

	signal data1_xor : std_logic_vector(XLEN-1 downto 0);

begin

	for_generate : for i in 0 to XLEN-1 generate
		data1_xor(i) <= add_i.data1(i) xor add_i.op;
	end generate;

	cla_comp : cla
		generic map(
			SIZE => XLEN
		)
		port map(
			a    => add_i.data0,
			b    => data1_xor,
			c_in => add_i.op,
			s    => add_o.result
		);

end architecture;
