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

entity test_adder is
	generic(
		XLEN : natural := XLEN;
		TYP  : std_logic := TYP
	);
end entity test_adder;

architecture behavior of test_adder is

	signal reset : std_logic := '0';
	signal clock : std_logic := '0';

	constant empty : std_logic_vector(XLEN-1 downto 0) := (others => '0');

	signal a : std_logic_vector(XLEN-1 downto 0) := (others => '0');
	signal b : std_logic_vector(XLEN-1 downto 0) := (others => '0');
	signal p : std_logic_vector(XLEN-1 downto 0) := (others => '0');
	signal q : std_logic_vector(XLEN-1 downto 0) := (others => '0');
	signal r : std_logic_vector(XLEN-1 downto 0) := (others => '0');
	signal s : std_logic := '0';

	component add
		generic(
			XLEN : natural := 32
		);
		port(
			add_i : in  add_in_type;
			add_o : out add_out_type
		);
	end component;

	procedure check(
		aa : in std_logic_vector(XLEN-1 downto 0);
		bb : in std_logic_vector(XLEN-1 downto 0);
		pp : in std_logic_vector(XLEN-1 downto 0);
		qq : in std_logic_vector(XLEN-1 downto 0);
		rr : in std_logic_vector(XLEN-1 downto 0);
		ss : in std_logic) is
		variable buf : line;
		constant succ : string := "TEST SUCCEEDED";
		constant fail : string := "TEST FAILED";
	begin
		if ss = '0' then
			report succ & " => " & to_hstring(aa) & " + " & to_hstring(bb) & " = " & to_hstring(pp) & " ^ " & to_hstring(qq) & " == " & to_hstring(rr);
		else
			report fail & " => " & to_hstring(aa) & " + " & to_hstring(bb) & " = " & to_hstring(pp) & " ^ " & to_hstring(qq) & " == " & to_hstring(rr) severity error;
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

	add_comp : add
	generic map(
		XLEN => XLEN
	)
	port map(
		add_i.data0  => a,
		add_i.data1  => b,
		add_i.op     => TYP,
		add_o.result => p
	);

	ADDITION : if TYP = '0' generate
		q <= std_logic_vector(unsigned(a)+unsigned(b));
	end generate ADDITION;
	SUBTRACTION : if TYP = '1' generate
		q <= std_logic_vector(unsigned(a)-unsigned(b));
	end generate SUBTRACTION;

	r <= p xor q;
	s <= or(r);

	process(clock)

	begin

		if rising_edge(clock) then

			check(a,b,p,q,r,s);

		end if;

	end process;

end architecture;
