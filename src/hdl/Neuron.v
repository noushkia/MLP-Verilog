module Neuron #(parameter n = 1, m = 0, number_of_input = 2, clog2_number_of_input = 1) (
    input clk,    // Clock
    input clk_en, // Clock Enable
    input rst,    // reset
    input [number_of_input*n-1:0] datas,
    input [number_of_input*n-1:0] weights,
    input [n-1:0] bias,
    output signed [n-1:0] result,
    output ready
);

    wire [clog2_number_of_input-1:0] addr; // Adder Tree
    wire ctrl_rst;
    wire ready_mid;
    wire use_bias;
    wire signed [n-1:0] data, weight, mult_result, sum_result, sum_result_registered, result_middle;

	NeuronController #(number_of_input, clog2_number_of_input) ctrl(clk, clk_en, rst, ready_mid, ctrl_rst, use_bias, addr);
    Reg #(1) ready_reg(clk, clk_en, rst, ready_mid, ready);


    InputSelector #(n, number_of_input, clog2_number_of_input) input_selector(addr, datas, weights, data, weight);
	
    Multiplier #(n, m) multiplier(data, weight, mult_result);
    Adder #(n, m) adder((use_bias ? bias : mult_result), sum_result_registered, sum_result);
    Reg #(n) accumulate_reg(clk, clk_en, rst | ctrl_rst, sum_result, sum_result_registered);
    
	ReLU #(n, m) relu_activation(sum_result, result_middle);
    Reg #(n) result_reg(clk, clk_en & ready_mid, rst, result_middle, result);
    
	
endmodule