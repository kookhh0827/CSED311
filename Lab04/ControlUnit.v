`include "opcodes.v"

module ControlUnit(
    input [6:0] opcode,  // input
    output reg mem_read,      // output
    output reg mem_to_reg,    // output
    output reg mem_write,     // output
    output reg alu_src,       // output
    output reg write_enable,  // output
    output reg pc_to_reg,     // output
    output reg [1:0] alu_op,        // output
    output reg is_ecall       // output (ecall inst)
    );

    always @(*) begin
        case (opcode)
            `ARITHMETIC: begin
                {mem_read, mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, alu_op, is_ecall} = 9'b000010100;
            end
            `ARITHMETIC_IMM: begin
                {mem_read, mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, alu_op, is_ecall} = 9'b000110110;        
            end
            `LOAD: begin
                {mem_read, mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, alu_op, is_ecall} = 9'b110110000;
            end
            `STORE: begin
                {mem_read, mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, alu_op, is_ecall} = 9'b001100000;
            end
            `ECALL: begin
                {mem_read, mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, alu_op, is_ecall} = 9'b000000001;        
            end
        endcase
    end

endmodule