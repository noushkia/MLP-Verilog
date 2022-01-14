// Check if the unit is finished
// Reset if finished
// Find the next address to calculate mac
module NeuronController #(parameter number_of_input = 2, clog2_number_of_input = 1) (
    input clk,    // Clock
    input clk_en, // Clock Enable
    input rst,    // reset
    output ready,
    output ctrl_rst,
    output use_bias,
    output [clog2_number_of_input-1:0] addr
);

    wire carry;
    wire [clog2_number_of_input-1:0] middle_addr;
	
	assign ctrl_rst = {carry, middle_addr} == number_of_input;
	
    Counter #(clog2_number_of_input + 1) counter(clk, clk_en, rst | ctrl_rst, {carry, middle_addr});
	
    assign ready = {carry, middle_addr} == number_of_input;
    assign use_bias = {carry, middle_addr} == number_of_input;
    assign addr = use_bias ? {clog2_number_of_input{1'b0}} : middle_addr;
endmodule