

module top_tb();
  reg       clk = 0, reset = 1;

  always begin
      clk <= ~clk;
      #2;
  end

  wire reg_WE;
  wire rs1_SEL;
  wire rs2_SEL;
  wire dmem_WE;
  wire [1:0] pc_SEL;
  wire [1:0] reg_SEL;
  wire [1:0] reg_RD;
  wire [2:0] imm_SEL;
  wire [2:0] dmem_SEL;
  wire [3:0] ALU_SEL;

  wire [31:0] pc;
  wire [31:0] Instr;
  wire [31:0] memAdrs;
  wire [31:0] memDataRD;
  wire [31:0] memDataWD;
  wire [6:0]  opcode, funct7;
  wire [2:0]  funct3;
  wire        jump;
  wire [4:0]  rs1, rs2, rs3;
  wire        stall_F, stall_D, stall_E, stall_M, stall_WB;
  wire        flush_F, flush_D, flush_E, flush_M, flush_WB;
  wire        reg_WE_D;    

  datapath DUT (
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


  control_logic control_unit(
    .clk(clk), 
    .reset(reset),
    .opcode(opcode),
    .funct7(funct7), 
    .funct3(funct3), 
    .jump(jump), 
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

  hazard_logic hazard_unit (
    .clk(clk), 
    .reset(reset), 
    .reg_WE(reg_WE_D), 
    .reg_RD(reg_RD), 
    .rs1(rs1), 
    .rs2(rs2), 
    .rs3(rs3),
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



  imem instruction_mem (
    .a(pc),
    .rd(Instr)
  );

  dmem data_mem (
    .a(memAdrs), 
    .rd(memDataRD), 
    .wd(memDataWD), 
    .clk(clk), 
    .we(dmem_WE), 
    .mode(dmem_SEL), 
    .reset(reset)
  );

  initial begin
    #6
    reset <= 1'b0;

    #48

    $finish;
  end

  integer i;
	initial begin
		$dumpfile("top/top_tb.vcd");
		$dumpvars(0, top_tb);

    for (i = 0; i < 32; i = i + 1)
      $dumpvars(1, DUT.regFILE.x[i]);

	end
endmodule