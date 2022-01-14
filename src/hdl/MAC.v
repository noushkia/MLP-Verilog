// Multiply and Accumulate

module MAC(
    a,
    w,
    out
);
    input [62 * 8 - 1 : 0] a, w;
    
    //a[0]: a[7 : 0]  
    //      a[15 : 8]
    //      a[]
    output [20 : 0] out;  

    reg [20 : 0] negs ;
    reg [20 : 0] pos ;
	integer i;
	always @(a, w) begin
		negs = 21'b0;
        pos = 21'b0;
		for (i = 0 ; i < 62 ; i = i + 1)
		begin
			if (a[8 * i + 7] ^ w[8 * i + 7] == 1'b1) //negative
            begin
				negs = negs + a[8 * i +: 7] * w[8 * i +: 7];
                //$display("i = %d, neg: %d %d    ", i, a[8 * i +: 7], w[8 * i +: 7]);
            end
			else
            begin
				pos = pos + a[8 * i +: 7] * w[8 * i +: 7];  
                //$display("i = %d, pos %d %d", i, a[8 * i +: 7], w[8 * i +: 7]);      
            end
		end
	end

    wire [19 : 0] pn, np;
    assign pn = pos - negs;
    assign np = negs - pos;
    assign out = (pos > negs) ? {1'b0, pn} : {1'b1, np};

endmodule
