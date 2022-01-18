module Adder #(parameter n = 8) (
    input signed [2*n-1:0] in1,
    input signed [3*n-4:0]in2,
    output signed [3*n-4:0] result
);

    wire [n:0] out = in1 + in2;
	
	// Overflow?
    wire of = !(in1[n-1]^in2[n-1]) ? out[n] ^ in1[n-1] : 1'b0;
	
    assign result = of ? {in1[n-1],{n-1{!in1[n-1]}}}:out[n-1:0];

endmodule
