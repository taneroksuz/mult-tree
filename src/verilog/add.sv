import configure::*;

module add
#(
	parameter XLEN = 32
)
(
	input  logic [XLEN-1 : 0] data0,
	input  logic [XLEN-1 : 0] data1,
	input  logic [0      : 0] op,
	output logic [XLEN-1 : 0] result
);
	timeunit 1ps;
	timeprecision 1ps;

	logic [XLEN-1 : 0] data1_xor;
	logic [0 : 0] carry;

	assign data1_xor = data1 ^ {XLEN{op}};

	cla #(
		.SIZE (XLEN)
	) cla_comp
	(
		.a (data0),
		.b (data1_xor),
		.c_in (op),
		.s (result),
		.c_out (carry)
	);

endmodule