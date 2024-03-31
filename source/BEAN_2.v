
// -------------------------------- //
//	By: Bryce Keen	
//	Created: 08/13/2023
// -------------------------------- //
//	Last Modified: 03/30/2024

//
//	BEAN_2.v
//		The BEAN-2 is a RV32I implementation 
//    microarchitecture of the BEAN-2 follows a 5 stage pipelined CPU
//    with flush and stall capabilities
//    

module BEAN_2 (clk, reset, Instr, memDataRD, dmem_WE, 
               dmem_SEL, pc, memAdrs, memDataWD);
               
  input wire            clk, reset;
  input wire [31:0]     Instr;
  input wire [31:0]     memDataRD;

  output wire           dmem_WE;
  output wire [2:0]     dmem_SEL;
  output wire [31:0]    pc;
  output wire [31:0]    memAdrs;
  output wire [31:0]    memDataWD;


  wire reg_WE;
  wire rs1_SEL;
  wire rs2_SEL;
  wire [1:0] pc_SEL;
  wire [1:0] reg_SEL;
  wire [1:0] reg_RD;
  wire [2:0] imm_SEL;
  wire [3:0] ALU_SEL;

  wire [6:0]  opcode, funct7;
  wire [2:0]  funct3;
  wire        jump;
  wire [4:0]  rs1, rs2, rs3;
  wire        stall_F, stall_D, stall_E, stall_M, stall_WB;
  wire        flush_F, flush_D, flush_E, flush_M, flush_WB;
  wire        reg_WE_D;    
  wire        jumping;

  datapath Datapath_Unit (
    .clk(clk), 
    .reset(reset),
    .reg_WE(reg_WE),
    .rs1_SEL(rs1_SEL), 
    .rs2_SEL(rs2_SEL),
    .pc_SEL(pc_SEL), 
    .reg_SEL(reg_SEL),
    .imm_SEL(imm_SEL),
    .ALU_SEL(ALU_SEL),
    .Instr(Instr),
    .memDataRD(memDataRD),
    .pc(pc),
    .memDataWD(memDataWD), 
    .memAdrs(memAdrs),
    .opcode(opcode), 
    .funct7(funct7),
    .funct3(funct3),
    .rs1(rs1), 
    .rs2(rs2), 
    .rs3(rs3), 
    .jump(jump),

    .stall_F(stall_F),
    .stall_D(stall_D),
    .stall_E(stall_E), 
    .stall_M(stall_M), 
    .stall_WB(stall_WB),
    .flush_F(flush_F), 
    .flush_D(flush_D), 
    .flush_E(flush_E), 
    .flush_M(flush_M), 
    .flush_WB(flush_WB)
  );


  control_logic Control_Unit(
    .clk(clk), 
    .reset(reset),
    .opcode(opcode),
    .funct7(funct7), 
    .funct3(funct3), 
    .jump(jump), 
    .jumping(jumping),
    .ALU_SEL(ALU_SEL), 
    .dmem_SEL(dmem_SEL), 
    .imm_SEL(imm_SEL), 
    .reg_SEL(reg_SEL), 
    .pc_SEL(pc_SEL), 
    .reg_RD(reg_RD),
    .dmem_WE(dmem_WE), 
    .reg_WE(reg_WE), 
    .rs1_SEL(rs1_SEL), 
    .rs2_SEL(rs2_SEL),
    .reg_WE_D_out(reg_WE_D),

    .stall_E(stall_E), 
    .stall_M(stall_M), 
    .stall_WB(stall_WB),
    .flush_E(flush_E), 
    .flush_M(flush_M), 
    .flush_WB(flush_WB));

  hazard_logic Hazard_Unit (
    .clk(clk), 
    .reset(reset), 
    .reg_WE(reg_WE_D), 
    .reg_RD(reg_RD), 
    .rs1(rs1), 
    .rs2(rs2), 
    .rs3(rs3),
    .jumping(pc_SEL[0]),
    .flush_F(flush_F), 
    .flush_D(flush_D), 
    .flush_E(flush_E), 
    .flush_M(flush_M), 
    .flush_WB(flush_WB),
    .stall_F(stall_F), 
    .stall_D(stall_D), 
    .stall_E(stall_E), 
    .stall_M(stall_M), 
    .stall_WB(stall_WB));

endmodule


