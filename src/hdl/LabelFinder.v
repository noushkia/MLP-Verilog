// Finds respective labels of given numbers
// Uses one hot vector
module LabelFinder #(parameter n = 8, number_of_labels = 10, clog2_number_of_labels = 4) (
    input [number_of_labels*n-1:0] numbers, // Predicted Probabilities
    output reg [clog2_number_of_labels-1:0] label // Final labels
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

//     wire [7 : 0] n0 = in[7 : 0];
//     wire [7 : 0] n1 = in[15 : 8];
//     wire [7 : 0] n2 = in[23 : 16];
//     wire [7 : 0] n3 = in[31 : 24];
//     wire [7 : 0] n4 = in[39 : 32];
//     wire [7 : 0] n5 = in[47 : 40];
//     wire [7 : 0] n6 = in[55 : 48];
//     wire [7 : 0] n7 = in[63 : 56];
//     wire [7 : 0] n8 = in[71 : 64];
//     wire [7 : 0] n9 = in[79 : 72];

    
//     always @(*) begin
//         if (n1 >= n0 && n1 >= n2 && n1 >= n3 && n1 >= n4 && n1 >= n5 && n1 >= n6 && n1 >= n7 && n1 >= n8 && n1 >= n9)
//             max = 4'b0001;
//         else
//         if (n0 >= n1 && n0 >= n2 && n0 >= n3 && n0 >= n4 && n0 >= n5 && n0 >= n6 && n0 >= n7 && n0 >= n8 && n0 >= n9)
//             max = 4'b0000;
//         else
//         if (n2 >= n0 && n2 >= n1 && n2 >= n3 && n2 >= n4 && n2 >= n5 && n2 >= n6 && n2 >= n7 && n2 >= n8 && n2 >= n9)
//             max = 4'b0010;
//         else

//         if (n3 >= n0 && n3 >= n1 && n3 >= n2 && n3 >= n4 && n3 >= n5 && n3 >= n6 && n3 >= n7 && n3 >= n8 && n3 >= n9)
//             max = 4'b0011;
//         else

//         if (n4 >= n0 && n4 >= n1 && n4 >= n2 && n4 >= n3 && n4 >= n5 && n4 >= n6 && n4 >= n7 && n4 >= n8 && n4 >= n9)
//             max = 4'b0100;

//         else
//         if (n5 >= n0 && n5 >= n1 && n5 >= n2 && n5 >= n3 && n5 >= n4 && n5 >= n6 && n5 >= n7 && n5 >= n8 && n5 >= n9)
//             max = 4'b0101;

//         else
//         if (n6 >= n0 && n6 >= n1 && n6 >= n2 && n6 >= n3 && n6 >= n4 && n6 >= n5 && n6 >= n7 && n6 >= n8 && n6 >= n9)
//             max = 4'b0110;

//         else
//         if (n7 >= n0 && n7 >= n1 && n7 >= n2 && n7 >= n3 && n7 >= n4 && n7 >= n5 && n7 >= n6 && n7 >= n8 && n7 >= n9)
//             max = 4'b0111;

//         else
//         if (n8 >= n0 && n8 >= n1 && n8 >= n2 && n8 >= n3 && n8 >= n4 && n8 >= n5 && n8 >= n6 && n8 >= n7 && n8 >= n9)
//             max = 4'b1000;

//         else
//         if (n9 >= n0 && n9 >= n1 && n9 >= n2 && n9 >= n3 && n9 >= n4 && n9 >= n5 && n9 >= n6 && n9 >= n7 && n9 >= n8)
//             max = 4'b1001;
//     end

// endmodule
