import configure::*;

class rng;
	rand bit [XLEN-1 : 0] a;
	rand bit [XLEN-1 : 0] b;
endclass

module test_adder();
	timeunit 1ps;
	timeprecision 1ps;

	task check(
		input logic [XLEN-1 : 0] aa,
		input logic [XLEN-1 : 0] bb,
		input logic [XLEN-1 : 0] pp,
		input logic [XLEN-1 : 0] qq,
		input logic [XLEN-1 : 0] rr,
		input logic [0      : 0] ss,
		input logic [0      : 0] tt
	);
		begin
			if (ss == 0) begin
				$write("%c[1;32m",8'h1B);
				$display("TEST SUCCEEDED");
				$write("%c[0m",8'h1B);
			end else begin
				$write("%c[1;31m",8'h1B);
				$display("TEST FAILED");
				$write("%c[0m",8'h1B);
			end
			if (tt == 0) begin
				$display("%h + %h = %h ^ %h == %h",aa,bb,pp,qq,rr);
			end else begin
				$display("%h - %h = %h ^ %h == %h",aa,bb,pp,qq,rr);
			end
		end
	endtask

	logic clock = 0;

	logic op;

	logic [XLEN-1 : 0] a; 
	logic [XLEN-1 : 0] b;
	logic [XLEN-1 : 0] p;
	logic [XLEN-1 : 0] q;
	logic [XLEN-1 : 0] r;
	logic [0      : 0] s;

	rng gen;

	initial begin
		gen = new();
		gen.srandom(SEED);
	end

	initial begin
		if (TYP == 0) begin
			$dumpfile("add.vcd");
		end else begin
			$dumpfile("sub.vcd");
		end
		$dumpvars(0,test_adder);
	end

	initial begin
		#(MAXTIME) $finish;
	end

	always begin
		#1 clock = ~clock;
	end

	add #(
		.XLEN (XLEN)
	) add_comp
	(
		.data0 (a),
		.data1 (b),
		.op (op),
		.result (p)
	);

	assign op = TYP == 0 ? 0 : 1;
	assign q = TYP == 0 ? a + b : a - b;
	assign r = p ^ q;
	assign s = |(r);

	always begin
		/* verilator lint_off IGNOREDRETURN */
		gen.randomize();
		a = gen.a;
		b = gen.b;
		@(posedge clock);
		check(a,b,p,q,r,s,op);
	end

endmodule