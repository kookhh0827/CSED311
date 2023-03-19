`include "opcodes.v"
`include "alu_opcodes.v"

module ALUControlUnit(input [6:0] opcode,
                      input [2:0] funct3,
                      input funct7,      
                      output reg [4:0] alu_op);
                      
                      
    
    always @(*) begin
        alu_op = `ALU_NOP;
        case(opcode)
        `ARITHMETIC: begin
            if (funct7 && funct3 == `FUNCT3_SUB) begin
                alu_op = `ALU_SUB;
            end
            else if (!funct7) begin
                case(funct3)
                `FUNCT3_ADD: alu_op = `ALU_ADD;
                `FUNCT3_SLL: alu_op = `ALU_SLL;
                `FUNCT3_XOR: alu_op = `ALU_XOR;
                `FUNCT3_OR: alu_op = `ALU_OR;
                `FUNCT3_AND: alu_op = `ALU_AND;
                `FUNCT3_SRL: alu_op = `ALU_SRL;
                default: alu_op = `ALU_NOP;
                endcase
            end
            else begin
                alu_op = `ALU_NOP;
            end
        end
        `ARITHMETIC_IMM: begin
            case(funct3)
            `FUNCT3_ADD: alu_op = `ALU_ADD;
            `FUNCT3_SLL: alu_op = funct7 == 0 ? `ALU_SLL : `ALU_NOP;
            `FUNCT3_XOR: alu_op = `ALU_XOR;
            `FUNCT3_OR: alu_op = `ALU_OR;
            `FUNCT3_AND: alu_op = `ALU_AND;
            `FUNCT3_SRL: alu_op = funct7 == 0 ? `ALU_SRL : `ALU_NOP;
            default: alu_op = `ALU_NOP;
            endcase
        end
        `LOAD: begin
            alu_op = funct3 == `FUNCT3_LW ? `ALU_ADD : `ALU_NOP;
        end
        `STORE: begin
            alu_op = funct3 == `FUNCT3_SW ? `ALU_ADD : `ALU_NOP;
        end
        `BRANCH: begin
            case(funct3)
            `FUNCT3_BEQ: alu_op = `ALU_BEQ;
            `FUNCT3_BNE: alu_op = `ALU_BNE;
            `FUNCT3_BLT: alu_op = `ALU_BLT;
            `FUNCT3_BGE: alu_op = `ALU_BGE;
            default: alu_op = `ALU_NOP;
            endcase
        end
        `JALR: begin
            alu_op = `ALU_ADD;
        end 
        `JAL: begin
            alu_op = `ALU_NOP;
        end
        `ECALL: begin 
            alu_op = `ALU_NOP;
        end
        default: begin
            alu_op = `ALU_NOP;
        end
        endcase
    end
    
endmodule
