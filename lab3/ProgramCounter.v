module PC(input reset,
          input clk,
          input is_halted,
          input write_enable_pc,
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
        else if (is_halted && write_enable_pc) begin
            current_pc <= current_pc;
        end
        else begin
            current_pc <= next_pc;
        end
    end
endmodule
