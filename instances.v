// Instances


reg [11:0]AR_Datain;
wire AR_CLK, AR_LD, AR_INR, AR_CLR;
wire [11:0]AR_Dataout;

reg [11:0]PC_Datain;
wire PC_CLK, PC_LD, PC_INR, PC_CLR;
wire [11:0]PC_Dataout;

reg [15:0]DR_Datain;
wire DR_CLK, DR_LD, DR_INR, DR_CLR;
wire [15:0]DR_Dataout;

reg [15:0]IR_Datain;
wire IR_CLK, IR_LD, IR_INR, IR_CLR;
wire [15:0]IR_Dataout;

reg [15:0]AC_Datain;
wire AC_CLK, AC_LD, AC_INR, AC_CLR;
wire [15:0]AC_Dataout;

wire [15:0]ALU_A;
wire [15:0]ALU_B;
wire [15:0]ALU_Result;
wire ALU_E;
wire ALU_Select;

wire COUN_CLR, COUN_CLK;
wire [3:0]COUN_coun_out;

wire [3:0]DEC_indata;
wire [15:0]DEC_outdata;

wire [11:0]MEM_add_line;
wire [15:0]MEM_data_line;
wire MEM_r_line, MEM_w_line, MEME_clk;

// 12-Bit Address Register
register12 AR (
    .Datain(AR_Datain),			// 12 bit data inputs
    .CLK(AR_CLK),			// 1 clock input
    .LD(AR_LD),				// 1 load input
    .INR(AR_INR),			// 1 increment input
    .CLR(AR_CLR),			// 1 clear input
    .Dataout(AR_Dataout)			// 12 bit outpu
);


// 12-Bit Program Counter
register12 PC (
  .Datain(PC_Datain),			// 12 bit data inputs
  .CLK(PC_CLK),			// 1 clock input
  .LD(PC_LD),				// 1 load input
  .INR(PC_INR),			// 1 increment input
  .CLR(PC_CLR),			// 1 clear input
  .Dataout(PC_Dataout)			// 12 bit outpu
);


// 16-Bit Data Register
register16 DR(
  .Datain(DR_Datain),			// 12 bit data inputs
  .CLK(DR_CLK),			// 1 clock input
  .LD(DR_LD),				// 1 load input
  .INR(DR_INR),			// 1 increment input
  .CLR(DR_CLR),			// 1 clear input
  .Dataout(DR_Dataout)			// 16 bit outputs
);


// 16-Bit Instruction Register
register16 IR(
  .Datain(IR_Datain),			// 12 bit data inputs
  .CLK(IR_CLK),			// 1 clock input
  .LD(IR_LD),				// 1 load input
  .INR(IR_INR),			// 1 increment input
  .CLR(IR_CLR),			// 1 clear input
  .Dataout(IR_Dataout)			// 16 bit outputs
);


// 16-Bit Accumlator
register16 Accumlator(
  .Datain(AC_Datain),			// 12 bit data inputs
  .CLK(AC_CLK),			// 1 clock input
  .LD(AC_LD),				// 1 load input
  .INR(AC_INR),			// 1 increment input
  .CLR(AC_CLR),			// 1 clear input
  .Dataout(AC_Dataout)			// 16 bit outputs
);


// ALU
alu ALU(
    .A(ALU_A),			// 16 bit data inputs
    .B(ALU_B),			// 16 bit data inputs
    .Result(ALU_Result),		// 16 bit data outputs
    .E(ALU_E),			// 1 extension bit
    .Select(ALU_Select)		// 1 selector
);


// Sequencer
counter Counter(
    .CLR(COUN_CLR),
    .CLK(COUN_CLK),
    .coun_out(COUN_coun_out)
);

decoder Decoder(
    .indata(DEC_indata),
    .outdata(DEC_outdata)
);
// Connection with counter
assign DEC_indata = COUN_coun_out;


// Memory
memory memory(
    .add_line(MEM_add_line),
    .data_line(MEM_data_line),
    .r_line(MEM_r_line),
    .w_line(MEM_w_line),
    .clk(MEME_clk)
);
