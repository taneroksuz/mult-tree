import configure::*;

module fa
(
	input  logic [0 : 0] a,
	input  logic [0 : 0] b,
	input  logic [0 : 0] c_i,
	output logic [0 : 0] s,
	output logic [0 : 0] c_o
);
	timeunit 1ps;
	timeprecision 1ps;

	logic s_1,c_1,c_2;

	ha ha_1_comp (.a (a), .b(b), .s(s_1), .c(c_1));
	ha ha_2_comp (.a (s_1), .b(c_i), .s(s), .c(c_2));

	assign c_o = c_1 | c_2;

endmodule