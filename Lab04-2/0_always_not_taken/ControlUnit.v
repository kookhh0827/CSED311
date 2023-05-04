`include "opcodes.v"

module ControlUnit(
    input [6:0] opcode,       // input
    output reg is_jal,        // output
    output reg is_jalr,       // output
    output reg is_branch,     // output  
    output reg mem_read,      // output
    output reg mem_to_reg,    // output
    output reg mem_write,     // output
    output reg alu_src,       // output
    output reg write_enable,  // output
    output reg pc_to_reg,     // output
    output reg [1:0] alu_op,  // output
    output reg is_ecall       // output (ecall inst)
    );

    always @(*) begin
        case (opcode)
            `ARITHMETIC: begin
                {is_jal, is_jalr, is_branch, mem_read, mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, alu_op, is_ecall} = 12'b000000010100;
            end
            `ARITHMETIC_IMM: begin
                {is_jal, is_jalr, is_branch, mem_read, mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, alu_op, is_ecall} = 12'b000000110110;        
            end
            `LOAD: begin
                {is_jal, is_jalr, is_branch, mem_read, mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, alu_op, is_ecall} = 12'b000110110000;
            end
            `STORE: begin
                {is_jal, is_jalr, is_branch, mem_read, mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, alu_op, is_ecall} = 12'b000001100000;
            end
            `JAL: begin
                {is_jal, is_jalr, is_branch, mem_read, mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, alu_op, is_ecall} = 12'b100000011000;  
            end
            `JALR: begin
                {is_jal, is_jalr, is_branch, mem_read, mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, alu_op, is_ecall} = 12'b010000111000;  
            end
            `BRANCH: begin
                {is_jal, is_jalr, is_branch, mem_read, mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, alu_op, is_ecall} = 12'b001000000010;  
            end
            `ECALL: begin
                {is_jal, is_jalr, is_branch, mem_read, mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, alu_op, is_ecall} = 12'b000000000001;        
            end
            default: begin
                {is_jal, is_jalr, is_branch, mem_read, mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, alu_op, is_ecall} = 12'b000000000000;   
            end
        endcase
    end

endmodule