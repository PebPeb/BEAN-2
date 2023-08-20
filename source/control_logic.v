
// -------------------------------- //
//	By: Bryce Keen	
//	Created: 08/13/2023
// -------------------------------- //
//	Last Modified: 08/13/2023

//
//	control_logic.v
//		RV32I Control Logic for the BEAN-2 pipeline
//


module control_logic(opcode, funct7, funct3, jump, jumping, ALU_SEL, dmem_SEL, 
                     imm_SEL, reg_SEL, pc_SEL, reg_RD, dmem_WE, 
                     reg_WE, rs1_SEL, rs2_SEL, clk, reset,
                     stall_E, stall_M, stall_WB,
                     flush_E, flush_M, flush_WB, reg_WE_D_out);

  // Input & Outputs
  input wire [6:0]     opcode, funct7;
  input wire [2:0]     funct3;
  input wire           jump, clk, reset;
  input wire           stall_E, stall_M, stall_WB;
  input wire           flush_E, flush_M, flush_WB;

  output wire [3:0]    ALU_SEL;
  output wire [2:0]    dmem_SEL, imm_SEL;
  output wire [1:0]    reg_SEL, pc_SEL; 
  output wire [1:0]    reg_RD;
  output wire          dmem_WE, reg_WE, rs1_SEL, rs2_SEL;
  output wire          reg_WE_D_out, jumping;   

  // assign opcode = inst[6:0];
  // assign funct3 = inst[14:12];
  // assign funct7 = inst[31:25];
  assign reg_WE_D_out = reg_WE_D;

  // ----------------------------- //
  // Decode
  // ----------------------------- //

  wire [2:0]      dmem_SEL_D;
  wire            dmem_WE_D;
  wire            reg_WE_D;
  wire            rs1_SEL_D;
  wire            rs2_SEL_D;
  wire [1:0]      reg_SEL_D;
  wire [1:0]      pc_SEL_D;
  wire [2:0]      imm_SEL_D;
  wire [3:0]      ALU_SEL_D;
  wire            pc_cond_D;
  wire            pc_not_D;


  control_unit control_SEL (
      .opcode(opcode),
      .funct7(funct7),
      .funct3(funct3),
      .dmem_SEL(dmem_SEL_D),
      .dmem_WE(dmem_WE_D),
      .reg_WE(reg_WE_D),
      .rs1_SEL(rs1_SEL_D),
      .rs2_SEL(rs2_SEL_D),
      .reg_SEL(reg_SEL_D),
      .pc_SEL(pc_SEL_D),
      .reg_RD(reg_RD),
      .imm_SEL(imm_SEL_D),
      .ALU_SEL(ALU_SEL_D),
      .pc_cond(pc_cond_D),
      .pc_not(pc_not_D));


  assign imm_SEL = imm_SEL_D;

  // ----------------------------- //
  // Execute
  // ----------------------------- //

  reg [2:0]       dmem_SEL_E = 0;
  reg             dmem_WE_E = 0;
  reg             reg_WE_E = 0;
  reg             rs1_SEL_E = 0;
  reg             rs2_SEL_E = 0;
  reg [1:0]       reg_SEL_E = 0;
  reg [1:0]       pc_SEL_E = 0;
  reg [3:0]       ALU_SEL_E = 0;
  reg             pc_cond_E = 0;
  reg             pc_not_E = 0;

  wire [1:0]      pc_SEL_E_cond;
  wire            en_E;
  assign en_E = ~stall_E;


  // REG_execute
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      dmem_SEL_E <= 0;
      dmem_WE_E <= 0;
      reg_WE_E <= 0;
      rs1_SEL_E <= 0;
      rs2_SEL_E <= 0;
      reg_SEL_E <= 0;
      pc_SEL_E <= 0;
      ALU_SEL_E <= 0;
      pc_cond_E <= 0;
      pc_not_E <= 0;
    end
    else if (en_E) begin
      dmem_SEL_E <= dmem_SEL_D;
      dmem_WE_E <= dmem_WE_D;
      reg_WE_E <= reg_WE_D;
      rs1_SEL_E <= rs1_SEL_D;
      rs2_SEL_E <= rs2_SEL_D;
      reg_SEL_E <= reg_SEL_D;
      pc_SEL_E <= pc_SEL_D;
      ALU_SEL_E <= ALU_SEL_D;
      pc_cond_E <= pc_cond_D;
      pc_not_E <= pc_not_D;
    end
  end
  always @(posedge flush_E) begin
    dmem_SEL_E <= 0;
    dmem_WE_E <= 0;
    reg_WE_E <= 0;
    rs1_SEL_E <= 0;
    rs2_SEL_E <= 0;
    reg_SEL_E <= 0;
    pc_SEL_E <= 0;
    ALU_SEL_E <= 0;
    pc_cond_E <= 0;
    pc_not_E <= 0; 
  end



  // pc_control
  assign pc_SEL_E_cond = pc_cond_E ? {(jump == (1'b1 ^ pc_not_E)) ? 2'b11 : 2'b00} : pc_SEL_E; 
  assign jumping = pc_cond_E & (jump & (1'b1 ^ pc_not_E));

  assign ALU_SEL = ALU_SEL_E;
  assign rs1_SEL = rs1_SEL_E;
  assign rs2_SEL = rs2_SEL_E;

  // ----------------------------- //
  // Memory
  // ----------------------------- //

  reg [2:0]       dmem_SEL_M = 0;
  reg             dmem_WE_M = 0;
  reg             reg_WE_M = 0;
  reg [1:0]       reg_SEL_M = 0;
  reg [1:0]       pc_SEL_M = 0;


  wire            en_M;
  assign en_M = ~stall_M;

  // REG_memory
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      dmem_SEL_M <= 0;
      dmem_WE_M <= 0;
      reg_WE_M <= 0;
      reg_SEL_M <= 0;
      pc_SEL_M <= 0;
    end
    else if (en_M) begin
      dmem_SEL_M <= dmem_SEL_E;
      dmem_WE_M <= dmem_WE_E;
      reg_WE_M <= reg_WE_E;
      reg_SEL_M <= reg_SEL_E;
      pc_SEL_M <= pc_SEL_E_cond;
    end
  end
  always @(posedge flush_M) begin
    dmem_SEL_M <= 0;
    dmem_WE_M <= 0;
    reg_WE_M <= 0;
    reg_SEL_M <= 0;
    pc_SEL_M <= 0;
  end

  assign dmem_SEL = dmem_SEL_M;
  assign pc_SEL = pc_SEL_M;
  assign dmem_WE = dmem_WE_M;

  // ----------------------------- //
  // Write Back
  // ----------------------------- //
  reg             reg_WE_WB = 0;
  reg [1:0]       reg_SEL_WB = 0;

  wire            en_WB;
  assign en_WB = ~stall_WB;

  // REG_writeback
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      reg_WE_WB <= 0;
      reg_SEL_WB <= 0;
    end
    else if (en_WB) begin
      reg_WE_WB <= reg_WE_M;
      reg_SEL_WB <= reg_SEL_M;
    end
  end
  always @(posedge flush_WB) begin
    reg_WE_WB <= 0;
    reg_SEL_WB <= 0;   
  end

  assign reg_WE = reg_WE_WB;
  assign reg_SEL = reg_SEL_WB;

endmodule












module control_unit(
    opcode, 
    funct7, 
    funct3,
    dmem_SEL,
    dmem_WE,
    reg_WE,
    rs1_SEL,
    rs2_SEL,
    reg_SEL,
    pc_SEL,
    reg_RD,
    imm_SEL,
    ALU_SEL,
    pc_cond,
    pc_not);

  input [6:0]       opcode;
  input [6:0]       funct7;
  input [2:0]       funct3;

  output reg [2:0]    dmem_SEL, imm_SEL;
  output reg [3:0]    ALU_SEL;
  output reg [1:0]    reg_SEL, pc_SEL;
  output reg [1:0]    reg_RD; 
  output reg          dmem_WE, reg_WE, rs1_SEL, rs2_SEL; 
  output reg          pc_cond, pc_not;

  localparam reg_RD_NONE = 2'b00;
  localparam reg_RD_RS1  = 2'b01;
  localparam reg_RD_RS2  = 2'b10;
  localparam reg_RD_BOTH = 2'b11;

  initial begin
    dmem_SEL     <= 3'b000;
    dmem_WE      <= 1'b0;
    reg_WE       <= 1'b0;
    rs1_SEL      <= 1'b0;
    rs2_SEL      <= 1'b0;
    reg_SEL      <= 2'b00;
    pc_SEL       <= 2'b00;
    imm_SEL      <= 3'b000;
    ALU_SEL      <= 4'b0000;
    pc_cond      <= 1'b0;
    pc_not       <= 1'b0;
    reg_RD       <= reg_RD_NONE;

  end

  always @(*) begin
    pc_cond <= 1'b0;
    pc_not <= 1'b0;
    reg_RD <= reg_RD_NONE;

    case (opcode)
      7'b0110111:   // LUI
        begin
          dmem_SEL  <= 3'b000;
          dmem_WE   <= 1'b0;
          reg_WE    <= 1'b1;
          rs1_SEL   <= 1'b0;
          rs2_SEL   <= 1'b0;
          reg_SEL   <= 2'b10;
          pc_SEL    <= 2'b00;
          imm_SEL   <= 3'b000;
          ALU_SEL   <= 4'b0000;
        end
      7'b0010111:   // AUIPC
        begin
          dmem_SEL  <= 3'b000;
          dmem_WE   <= 1'b0;
          reg_WE    <= 1'b1;
          rs1_SEL   <= 1'b1;
          rs2_SEL   <= 1'b1;
          reg_SEL   <= 2'b01;
          pc_SEL    <= 2'b00;
          imm_SEL   <= 3'b000;
          ALU_SEL   <= 4'b0000;
        end
      7'b1101111:   // JAL
        begin
          dmem_SEL  <= 3'b000;
          dmem_WE   <= 1'b0;
          reg_WE    <= 1'b1;
          rs1_SEL   <= 1'b0;
          rs2_SEL   <= 1'b0;
          reg_SEL   <= 2'b11;
          pc_SEL    <= 2'b11;
          imm_SEL   <= 3'b100;
          ALU_SEL   <= 4'b0000;
        end
      7'b1100111:   // JALR
        begin
          dmem_SEL  <= 3'b000;
          dmem_WE   <= 1'b0;
          reg_WE    <= 1'b1;
          rs1_SEL   <= 1'b0;
          rs2_SEL   <= 1'b1;
          reg_SEL   <= 2'b11;
          pc_SEL    <= 2'b01;
          imm_SEL   <= 3'b011;
          ALU_SEL   <= 4'b1101;
          reg_RD    <= reg_RD_RS1;
        end
      7'b1100011:   // Banch instructions
        begin
          dmem_SEL  <= 3'b000;
          dmem_WE   <= 1'b0;
          reg_WE    <= 1'b0;
          rs1_SEL   <= 1'b0;
          rs2_SEL   <= 1'b0;
          reg_SEL   <= 2'b00;
          pc_SEL    <= 2'b00;
          imm_SEL   <= 3'b010;
          reg_RD    <= reg_RD_BOTH;

          pc_cond <= 1'b1;
          case (funct3)
            3'b000:      ALU_SEL   <= 4'b1000;    // BEQ
            3'b001:                               // BNE
              begin
                ALU_SEL   <= 4'b1000;
                pc_not <= 1'b1;
              end
            3'b100:       ALU_SEL   <= 4'b1010;   // BLT
            3'b101:       ALU_SEL   <= 4'b1100;   // BGE
            3'b110:       ALU_SEL   <= 4'b1001;   // BLTU
            3'b111:       ALU_SEL   <= 4'b1011;   // BGEU
          endcase
        end
      7'b0000011:   // Load instructions
        begin
          dmem_WE   <= 1'b0;
          reg_WE    <= 1'b1;
          rs1_SEL   <= 1'b0;
          rs2_SEL   <= 1'b1;
          reg_SEL   <= 2'b00;
          pc_SEL    <= 2'b00;
          imm_SEL   <= 3'b011;
          ALU_SEL   <= 4'b0000;
          reg_RD    <= reg_RD_RS1;
          case (funct3)
            3'b000:       dmem_SEL  <= 3'b110;    // LB
            3'b001:       dmem_SEL  <= 3'b101;    // LH
            3'b010:       dmem_SEL  <= 3'b000;    // LW
            3'b100:       dmem_SEL  <= 3'b010;    // LBU
            3'b101:       dmem_SEL  <= 3'b001;    // LHU
          endcase
        end
      7'b0100011:   // Store instructions
        begin
          dmem_WE   <= 1'b1;
          reg_WE    <= 1'b0;
          rs1_SEL   <= 1'b0;
          rs2_SEL   <= 1'b1;
          reg_SEL   <= 2'b00;
          pc_SEL    <= 2'b00;
          imm_SEL   <= 3'b001;
          ALU_SEL   <= 4'b0000;
          reg_RD    <= reg_RD_BOTH;
          case (funct3)
            3'b000:       dmem_SEL  <= 3'b010;    // SB
            3'b001:       dmem_SEL  <= 3'b001;    // SH
            3'b010:       dmem_SEL  <= 3'b000;    // SW
          endcase
        end
      7'b0010011:   // Immediate Arithmetic 
        begin
          dmem_SEL  <= 3'b000;
          dmem_WE   <= 1'b0;
          reg_WE    <= 1'b1;
          rs1_SEL   <= 1'b0;
          rs2_SEL   <= 1'b1;
          reg_SEL   <= 2'b01;
          pc_SEL    <= 2'b00;
          imm_SEL   <= 3'b011;
          reg_RD    <= reg_RD_RS1;

          case (funct3)
            3'b000:       ALU_SEL   <= 4'b0000;   // ADDI
            3'b010:       ALU_SEL   <= 4'b1010;   // SLTI
            3'b011:       ALU_SEL   <= 4'b1001;   // SLTIU
            3'b100:       ALU_SEL   <= 4'b0100;   // XORI
            3'b110:       ALU_SEL   <= 4'b0011;   // ORI
            3'b111:       ALU_SEL   <= 4'b0010;   // ANDI
            3'b001:
              case (funct7)
                7'b0000000:   ALU_SEL   <= 4'b0101;   // SLLI
              endcase
            3'b101:     
              case (funct7)
                7'b0000000:   ALU_SEL   <= 4'b0110;   // SRLI
                7'b0100000:   ALU_SEL   <= 4'b0111;   // SRAI
              endcase
          endcase
        end
      7'b0110011:   // Register Arithmetic
        begin 
          dmem_SEL  <= 3'b000;
          dmem_WE   <= 1'b0;
          reg_WE    <= 1'b1;
          rs1_SEL   <= 1'b0;
          rs2_SEL   <= 1'b0;
          reg_SEL   <= 2'b01;
          pc_SEL    <= 2'b00;
          imm_SEL   <= 3'b000;
          reg_RD    <= reg_RD_BOTH;
        
          case (funct7) 
            7'b0000000:
              case (funct3)
                3'b000:   ALU_SEL   <= 4'b0000;   // ADD
                3'b001:   ALU_SEL   <= 4'b0101;   // SLL
                3'b010:   ALU_SEL   <= 4'b1010;   // SLT
                3'b011:   ALU_SEL   <= 4'b1001;   // SLTU
                3'b100:   ALU_SEL   <= 4'b0100;   // XOR
                3'b101:   ALU_SEL   <= 4'b0110;   // SRL
                3'b110:   ALU_SEL   <= 4'b0011;   // OR
                3'b111:   ALU_SEL   <= 4'b0010;   // AND
              endcase
            7'b0100000:
              case (funct3)
                3'b000:   ALU_SEL   <= 4'b0001;   // SUB
                3'b101:   ALU_SEL   <= 4'b0111;   // SRA
              endcase
          endcase 
        end  
      default:
          begin
              dmem_SEL  <= 3'b000;
              dmem_WE   <= 1'b0;
              reg_WE    <= 1'b0;
              rs1_SEL   <= 1'b0;
              rs2_SEL   <= 1'b0;
              reg_SEL   <= 2'b00;
              pc_SEL    <= 2'b00;
              imm_SEL   <= 3'b000;
              ALU_SEL   <= 4'b0000;
              reg_RD    <= reg_RD_NONE;
          end
      endcase
  end
endmodule
