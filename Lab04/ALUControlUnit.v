`include "opcodes.v"
`include "alu_opcodes.v"

module ALUControlUnit(input [2:0] funct3,
                      input funct7,
                      input[1:0] alu_op,
                      output reg [4:0] alu_control);
                      
    always @(*) begin
        alu_control = `ALU_NOP;
        if (alu_op == 2'b00) begin
            // add case
            alu_control = `ALU_ADD;
        end
        else if (alu_op == 2'b01) begin
            // branch case
            case(funct3)
                `FUNCT3_BEQ: alu_control = `ALU_BEQ;
                `FUNCT3_BNE: alu_control = `ALU_BNE;
                `FUNCT3_BLT: alu_control = `ALU_BLT;
                `FUNCT3_BGE: alu_control = `ALU_BGE;
                default: alu_control = `ALU_NOP;
            endcase
        end
        else if (alu_op == 2'b10) begin
            // r-type alu op case
            if (funct7 && funct3 == `FUNCT3_SUB) begin
                alu_control = `ALU_SUB;
            end
            else begin
                case(funct3)
                    `FUNCT3_ADD: alu_control = `ALU_ADD;
                    `FUNCT3_SLL: alu_control = `ALU_SLL;
                    `FUNCT3_XOR: alu_control = `ALU_XOR;
                    `FUNCT3_OR: alu_control = `ALU_OR;
                    `FUNCT3_AND: alu_control = `ALU_AND;
                    `FUNCT3_SRL: alu_control = `ALU_SRL;
                    default: alu_control = `ALU_NOP;
                endcase
            end
        end
        else if (alu_op == 2'b11) begin
            // I-type alu op case
            case(funct3)
                `FUNCT3_ADD: alu_control = `ALU_ADD;
                `FUNCT3_SLL: alu_control = `ALU_SLL;
                `FUNCT3_XOR: alu_control = `ALU_XOR;
                `FUNCT3_OR: alu_control = `ALU_OR;
                `FUNCT3_AND: alu_control = `ALU_AND;
                `FUNCT3_SRL: alu_control = `ALU_SRL;
                default: alu_control = `ALU_NOP;
            endcase
        end
    end                   
       
endmodule
