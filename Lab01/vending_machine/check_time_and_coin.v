`include "vending_machine_def.v"
	

module check_time_and_coin(clk,reset_n,current_output,current_state,wait_time_nxt,wait_time,o_return_coin);
	input clk;
	input reset_n;
	input [`kTotalBits-1:0] current_output;
	input [1:0] current_state;
	input  [`kTotalBits-1:0] wait_time_nxt;
	output reg  [`kNumCoins-1:0] o_return_coin;
	output reg [31:0] wait_time;
	
	localparam STATE_INIT = 2'b00, STATE_IDLE = 2'b01, STATE_OUTPUT = 2'b10, STATE_RETURN = 2'b11;
   
    
	// initiate values
	initial begin
		// TODO: initiate values
		o_return_coin = 0;
		wait_time = `kWaitTime;
	end

	always @(*) begin
		// TODO: o_return_coin
		o_return_coin = 0;
        if (current_state == STATE_RETURN)
            o_return_coin = current_output;
        else
            o_return_coin = 0;
	end

	always @(posedge clk ) begin
	   if (!reset_n) begin
		// TODO: reset all states.
		  o_return_coin <= 0;
		  wait_time <= `kWaitTime;
		end
		else begin
		// TODO: update all states.
		  wait_time <= wait_time_nxt;
		end
	end
endmodule 