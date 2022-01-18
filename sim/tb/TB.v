`timescale 1ns/1ns

module TB();
    parameter
        n = 8,
        input_size = 10,
        number_of_inputs = 62,
        size_of_hidden_layer = 30,
        size_of_output_layer = 10,
        number_of_test_cases = 750,
        clog2_number_of_inputs = 6,
        clog2_size_of_hidden_layer = 5,
        clog2_size_of_output_layer = 4,
        clog2_number_of_test_cases = 10;

    reg clk, rst, start;
    wire done;
    wire [9 : 0] accuracy;

    MLP #(
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
        ) mlp(
            .clk(clk), .rst(rst), .start(start),
            .done(done),
            .accuracy(accuracy)
        );

    initial begin
        rst = 1'b1;
        start = 1'b0;
        clk = 0;
        #30
        rst = 1'b0;
        start = 1'b1;
        repeat(10000)
            #15 clk = ~clk;
        start = 1'b0;
        #1000
        $stop;
    end

endmodule