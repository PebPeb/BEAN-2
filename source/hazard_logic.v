
// -------------------------------- //
//	By: Bryce Keen	
//	Created: 08/14/2023
// -------------------------------- //
//	Last Modified: 08/14/2023

//
//	hazard_logic.v
//		
//


module hazard_logic(clk, reset);

  input           clk, reset;
  input           reg_WE;
  input [4:0]     rs1, rs2, rs3;
  output          flush_E, flush_M, flush_WB;
  output          stall_E, stall_M, stall_WB;


  reg [31:0]      reg_reserve = 32'h00000000;

  // ----------------------------- //
  // Decode
  // ----------------------------- //

  always @(posedge clk, reg_WE, rs3, reg_WE_WB, rs3_WB) begin
    if (reg_WE) begin
      reg_reserve[rs3] <= 1'b1;
    end
    
    if (reg_WE_WB & ~reg_WE) begin
      reg_reserve[rs3_WB] <= 1'b0;
    end
    
  end

  /*
  if (reg_reserve[rs1] | reg_reserve[rs2])
    Then start halting 
      - halt Fetch to stop PC counter
      - halt Decode to stop New instructions
      - halt Execude
        - next clk halt memory unless cleared

  */

  // ----------------------------- //
  // Execute
  // ----------------------------- //

  reg             reg_WE_E = 0;
  reg [4:0]       rs3_E = 0;

  wire            en_E, reset_E;
  assign en_E = ~stall_E;
  assign reset_E = reset | flush_E;

  // REG_execute
  always @(posedge clk, posedge reset_E) begin
    if (reset_E) begin
      rs3_E <= 0;
      reg_WE_E <= 0;
    end
    else if (en_E) begin
      rs3_E <= rs3;
      reg_WE_E <= reg_WE;
    end
  end

  // ----------------------------- //
  // Memory
  // ----------------------------- //

  reg             reg_WE_M = 0;
  reg [4:0]       rs3_M = 0;

  wire            en_M, reset_M;
  assign en_M = ~stall_M;
  assign reset_M = reset | flush_M;

  // REG_memory
  always @(posedge clk, posedge reset_M) begin
    if (reset_M) begin
      rs3_M <= 0;
      reg_WE_M <= 0;
    end
    else if (en_M) begin
      rs3_M <= rs3_E;
      reg_WE_M <= reg_WE_E;
    end
  end

  // ----------------------------- //
  // Write Back
  // ----------------------------- //

  reg             reg_WE_WB = 0;
  reg [4:0]       rs3_WB = 0;

  wire            en_WB, reset_WB;
  assign en_WB = ~stall_WB;
  assign reset_WB = reset | flush_WB;

  // REG_writeback
  always @(posedge clk, posedge reset_WB) begin
    if (reset_WB) begin
      reg_WE_WB <= 0;
      rs3_WB <= 0;
    end
    else if (en_WB) begin
      reg_WE_WB <= reg_WE_M;
      rs3_WB <= rs3_M;
    end
  end

endmodule
