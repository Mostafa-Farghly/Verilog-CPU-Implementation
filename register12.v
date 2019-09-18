module register12(
Datain,			// 12 bit data inputs
CLK,			// 1 clock input
LD,				// 1 load input
INR,			// 1 increment input
CLR,			// 1 clear input
Dataout			// 12 bit outputs
);

/* ............ Input ports ............ */
input [11:0] Datain;
input CLK;
input LD;
input INR;
input CLR;

/* ............ Output ports ............ */
output [11:0] Dataout;

/* ............ Input Ports Data Type ............ */
wire [11:0] Datain;
wire CLK;
wire LD;
wire INR;
wire CLR;

/* ............ Output Ports Data Type ............ */
reg [11:0] Dataout;

/* ............ Code starts here ............ */
always @(posedge CLK)
begin
	if (CLR == 1'b1) begin
	Dataout <= 12'h000;
	end

	else if (LD == 1'b1) begin
	Dataout <= Datain;
	end

	else if (INR == 1'b1) begin
	Dataout <= Dataout+1;
	end

	else begin
	Dataout <= Dataout;
	end
	
end
endmodule
