
// -------------------------------- //
//	By: Bryce Keen	
//	Created: 08/13/2023
// -------------------------------- //
//	Last Modified: 08/13/2023

//
//	control_logic.v
//		RV32I Control Logic for the BEAN-2 pipeline
//


module control_logic(opcode, funct7, funct3, jump, ALU_SEL, dmem_SEL, 
                     imm_SEL, reg_SEL, pc_SEL, dmem_WE, 
                     reg_WE, rs1_SEL, rs2_SEL, clk, reset,
                     stall_E, stall_M, stall_WB,
                     flush_E, flush_M, flush_WB);

  // Input & Outputs
  input wire [6:0]     opcode, funct7;
  input wire [2:0]     funct3;
  input wire           jump, clk, reset;
  input wire           stall_E, stall_M, stall_WB;
  input wire           flush_E, flush_M, flush_WB;

  output wire [3:0]    ALU_SEL;
  output wire [2:0]    dmem_SEL, imm_SEL;
  output wire [1:0]    reg_SEL, pc_SEL; 
  output wire          dmem_WE, reg_WE, rs1_SEL, rs2_SEL;

  // assign opcode = inst[6:0];
  // assign funct3 = inst[14:12];
  // assign funct7 = inst[31:25];


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

  wire            pc_SEL_E_cond;
  wire            en_E, reset_E;
  assign en_E = ~stall_E;
  assign reset_E = reset | flush_E;

  // REG_execute
  always @(posedge clk, posedge reset_E) begin
    if (reset_E) begin
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

  // pc_control
  assign pc_SEL_E_cond = pc_cond_E ? ((jump == (1'b1 ^ pc_not_E)) ? 2'b11 : 2'b00) : pc_SEL_E; 

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


  wire            en_M, reset_M;
  assign en_M = ~stall_M;
  assign reset_M = reset | flush_M;

  // REG_memory
  always @(posedge clk, posedge reset_M) begin
    if (reset_M) begin
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

  assign dmem_SEL = dmem_SEL_M;
  assign pc_SEL = pc_SEL_M;
  assign dmem_WE = dmem_WE_M;

  // ----------------------------- //
  // Write Back
  // ----------------------------- //
  reg             reg_WE_WB = 0;
  reg [1:0]       reg_SEL_WB = 0;

  wire            en_WB, reset_WB;
  assign en_WB = ~stall_WB;
  assign reset_WB = reset | flush_WB;

  // REG_writeback
  always @(posedge clk, posedge reset_WB) begin
    if (reset_WB) begin
      reg_WE_WB <= 0;
      reg_SEL_WB <= 0;
    end
    else if (en_WB) begin
      reg_WE_WB <= reg_WE_M;
      reg_SEL_WB <= reg_SEL_M;
    end
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
  output reg          dmem_WE, reg_WE, rs1_SEL, rs2_SEL; 
  output reg          pc_cond, pc_not;

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
  end

  always @(*) begin
    pc_cond <= 1'b0;
    pc_not <= 1'b0;

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
        end
      7'b1100011:
        begin
          case (funct3)
            3'b000:       // BEQ
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b0;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b0;
                reg_SEL   <= 2'b00;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b010;
                ALU_SEL   <= 4'b1000;

                pc_cond <= 1'b1;
              end
            3'b001:       // BNE
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b0;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b0;
                reg_SEL   <= 2'b00;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b010;
                ALU_SEL   <= 4'b1000;

                pc_cond <= 1'b1;
                pc_not <= 1'b1;
              end
            3'b100:       // BLT
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b0;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b0;
                reg_SEL   <= 2'b00;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b010;
                ALU_SEL   <= 4'b1010;

                pc_cond <= 1'b1;
              end
            3'b101:       // BGE
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b0;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b0;
                reg_SEL   <= 2'b00;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b010;
                ALU_SEL   <= 4'b1100;

                pc_cond <= 1'b1;
              end
            3'b110:       // BLTU
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b0;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b0;
                reg_SEL   <= 2'b00;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b010;
                ALU_SEL   <= 4'b1001;

                pc_cond <= 1'b1;
              end
            3'b111:       // BGEU
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b0;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b0;
                reg_SEL   <= 2'b00;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b010;
                ALU_SEL   <= 4'b1011;

                pc_cond <= 1'b1;
              end
          endcase
        end
      7'b0000011:
        begin
          case (funct3)
            3'b000:       // LB
              begin
                dmem_SEL  <= 3'b110;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b1;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b1;
                reg_SEL   <= 2'b00;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b011;
                ALU_SEL   <= 4'b0000;
              end
            3'b001:       // LH
              begin
                dmem_SEL  <= 3'b101;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b1;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b1;
                reg_SEL   <= 2'b00;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b011;
                ALU_SEL   <= 4'b0000;
              end
            3'b010:       // LW
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b1;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b1;
                reg_SEL   <= 2'b00;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b011;
                ALU_SEL   <= 4'b0000;
              end
            3'b100:       // LBU
              begin
                dmem_SEL  <= 3'b010;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b1;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b1;
                reg_SEL   <= 2'b00;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b011;
                ALU_SEL   <= 4'b0000;
              end
            3'b101:       // LHU
              begin
                dmem_SEL  <= 3'b001;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b1;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b1;
                reg_SEL   <= 2'b00;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b011;
                ALU_SEL   <= 4'b0000;
              end
          endcase
        end
      7'b0100011:
        begin
          case (funct3)
            3'b000:       // SB
              begin
                dmem_SEL  <= 3'b010;
                dmem_WE   <= 1'b1;
                reg_WE    <= 1'b0;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b1;
                reg_SEL   <= 2'b00;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b001;
                ALU_SEL   <= 4'b0000;
              end
            3'b001:       // SH
              begin
                dmem_SEL  <= 3'b001;
                dmem_WE   <= 1'b1;
                reg_WE    <= 1'b0;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b1;
                reg_SEL   <= 2'b00;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b001;
                ALU_SEL   <= 4'b0000;
              end
            3'b010:       // SW
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b1;
                reg_WE    <= 1'b0;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b1;
                reg_SEL   <= 2'b00;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b001;
                ALU_SEL   <= 4'b0000;
              end
          endcase
        end
      7'b0010011:
        begin
          case (funct3)
            3'b000:       // ADDI
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b1;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b1;
                reg_SEL   <= 2'b01;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b011;
                ALU_SEL   <= 4'b0000;
              end
            3'b010:       // SLTI
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b1;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b1;
                reg_SEL   <= 2'b01;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b011;
                ALU_SEL   <= 4'b1010;
              end
            3'b011:       // SLTIU
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b1;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b1;
                reg_SEL   <= 2'b01;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b011;
                ALU_SEL   <= 4'b1001;
              end
            3'b100:       // XORI
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b1;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b1;
                reg_SEL   <= 2'b01;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b011;
                ALU_SEL   <= 4'b0100;
              end
            3'b110:       // ORI
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b1;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b1;
                reg_SEL   <= 2'b01;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b011;
                ALU_SEL   <= 4'b0011;
              end
            3'b111:       // ANDI
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b1;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b1;
                reg_SEL   <= 2'b01;
                pc_SEL    <= 2'b00;
                imm_SEL   <= 3'b011;
                ALU_SEL   <= 4'b0010;
              end
            3'b001:
              case (funct7)
                7'b0000000:   // SLLI
                  begin
                    dmem_SEL  <= 3'b000;
                    dmem_WE   <= 1'b0;
                    reg_WE    <= 1'b1;
                    rs1_SEL   <= 1'b0;
                    rs2_SEL   <= 1'b1;
                    reg_SEL   <= 2'b01;
                    pc_SEL    <= 2'b00;
                    imm_SEL   <= 3'b011;
                    ALU_SEL   <= 4'b0101;
                  end
              endcase
            3'b101:     
              case (funct7)
                7'b0000000:   // SRLI
                  begin
                    dmem_SEL  <= 3'b000;
                    dmem_WE   <= 1'b0;
                    reg_WE    <= 1'b1;
                    rs1_SEL   <= 1'b0;
                    rs2_SEL   <= 1'b1;
                    reg_SEL   <= 2'b01;
                    pc_SEL    <= 2'b00;
                    imm_SEL   <= 3'b011;
                    ALU_SEL   <= 4'b0110;
                  end
                7'b0100000:   // SRAI
                  begin
                    dmem_SEL  <= 3'b000;
                    dmem_WE   <= 1'b0;
                    reg_WE    <= 1'b1;
                    rs1_SEL   <= 1'b0;
                    rs2_SEL   <= 1'b1;
                    reg_SEL   <= 2'b01;
                    pc_SEL    <= 2'b00;
                    imm_SEL   <= 3'b011;
                    ALU_SEL   <= 4'b0111;
                  end
              endcase
          endcase
        end
      7'b0110011:
        case (funct3)
          3'b000:
            case (funct7)
              7'b0000000:   // ADD
                begin
                  dmem_SEL  <= 3'b000;
                  dmem_WE   <= 1'b0;
                  reg_WE    <= 1'b1;
                  rs1_SEL   <= 1'b0;
                  rs2_SEL   <= 1'b0;
                  reg_SEL   <= 2'b01;
                  pc_SEL    <= 2'b00;
                  imm_SEL   <= 3'b000;
                  ALU_SEL   <= 4'b0000;
                end
              7'b0100000:   // SUB
                begin
                  dmem_SEL  <= 3'b000;
                  dmem_WE   <= 1'b0;
                  reg_WE    <= 1'b1;
                  rs1_SEL   <= 1'b0;
                  rs2_SEL   <= 1'b0;
                  reg_SEL   <= 2'b01;
                  pc_SEL    <= 2'b00;
                  imm_SEL   <= 3'b000;
                  ALU_SEL   <= 4'b0001;
                end
            endcase
          3'b001:
            case (funct7)
              7'b0000000:   // SLL
                begin
                  dmem_SEL  <= 3'b000;
                  dmem_WE   <= 1'b0;
                  reg_WE    <= 1'b1;
                  rs1_SEL   <= 1'b0;
                  rs2_SEL   <= 1'b0;
                  reg_SEL   <= 2'b01;
                  pc_SEL    <= 2'b00;
                  imm_SEL   <= 3'b000;
                  ALU_SEL   <= 4'b0101;
                end
            endcase
          3'b010:
            case (funct7)
              7'b0000000:   // SLT
                begin
                  dmem_SEL  <= 3'b000;
                  dmem_WE   <= 1'b0;
                  reg_WE    <= 1'b1;
                  rs1_SEL   <= 1'b0;
                  rs2_SEL   <= 1'b0;
                  reg_SEL   <= 2'b01;
                  pc_SEL    <= 2'b00;
                  imm_SEL   <= 3'b000;
                  ALU_SEL   <= 4'b1010;
                end
            endcase
          3'b011:
            case (funct7)
              7'b0000000:   // SLTU
                begin
                  dmem_SEL  <= 3'b000;
                  dmem_WE   <= 1'b0;
                  reg_WE    <= 1'b1;
                  rs1_SEL   <= 1'b0;
                  rs2_SEL   <= 1'b0;
                  reg_SEL   <= 2'b01;
                  pc_SEL    <= 2'b00;
                  imm_SEL   <= 3'b000;
                  ALU_SEL   <= 4'b1001;
                end
            endcase
          3'b100:
            case (funct7)
              7'b0000000:   // XOR
                begin
                  dmem_SEL  <= 3'b000;
                  dmem_WE   <= 1'b0;
                  reg_WE    <= 1'b1;
                  rs1_SEL   <= 1'b0;
                  rs2_SEL   <= 1'b0;
                  reg_SEL   <= 2'b01;
                  pc_SEL    <= 2'b00;
                  imm_SEL   <= 3'b000;
                  ALU_SEL   <= 4'b0100;
                end
            endcase
          3'b101:
            case (funct7)
              7'b0000000:   // SRL
                begin
                  dmem_SEL  <= 3'b000;
                  dmem_WE   <= 1'b0;
                  reg_WE    <= 1'b1;
                  rs1_SEL   <= 1'b0;
                  rs2_SEL   <= 1'b0;
                  reg_SEL   <= 2'b01;
                  pc_SEL    <= 2'b00;
                  imm_SEL   <= 3'b000;
                  ALU_SEL   <= 4'b0110;
                end
              7'b0100000:   // SRA
                begin
                  dmem_SEL  <= 3'b000;
                  dmem_WE   <= 1'b0;
                  reg_WE    <= 1'b1;
                  rs1_SEL   <= 1'b0;
                  rs2_SEL   <= 1'b0;
                  reg_SEL   <= 2'b01;
                  pc_SEL    <= 2'b00;
                  imm_SEL   <= 3'b000;
                  ALU_SEL   <= 4'b0111;
                end
            endcase
          3'b110:
            case (funct7)
              7'b0000000:   // OR
                begin
                  dmem_SEL  <= 3'b000;
                  dmem_WE   <= 1'b0;
                  reg_WE    <= 1'b1;
                  rs1_SEL   <= 1'b0;
                  rs2_SEL   <= 1'b0;
                  reg_SEL   <= 2'b01;
                  pc_SEL    <= 2'b00;
                  imm_SEL   <= 3'b000;
                  ALU_SEL   <= 4'b0011;
                end
            endcase
          3'b111:
            case (funct7)
              7'b0000000:   // AND
                begin
                  dmem_SEL  <= 3'b000;
                  dmem_WE   <= 1'b0;
                  reg_WE    <= 1'b1;
                  rs1_SEL   <= 1'b0;
                  rs2_SEL   <= 1'b0;
                  reg_SEL   <= 2'b01;
                  pc_SEL    <= 2'b00;
                  imm_SEL   <= 3'b000;
                  ALU_SEL   <= 4'b0010;
                end
            endcase
        endcase   
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
          end
      endcase
  end
endmodule
