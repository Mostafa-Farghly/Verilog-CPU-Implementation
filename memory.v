module memory(
add_line,
data_line,
r_line,
w_line,
clk
);

/*......Ports Direction.......*/
input [11:0]add_line;
input r_line, w_line;
input clk;

inout [15:0]data_line;
/*.....Types Decleration.....*/
wire [11:0]add_line;
wire r_line, w_line;
wire clk;
wire [15:0]data_line;
/*...Internal Registers...*/
reg [15:0]my_memory[0:4095];
reg [15:0]dataout;

/*........................*/
// Load memory
initial begin
	$readmemh("memory.mem", my_memory);
end

assign data_line = (r_line && !w_line) ? dataout : 16'bz;

always @(posedge clk)
begin
	if (r_line && !w_line) begin
		dataout <= my_memory[add_line];
	end
	else if (w_line && !r_line) begin
		my_memory[add_line] <= data_line;
	end
	else begin
	dataout <= 16'bz;
	end
end
endmodule
