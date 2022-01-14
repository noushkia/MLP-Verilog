module Multiplier #(parameter n = 1, m = 0) (
    input signed [n-1:0] in1, in2,
    output signed [n-1:0] result
);
    wire [2*n-1:0] out = in1 * in2;
	
	// Overflow?
    wire of_not = !(|out[2*n-1:n+m-1]) || (&out[2*n-1:n+m-1]);
    
	wire [n-1:0] of_o = (in1[n-1]^in2[n-1]) ? {1'b1,{n-1{1'b0}}}:{1'b0,{n-1{1'b1}}};
	
    assign result = !of_not ? of_o : out[n+m-1:m];

endmodule