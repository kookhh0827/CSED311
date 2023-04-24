module HaltChecker(input reset,
                   input clk,
                   input [31:0] x17,
                   input is_ecall,
                   output reg is_halted);
    
    always @(posedge clk) begin
        if (reset) begin
            is_halted <= 0;
        end
        else begin
            if (is_ecall && x17 == 10) begin
                is_halted <= 1;
            end
            else begin
                is_halted <= is_halted;
            end
        end
    end
endmodule

