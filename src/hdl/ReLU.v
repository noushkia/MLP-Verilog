// ReLU activation function
// Output is zero id input is negative, otherwise it's identical
module ReLU #(parameter n = 8) (
    input [n-1:0] in,
    output [n-1:0] out
);

    assign out = in[n-1] ? 'd0 : in;

endmodule
