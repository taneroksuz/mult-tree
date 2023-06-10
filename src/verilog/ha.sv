import configure::*;

module ha
(
	input  logic [0 : 0] a,
	input  logic [0 : 0] b,
	output logic [0 : 0] s,
	output logic [0 : 0] c
);
	timeunit 1ps;
	timeprecision 1ps;

	assign s = a ^ b;
	assign c = a & b;

endmodule