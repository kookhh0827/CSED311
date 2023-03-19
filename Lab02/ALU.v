`include "opcodes.v"
`include "alu_opcodes.v"

module ALU(input [4:0] alu_op,
           input [31:0] alu_in_1,
           input [31:0] alu_in_2,      
           output reg [31:0] alu_result,        
           output reg alu_bcond);
    
    always @(*) begin
        alu_result = 0;
        alu_bcond = 0;
        case(alu_op)
            `ALU_ADD: begin
                alu_result = alu_in_1 + alu_in_2;
                alu_bcond = 0;
            end
            `ALU_SUB: begin
                alu_result = alu_in_1 - alu_in_2;
                alu_bcond = 0;
            end
            `ALU_OR: begin
                alu_result = alu_in_1 | alu_in_2;
                alu_bcond = 0;
            end
            `ALU_AND: begin
                alu_result = alu_in_1 & alu_in_2;
                alu_bcond = 0;
            end
            `ALU_XOR: begin
                alu_result = alu_in_1 ^ alu_in_2;
                alu_bcond = 0;
            end
            `ALU_SLL: begin
                alu_result = alu_in_1 << alu_in_2;
                alu_bcond = 0;
            end
            `ALU_SRL: begin
                alu_result = alu_in_1 >> alu_in_2;
                alu_bcond = 0;
            end
            `ALU_BEQ: begin
                alu_result = 0;
                if (alu_in_1 == alu_in_2)
                    alu_bcond = 1;
                else
                    alu_bcond = 0;
            end
            `ALU_BNE: begin
                alu_result = 0;
                if (alu_in_1 != alu_in_2)
                    alu_bcond = 1;
                else
                    alu_bcond = 0;
            end
            `ALU_BLT: begin
                alu_result = 0;
                if (alu_in_1 < alu_in_2)
                    alu_bcond = 1;
                else
                    alu_bcond = 0;
            end
            `ALU_BGE: begin
                alu_result = 0;
                if (alu_in_1 >= alu_in_2)
                    alu_bcond = 1;
                else
                    alu_bcond = 0;
            end
            default: begin
                alu_result = 0;
                alu_bcond = 0;
            end
        endcase
    end
endmodule
