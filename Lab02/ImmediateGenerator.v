`include "opcodes.v"
`include "alu_opcodes.v"

module ImmediateGenerator(input [31:0] instr,   
                          output reg [31:0] imm_gen_out); 
    
    always @(*) begin
        case (instr)
            // I-type
            // ADDI, XORI, ORI, AND, SLLI, SRLI
            0010011: imm_gen_out = { {21{instr[31]}}, instr[30:20] };
            // LW
            0000011: imm_gen_out = { {21{instr[31]}}, instr[30:20] };
            // JALR
            1100111: imm_gen_out = { {21{instr[31]}}, instr[30:20] };
            // S-type
            // SW
            0100011: imm_gen_out = { {21{instr[31]}}, instr[30:25], instr[11:7] };
            // SB-type
            //BEQ, BNE, BLT, BGE
            1100111: imm_gen_out = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 0 };
            // UJ-type
            //JAL
            1101111: imm_gen_out = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:25], instr[24:21], 0 };
            default : imm_gen_out = 0; // NO CASE
        endcase
    end                  
endmodule
