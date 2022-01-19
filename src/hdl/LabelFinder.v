// Finds respective labels of given numbers
// Uses one hot vector
module LabelFinder #(parameter n = 8, number_of_labels = 10, clog2_number_of_labels = 4, size_of_output_layer = 10) (
    input [n*size_of_output_layer-1:0] numbers, // Predicted Probabilities
    output reg [clog2_number_of_labels-1:0] label// Final labels
);
    reg [clog2_number_of_labels-1:0] max_prob_idx;
    reg [n-1:0] max_prob;

    // Find the most probable number for each label
    integer i;
    always @(numbers) begin
        max_prob = 'd0;
        max_prob_idx = 'd0;
        for(i = 0; i < number_of_labels; i = i + 1)
            if(max_prob < numbers[n*i +: n-1]) begin
                max_prob = numbers[n*i +: n-1];
                max_prob_idx = i;
            end
        
        // $display("Most prob value = %d", max_prob_idx);
        label = max_prob_idx;
    end

endmodule
