module Multiplier #(parameter n = 8) (
    input signed [n-1:0] in1, //data
    in2, // weight
    output signed [2*n-1:0] result
);
    assign result = in1*in2;
endmodule
