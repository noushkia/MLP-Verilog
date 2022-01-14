`default_nettype none
module InputSelector #(parameter n = 1, number_of_input = 2, clog2_number_of_input = 1) (
    input [clog2_number_of_input-1:0] addr,
    input [number_of_input*n-1:0] datas,
    input [number_of_input*n-1:0] weights,
    output signed [n-1:0] data, weight
);
    assign data = datas[addr*n+n-1-:n];
    assign weight = weights[addr*n+n-1-:n];

endmodule