
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

module hazard_logic(clk, reset, reg_WE, reg_RD, rs1, rs2, rs3, jumping,
                    flush_F, flush_D, flush_E, flush_M, flush_WB,
                    stall_F, stall_D, stall_E, stall_M, stall_WB);

  input           clk, reset;
  input           reg_WE;
  input           jumping;
  input [1:0]     reg_RD;
  input [4:0]     rs1, rs2, rs3;
  output wire     flush_F, flush_D, flush_E, flush_M, flush_WB;
  output wire     stall_F, stall_D, stall_E, stall_M, stall_WB;


  reg             flush_F_n = 0, flush_D_n = 0, flush_E_n = 0, flush_M_n = 0, flush_WB_n = 0;
  reg             stall_F_n = 0, stall_D_n = 0, stall_E_n = 0, stall_M_n = 0, stall_WB_n = 0;

  assign flush_F = flush_F_n;
  assign flush_D = flush_D_n;
  assign flush_E = flush_E_n;
  assign flush_M = flush_M_n;
  assign flush_WB = flush_WB_n;
  assign stall_F = stall_F_n;
  assign stall_D = stall_D_n;
  assign stall_E = stall_E_n;
  assign stall_M = stall_M_n;
  assign stall_WB = stall_WB_n;


  // Hazard State Machine

  localparam OPERATIONAL_STATE = 2'b00;
  localparam COLLISION_STATE = 2'b01;
  localparam JUMP_STATE = 2'b10;
  reg [1:0]  current_state = OPERATIONAL_STATE;
  reg [1:0]  next_state = OPERATIONAL_STATE;

  // State Register
  always @(posedge clk, posedge reset) begin
    if (reset)
      current_state <= OPERATIONAL_STATE;
    else
      current_state <= next_state;
  end

  // State Transition
  always @(posedge clk) begin
    case (current_state)
      OPERATIONAL_STATE:
        if (jumping)
          next_state <= JUMP_STATE;
        else if (rd_wr_collision)
          next_state <= COLLISION_STATE;
        else
          next_state <= OPERATIONAL_STATE;
      JUMP_STATE:
        if (rd_wr_collision)
            next_state <= COLLISION_STATE;
        else
          next_state <= OPERATIONAL_STATE;
      COLLISION_STATE:
        if (jumping)
          next_state <= JUMP_STATE;
        else if (rd_wr_collision)
          next_state <= COLLISION_STATE;
        else
          next_state <= OPERATIONAL_STATE;
    endcase
  end


  // State Logic
  always @(posedge clk) begin
    case (current_state)
      OPERATIONAL_STATE:
        flush_D_n <= 1'b0;
        flush_E_n <= 1'b0;
        flush_M_n <= 1'b0;

      JUMP_STATE:
        if (reg_WE_E)
          reg_reserve[rs3_E] = 1'b0;
        if (reg_WE_M)
          reg_reserve[rs3_M] = 1'b0;
          
        flush_D_n <= 1'b1;
        flush_E_n <= 1'b1;
        flush_M_n <= 1'b1;

      COLLISION_STATE:
        flush_D_n <= 1'b0;
        flush_E_n <= 1'b1;
        flush_M_n <= 1'b0;

    endcase
  end

  // Clearing and setting the reg_reserve on different edges 
  // allows for CPU to return from stalling 1 cycle faster

  // Set on rising edge
  always @(posedge clk) begin
    if (reg_WE & (rs3 != 0)) begin
      reg_reserve[rs3] <= 1'b1;
    end
  end
  // Clear on falling edge
  always @(negedge clk) begin
    if (reg_WE_WB)
      reg_reserve[rs3_WB] <= 1'b0;
    else if 
  end

  // Continuesly checking for a read write collision
  always @(*) begin
    case (reg_RD)
      00:   rd_wr_collision <= 1'b0;
      01:   rd_wr_collision <= reg_reserve[rs1];
      10:   rd_wr_collision <= reg_reserve[rs2];
      11:   rd_wr_collision <= reg_reserve[rs1] | reg_reserve[rs2];
    endcase
  end

  always @(*) begin
    if (rd_wr_collision) begin
      stall_F_n <= 1'b1;
      stall_D_n <= 1'b1; 
      stall_E_n <= 1'b1; 
    else
      stall_F_n <= 1'b0;
      stall_D_n <= 1'b0; 
      stall_E_n <= 1'b0; 
    end
  end


  // ----------------------------- //
  // Execute
  // ----------------------------- //

  reg [4:0]       rs3_E = 0;
  reg             reg_WE_E = 0;
  wire            enable_E, reset_E;

  assign enable_E       = ~stall_E_n;
  assign reset_E  = reset | flush_E_n;

  // REG_execute
  always @(posedge clk, posedge reset_E) begin
    if (reset_E) begin
      rs3_E <= 0;
      reg_WE_E <= 0;
    end
    else if (enable_E) begin
      rs3_E <= rs3;
      reg_WE_E <= reg_WE;
    end
  end

  // ----------------------------- //
  // Memory
  // ----------------------------- //

  reg [4:0]       rs3_M = 0;
  reg             reg_WE_M = 0;
  wire            enable_M, reset_M;

  assign enable_M       = ~stall_M_n;
  assign reset_M  = reset | flush_M_n;

  // REG_memory
  always @(posedge clk, posedge reset_M) begin
    if (reset_M) begin
      rs3_M <= 0;
      reg_WE_M <= 0;
    end
    else if (enable_M) begin
      rs3_M <= rs3_E;
      reg_WE_M <= reg_WE_E;
    end
  end

  // // ----------------------------- //
  // // Write Back
  // // ----------------------------- //

  reg [4:0]       rs3_WB = 0;
  reg             reg_WE_WB = 0;
  wire            enable_WB, reset_WB;

  assign enable_WB       = ~stall_WB_n;
  assign reset_WB  = reset | flush_WB_n;

  // REG_writeback
  always @(posedge clk, posedge reset_WB) begin
    if (reset_WB) begin
      reg_WE_WB <= 0;
      rs3_WB <= 0;
    end
    else if (enable_WB) begin
      reg_WE_WB <= reg_WE_M;
      rs3_WB <= rs3_M;
    end
  end

endmodule