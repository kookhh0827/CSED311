`include "opcodes.v"

module ImmediateGenerator(input [31:0] instr,   
                          output reg [31:0] imm_gen_out); 
    
    always @(*) begin
        case (instr[6:0])
            // I-type
            // ADDI, XORI, ORI, AND, SLLI, SRLI
            `ARITHMETIC_IMM: imm_gen_out = { {21{instr[31]}}, instr[30:20] };
            // LW
            `LOAD: imm_gen_out = { {21{instr[31]}}, instr[30:20] };
            // JALR
            `JALR: imm_gen_out = { {21{instr[31]}}, instr[30:20] };
            // S-type
            // SW
            `STORE: imm_gen_out = { {21{instr[31]}}, instr[30:25], instr[11:7] };
            // SB-type
            //BEQ, BNE, BLT, BGE
            `BRANCH: imm_gen_out = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 };
            // UJ-type
            //JAL
            `JAL: imm_gen_out = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:25], instr[24:21], 1'b0 };
            default : imm_gen_out = 0; // NO CASE
        endcase
    end                  
endmodule
