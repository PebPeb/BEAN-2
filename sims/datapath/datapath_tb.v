

module datapath_tb();
  reg       clk = 0, reset = 1;

  always begin
      clk <= ~clk;
      #2;
  end

  reg reg_WE = 0;
  reg rs1_SEL = 0;
  reg rs2_SEL = 0;
  reg dmem_WE = 0;
  reg [1:0] pc_SEL = 0;
  reg [1:0] reg_SEL = 0;
  reg [2:0] imm_SEL = 0;
  reg [2:0] dmem_SEL = 0;
  reg [3:0] ALU_SEL = 0;

  wire [31:0] pc;
  wire [31:0] Instr;
  wire [31:0] memAdrs;
  wire [31:0] memDataRD;
  wire [31:0] memDataWD;


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
    .memAdrs(memAdrs)
  );

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

    dmem_SEL <= 3'b000;
    dmem_WE <= 1'b0; 
    reg_WE <= 1'b1;
    rs1_SEL <= 1'b0;
    rs2_SEL <= 1'b1;
    reg_SEL <= 2'b01;
    pc_SEL <= 2'b00;
    imm_SEL <= 3'b011;
    ALU_SEL <= 4'b0000;
    #48

    $finish;
  end

  integer i;
	initial begin
		$dumpfile("datapath_tb.vcd");
		$dumpvars(0, datapath_tb);

    for (i = 0; i < 32; i = i + 1)
      $dumpvars(1, DUT.regFILE.x[i]);

	end
endmodule