module PU #(parameter n = 8, number_of_inputs = 62) (
    input [n-1 : 0] bias,
    input [number_of_inputs * n - 1 : 0] weights,
    input [number_of_inputs * n - 1 : 0] data,
    output [n-1 : 0] result
);
    wire [3*n-4 : 0] mac_result, shifted_sum, relu_result;
    reg [3*n-4 : 0] sum_result;
    
    //----------------------------MAC Unit----------------------------//
    MAC mac_62(.data(data), .weights(weights), .result(mac_result));

    //----------------------------Bias Sum----------------------------//   
    always @(bias, mac_result) begin : apply_bias
        if (bias[n-1] ^ mac_result[3*n-4]) begin
            if (mac_result[19 : 0] > bias[6 : 0]* 7'd127)
                sum_result = {~bias[n-1], mac_result[19 : 0] - bias[6 : 0] * 7'd127};
            else
                sum_result = {bias[n-1], bias[6 : 0] * 7'd127 - mac_result[19 : 0]};
        end
        else begin
            sum_result = {bias[n-1], bias[6 : 0] * 7'd127 + mac_result[19 : 0]};
        end
    end 

    //----------------------------Shift Sum----------------------------//
    assign shifted_sum = {sum_result[3*n-4], 9'd0, sum_result[19 : 9]}; // Keep the sign bit!

    //----------------------------ReLU Function------------------------//
    ReLU #(3*n-3) relu(.in(shifted_sum), .out(relu_result));

    //----------------------------Saturation------------------------//
    assign result = (relu_result > 21'd127) ? {1'b0, 7'd127} : {1'b0, relu_result[n-2 : 0]};
endmodule
