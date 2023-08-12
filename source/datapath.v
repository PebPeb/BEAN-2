
//
//	datapath.v
//		RV32I datapath
//

// -------------------------------- //
//	By: Bryce Keen	
//	Created: 08/11/2023
// -------------------------------- //
//	Last Modified: 08/12/2023

// Change Log:	NA

module datapath(
  clk, reset,
  reg_WE,
  rs1_SEL, rs2_SEL,
  pc_SEL, reg_SEL,
  imm_SEL,
  ALU_SEL,
  Instr,
  memDataRD,
  pc,
  memDataWD, memAdrs);

  input             clk, reset;
  input             reg_WE;
  input             rs1_SEL, rs2_SEL;
  input [1:0]       pc_SEL, reg_SEL;
  input [2:0]       imm_SEL;
  input [3:0]       ALU_SEL;
  input [31:0]      Instr;
  input [31:0]      memDataRD;

  output [31:0]     pc;
  output [31:0]     memDataWD, memAdrs;





  // ----------------------------- //
  // Fetch
  // ----------------------------- //
  
  wire [31:0]     pc_plus4_F, pc_F, instr_F;
  wire [31:0]     pc_now, pc_next;

  mux2 #(.WIDTH(32)) MUX_pc_0 (
    .a(pc_plus4_F), 
    .b(pc_jump), 
    .sel(pc_SEL[0]), 
    .y(pc_now));

  flopr #(.WIDTH(32)) REG_pc (
      .d(pc_now), 
      .q(pc_next), 
      .clk(clk), 
      .reset(reset));

  adder #(.WIDTH(32)) plus4 (
    .a(4), 
    .b(pc_next), 
    .y(pc_plus4_F));

  assign instr_F = Instr;                   // Instruction input from memory
  assign pc_F = pc_next;
  assign pc = pc_next;                      // PC for Instruction memory







  // ----------------------------- //
  // Decode
  // ----------------------------- //

  reg [31:0]      pc_plus4_D = 0, pc_D = 0, instr_D = 0;
  
  wire            invrt_clk;
  wire [31:0]     rdout1_D, rdout2_D, wrs3;
  wire [31:0]     ExtImm_D


  // REG_decode
  always @(posedge clk, posedge reset) begin
      if (reset) begin
        pc_plus4_D = 0;
        pc_D = 0;
        instr_D = 0;
      end
      else begin
        pc_plus4_D = pc_plus4_F;
        pc_D = pc_F;
        instr_D = instr_F;
      end
  end

  assign invrt_clk = ~clk;

  regfile regFILE (
      .rs1(instr_D[19:15]),
      .rs2(instr_D[24:20]),
      .wrs3(wrs3),
      .rd(instr_D[11:7]),
      .we(reg_WE),
      .clk(invrt_clk),
      .reset(reset),
      .rdout1(rdout1_D),
      .rdout2(rdout2_D));

  extend extendImm(
      .Instr(instr_D[31:7]), 
      .ImmSrc(imm_SEL), 
      .ExtImm(ExtImm_D));
  





  // ----------------------------- //
  // Execute
  // ----------------------------- //
  
  reg [31:0]      pc_plus4_E = 0, pc_E = 0, ExtImm_E = 0;
  reg [31:0]      rdout1_E = 0, rdout2_E = 0;

  wire [31:0]     muxrs1, muxrs2;
  wire [31:0]     ALUResults_E;
  wire [31:0]     pcPlusImm_E;

  // REG_execute
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      pc_E = 0;
      pc_plus4_E = 0;
      ExtImm_E = 0;
      rdout1_E = 0;
      rdout2_E = 0;
    end
    else begin
      pc_E = pc_D;
      pc_plus4_E = pc_plus4_D;
      ExtImm_E = ExtImm_D;
      rdout1_E = rdout1_D;
      rdout2_E = rdout2_D;
    end
  end

  mux2 #(.WIDTH(32)) MUX_rs1 (
      .a(rdout1_E), 
      .b(pc_E), 
      .sel(rs1_SEL), 
      .y(muxrs1));

  mux2 #(.WIDTH(32)) MUX_rs2 (
      .a(rdout2_E), 
      .b(ExtImm_E), 
      .sel(rs2_SEL), 
      .y(muxrs2));

  alu32 ALU (
      .a(muxrs1), 
      .b(muxrs2), 
      .ALUControl(ALU_SEL), 
      .result(ALUResults_E));

  adder #(.WIDTH(32)) ADDER_Imm (
      .a(pc_E), 
      .b(ExtImm_E), 
      .y(pcPlusImm_E));






  // ----------------------------- //
  // Memory
  // ----------------------------- //

  reg [31:0]      pc_plus4_M = 0, pcPlusImm_M = 0, ExtImm_M = 0;
  reg [31:0]      rdout2_M = 0, ALUResults_M = 0;

  wire [31:0]     pc_jump;
  wire [31:0]     memData_M;


  // REG_memory
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      pc_plus4_M = 0;
      pcPlusImm_M = 0;
      rdout2_M = 0;
      ExtImm_M = 0;
      ALUResults_M = 0;
    end
    else begin
      ExtImm_M = ExtImm_E;
      pc_plus4_M = pc_plus4_E;
      pcPlusImm_M = pcPlusImm_E;
      rdout2_M = rdout2_E;
      ALUResults_M = ALUResults_E;
    end
  end

  assign memAdrs = ALUResults_M;

  mux2 #(.WIDTH(32)) MUX_pc_1 (
      .a(ALUResults_M),
      .b(pcPlusImm_M),
      .sel(pc_SEL[1]), 
      .y(pc_jump));

  assign memData_M = memDataRD;






  // ----------------------------- //
  // Write Back
  // ----------------------------- //

  reg [31:0]      pc_plus4_WB = 0, memData_WB = 0, ALUResults_WB = 0;
  reg [31:0]      ExtImm_WB = 0;

  // REG_writeback
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      pc_plus4_WB = 0;
      memData_WB = 0;
      ALUResults_WB = 0;
      ExtImm_WB = 0;
    end
    else begin
      pc_plus4_WB = pc_plus4_M;
      memData_WB = memData_M;
      ALUResults_WB = ALUResults_M;
      ExtImm_WB = ExtImm_M;
    end
  end


  mux4 #(.WIDTH(32)) MUX_regfile (
      .a(memData_WB),
      .b(ALUResults_WB),
      .c(ExtImm_WB),
      .d(pc_plus4_WB),
      .sel(reg_SEL), 
      .y(wrs3));


endmodule





