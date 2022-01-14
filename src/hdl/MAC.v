// Multiply and Accumulate

module MAC #(parameter n = 1, m = 0) (
    input clk, clk_en, rst, ctrl_rst, use_bias, 
    input [n-1:0] bias,
    input signed [n-1:0] data,
    input signed [n-1:0] weight,
    output signed [n-1:0] sum_result
);

    wire signed [n-1:0] mult_result, sum_result_registered;

    Multiplier #(n, m) multiplier(data, weight, mult_result);
    Adder #(n, m) adder((use_bias ? bias : mult_result), sum_result_registered, sum_result);
    Register #(n) accumulate_reg(clk, clk_en, rst | ctrl_rst, sum_result, sum_result_registered);

endmodule
