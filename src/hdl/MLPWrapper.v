module MLPWrapper #(parameter
    n = 8,                    //4(bits of data)*4(convert hex to bin)
    m = 6,
    number_of_inputs = 62,
    size_of_hidden_layer = 30, // 30 neurons on hidden layer
    size_of_output_layer = 10, // 10 neurons on output layer
    number_of_test_cases = 750,
    clog2_number_of_inputs = 6,
    clog2_size_of_hidden_layer = 5,
    clog2_size_of_output_layer = 4,
    clog2_number_of_test_cases = 10
) (
    input clk, clk_en, rst,
    output [clog2_size_of_output_layer-1:0] label, 
    output ready
);

    reg cnt_en;
    reg [number_of_inputs*n-1:0] data[0:number_of_test_cases-1];
    wire [clog2_number_of_test_cases-1:0] counter_out;

    initial $readmemh("../src/Input and Parameters/fixed_te_data_sm.dat", data, 0, number_of_test_cases-1);

    MLP #(
        n,
        m,
        number_of_inputs,
        size_of_hidden_layer,
        size_of_output_layer,
        clog2_number_of_inputs,
        clog2_size_of_hidden_layer,
        clog2_size_of_output_layer
    ) mlp(clk, clk_en, rst, data[counter_out], label, ready);

    Counter #(clog2_number_of_test_cases) counter(clk, clk_en & cnt_en, rst, counter_out);

    always @(*)
        if(rst)
            cnt_en = 0;
        else if(ready)
            cnt_en = 1;
        else
            cnt_en = 0;

endmodule