`include "opcodes.v"

module Use_RS1(
    input [6:0] opcode,
    input [4:0] rs1,
    output reg use_rs1
    );
    always @(*) begin
    use_rs1 = opcode != `ECALL && rs1 != 5'b0;
end
endmodule
