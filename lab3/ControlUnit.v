module ControlUnit(input reset,
                   input clk,
                   input [6:0] opcode,
                   input alu_bcond,
                   output PCWriteNotCond,
                   output PCWrite,
                   output IorD,
                   output MemRead,
                   output MemWrite,
                   output MemtoReg,
                   output IRWrite,
                   output PCSource,
                   output ALUOp,
                   output ALUSrcA,
                   output ALUSrcB,
                   output RegWrite,
                   output is_ecall);
    
endmodule