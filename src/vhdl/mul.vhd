library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wire.all;

entity mul is
	generic(
		XLEN : natural := 32;
		TYP  : std_logic := '0'
	);
	port(
		mul_i : in  mul_in_type;
		mul_o : out mul_out_type
	);
end mul;

architecture behavior of mul is

	component dadda
		port(
			x  : in  std_logic_vector(XLEN-1 downto 0);
			y  : in  std_logic_vector(XLEN-1 downto 0);
			z0 : out std_logic_vector(2*XLEN-1 downto 0);
			z1 : out std_logic_vector(2*XLEN-1 downto 0)
		);
	end component;

	component wallace
		port(
			x  : in  std_logic_vector(XLEN-1 downto 0);
			y  : in  std_logic_vector(XLEN-1 downto 0);
			z0 : out std_logic_vector(2*XLEN-1 downto 0);
			z1 : out std_logic_vector(2*XLEN-1 downto 0)
		);
	end component;

	signal a  : std_logic_vector(XLEN-1 downto 0);
	signal b  : std_logic_vector(XLEN-1 downto 0);

	signal z0 : std_logic_vector(2*XLEN-1 downto 0);
	signal z1 : std_logic_vector(2*XLEN-1 downto 0);

begin

	a <= mul_i.a;
	b <= mul_i.b;

	DADDA_TREE : if TYP = '0' generate
		dadda_comp   : dadda   port map(a,b,z0,z1);
	end generate DADDA_TREE;
	WALLACE_TREE : if TYP = '1' generate
		wallace_comp : wallace port map(a,b,z0,z1);
	end generate WALLACE_TREE;

	mul_o.c <= std_logic_vector(unsigned(z0)+unsigned(z1));


end architecture;
