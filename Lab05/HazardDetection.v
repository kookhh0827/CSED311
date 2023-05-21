module HazardDetection(input [4:0] rs1,
                       input [4:0] rs2,
                       input [6:0] opcode,
                       input ID_EX_mem_read,
                       input [4:0] ID_EX_rd,
                       input is_ecall,
                       input ID_EX_reg_write,
                       input [4:0] EX_MEM_rd,
                       input EX_MEM_mem_read,
                       input EX_is_hit,
                       input EX_is_output_valid,
                       input EX_is_ready,
                       output reg is_stall);

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
        is_stall = ( (((use_rs1 && rs1 == ID_EX_rd) || (use_rs2 && rs2 == ID_EX_rd)) && ID_EX_mem_read)
        || (is_ecall && (ID_EX_rd == 17 && (ID_EX_mem_read || ID_EX_reg_write)) || (EX_MEM_rd == 17 && EX_MEM_mem_read)))
        || ! (EX_is_hit && EX_is_output_valid && EX_is_ready);
    end

endmodule
