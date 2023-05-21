// Title         : vending_machine.v
// Author      : Jae-Eon Jo (Jojaeeon@postech.ac.kr) 
//			     Dongup Kwon (nankdu7@postech.ac.kr) (2015.03.30)
//			     Jaehun Ryu (jaehunryu@postech.ac.kr) (2021.03.07)

`include "vending_machine_def.v"


module vending_machine (
	clk,							// Clock signal
	reset_n,						// Reset signal (active-low)

	i_input_coin,				// coin is inserted.
	i_select_item,				// item is selected.
	i_trigger_return,			// change-return is triggered 

	o_available_item,			// Sign of the item availability
	o_output_item,			// Sign of the item withdrawal
	o_return_coin				// Sign of the coin return
);

	// Ports Declaration
	// Do not modify the module interface
	input clk;
	input reset_n;
	
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0] i_select_item;
	input i_trigger_return;
		
	output [`kNumItems-1:0] o_available_item;
	output [`kNumItems-1:0] o_output_item;
	output [`kNumCoins-1:0] o_return_coin;


	

	// Do not modify the values.
	wire [31:0] item_price [`kNumItems-1:0];	// Price of each item
	wire [31:0] coin_value [`kNumCoins-1:0];	// Value of each coin
	assign item_price[0] = 400;
	assign item_price[1] = 500;
	assign item_price[2] = 1000;
	assign item_price[3] = 2000;
	assign coin_value[0] = 100;
	assign coin_value[1] = 500;
	assign coin_value[2] = 1000;

	// Internal states. You may add your own net variables.
	wire [`kTotalBits-1:0] current_total;
	wire [`kTotalBits-1:0] current_output;
    wire [1:0] current_state;
    	
	// Next internal states. You may add your own net variables.
	wire [`kTotalBits-1:0] current_total_nxt;
	wire [`kTotalBits-1:0] current_output_nxt;
	wire [`kTotalBits-1:0] wait_time_nxt;
	wire [1:0] current_state_nxt;

	// Variables. You may add more your own net variables.
	wire [31:0] wait_time;


	// This module interface, structure, and given a number of modules are not mandatory but recommended.
	// However, Implementations that use modules are mandatory.
		
  	check_time_and_coin check_time_and_coin_module(
									.clk(clk),
									.reset_n(reset_n),
									.current_output(current_output),
                                    .current_state(current_state),
									.wait_time_nxt(wait_time_nxt),
									.wait_time(wait_time),
									.o_return_coin(o_return_coin));

	calculate_current_state calculate_current_state_module(.i_input_coin(i_input_coin),
										.i_select_item(i_select_item),
										.i_trigger_return(i_trigger_return),
										.item_price(item_price),
										.coin_value(coin_value),
										.current_total(current_total),
										.current_output(current_output),
										.current_state(current_state),
										.current_total_nxt(current_total_nxt),
										.current_output_nxt(current_output_nxt),
										.current_state_nxt(current_state_nxt),
										.wait_time(wait_time),
										.wait_time_nxt(wait_time_nxt),
										.o_available_item(o_available_item),
										.o_output_item(o_output_item));
	
  	change_state change_state_module(
						.clk(clk),
						.reset_n(reset_n),
						.current_total_nxt(current_total_nxt),
						.current_output_nxt(current_output_nxt),
                        .current_state_nxt(current_state_nxt),
						.current_total(current_total),
						.current_output(current_output),
                        .current_state(current_state));


endmodule
