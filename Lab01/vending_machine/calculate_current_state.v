
`include "vending_machine_def.v"

module calculate_current_state(i_input_coin,i_select_item,i_trigger_return,item_price,coin_value,current_total,current_output,current_state,
current_total_nxt,current_output_nxt,current_state_nxt,wait_time,wait_time_nxt,o_available_item,o_output_item);

	
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
	input i_trigger_return;		
	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];	
	input [`kTotalBits-1:0] current_total;
	input [`kTotalBits-1:0] current_output;
	input [1:0] current_state;
	input [31:0] wait_time;
	output reg [`kNumItems-1:0] o_available_item,o_output_item;
	output reg  [`kTotalBits-1:0] current_total_nxt, current_output_nxt, wait_time_nxt;
	output reg [1:0] current_state_nxt;
	integer i;	

    localparam STATE_INIT = 2'b00, STATE_IDLE = 2'b01, STATE_OUTPUT = 2'b10, STATE_RETURN = 2'b11;

	
	// Combinational logic for the next states
	always @(*) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).
		// Calculate the next current_total state.
		current_total_nxt = current_total;
		current_output_nxt = 0;
		current_state_nxt = current_state;
		wait_time_nxt = wait_time;
		
		case(current_state)
		  STATE_INIT: begin
		      if (i_input_coin) begin
		          for(i = 0; i < `kNumCoins; i = i + 1)
		              current_total_nxt = current_total_nxt + i_input_coin[i] * coin_value[i];
		          for(i = 0; i < `kNumItems; i = i + 1)
		              current_output_nxt[i] = (current_total_nxt >= item_price[i]) ? 1'b1 : 1'b0;
		          current_state_nxt = STATE_IDLE;
		          wait_time_nxt = `kWaitTime;
		      end
		      else begin
		          current_total_nxt = 0;
                  current_output_nxt = 0;
                  current_state_nxt = STATE_INIT;
                  wait_time_nxt = `kWaitTime;
		      end
		  end
		  STATE_IDLE: begin
		      if (i_input_coin) begin
		          for(i = 0; i < `kNumCoins; i = i + 1)
		              current_total_nxt = current_total_nxt + i_input_coin[i] * coin_value[i];
		          for(i = 0; i < `kNumItems; i = i + 1)
		              current_output_nxt[i] = (current_total_nxt >= item_price[i]) ? 1'b1 : 1'b0;
		          current_state_nxt = STATE_IDLE;
		          wait_time_nxt = `kWaitTime;
		      end
		      else if (i_select_item) begin
		          for(i = 0; i < `kNumItems; i = i + 1)
		              current_total_nxt = current_total_nxt - i_select_item[i] * item_price[i];
		          if($signed(current_total_nxt) >= 0) begin
		              current_output_nxt = i_select_item;
		              current_state_nxt = STATE_OUTPUT;
		              wait_time_nxt = `kWaitTime;
		          end
		          else begin
		              if (wait_time == 1 || i_trigger_return) begin
		                  current_total_nxt = current_total;
		                  current_output_nxt = 0;
		                  current_state_nxt = STATE_RETURN;
		                  wait_time_nxt = 0;
		              end
		              else begin
		                  current_total_nxt = current_total;
		                  current_output_nxt = current_output;
		                  current_state_nxt = current_state;
		                  wait_time_nxt = wait_time - 1;
		              end
		          end
		      end
		      else begin
		          if (wait_time == 1 || i_trigger_return) begin
                      current_total_nxt = current_total;
                      current_output_nxt = 0;
                      current_state_nxt = STATE_RETURN;
                      wait_time_nxt = 0;
                  end
                  else begin
                      current_total_nxt = current_total;
                      current_output_nxt = current_output;
                      current_state_nxt = current_state;
                      wait_time_nxt = wait_time - 1;
                  end
		      end
		  end
		  STATE_OUTPUT: begin
		      if (i_input_coin) begin
		          for(i = 0; i < `kNumCoins; i = i + 1)
		              current_total_nxt = current_total_nxt + i_input_coin[i] * coin_value[i];
		          for(i = 0; i < `kNumItems; i = i + 1)
		              current_output_nxt[i] = (current_total_nxt >= item_price[i]) ? 1'b1 : 1'b0;
		          current_state_nxt = STATE_IDLE;
		          wait_time_nxt = `kWaitTime;
		      end
		      else if (i_select_item) begin
		          for(i = 0; i < `kNumItems; i = i + 1)
		              current_total_nxt = current_total_nxt - i_select_item[i] * item_price[i];
		          if($signed(current_total_nxt) >= 0) begin
		              current_output_nxt = i_select_item;
		              current_state_nxt = STATE_OUTPUT;
		              wait_time_nxt = `kWaitTime;
		          end
		          else begin
		              current_total_nxt = current_total;
		              for(i = 0; i < `kNumItems; i = i + 1)
		                  current_output_nxt[i] = (current_total_nxt >= item_price[i]) ? 1'b1 : 1'b0;
		              current_state_nxt = STATE_IDLE;
		              wait_time_nxt = wait_time - 1;
		          end
		      end
		      else if (i_trigger_return) begin
		          current_total_nxt = current_total;
                  current_output_nxt = 0;
                  current_state_nxt = STATE_RETURN;
                  wait_time_nxt = 0;
		      end
		      else begin
		          current_total_nxt = current_total;
                  for(i = 0; i < `kNumItems; i = i + 1)
		              current_output_nxt[i] = (current_total_nxt >= item_price[i]) ? 1'b1 : 1'b0;
                  current_state_nxt = STATE_IDLE;
                  wait_time_nxt = wait_time - 1;
		      end
		  end
		  STATE_RETURN: begin
		      if (current_total > 0) begin
		          for(i = `kNumCoins; i > 0; i = i - 1) begin
		              if (current_total_nxt >= coin_value[i-1]) begin
		                  current_total_nxt = current_total_nxt - coin_value[i-1];
		                  current_output_nxt[i-1] = 1'b1;
		              end
		              else begin
		                  current_total_nxt = current_total_nxt;
		                  current_output_nxt[i-1] = 1'b0;
		              end
		          end 
		          current_state_nxt = STATE_RETURN;
		          wait_time_nxt = 0;
		      end
		      else begin
		          current_total_nxt = 0;
		          current_output_nxt = 0;
		          current_state_nxt = STATE_INIT;
		          wait_time_nxt = `kWaitTime;
		      end
		  end
		  default: begin
		      current_total_nxt = current_total;
              current_output_nxt = current_output;
              current_state_nxt = current_state;
              wait_time_nxt = wait_time;
		  end
		endcase
	end

	
	
	// Combinational logic for the outputs
	always @(*) begin
		// TODO: o_available_item
		// TODO: o_output_item
		o_available_item = 0;
		o_output_item = 0;
        case(current_state)
		  STATE_IDLE: begin
		      o_available_item = current_output;
		      o_output_item = 0;
		  end
		  STATE_OUTPUT: begin
		      o_available_item = 0;
		      o_output_item = current_output;
		  end
		  default: begin
		      o_available_item = 0;
		      o_output_item = 0;
		  end
	   endcase
	end
 
	


endmodule 