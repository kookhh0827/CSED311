`include "opcodes.v"
`include "alu_opcodes.v"

module ControlUnit(input [6:0] opcode,
                   output reg is_jal,
                   output reg is_jalr,      
                   output reg branch,        
                   output reg mem_read,        
                   output reg mem_to_reg,   
                   output reg mem_write,         
                   output reg alu_src,   
                   output reg write_enable,
                   output reg pc_to_reg,
                   output reg is_ecall);
    
    always @(*) begin
        case(opcode)
        `ARITHMETIC: begin
            is_jal = 0; is_jalr = 0; branch = 0;
            mem_read = 0; mem_to_reg = 0; mem_write = 0;
            alu_src = 0; write_enable = 1; pc_to_reg = 0;
            is_ecall = 0;
        end
        `ARITHMETIC_IMM: begin
            is_jal = 0; is_jalr = 0; branch = 0;
            mem_read = 0; mem_to_reg = 0; mem_write = 0;
            alu_src = 1; write_enable = 1; pc_to_reg = 0;
            is_ecall = 0;
        end
        `LOAD: begin
            is_jal = 0; is_jalr = 0; branch = 0;
            mem_read = 1; mem_to_reg = 1; mem_write = 0;
            alu_src = 1; write_enable = 1; pc_to_reg = 0;
            is_ecall = 0;
        end
        `STORE: begin
            is_jal = 0; is_jalr = 0; branch = 0;
            mem_read = 0; mem_to_reg = 0; mem_write = 1;
            alu_src = 1; write_enable = 0; pc_to_reg = 0;
            is_ecall = 0;
        end
        `BRANCH: begin
            is_jal = 0; is_jalr = 0; branch = 1;
            mem_read = 0; mem_to_reg = 0; mem_write = 0;
            alu_src = 0; write_enable = 0; pc_to_reg = 0;
            is_ecall = 0;
        end
        `JAL: begin
            is_jal = 1; is_jalr = 0; branch = 0;
            mem_read = 0; mem_to_reg = 0; mem_write = 0;
            alu_src = 0; write_enable = 1; pc_to_reg = 1;
            is_ecall = 0;
        end
        `JALR: begin
            is_jal = 0; is_jalr = 1; branch = 0;
            mem_read = 0; mem_to_reg = 0; mem_write = 0;
            alu_src = 1; write_enable = 1; pc_to_reg = 1;
            is_ecall = 0;
        end
        `ECALL: begin
            is_jal = 0; is_jalr = 0; branch = 0;
            mem_read = 0; mem_to_reg = 0; mem_write = 0;
            alu_src = 0; write_enable = 0; pc_to_reg = 0;
            is_ecall = 1;
        end
        default: begin
            is_jal = 0; is_jalr = 0; branch = 0;
            mem_read = 0; mem_to_reg = 0; mem_write = 0;
            alu_src = 0; write_enable = 0; pc_to_reg = 0;
            is_ecall = 0;
        end
        endcase
    end  
endmodule
