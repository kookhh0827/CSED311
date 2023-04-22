module ForwardingUnit (input[4:0] rs1_ex,              // input
                        input[4:0] rs2_ex,             // input
                        input[4:0] rd_mem,             // input 
                        input register_write_mem,      // input 
                        input[4:0] rd_wb,              // input
                        input register_write_wb,       // input
                        output reg [1:0] forward_rs1,  // output
                        output reg [1:0] forward_rs2); // output
    
    always @(*) begin
        if ((rs1_ex != 0) && (rs1_ex == rd_mem) && register_write_mem) begin
            forward_rs1 = 2'b01;
        end
        else if ((rs1_ex != 0) && (rs1_ex == rd_wb) && register_write_wb) begin
            forward_rs1 = 2'b10;
        end
        else begin
            forward_rs1 = 2'b00;
        end
    end

    always @(*) begin
        if ((rs2_ex != 0) && (rs2_ex == rd_mem) && register_write_mem) begin
            forward_rs2 = 2'b01;
        end
        else if ((rs2_ex != 0) && (rs2_ex == rd_wb) && register_write_wb) begin
            forward_rs2 = 2'b10;
        end
        else begin
            forward_rs2 = 2'b00;
        end
    end

endmodule