module BranchTargetBuffer(
    input [31:0] current_pc,
    input [31:0] IF_ID_pc,
    input [31:0] ID_EX_pc,
    input [31:0] EX_pc_plus_imm,
    input [31:0] EX_alu_result,
    input ID_EX_is_branch,
    input ID_EX_is_jal,
    input ID_EX_is_jalr,
    input EX_alu_bcond,
    output reg is_flush,
    output reg [31:0] next_pc
    );

endmodule
