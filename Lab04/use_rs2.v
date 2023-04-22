`include "opcodes.v"

module Use_RS2(
    input [6:0] opcode,
    input [4:0] rs2,
    output reg use_rs2
    );
    always @(*) begin
    use_rs2 = (opcode == `ARITHMETIC || opcode == `STORE) && rs2 != 5'b0;
end
endmodule
