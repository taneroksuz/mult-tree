-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use work.randombasepkg.all;
use work.randompkg.all;

use work.configure.all;
use work.wire.all;

library std;
use std.textio.all;
use std.env.all;

entity test_multiply is
	generic(
		XLEN : natural := XLEN;
		TYP  : std_logic := TYP
	);
end entity test_multiply;

architecture behavior of test_multiply is

	signal reset : std_logic := '0';
	signal clock : std_logic := '0';

	constant empty : std_logic_vector(XLEN-1 downto 0) := (others => '0');

	signal a : std_logic_vector(XLEN-1 downto 0) := (others => '0');
	signal b : std_logic_vector(XLEN-1 downto 0) := (others => '0');
	signal p : std_logic_vector(2*XLEN-1 downto 0) := (others => '0');
	signal q : std_logic_vector(2*XLEN-1 downto 0) := (others => '0');
	signal r : std_logic_vector(2*XLEN-1 downto 0) := (others => '0');
	signal s : std_logic := '0';

	component mul
		generic(
			XLEN : natural := 32;
			TYP  : std_logic := '0'
		);
		port(
			mul_i : in  mul_in_type;
			mul_o : out mul_out_type
		);
	end component;

	procedure check(
		aa : in std_logic_vector(XLEN-1 downto 0);
		bb : in std_logic_vector(XLEN-1 downto 0);
		pp : in std_logic_vector(2*XLEN-1 downto 0);
		qq : in std_logic_vector(2*XLEN-1 downto 0);
		rr : in std_logic_vector(2*XLEN-1 downto 0);
		ss : in std_logic) is
		variable buf : line;
		constant succ : string := "TEST SUCCEEDED";
		constant fail : string := "TEST FAILED";
	begin
		if ss = '0' then
			report succ & " => " & to_hstring(aa) & " * " & to_hstring(bb) & " = " & to_hstring(pp) & " ^ " & to_hstring(qq) & " == " & to_hstring(rr);
		else
			report fail & " => " & to_hstring(aa) & " * " & to_hstring(bb) & " = " & to_hstring(pp) & " ^ " & to_hstring(qq) & " == " & to_hstring(rr) severity error;
		end if;
	end procedure check;

begin

	reset <= '1' after 10 ps;
	clock <= not clock after 1 ps;

	process(reset, clock)

		variable rv : randomptype;

	begin

		if rising_edge(clock) then

			if reset = '0' then

				a <= empty;
				b <= empty;

				rv.initseed(rv'instance_name);

			else

				a <= rv.randslv(XLEN);
				b <= rv.randslv(XLEN);

			end if;

		end if;

	end process;

	mul_comp : mul
	generic map(
		XLEN => XLEN,
		TYP  => TYP
	)
	port map(
		mul_i.a => a,
		mul_i.b => b,
		mul_o.c => p
	);

	q <= std_logic_vector(unsigned(a)*unsigned(b));
	r <= p xor q;
	s <= or(r);

	process(clock)

	begin

		if rising_edge(clock) then

			check(a,b,p,q,r,s);

		end if;

	end process;

end architecture;
