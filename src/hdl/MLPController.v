module MLPController #(parameter n = 8, number_of_test_cases = 750)(
    input start,
    input clk,
    input rst,
    input [9 : 0] addr_cnt,
    output reg [1 : 0] curr_layer,
    output reg [30 - 1 : 0] ld_en,
    output reg inc_addr,
    output reg done,
    output reg init
);
    reg [2 : 0] ps, ns;

    parameter [2:0] IDLE = 3'd0, H1 = 3'd1, H2 = 3'd2, H3 = 3'd3, O1 = 3'd4, DONE = 3'd5;
	
	always @(posedge clk, posedge rst)
    begin
        if (rst)
            ps <= IDLE;
        else
            ps <= ns;
    end
	
    always @(ps or addr_cnt or start) begin
        case(ps)
            IDLE: ns <= start ? H1 : IDLE; 
            H1: ns <= H2;
            H2: ns <= H3;
            H3: ns <= O1;
            O1: ns <= (addr_cnt < number_of_test_cases-1) ? H1 : DONE;
            DONE: ns <= IDLE;
        endcase
    end

    always @(ps) begin
        {curr_layer, inc_addr, done, init} = 5'd0;
        ld_en = 30'd0;

        case(ps)
            IDLE: init = 1'b1;
            H1: {curr_layer, ld_en} = {2'd0, 20'd0, 10'b1111111111};
            H2: {curr_layer, ld_en} = {2'd1, 10'd0, 10'b1111111111, 10'd0};
            H3: {curr_layer, ld_en} = {2'd2, 10'b1111111111, 20'd0};
            O1: {curr_layer, inc_addr} = {2'd3, 1'b1};
            DONE: done = 1'b1;
        endcase
    end

endmodule