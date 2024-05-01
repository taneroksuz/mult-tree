import configure::*;

module mul
#(
	parameter XLEN = 32,
	parameter YLEN = 32,
	parameter TYP = 0
)
(
	input  logic [XLEN-1   : 0] a,
	input  logic [YLEN-1   : 0] b,
	output logic [XLEN+YLEN-1 : 0] c
);
	timeunit 1ps;
	timeprecision 1ps;

	logic [XLEN+YLEN-1 : 0] z0;
	logic [XLEN+YLEN-1 : 0] z1;

	generate
		if (TYP == 0) begin
			dadda dadda_comp(a,b,z0,z1);
		end else begin
			wallace wallace_comp(a,b,z0,z1);
		end
	endgenerate

	assign c = z0 + z1;

endmodule