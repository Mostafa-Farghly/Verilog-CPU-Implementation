// TestBench for CPU
`include "cpu.v"

module cpu_tb();

// Instantination
reg CLK;
reg RESET;
wire [15:0]AC;

cpu cpu_UT(
  CLK,
  RESET,
  AC
);

// Clock Generation
always begin
    #5 CLK = ~CLK;
end

// Initialization
initial begin
  $dumpfile("cpu.vcd");
  $dumpvars;

  CLK = 1'b0;
  RESET = 1'b1;
  #22 RESET = 1'b0;

  #130 $finish;
end

endmodule
