// 4-Bits counter
module counter(
CLR,
CLK,
coun_out
);

/*..........Input Ports.......*/
input CLR;
input CLK;
/*.........Output Ports.......*/
output [3:0]coun_out;
/*......types Decleration......*/
wire CLR;
wire CLK;

reg [3:0]coun_out;

/*........Functionality......*/
always @(posedge CLK)
begin
	if (CLR == 1'b1) begin
		coun_out <= 4'h0;
	end

	else begin
		#7 coun_out <= coun_out + 1;
	end
end
endmodule
// End of 4_bit counter Description

// 4-16 Decoder
module decoder(
indata,
outdata
);

/*..........Input Ports.......*/
input [3:0]indata;
/*.........Output Ports.......*/
output [15:0]outdata;
/*......types Decleration......*/
wire CLR;
wire CLK;
wire [3:0]coun_out;
wire [3:0]indata;

reg [15:0]outdata;

/*........Functionality......*/
always @(*)
begin
	outdata = 16'h0000;
	outdata[indata] = 1'b1;
end

/*...Connect decoder with counter...*/
counter C_D(
CLR,
CLK,
coun_out
);

endmodule
