`include "opcodes.v"
`include "alu_opcodes.v"

module PC(input	reset,
          input clk,
          input [31:0] next_pc, // next pc state
          output reg [31:0] current_pc); // current pc state
    
    // Todo
    // update PC at every clock cycle
    // Initialize current pc state
    always @(posedge clk) begin
        // Reset current_pc
        if (reset) begin
            current_pc <= 0;
        end
        else begin
            current_pc <= next_pc;
        end
    end
endmodule
