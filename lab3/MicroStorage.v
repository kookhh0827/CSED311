`include "states.v"

module MicroStorage(input [4:0] current_state,
                    output reg [1:0] AddrCtl,
                    output reg PCWriteNotCond,
                    output reg PCWrite,
                    output reg IorD,
                    output reg MemRead,
                    output reg MemWrite,
                    output reg MemtoReg,
                    output reg IRWrite,
                    output reg PCSource,
                    output reg [1:0] ALUOp,
                    output reg ALUSrcA,
                    output reg [1:0] ALUSrcB,
                    output reg RegWrite);
    
    always @(*) begin
        case(current_state)
        `IF: begin
            AddrCtl = 2'b11;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00010010000000;
        end
        `ID: begin
            AddrCtl = 2'b01;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00000000000010;
        end
        `EX_R: begin
            AddrCtl = 2'b10;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00000000101000;
        end
        `EX_I: begin
            AddrCtl = 2'b10;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00000000111100;
        end
        `EX_LW: begin
            AddrCtl = 2'b10;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00000000001100;
        end
        `EX1_B: begin
            AddrCtl = 2'b11;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b10000001011000;
        end
        `EX2_B: begin
            AddrCtl = 2'b00;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b01000000000100;
        end
        `MEM_WR: begin
            AddrCtl = 2'b00;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b01101000000010;
        end
        `MEM_RD: begin
            AddrCtl = 2'b11;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00110000001100;
        end
        `WB_M: begin
            AddrCtl = 2'b00;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b01000100000011;
        end
        `WB_R: begin
            AddrCtl = 2'b00;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b01000000000011;
        end
        `WB_JAL: begin
            AddrCtl = 2'b00;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b01000000000101;
        end
        `WB_JALR: begin
            AddrCtl = 2'b00;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b01000000001101;
        end
        default: begin
            AddrCtl = 2'b00;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00000000000000;
        end
        endcase
    end
endmodule

