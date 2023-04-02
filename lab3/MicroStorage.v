module MicroStorage(input [4:0] current_state,
                    output reg [1:0] AddrCtl,
                    output reg ns_IF1,
                    output reg PCWriteNotCond,
                    output reg PCWrite,
                    output reg IorD,
                    output reg MemRead,
                    output reg MemWrite,
                    output reg MemtoReg,
                    output reg IRWrite,
                    output reg PCSource,
                    output reg ALUOp,
                    output reg ALUSrcA,
                    output reg ALUSrcB,
                    output reg RegWrite);
    
endmodule

