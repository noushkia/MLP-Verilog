module PU #(parameter n = 8, number_of_input = 62, clog2_number_of_input = 6) (
    input clk,    // Clock
    input clk_en, // Clock Enable
    input rst,    // reset
    input [number_of_input*n-1:0] datas,
    input [number_of_input*n-1:0] weights,
    input [n-1:0] bias,
    output signed [n-1:0] result,
    output ready // Result is ready
);

    wire [clog2_number_of_input-1:0] addr;
    wire ctrl_rst, ready_mid, use_bias;
    wire signed [n-1:0] data, weight, result_middle; //8bit inputs
    wire signed [2*n-1:0] mult_result; // 16bit multiplier output
    wire signed [3*n-4:0] sum_result, sum_result_registered, relu_result; // 21bit MAC output

    // Controller for Neuron
	NeuronController #(number_of_input, clog2_number_of_input) ctrl(clk, clk_en, rst, ready_mid, ctrl_rst, use_bias, addr);
    Register #(1) ready_reg(clk, clk_en, rst, ready_mid, ready);

    // Select the input for MAC unit
    InputSelector #(n, number_of_input, clog2_number_of_input) input_selector(addr, datas, weights, data, weight);
    
    // Apply multiplications and accumulations
    Multiplier #(n) multiplier(data, weight, mult_result); //16bits
    Adder #(n) adder((use_bias ? bias : mult_result), sum_result_registered, sum_result); //21bits
    Register #(3*n-3) accumulate_reg(clk, clk_en, rst | ctrl_rst, sum_result, sum_result_registered); //21bits

    // Apply function on mac result
	ReLU #(3*n-3) relu_activation(sum_result, relu_result);
    assign result_middle = (relu_result > 'd127) ? {1'b0, 7'd127} : {1'b0, relu_result[n-2:0]};
    // Write on result register
    Register #(n) result_reg(clk, clk_en & ready_mid, rst, result_middle, result);
	
endmodule
