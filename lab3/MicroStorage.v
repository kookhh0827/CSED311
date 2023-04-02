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
        `IF1,
        `IF2,
        `IF3,
        `IF4: begin
            AddrCtl = 2'b11;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00010x1xxxxxx0;
        end
        `ID: begin
            AddrCtl = 2'b01;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00x00x00000010;
        end
        `EX1_R: begin
            AddrCtl = 2'b11;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00x00x0x101000;
        end
        `EX2_R: begin
            AddrCtl = 2'b10;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00x00x0x101000;
        end
        `EX1_I: begin
            AddrCtl = 2'b11;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00x00x0x111100;
        end
        `EX2_I: begin
            AddrCtl = 2'b10;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00x00x0x111100;
        end
        `EX_LW: begin
            AddrCtl = 2'b10;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00x00x0x001100;
        end
        `EX1_B: begin
            AddrCtl = 2'b11;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b10x00x01011000;
        end
        `EX2_B: begin
            AddrCtl = 2'b00;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b01x00x00000100;
        end
        `MEM1_WR,
        `MEM2_WR,
        `MEM3_WR: begin
            AddrCtl = 2'b11;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00101x0xxxxxx0;
        end 
        `MEM4_WR: begin
            AddrCtl = 2'b00;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b01101x00000010;
        end
        `MEM1_RD,
        `MEM2_RD,
        `MEM3_RD,
        `MEM4_RD: begin
            AddrCtl = 2'b11;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00110x0x001100;
        end
        `WB_M: begin
            AddrCtl = 2'b00;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b01x00100000011;
        end
        `WB_R: begin
            AddrCtl = 2'b00;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b01x00000000011;
        end
        `WB_JAL: begin
            AddrCtl = 2'b00;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b01x00000000101;
        end
        `WB_JALR: begin
            AddrCtl = 2'b00;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b01x00000001101;
        end
        default: begin
            AddrCtl = 2'b00;
            {PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite} = 14'b00000000000000;
        end
        endcase
    end
endmodule

