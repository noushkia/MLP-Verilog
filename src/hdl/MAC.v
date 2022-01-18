module MAC #(parameter n = 8, number_of_inputs = 62) (
    input [number_of_inputs * n - 1 : 0] data, weights,
    output [3*n-4 : 0] result
);
    reg [3*n-4 : 0] neg_muls;
    reg [3*n-4 : 0] pos_muls;
    
	integer i;
	always @(data, weights) begin
		neg_muls = 'd0;
        pos_muls = 'd0;
		for (i = 0; i < number_of_inputs ; i = i + 1) begin
			if (data[n * i + n-1] ^ weights[n * i + n-1] == 1'b1) //negative
				neg_muls = neg_muls + data[n * i +: n-1] * weights[n * i +: n-1];
			else
				pos_muls = pos_muls + data[n * i +: n-1] * weights[n * i +: n-1];     
		end
	end

   assign result = (pos_muls > neg_muls) ? {1'b0, pos_muls[3*n-5 : 0] - neg_muls[3*n-5 : 0]} : {1'b1, neg_muls[3*n-5 : 0] - pos_muls[3*n-5 : 0]};

endmodule
