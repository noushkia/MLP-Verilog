module Register #(parameter n = 8) (
    input clk, // Clock
    input ld, // Load
    input rst, // Reset
    input [n-1:0] in, //Input
    output reg [n-1:0] out //Output
);

    always@(posedge clk) begin
      if(rst)
        out <= 'd0;
      else if(ld)
        out <= in;
    end

endmodule