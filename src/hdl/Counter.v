module Counter #(parameter n = 8) (
    input clk,    // Clock
    input clk_en, // Clock Enable
    input rst,    // reset
    output reg [n-1:0] count
);
    
    always @(posedge clk, posedge rst) begin
        if (rst)
            count <= 'd0;        
        else if (clk_en)
            count <= count + 1;
    end

endmodule