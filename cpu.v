// Top level module of CPU

`include "register12.v"
`include "register16.v"
`include "alu.v"
`include "sequencer.v"
`include "memory.v"


module  cpu(
    CLK,
    RESET,
    AC
    );

// ** Ports Direction
input CLK;
input RESET;
output [0:15] AC;

// ** Ports Types
wire CLK;
wire RESET;
wire [0:15] AC;

// ** Instances
`include "instances.v"

// ** Clock Connections
assign AR_CLK = CLK;
assign PC_CLK = CLK;
assign DR_CLK = CLK;
assign IR_CLK = CLK;
assign AC_CLK = CLK;
assign COUN_CLK = CLK;
assign MEME_clk = CLK;

// ** RESET Connections
assign PC_CLR = RESET;

// AC Connections
assign AC = AC_Dataout;

// Connections to Counter Clear Line
assign #2 COUN_CLR = (RESET || r
                  || (DEC_outdata[5] && !(IR_Dataout[14:12] == 3'b110))
                  || ((DEC_outdata[6] && (IR_Dataout[14:12] == 3'b110))))
                  ? 1'b1 : 1'b0;     // RESET | HLT | !D6&T5 | D6T6

// ** Internal Connections
wire r;
assign #7 r = (DEC_outdata[2] && !IR_Dataout[15] &&
            (IR_Dataout[14:12] == 3'b111)) ? 1'b1 : 1'b0;

reg EXT;            // Manipulates the Extension Bit of the ALU
assign ALU_E = EXT;

// Connections To Accumlator Load Line
wire RRI_AC_LD;     // Regiter Reference Intructions for Accumlator
assign RRI_AC_LD = r & (IR_Dataout[11] | IR_Dataout[9]
                    | IR_Dataout[7] | IR_Dataout[6] | IR_Dataout[5]);
                    // r & (CLA | CMA | CIR | CIL | INC)

wire MRI_AC_LD;     // Memory Reference Instructions that Use the Accumlator
assign #7 MRI_AC_LD = ((IR_Dataout[14:12] < 3) && DEC_outdata[4]) ?
                    1'b1 : 1'b0;        // T5 & (AND | ADD | LDA)

assign AC_LD = RRI_AC_LD | MRI_AC_LD;

// Connections To Program Counter Load Line
wire RRI_PC_LD;     // Register Reference Instructions for Program Counter
assign RRI_PC_LD = r & (IR_Dataout[4] | IR_Dataout[3]
                    | IR_Dataout[2] | IR_Dataout[1]);

wire MRI_PC_LD;
assign #7 MRI_PC_LD = ((DEC_outdata[3] && IR_Dataout[14:12] == 3'b100)
                    || (DEC_outdata[4] && IR_Dataout[14:12] == 3'b101)
                    || (DEC_outdata[5] && IR_Dataout[14:12] == 3'b110)) ?
                    1'b1 : 1'b0;

assign PC_LD = RRI_PC_LD | MRI_PC_LD;

// Connections To Data Register Load Line
assign #7 DR_LD = ((DEC_outdata[3] && IR_Dataout[14:12] == 3'b000)
                || (DEC_outdata[3] && IR_Dataout[14:12] == 3'b001)
                || (DEC_outdata[3] && IR_Dataout[14:12] == 3'b010)
                || (DEC_outdata[3] && IR_Dataout[14:12] == 3'b110)
                || (DEC_outdata[4] && IR_Dataout[14:12] == 3'b110)) ?
                1'b1 : 1'b0; // DoT4 | D1T4 | D2T4 | D6T4 | D6T5

// Connections To Memory Read Line
assign #7 MEM_r_line = (DEC_outdata[0] || (DEC_outdata[2]
                    && IR_Dataout[15] && (IR_Dataout[14:12] != 3'b111))
                    || (DEC_outdata[3] && IR_Dataout[14:12] == 3'b000)
                    || (DEC_outdata[3] && IR_Dataout[14:12] == 3'b001)
                    || (DEC_outdata[3] && IR_Dataout[14:12] == 3'b010)
                    || (DEC_outdata[3] && IR_Dataout[14:12] == 3'b110))
                    ? 1'b1 : 1'b0; // D0T4 | D1T4 | D2T4 | D6T4

// Connections To Memory Write Line
assign #7 MEM_w_line = ((DEC_outdata[3] && IR_Dataout[14:12] == 3'b011)
                    || (DEC_outdata[3] && IR_Dataout[14:12] == 3'b101)
                    || (DEC_outdata[5] && IR_Dataout[14:12] == 3'b110))
                    ? 1'b1 : 1'b0; // D3T4 | D5T4 | D6T6

// Write in Memory
reg Datain_MEM;
assign MEM_data_line = (MEM_w_line && !MEM_r_line) ? Datain_MEM : 16'bz;

// Connections To Address Load Line
assign #7 AR_LD = (!COUN_coun_out || DEC_outdata[1]
                || (DEC_outdata[2] &&  IR_Dataout[15]
                && (IR_Dataout[14:12] != 3'b111))
                || (DEC_outdata[3] && IR_Dataout[14:12] == 3'b101)) ?
                1'b1 : 1'b0;

// Connections To Instruction Register Load Line
assign #7 IR_LD = DEC_outdata[0];

// Connections To Program Counter Increment Line
assign #2 PC_INR = DEC_outdata[0];

// Connections To Memory Address Line
assign MEM_add_line = AR_Dataout;

// Connections To ALU
assign ALU_A = AC_Dataout;
assign ALU_B = DR_Dataout;
assign #7 ALU_Select = (DEC_outdata[4] && IR_Dataout[14:12] == 3'b001) ?
                    1'b1 : 1'b0;


reg Fetched;

initial
begin #7
  // Fetch @ T0
  AR_Datain <= PC_Dataout;
  Fetched <= 1'b0;
end


// Flow Control
always @(posedge CLK)
begin
    if (!RESET) begin
        // If Register Reference Instruction
      if (r) begin
        case (IR_Dataout[11:0])
            12'h800: AC_Datain <= 16'h0000;         // CLA
            12'h400: EXT <= 1'b0;                   // CLE
            12'h200: AC_Datain <= ~AC_Dataout;       // CMA
            12'h100: EXT <= ~EXT;                   // CME
            12'h080: begin                          // CIR
                        AC_Datain <= {ALU_E, AC_Dataout[15:1]};
                        EXT <= AC_Dataout[0];
                    end
            12'h040: begin                          // CIL
                        AC_Datain <= {AC_Dataout[14:0], ALU_E};
                        EXT <= AC_Dataout[15];
                    end
            12'h020: AC_Datain <= (AC_Dataout + 1);  // INC
            12'h010: begin                          // SPA
                        if (AC_Dataout[15]) begin
                            PC_Datain <= (PC_Dataout + 1);
                        end
                        else begin
                            PC_Datain <= PC_Dataout;
                        end
                     end
            12'h008: begin                          // SNA
                        if (!AC_Dataout[15]) begin
                            PC_Datain <= (PC_Dataout + 1);
                        end
                        else begin
                            PC_Datain <= PC_Dataout;
                        end
                     end
            12'h004: begin                          // SZA
                        if (!AC_Dataout) begin
                            PC_Datain <= (PC_Dataout + 1);
                        end
                        else begin
                            PC_Datain <= PC_Dataout;
                        end
                     end
            12'h002: begin                          // SZE
                        if (!ALU_E) begin
                            PC_Datain <= (PC_Dataout + 1);
                        end
                        else begin
                            PC_Datain <= PC_Dataout;
                        end
                     end
            12'h001: #1;                            // HLT
            default: $display("Error in RRI!");
        endcase
      end
        // Fetching, Decoding and Getting Effective Address
        // +
        // If Memory Reference Instruction
        else if (!COUN_coun_out && Fetched)
        begin
          // Fetch @ T0
          AR_Datain <= PC_Dataout;
          Fetched <= 1'b0;
        end

        else begin
            Fetched <= 1'b1;
            case (DEC_outdata)
                // Fetch @ T0
                //16'h0001: AR_Datain <= PC_Dataout; // TODO
                // Fetch @ T1
                16'h0001: #7 IR_Datain <= MEM_data_line;
                // Decode @ T2
                16'h0002: #7 AR_Datain <= IR_Dataout[11:0];
                // Indirect @ T3
                16'h0004: #7 AR_Datain <= MEM_data_line[11:0];

                //Memory Reference Instructions
                // @ T4
                16'h0008: begin #7
                  case (IR_Dataout[14:12])
                    // AND
                    3'b000: DR_Datain <= MEM_data_line;
                    // ADD
                    3'b001: DR_Datain <= MEM_data_line;
                    // LDA
                    3'b010: DR_Datain <= MEM_data_line;
                    // STA
                    3'b011: Datain_MEM <= AC_Dataout;
                    // BUN
                    3'b100: PC_Datain <= AR_Dataout;
                    // BSA
                    3'b101: begin
                      Datain_MEM <= PC_Dataout;
                      AR_Datain <= (AR_Dataout + 1);
                    end
                    // ISZ
                    3'b110: DR_Datain <= MEM_data_line;
                    // If Non (Error)
                    default: $display("Error in MRI T4!");
                  endcase
                end
                // @ T5
                16'h0010: begin #7
                  case (IR_Dataout[14:12])
                    // AND
                    3'b000: AC_Datain <= ALU_Result;
                    // ADD
                    3'b001: AC_Datain <= ALU_Result;
                    // LDA
                    3'b010: AC_Datain <= DR_Dataout;
                    // BSA
                    3'b101: PC_Datain <= AR_Dataout;
                    // ISZ
                    3'b110: DR_Datain <= (DR_Dataout + 1);
                    // IF Non (Error)
                    default:  $display("Error in MRI T5!");
                  endcase
                end
                // @ T6
                16'h0020: begin #7
                  case (IR_Dataout[14:12])
                    // ISZ
                    3'b110: begin
                      Datain_MEM <= DR_Dataout;
                      if (!DR_Dataout) begin
                        PC_Datain <= (PC_Dataout + 1);
                      end
                      else begin
                        PC_Datain <= PC_Dataout;
                      end
                    end
                    // Error
                    default: $display("Error in MRI T6!");
                  endcase
                  end
                default: $display("Error in MRI!");
            endcase
        end
    end
end


endmodule
