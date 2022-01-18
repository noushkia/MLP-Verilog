// Multiply and Accumulate

module MAC #(parameter n = 8) (
    input clk, clk_en, rst, ctrl_rst, use_bias, 
    input [n-1:0] bias,
    input signed [2*n-1:0] mult_result,
    output signed [3*n-4:0] sum_result
);
    wire signed [3*n-4:0] sum_result_registered, result_middle;

    Adder #(n) adder((use_bias ? bias : mult_result), sum_result_registered, sum_result);
    Register #(3*n-3) accumulate_reg(clk, clk_en, rst | ctrl_rst, sum_result, sum_result_registered);

endmodule
