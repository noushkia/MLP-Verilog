module MUX4to1 #(parameter n = 8) (
                input [n-1 : 0] in1, in2, in3, in4, 
                input [1:0] sel,
                output [n-1 : 0] out);
                
    assign out = sel == 2'd0 ? in1 :
                 sel == 2'd1 ? in2 :
                 sel == 2'd2 ? in3 :
                 sel == 2'd3 ? in4 :
                 496'dZ;

endmodule     