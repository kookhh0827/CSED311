`include "opcodes.v"

module HazardDetection(
    input [4:0] rs1,
    input [4:0] rs2,
    input [6:0] opcode,
    input [4:0] ID_EX_mem_read,
    input [4:0] ID_EX_rd,
    output reg is_stall
    );
endmodule


wire use_rs1, use_rs2;

Use_RS1 Use_RS1(
    .rs1(rs1),
    .opcode(opcode),
    .use_rs1(use_rs1)
);

Use_RS2 Use_RS2(
    .rs2(rs2),
    .opcode(opcode),
    .use_rs2(use_rs2)    
);

always @(*) begin
    is_stall = ((use_rs1 && rs1 == ID_EX_rd) || (use_rs2 && rs2 == ID_EX_rd)) && ID_EX_mem_read;
end
