
// -------------------------------- //
//	By: Bryce Keen	
//	Created: 08/14/2023
// -------------------------------- //
//	Last Modified: 08/14/2023

//
//	hazard_logic.v
//		
//


// reg_RD
//  00 -> none
//  01 -> rs1
//  10 -> rs2
//  11 -> rs1 & rs2

// reg_WE
//  0 -> none
//  1 -> rs3

module hazard_logic(clk, reset, reg_WE, reg_RD, rs1, rs2, rs3, rs3_WB,
                    flush_F, flush_D, flush_E, flush_M, flush_WB,
                    stall_F, stall_D, stall_E, stall_M, stall_WB);

  input           clk, reset;
  input           reg_WE;
  input [1:0]     reg_RD;
  input [4:0]     rs1, rs2, rs3, rs3_WB;
  output reg      flush_F = 0, flush_D = 0, flush_E = 0, flush_M = 0, flush_WB = 0;
  output reg      stall_F = 0, stall_D = 0, stall_E = 0, stall_M = 0, stall_WB = 0;


  // ----------------------------- //
  // Decode
  // ----------------------------- //

  reg [31:0]      reg_reserve = 32'h00000000;
  reg             rd_wr_collision = 0;

  always @(posedge clk) begin
    if (reg_WE & rs3) begin
      reg_reserve[rs3] <= 1'b1;
    end
  end

  always @(negedge clk) begin
    if (reg_WE_WB) begin
      reg_reserve[rs3_WB] <= 1'b0;
    end    
  end

  // Read Write Collision 
  // Happens when tring to read from a register that is waiting to be writen too
  always @(reg_RD, rs1, rs2, reset) begin
    if (reset) begin
      rd_wr_collision <= 1'b0;
    end
    else begin
      case (reg_RD)
        00:   rd_wr_collision <= 1'b0;
        01:   rd_wr_collision <= reg_reserve[rs1];
        10:   rd_wr_collision <= reg_reserve[rs2];
        11:   rd_wr_collision <= reg_reserve[rs1] | reg_reserve[rs2];
      endcase
    end
  end

  // stall logic
  reg           stall = 0;
  always @(*) begin
    if (rd_wr_collision) begin
      stall <= 1'b1;
      stall_F <= 1'b1;
      stall_D <= 1'b1; 
      stall_E <= 1'b1; 
    end
    else begin
      stall <= 1'b0;
      stall_F <= 1'b0;
      stall_D <= 1'b0; 
      stall_E <= 1'b0; 
    end
  end

  // ----------------------------- //
  // Execute
  // ----------------------------- //

  always @(posedge clk) begin
    if (stall) begin
      flush_E <= 1'b1;
    end
    else begin
      flush_E <= 1'b0;
    end
  end

  // reg             reg_WE_E = 0;
  // reg [4:0]       rs3_E = 0;

  // wire            en_E, reset_E;
  // assign en_E = ~stall_E;
  // assign reset_E = reset | flush_E;

  // // REG_execute
  // always @(posedge clk, posedge reset_E) begin
  //   if (reset_E) begin
  //     rs3_E <= 0;
  //     reg_WE_E <= 0;
  //   end
  //   else if (en_E) begin
  //     rs3_E <= rs3;
  //     reg_WE_E <= reg_WE;
  //   end
  // end

  // ----------------------------- //
  // Memory
  // ----------------------------- //

  // reg             reg_WE_M = 0;
  // reg [4:0]       rs3_M = 0;

  // wire            en_M, reset_M;
  // assign en_M = ~stall_M;
  // assign reset_M = reset | flush_M;

  // // REG_memory
  // always @(posedge clk, posedge reset_M) begin
  //   if (reset_M) begin
  //     rs3_M <= 0;
  //     reg_WE_M <= 0;
  //   end
  //   else if (en_M) begin
  //     rs3_M <= rs3_E;
  //     reg_WE_M <= reg_WE_E;
  //   end
  // end

  // ----------------------------- //
  // Write Back
  // ----------------------------- //

  // reg             reg_WE_WB = 0;
  // reg [4:0]       rs3_WB = 0;

  // wire            en_WB, reset_WB;
  // assign en_WB = ~stall_WB;
  // assign reset_WB = reset | flush_WB;

  // // REG_writeback
  // always @(posedge clk, posedge reset_WB) begin
  //   if (reset_WB) begin
  //     reg_WE_WB <= 0;
  //     rs3_WB <= 0;
  //   end
  //   else if (en_WB) begin
  //     reg_WE_WB <= reg_WE_M;
  //     rs3_WB <= rs3_M;
  //   end
  // end

endmodule
