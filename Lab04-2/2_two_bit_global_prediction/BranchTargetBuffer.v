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
                                                      output reg is_flush,
                                                      output reg [31:0] next_pc);
    localparam TAG_BIT = 32 - ENTRY_BIT - 2;
    integer i;

    reg val_table[0:2 << ENTRY_BIT - 1];
    reg is_branch_table[0:2 << ENTRY_BIT - 1];
    reg [TAG_BIT - 1:0] tag_table[0:2 << ENTRY_BIT - 1];
    reg [31:0] btb_table[0:2 << ENTRY_BIT - 1];

    wire [ENTRY_BIT-1:0] btb_idx = current_pc[2 + ENTRY_BIT - 1:2];
    wire [TAG_BIT - 1:0] tag = current_pc[31:2 + ENTRY_BIT];

    wire [ENTRY_BIT-1:0] EX_btb_idx = ID_EX_pc[2 + ENTRY_BIT - 1:2];
    wire [TAG_BIT - 1:0] EX_tag = ID_EX_pc[31:2 + ENTRY_BIT];

    // 2 bit predcitor
    reg [1:0] current_counter;
    reg [1:0] next_counter;

    always @(*) begin
        val_table[EX_btb_idx] = val_table[EX_btb_idx];
        tag_table[EX_btb_idx] = tag_table[EX_btb_idx];
        btb_table[EX_btb_idx] = btb_table[EX_btb_idx];
        is_branch_table[EX_btb_idx] = is_branch_table[EX_btb_idx]
        is_flush = 1'b0;
        next_pc = current_pc + 4;

        if (ID_EX_is_jal) begin
            val_table[EX_btb_idx] = 1'b1;
            tag_table[EX_btb_idx] = EX_tag;
            btb_table[EX_btb_idx] = EX_pc_plus_imm;
            is_branch_table[EX_btb_idx] = 1'b0;

            if (IF_ID_pc != EX_pc_plus_imm)
                is_flush = 1'b1;
            else
                is_flush = 1'b0;
        end
        else if (ID_EX_is_branch) begin
            val_table[EX_btb_idx] = 1'b1;
            tag_table[EX_btb_idx] = EX_tag;
            btb_table[EX_btb_idx] = EX_pc_plus_imm;
            is_branch_table[EX_btb_idx] = 1'b1;

            if (EX_alu_bcond && (EX_pc_plus_imm != IF_ID_pc))
                is_flush = 1'b1;
            else if (!EX_alu_bcond && (IF_ID_pc != ID_EX_pc + 4))
                is_flush = 1'b1;
            else
                is_flush = 1'b0;
        end
        else if (ID_EX_is_jalr) begin
            val_table[EX_btb_idx] = 1'b1;
            tag_table[EX_btb_idx] = EX_tag;
            btb_table[EX_btb_idx] = EX_alu_result;
            is_branch_table[EX_btb_idx] = 1'b0;

            if (IF_ID_pc != EX_alu_result)
                is_flush = 1'b1;
            else
                is_flush = 1'b0;
        end
        else begin
            val_table[EX_btb_idx] = 0;
            tag_table[EX_btb_idx] = 0;
            btb_table[EX_btb_idx] = 0;
            is_branch_table[EX_btb_idx] = 0;

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
            if (tag_table[btb_idx] == tag && val_table[btb_idx] && (!is_branch_table[btb_idx] || current_counter > 2'b01)) begin
                next_pc = btb_table[btb_idx];
            end
            else begin
                next_pc = current_pc + 4;
            end
        end
    end

    // calculating states of saturation counter
    always @(*) begin
        next_counter = current_counter;
        if (ID_EX_is_branch) begin
            if (EX_alu_bcond) begin
                if (current_counter != 2'b11)
                    next_counter = current_counter + 1'b1;
                else
                    next_counter = current_counter;
            end
            else begin
                if (current_counter != 2'b00)
                    next_counter = current_counter - 1'b1;
                else
                    next_counter = current_counter;
            end
        end
        else begin
            next_counter = current_counter;
        end
    end

    // Initialize instruction memory (do not touch except path)
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < (2 << ENTRY_BIT); i = i + 1) begin
                val_table[i] <= 0;
                tag_table[i] <= 0;
                btb_table[i] <= 0;
                is_branch_table[i] <= 0;
                current_counter <= 2'b00;
            end
        end
        else begin
            current_counter = next_counter;
        end
    end
endmodule
