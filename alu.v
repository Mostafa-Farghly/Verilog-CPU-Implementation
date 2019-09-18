module alu(
A,			// 16 bit data inputs
B,			// 16 bit data inputs
Result,		// 16 bit data outputs
E,			// 1 extension bit
Select		// 1 selector
);

/* ............ Input ports ............ */
input [15:0] A;
input [15:0] B;
input Select;

/* ............ Output ports ............ */
output [15:0] Result;
output E;

/*.........Input Ports Data Type.........*/
wire [15:0] A;
wire [15:0] B;
wire Select;

/* ..........Output Ports Data Type ..........*/
reg [15:0] Result;
reg E;

/* ............ Code starts here ............ */
always @ (*)
begin
	if (Select == 1'b0) begin
	Result <= A & B;
	E = 1'b0;
	end
	else if (Select == 1'b1) begin
	{E, Result} <= {1'b0, A} + {1'b0, B};
	end
end
endmodule
