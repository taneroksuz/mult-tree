-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;

use work.configure.all;
use work.wire.all;

library std;
use std.textio.all;
use std.env.all;

entity test_multiply is
	generic(
		XLEN : natural := XLEN;
		YLEN : natural := YLEN;
		TYP  : std_logic := TYP
	);
end entity test_multiply;

architecture behavior of test_multiply is

	impure function rand_slv(len : integer; seed : integer) return std_logic_vector is
		variable r : real;
		variable s : integer;
		variable slv : std_logic_vector(len - 1 downto 0);
	begin
		s := seed;
		for i in slv'range loop
			uniform(s, s, r);
			slv(i) := '1' when r > 0.5 else '0';
		end loop;
		return slv;
	end function;

	procedure print(
		msg : in string) is
		variable buf : line;
	begin
		write(buf, msg);
		writeline(output, buf);
	end procedure print;

	signal seed0 : integer := SEED;
	signal seed1 : integer := SEED;

	signal reset : std_logic := '0';
	signal clock : std_logic := '0';

	constant empty_a : std_logic_vector(XLEN-1 downto 0) := (others => '0');
	constant empty_b : std_logic_vector(YLEN-1 downto 0) := (others => '0');

	signal a : std_logic_vector(XLEN-1 downto 0) := (others => '0');
	signal b : std_logic_vector(YLEN-1 downto 0) := (others => '0');
	signal p : std_logic_vector(XLEN+YLEN-1 downto 0) := (others => '0');
	signal q : std_logic_vector(XLEN+YLEN-1 downto 0) := (others => '0');
	signal r : std_logic_vector(XLEN+YLEN-1 downto 0) := (others => '0');
	signal s : std_logic := '0';

	component mul
		generic(
			XLEN : natural := 32;
			YLEN : natural := 32;
			TYP  : std_logic := '0'
		);
		port(
			mul_i : in  mul_in_type;
			mul_o : out mul_out_type
		);
	end component;

	procedure check(
		aa : in std_logic_vector(XLEN-1 downto 0);
		bb : in std_logic_vector(YLEN-1 downto 0);
		pp : in std_logic_vector(XLEN+YLEN-1 downto 0);
		qq : in std_logic_vector(XLEN+YLEN-1 downto 0);
		rr : in std_logic_vector(XLEN+YLEN-1 downto 0);
		ss : in std_logic) is
		variable buf : line;
	begin
		if ss = '0' then
			print(character'val(27) & "[1;32m" & "TEST SUCCEEDED" & character'val(27) & "[0m");
		else
			print(character'val(27) & "[1;31m" & "TEST FAILED" & character'val(27) & "[0m");
		end if;
		print(to_hstring(aa) & " * " & to_hstring(bb) & " = " & to_hstring(pp) & " ^ " & to_hstring(qq) & " == " & to_hstring(rr));
	end procedure check;

begin

	reset <= '1' after 10 ps;
	clock <= not clock after 1 ps;

	process(reset, clock)

	begin

		if rising_edge(clock) then

			if reset = '0' then

				a <= empty_a;
				b <= empty_b;

			else

				a <= rand_slv(XLEN,seed0);
				b <= rand_slv(YLEN,seed1);

				seed0 <= seed0-1;
				seed1 <= seed1+1;

			end if;

		end if;

	end process;

	mul_comp : mul
	generic map(
		XLEN => XLEN,
		YLEN => YLEN,
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
