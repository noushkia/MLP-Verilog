// Finds respective labels of given numbers
// Uses one hot vector
module LabelFinder #(parameter n = 2, number_of_labels = 1, clog2_number_of_labels = 1) (
    input [number_of_labels*n-1:0] numbers, // Predicted Results
    output reg [clog2_number_of_labels-1:0] label
);

    reg [number_of_labels-1:0] is_ge[0:number_of_labels-1];
    wire [number_of_labels-1:0] is_ge_all;

    // Find the most probable number for each label
    integer i, j, k;
    always @(numbers) begin
        for(i = 0; i < number_of_labels; i = i + 1)
            for(j = 0; j < number_of_labels; j = j + 1)
                is_ge[i][j] = numbers[n*i+n-1-:n] >= numbers[n*j+n-1-:n];
    end

    // Set the most probable label
    genvar v;
    generate
        for(v = 0; v < number_of_labels; v = v + 1) begin : compressor
            assign is_ge_all[v] = &is_ge[v];
        end
    endgenerate

    // Get the label
    always @(*) begin
        label = 'd0;
        for(k =  number_of_labels - 1; k >= 0; k = k - 1)
            if(is_ge_all[k])
                label = k[clog2_number_of_labels-1:0];
    end

endmodule
