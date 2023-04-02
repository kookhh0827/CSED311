`include "states.v"

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
                   output [1:0] ALUOp,
                   output ALUSrcA,
                   output [1:0] ALUSrcB,
                   output RegWrite,
                   output is_ecall);
    
    /***** Register declarations *****/
    // current micro program counter                
    reg [4:0] current_state;
    
    /***** Wire declarations *****/
    // for program counter update
    wire [4:0] next_state;
    
    // for address select logic
    wire [4:0] cs_plus_1 = current_state + 1'b1;
    wire [1:0] AddrCtl;
    
    // ---------- EcallChcker checks whether an instruction is ecall or not during ID state ----------
    EcallChecker EC(
        .current_state(current_state),  // input
        .opcode(opcode),                // input
        .is_ecall(is_ecall)             // output
    );
    
    // ---------- MicroProgram counter select logic ----------
    AddressSelector ASL(
        .opcode(opcode),         // input
        .cs_plus_1(cs_plus_1),   // input
        .AddrCtl(AddrCtl),       // input
        .alu_bcond(alu_bcond),   // input
        .next_state(next_state)  // output
    );
    
    // ---------- calculates control bits based on a current state ----------
    MicroStorage MS(
        .current_state(current_state),   // input
        .AddrCtl(AddrCtl),               // output
        .PCWriteNotCond(PCWriteNotCond), // output
        .PCWrite(PCWrite),               // output
        .IorD(IorD),                     // output
        .MemRead(MemRead),               // output
        .MemWrite(MemWrite),             // output
        .MemtoReg(MemtoReg),             // output
        .IRWrite(IRWrite),               // output
        .PCSource(PCSource),             // output
        .ALUOp(ALUOp),                   // output
        .ALUSrcA(ALUSrcA),               // output
        .ALUSrcB(ALUSrcB),               // output
        .RegWrite(RegWrite)              // output
    );
    
    // ---------- program counter update logic ----------
    always @(posedge clk) begin
        if (reset) begin
            current_state <= `IF1;
        end
        else begin
            current_state <= next_state;
        end
    end
endmodule