import configure::*;

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

	initial begin
		$dumpfile("output.vcd");
		$dumpvars(0,test_adder);
		$urandom(SEED);
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
		a = $urandom();
		b = $urandom();
		@(posedge clock);
		check(a,b,p,q,r,s,op);
	end

endmodule