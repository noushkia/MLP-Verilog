module MUX6to1 #(parameter n = 8) (
                input [n-1 : 0] in1, in2, in3, in4, in5, in6, 
                input [2:0] sel,
                output [n-1 : 0] out);
                
    assign out = sel == 3'd0 ? in1 :
                 sel == 3'd1 ? in2 :
                 sel == 3'd2 ? in3 :
                 sel == 3'd3 ? in4 :
                 sel == 3'd4 ? in5 :
                 sel == 3'd5 ? in6 :
                 496'dZ;

endmodule     