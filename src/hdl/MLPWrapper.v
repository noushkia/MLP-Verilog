module MLPWrapper #(parameter
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
    input clk,                                          // Clock
    input rst,                                          // Asynchronous reset
    input [2:0] curr_layer,                             // Current Layer
    input inc_addr,                                     // Increment address count
    input [size_of_hidden_layer + 1 : 0] ld_en,         // load hidden result i
    output [clog2_number_of_test_cases-1 : 0] addr_cnt,
    output [clog2_number_of_test_cases-1 : 0] correct   // number of correct predictions
);
    // Check if label prediction was correct
    reg eq;

    // wire [number_of_inputs*n-1:0] data, // Input data
    wire [clog2_size_of_output_layer-1:0] label; // between 0 and 9

    //---------------------------Data Memory---------------------------//
    reg [number_of_inputs*n-1:0] data [0:number_of_test_cases-1];

    //---------------------------Label Memory---------------------------//
    reg [clog2_size_of_output_layer-1:0] labels [0:number_of_test_cases-1];


    initial begin
       $readmemh("../src/Input and Parameters/fixed_te_data_sm.dat", data, 0, number_of_test_cases-1);
       $readmemh("../src/Input and Parameters/te_label_sm.dat", labels, 0, number_of_test_cases-1);
    end

    //---------------------------MLP Unit---------------------------//
    MLPDatapath #(
        n,
        input_size,
        number_of_inputs,
        size_of_hidden_layer,
        size_of_output_layer,
        clog2_number_of_inputs,
        clog2_size_of_hidden_layer,
        clog2_size_of_output_layer
    ) mlp(
        .clk(clk),
        .rst(rst),
        .curr_layer(curr_layer),
        .data(data[addr_cnt]),
        .ld_en(ld_en),
        .label(label)
    );


    //---------------------------Update Address---------------------------//
    Counter  #(10) addr_cnter (
        .clk(clk),
        .clk_en(inc_addr),
        .rst(rst),
        .count(addr_cnt)
    );

    assign eq = label == labels[addr_cnt];
    always @(addr_cnt, eq) begin
        $display("Index[%d]:\t\tHDL = %d\tReal = %d", addr_cnt, label, labels[addr_cnt]);
    end

    //---------------------------MLP Unit---------------------------//
    Counter  #(10) acc_cnter(
        .clk(clk),
        .clk_en(eq && (curr_layer == 3'd5)),
        .rst(rst),
        .count(correct)
    );

endmodule
