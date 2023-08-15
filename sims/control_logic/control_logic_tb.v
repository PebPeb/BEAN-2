

module control_logic_tb();
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
    .jump(jump),

    .stall_F(1'b0),
    .stall_D(1'b0),
    .stall_E(1'b0), 
    .stall_M(1'b0), 
    .stall_WB(1'b0),
    .flush_F(1'b0), 
    .flush_D(1'b0), 
    .flush_E(1'b0), 
    .flush_M(1'b0), 
    .flush_WB(1'b0)
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
    .dmem_WE(dmem_WE), 
    .reg_WE(reg_WE), 
    .rs1_SEL(rs1_SEL), 
    .rs2_SEL(rs2_SEL),

    .stall_E(1'b0), 
    .stall_M(1'b0), 
    .stall_WB(1'b0),
    .flush_E(1'b0), 
    .flush_M(1'b0), 
    .flush_WB(1'b0));



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
		$dumpfile("control_logic_tb.vcd");
		$dumpvars(0, control_logic_tb);

    for (i = 0; i < 32; i = i + 1)
      $dumpvars(1, DUT.regFILE.x[i]);

	end
endmodule