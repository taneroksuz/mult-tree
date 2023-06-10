import configure::*;

module cla
#(
	parameter SIZE = 4
)
(
	input  logic [SIZE-1 : 0] a,
	input  logic [SIZE-1 : 0] b,
	input  logic [0      : 0] c_in,
	output logic [SIZE-1 : 0] s,
	output logic [0      : 0] c_out
);
	timeunit 1ps;
	timeprecision 1ps;

	/* verilator lint_off UNOPTFLAT */

	genvar i;

	logic [SIZE-1 : 0] sum;
	logic [SIZE-1 : 0] c_g;
	logic [SIZE-1 : 0] c_p;
	logic [SIZE-1 : 0] c_i;

	assign sum = a ^ b;
	assign c_g = a & b;
	assign c_p = a | b;

	assign c_i[1] = c_g[0] | (c_p[0] & c_in);

	for (i = 1; i < SIZE-1; i++) begin
		assign c_i[i+1] = c_g[i] | (c_p[i] & c_i[i]);
	end

	assign c_out = c_g[SIZE-1] | (c_p[SIZE-1] & c_i[SIZE-1]);

	assign s[0] = sum[0] ^ c_in;
	assign s[SIZE-1:1] = sum[SIZE-1:1] ^ c_i[SIZE-1:1];

	/* verilator lint_on UNOPTFLAT */

endmodule