`include "opcodes.v"
`include "alu_opcodes.v"

module ImmediateGenerator(input [31:0] instr,   
                          output [31:0] imm_gen_out); 
    
    always @(*) begin
        case (instr)
            // I-type
            // ADDI, XORI, ORI, AND, SLLI, SRLI
            0010011: imm_gen_out = {21{instr[31]}, instr[30:20]};
            // LW
            0000011::
            // JALR
            1100111:
            // S-type
            // SW
            0100011:
            // SB-type
            //BEQ, BNE, BLT, BGE
            1100111:
            // UJ-type
            //JAL
            1101111:
            default : 
        endcase
    end                  
endmodule
                //extended[15:0] <= { {8{extend[7]}}, extend[7:0] }; 
