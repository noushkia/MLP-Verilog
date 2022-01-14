`default_nettype none
module MLP #(parameter
    n = 16,
    m = 6,
    number_of_inputs = 62,
    size_of_hidden_layer = 20,
    size_of_output_layer = 10,
    clog2_number_of_inputs = 6,
    clog2_size_of_hidden_layer = 5,
    clog2_size_of_output_layer = 4
) (
    input clk,    // Clock
    input clk_en, // Clock Enable
    input rst,  // Asynchronous reset
    input [number_of_inputs*n-1:0] data,
    output [clog2_size_of_output_layer-1:0] label,  // between 0 and 9
    output ready
);
    reg [n-1:0] hidden_layers_bias[0:size_of_hidden_layer-1], output_layers_bias[0:size_of_output_layer-1];
    reg [n*number_of_inputs-1:0] hidden_layers_weights[0:size_of_hidden_layer-1];
    reg [n*size_of_hidden_layer-1:0] output_layers_weights[0:size_of_output_layer-1];
    wire [size_of_hidden_layer-1:0] hidden_layer_readies;
    wire [size_of_output_layer-1:0] output_layer_readies;
    wire hidden_layer_ready, output_layer_ready;
    wire hidden_layer_rst, output_layer_rst;
    wire [size_of_hidden_layer*n-1:0] hidden_layer_results;
    wire [size_of_output_layer*n-1:0] output_layer_results;
    reg [1:0] state;
    assign hidden_layer_ready = &hidden_layer_readies;
    assign output_layer_ready = &output_layer_readies;
    assign ready = state == 2'd2;
    assign hidden_layer_rst = state == 2'd2;
    assign output_layer_rst = state == 2'd0;

    initial $readmemh("hex_data/output_layers_bias.hex", output_layers_bias, 0, size_of_output_layer-1);
    initial $readmemh("hex_data/output_layers_weights.hex", output_layers_weights, 0, size_of_output_layer-1);
    initial $readmemh("hex_data/hidden_layers_bias.hex", hidden_layers_bias, 0, size_of_hidden_layer-1);
    initial $readmemh("hex_data/hidden_layers_weights.hex", hidden_layers_weights, 0, size_of_hidden_layer-1);

    genvar i;
    generate
        for(i = 0; i < size_of_hidden_layer; i = i + 1) begin : hidden_layer
            Neuron #(n, m, number_of_inputs, clog2_number_of_inputs) neuron(
                clk,
                clk_en,
                rst | hidden_layer_rst ,
                data,
                hidden_layers_weights[i],
                hidden_layers_bias[i],
                hidden_layer_results[n*i+n-1-:n],
                hidden_layer_readies[i]
            );
        end
    endgenerate
    generate
        for(i = 0; i < size_of_output_layer; i = i + 1) begin : output_layer
            Neuron #(n, m, size_of_hidden_layer, clog2_size_of_hidden_layer) neuron(
                clk,
                clk_en,
                rst | output_layer_rst ,
                hidden_layer_results,
                output_layers_weights[i],
                output_layers_bias[i],
                output_layer_results[n*i+n-1-:n],
                output_layer_readies[i]
            );
        end
    endgenerate
    always @(posedge clk)
        if(rst) begin
            state <= 2'd0;
        end
        else if(clk_en) begin
            if(hidden_layer_ready & state == 2'd0)
                state <= 2'd1;
            else if(output_layer_ready & state == 2'd1)
                state <= 2'd2;
            else if(state == 2'd2)
                state <= 2'd0;
        end
    LabelFinder #(n, size_of_output_layer, clog2_size_of_output_layer) label_finer (output_layer_results, label);
endmodule