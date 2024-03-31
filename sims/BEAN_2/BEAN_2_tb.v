

module BEAN_2_tb();
  reg       clk = 0, reset = 1;

  always begin
      clk <= ~clk;
      #2;
  end

  wire dmem_WE;
  wire [2:0] dmem_SEL;
  wire [31:0] pc;
  wire [31:0] Instr;
  wire [31:0] memAdrs;
  wire [31:0] memDataRD;
  wire [31:0] memDataWD;

  BEAN_2 core (
    .clk(clk), 
    .reset(reset), 
    .Instr(Instr), 
    .memDataRD(memDataRD), 
    .dmem_WE(dmem_WE), 
    .dmem_SEL(dmem_SEL), 
    .pc(pc), 
    .memAdrs(memAdrs), 
    .memDataWD(memDataWD)
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

    #10000

    $finish;
  end

  integer i;
	initial begin
		$dumpfile("BEAN_2_tb.vcd");
		$dumpvars(0, BEAN_2_tb);

    for (i = 0; i < 32; i = i + 1)
      $dumpvars(1, core.Datapath_Unit.regFILE.x[i]);
    for (i = 0; i < 256; i = i + 1)
      $dumpvars(1, data_mem.mem[i]);

	end
endmodule