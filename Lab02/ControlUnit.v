`include "opcodes.v"

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
    end  
endmodule
