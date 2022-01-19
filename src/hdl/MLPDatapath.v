module MLPDatapath #(parameter
    n = 8,
    input_size = 8,
    number_of_inputs = 62,
    size_of_hidden_layer = 30,
    size_of_output_layer = 10,
    clog2_number_of_inputs = 6,
    clog2_size_of_hidden_layer = 5,
    clog2_size_of_output_layer = 4
) (
    input clk,    // Clock
    input rst,  // Asynchronous reset
    input [2:0] curr_layer, // Current Layer
    input [number_of_inputs*n-1:0] data, // Input data
    input [size_of_hidden_layer + 1 : 0] ld_en, // load hidden result i
    output [clog2_size_of_output_layer-1:0] label  // between 0 and 9
);
    //-----------------------Bias Memory-----------------------//
    reg [n-1:0] hidden_layers_bias[0:size_of_hidden_layer+1];
    reg [n-1:0] output_layers_bias[0:input_size*2-1];

    //-----------------------Weight Memory-----------------------//
    reg [n*number_of_inputs-1:0] hidden_layers_weights[0:size_of_hidden_layer+1];
    reg [n*size_of_hidden_layer-1:0] output_layers_weights[0:input_size*2-1];

    //-----------------------Layers Results-----------------------//
    wire [n - 1 : 0] neuron_result [0 : input_size - 1];
    wire [size_of_hidden_layer * n - 1 : 0] registered_hidden_layer_results;

    //-----------------------Other Wires-----------------------//
    wire [number_of_inputs*n - 1 : 0] selected_input [0 : input_size - 1]; //Inputs for PUs
    wire [number_of_inputs*n - 1 : 0] selected_weight[0 : input_size - 1];
    wire [n - 1 : 0] selected_bias  [0 : input_size - 1];
    wire [n - 1 : 0] hidden_layer_result [0 : size_of_hidden_layer + 1];


    // Get hidden layer bias and weight
    initial $readmemh("../src/Input and Parameters/fixed_b1_sm.dat", hidden_layers_bias, 0, size_of_hidden_layer+1);
    initial $readmemh("../src/Input and Parameters/fixed_w1_sm.dat", hidden_layers_weights, 0, size_of_hidden_layer+1);

    // Get output layer bias and weight
    initial $readmemh("../src/Input and Parameters/fixed_b2_sm.dat", output_layers_bias, 0, input_size*2-1);
    initial $readmemh("../src/Input and Parameters/fixed_w2_sm.dat", output_layers_weights, 0, input_size*2-1);

    //-----------------------Select Data, Bias and Weight-----------------------//
    genvar i;
    generate
        for (i = 0 ; i < input_size; i = i + 1) begin: get_datas
            //------Get Data------//
            assign selected_input[i] = (curr_layer <= 3'd3) ? data : { 256'd0, registered_hidden_layer_results};

            //------Get Weights------//
            MUX6to1 #(n*number_of_inputs) weight_mux(
                .in1(hidden_layers_weights[i]),
                .in2(hidden_layers_weights[i+input_size]),
                .in3(hidden_layers_weights[i+input_size*2]),
                .in4(hidden_layers_weights[i+input_size*3]),
                .in5({256'd0, output_layers_weights[i]}),
                .in6({256'd0, output_layers_weights[i+input_size]}),
                .sel(curr_layer),
                .out(selected_weight[i])
            );

            //------Get Bias------//
            MUX6to1 #(n) bias_mux(
                .in1(hidden_layers_bias[i]),
                .in2(hidden_layers_bias[i+input_size]),
                .in3(hidden_layers_bias[i+input_size*2]),
                .in4(hidden_layers_bias[i+input_size*3]),
                .in5(output_layers_bias[i]),
                .in6(output_layers_bias[i+input_size]),
                .sel(curr_layer),
                .out(selected_bias[i])
            );            
        end
    endgenerate

    //-----------------------Feed Neurons-----------------------//
    generate
        for (i = 0 ; i < input_size ; i = i + 1) begin
            PU #(n, number_of_inputs) hidden_pu( 
                .bias(selected_bias[i]),
                .weights(selected_weight[i]),
                .data(selected_input[i]),
                .result(neuron_result[i])
            );
        end

    endgenerate 

    //-----------------------Write Data-----------------------//
    generate
        for (i = 0 ; i < 8; i = i + 1) begin
            Register #(n) reg_1(
                .clk(clk),
                .ld(ld_en[i]),
                .rst(rst),
                .in(neuron_result[i]),
                .out(hidden_layer_result[i])
            );

            Register #(n) reg_2(
                .clk(clk),
                .ld(ld_en[i+8]),
                .rst(rst),
                .in(neuron_result[i]),
                .out(hidden_layer_result[i+8])
            );

            Register #(n) reg_3(
                .clk(clk),
                .ld(ld_en[i+16]),
                .rst(rst),
                .in(neuron_result[i]),
                .out(hidden_layer_result[i+16])
            );

            Register #(n) reg_4(
                .clk(clk),
                .ld(ld_en[i+24]),
                .rst(rst),
                .in(neuron_result[i]),
                .out(hidden_layer_result[i+24])
            );
        end
    endgenerate 

    assign registered_hidden_layer_results = {hidden_layer_result[0], hidden_layer_result[1], hidden_layer_result[2], 
                                              hidden_layer_result[3], hidden_layer_result[4], hidden_layer_result[5], 
                                              hidden_layer_result[6], hidden_layer_result[7], hidden_layer_result[8], 
                                              hidden_layer_result[9], hidden_layer_result[10], hidden_layer_result[11], 
                                              hidden_layer_result[12], hidden_layer_result[13], hidden_layer_result[14], 
                                              hidden_layer_result[15], hidden_layer_result[16], hidden_layer_result[17], 
                                              hidden_layer_result[18], hidden_layer_result[19], hidden_layer_result[20], 
                                              hidden_layer_result[21], hidden_layer_result[22], hidden_layer_result[23], 
                                              hidden_layer_result[24], hidden_layer_result[25], hidden_layer_result[26], 
                                              hidden_layer_result[27], hidden_layer_result[28], hidden_layer_result[29]};

    //--------------------------------------Softmax Layer-------------------------------------//
    LabelFinder #(n, size_of_output_layer, clog2_size_of_output_layer, size_of_output_layer) label_finder(
                            .numbers({
                                    neuron_result[1], neuron_result[0], hidden_layer_result[7], 
                                    hidden_layer_result[6], hidden_layer_result[5], hidden_layer_result[4], 
                                    hidden_layer_result[3], hidden_layer_result[2], hidden_layer_result[1], 
                                    hidden_layer_result[0]
                                    }),
                            .label(label)
                            );

endmodule
