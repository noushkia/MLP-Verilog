module Counter #(parameter n = 1) (
    input clk,    // Clock
    input clk_en, // Clock Enable
    input rst,    // reset
    output [n-1:0] count
);
    
    wire [n-1:0] next_value;
    Register #(n) Count(clk, clk_en, rst, next_count, count);
    assign next_count = count + 1'b1;

endmodule