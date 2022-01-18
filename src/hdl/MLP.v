module MLP #(parameter
    n = 8,
    input_size = 10,
    number_of_inputs = 62,
    size_of_hidden_layer = 30,
    size_of_output_layer = 10,
    clog2_number_of_inputs = 6,
    clog2_size_of_hidden_layer = 5,
    clog2_size_of_output_layer = 4,
    number_of_test_cases = 750,
    clog2_number_of_test_cases = 10 
) (
    input clk, rst, start,
    output done,
    output [9 : 0] accuracy
);

    wire [clog2_number_of_test_cases-1 : 0] correct;
    wire [size_of_hidden_layer - 1 : 0] ld_en;
    wire inc_addr, init;
    wire [1:0] curr_layer;
    wire [9 : 0] addr_cnt;

    MLPController #(n, number_of_test_cases) controller(
        .start(start),
        .clk(clk),
        .rst(rst),
        .addr_cnt(addr_cnt),
        .ld_en(ld_en),
        .curr_layer(curr_layer),
        .inc_addr(inc_addr),
        .done(done),
        .init(init)
        );
        
    MLPWrapper #(
        n,
        input_size,
        number_of_inputs,
        size_of_hidden_layer,
        size_of_output_layer,
        clog2_number_of_inputs,
        clog2_size_of_hidden_layer,
        clog2_size_of_output_layer,
        number_of_test_cases,
        clog2_number_of_test_cases 
    ) datapath(
        .clk(clk),
        .rst(rst | init),
        .curr_layer(curr_layer),
        .ld_en(ld_en),
        .inc_addr(inc_addr),
        .addr_cnt(addr_cnt),
        .correct(correct)
    );

    assign accuracy = (100 * correct / number_of_test_cases);

endmodule
