
// -------------------------------- //
//	By: Bryce Keen	
//	Created: 11/24/2022
// -------------------------------- //
//	Last Modified: 01/25/2023

//
//	control_logic.v
//		RV32I Control Logic
//


module control_logic(inst, jump, ALU_SEL, dmem_SEL, 
                     imm_SEL, reg_SEL, pc_SEL, dmem_WE, 
                     reg_WE, rs1_SEL, rs2_SEL, clk, reset);

  // Input & Outputs
  input wire [31:0]   inst;
  input wire          jump, clk, reset;

  output reg [3:0]    ALU_SEL;
  output reg [2:0]    dmem_SEL, imm_SEL;
  output reg [1:0]    reg_SEL, pc_SEL; 
  output reg          dmem_WE, reg_WE, rs1_SEL, rs2_SEL;

  // Internal
  wire [6:0]          opcode, funct7;
  wire [2:0]          funct3;

  assign opcode = inst[6:0];
  assign funct3 = inst[14:12];
  assign funct7 = inst[31:25];

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
  end




  // Control Select

  always @(*) begin
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
                pc_SEL    <= (jump == 1'b1) ? 2'b11 : 2'b00;
                imm_SEL   <= 3'b010;
                ALU_SEL   <= 4'b1000;
              end
            3'b001:       // BNE
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b0;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b0;
                reg_SEL   <= 2'b00;
                pc_SEL    <= (jump == 1'b0) ? 2'b11 : 2'b00;
                imm_SEL   <= 3'b010;
                ALU_SEL   <= 4'b1000;
              end
            3'b100:       // BLT
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b0;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b0;
                reg_SEL   <= 2'b00;
                pc_SEL    <= (jump == 1'b1) ? 2'b11 : 2'b00;
                imm_SEL   <= 3'b010;
                ALU_SEL   <= 4'b1010;
              end
            3'b101:       // BGE
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b0;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b0;
                reg_SEL   <= 2'b00;
                pc_SEL    <= (jump == 1'b1) ? 2'b11 : 2'b00;
                imm_SEL   <= 3'b010;
                ALU_SEL   <= 4'b1100;
              end
            3'b110:       // BLTU
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b0;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b0;
                reg_SEL   <= 2'b00;
                pc_SEL    <= (jump == 1'b1) ? 2'b11 : 2'b00;
                imm_SEL   <= 3'b010;
                ALU_SEL   <= 4'b1001;
              end
            3'b111:       // BGEU
              begin
                dmem_SEL  <= 3'b000;
                dmem_WE   <= 1'b0;
                reg_WE    <= 1'b0;
                rs1_SEL   <= 1'b0;
                rs2_SEL   <= 1'b0;
                reg_SEL   <= 2'b00;
                pc_SEL    <= (jump == 1'b1) ? 2'b11 : 2'b00;
                imm_SEL   <= 3'b010;
                ALU_SEL   <= 4'b1011;
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
