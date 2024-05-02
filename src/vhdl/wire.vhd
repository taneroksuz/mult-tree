library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;

package wire is

	type add_in_type is record
		data0 : std_logic_vector(XLEN-1 downto 0);
		data1 : std_logic_vector(XLEN-1 downto 0);
		op    : std_logic;
	end record;

	type add_out_type is record
		result : std_logic_vector(XLEN-1 downto 0);
	end record;

	type mul_in_type is record
		a : std_logic_vector(XLEN-1 downto 0);
		b : std_logic_vector(YLEN-1 downto 0);
	end record;

	type mul_out_type is record
		c : std_logic_vector(XLEN+YLEN-1 downto 0);
	end record;

end package;
