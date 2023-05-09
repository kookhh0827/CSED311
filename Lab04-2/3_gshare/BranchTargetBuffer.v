module BranchTargetBuffer #(parameter ENTRY_BIT = 5) (input clk,
                                                      input reset,
                                                      input [31:0] current_pc,
                                                      input [31:0] IF_ID_pc,
                                                      input [31:0] ID_EX_pc,
                                                      input [31:0] EX_pc_plus_imm,
                                                      input [31:0] EX_alu_result,
                                                      input ID_EX_is_branch,
                                                      input ID_EX_is_jal,
                                                      input ID_EX_is_jalr,
                                                      input EX_alu_bcond,
                                                      input [ENTRY_BIT-1:0] ID_EX_bhsr,
                                                      output reg [ENTRY_BIT-1:0] current_bhsr,
                                                      output reg is_flush,
                                                      output reg [31:0] next_pc);
    localparam TAG_BIT = 32 - ENTRY_BIT - 2;
    integer i;

    // global bhsr
    reg [ENTRY_BIT-1:0] global_bhsr;

    // 2 bit predcitor
    reg [1:0] current_counter[0:2 << ENTRY_BIT - 1];
    reg [1:0] next_counter;

    // BTB table values
    reg val_table[0:2 << ENTRY_BIT - 1];
    reg is_branch_table[0:2 << ENTRY_BIT - 1];
    reg [TAG_BIT - 1:0] tag_table[0:2 << ENTRY_BIT - 1];
    reg [31:0] btb_table[0:2 << ENTRY_BIT - 1];

    reg new_val, new_is_branch;
    reg [TAG_BIT - 1:0] new_tag;
    reg [31:0] new_btb;

    // btb info from current pc
    wire [ENTRY_BIT-1:0] btb_idx = current_pc[2 + ENTRY_BIT - 1:2];
    wire [TAG_BIT - 1:0] tag = current_pc[31:2 + ENTRY_BIT];

    // btb info from EX stage pc
    wire [ENTRY_BIT-1:0] EX_btb_idx = ID_EX_pc[2 + ENTRY_BIT - 1:2];
    wire [TAG_BIT - 1:0] EX_tag = ID_EX_pc[31:2 + ENTRY_BIT];

    // calculating flush and next pc
    always @(*) begin
        new_val = val_table[EX_btb_idx];
        new_tag = tag_table[EX_btb_idx];
        new_btb = btb_table[EX_btb_idx];
        new_is_branch = is_branch_table[EX_btb_idx];
        is_flush = 1'b0;
        next_pc = current_pc + 4;

        if (ID_EX_is_jal) begin
            new_val = 1'b1;
            new_tag = EX_tag;
            new_btb = EX_pc_plus_imm;
            new_is_branch = 1'b0;

            if (IF_ID_pc != EX_pc_plus_imm)
                is_flush = 1'b1;
            else
                is_flush = 1'b0;
        end
        else if (ID_EX_is_branch) begin
            new_val = 1'b1;
            new_tag = EX_tag;
            new_btb = EX_pc_plus_imm;
            new_is_branch = 1'b1;

            if (EX_alu_bcond && (EX_pc_plus_imm != IF_ID_pc))
                is_flush = 1'b1;
            else if (!EX_alu_bcond && (IF_ID_pc != ID_EX_pc + 4))
                is_flush = 1'b1;
            else
                is_flush = 1'b0;
        end
        else if (ID_EX_is_jalr) begin
            new_val = 1'b1;
            new_tag = EX_tag;
            new_btb = EX_alu_result;
            new_is_branch = 1'b0;

            if (IF_ID_pc != EX_alu_result)
                is_flush = 1'b1;
            else
                is_flush = 1'b0;
        end
        else begin
            new_val = 0;
            new_tag = 0;
            new_btb = 0;
            new_is_branch = 0;

            is_flush = 1'b0;
        end

        if (is_flush) begin
            if (ID_EX_is_jal) begin
                next_pc = EX_pc_plus_imm;
            end
            else if (ID_EX_is_branch) begin
                if (EX_alu_bcond)
                    next_pc = EX_pc_plus_imm;
                else
                    next_pc = ID_EX_pc + 4;
            end
            else if (ID_EX_is_jalr) begin
                next_pc = EX_alu_result;
            end
            else begin
                next_pc = current_pc + 4;
            end
        end
        else begin
            if (tag_table[btb_idx] == tag && val_table[btb_idx] && (!is_branch_table[btb_idx] || current_counter[btb_idx ^ global_bhsr] > 2'b01)) begin
                next_pc = btb_table[btb_idx];
            end
            else begin
                next_pc = current_pc + 4;
            end
        end
    end

    // calculating states of saturation counter
    always @(*) begin
        next_counter = current_counter[EX_btb_idx ^ ID_EX_bhsr];
        if (ID_EX_is_branch) begin
            if (EX_alu_bcond) begin
                if (current_counter[EX_btb_idx ^ ID_EX_bhsr] != 2'b11)
                    next_counter = current_counte[EX_btb_idx ^ ID_EX_bhsr]r + 1'b1;
                else
                    next_counter = current_counter[EX_btb_idx ^ ID_EX_bhsr];
            end
            else begin
                if (current_counter[EX_btb_idx ^ ID_EX_bhsr] != 2'b00)
                    next_counter = current_counter[EX_btb_idx ^ ID_EX_bhsr] - 1'b1;
                else
                    next_counter = current_counter[EX_btb_idx ^ ID_EX_bhsr];
            end
        end
        else begin
            next_counter = current_counter[EX_btb_idx ^ ID_EX_bhsr];
        end
    end

    // update table and counter
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < (2 << ENTRY_BIT); i = i + 1) begin
                val_table[i] <= 0;
                tag_table[i] <= 0;
                btb_table[i] <= 0;
                is_branch_table[i] <= 0;
                current_counter[i] <= 0;
            end
            global_bhsr <= 0;
        end
        else begin
            if (is_flush) begin
                val_table[EX_btb_idx] <= new_val;
                tag_table[EX_btb_idx] <= new_tag;
                btb_table[EX_btb_idx] <= new_btb;
                is_branch_table[EX_btb_idx] <= new_is_branch;
            end
            current_counter[EX_btb_idx ^ ID_EX_bhsr] <= next_counter;
            global_bhsr <= {global_bhsr << 1, EX_alu_bcond};
        end
    end
endmodule
