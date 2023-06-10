import configure::*;

module mutex
#(
	parameter SIZE = 4
)
(
	input  logic [SIZE-1 : 0] data0,
	input  logic [SIZE-1 : 0] data1,
	input  logic [0      : 0] sel,
	output logic [SIZE-1 : 0] result
);
	timeunit 1ps;
	timeprecision 1ps;

	assign result = sel == 0 ? data0 : data1;

endmodule