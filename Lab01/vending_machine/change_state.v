`include "vending_machine_def.v"


module change_state(clk,reset_n,current_total_nxt,current_output_nxt,current_state_nxt,current_total,current_output,current_state);

	input clk;
	input reset_n;
	input [`kTotalBits-1:0] current_total_nxt,current_output_nxt;
	input [1:0] current_state_nxt;
	output reg [`kTotalBits-1:0] current_total,current_output;
	output reg [1:0] current_state;
	
	// Sequential circuit to reset or update the states
	always @(posedge clk ) begin
		if (!reset_n) begin
			// TODO: reset all states.
			current_total <= 0;
			current_output <= 0;
			current_state <= 0;
		end
		else begin
			// TODO: update all states.
			current_total <= current_total_nxt;
			current_output <= current_output_nxt;
			current_state <= current_state_nxt;
		end
	end
endmodule 