module MLPController #(parameter n = 8, number_of_test_cases = 750, clog2_number_of_test_cases = 10)(
    input start,
    input clk,
    input rst,
    input [clog2_number_of_test_cases - 1 : 0] addr_cnt,
    output reg [2 : 0] curr_layer,
    output reg [32 - 1 : 0] ld_en,
    output reg inc_addr,
    output reg done,
    output reg init
);
    reg [2 : 0] ps, ns;

    parameter [2:0] IDLE = 3'd0, H1 = 3'd1, H2 = 3'd2, H3 = 3'd3, H4 = 3'd4, O1 = 3'd5, O2 = 3'd6, DONE = 3'd7;
	
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
            H3: ns <= H4;
            H4: ns <= O1;
            O1: ns <= O2;
            O2: ns <= (addr_cnt < number_of_test_cases-1) ? H1 : DONE;
            DONE: ns <= IDLE;
        endcase
    end

    always @(ps) begin
        {curr_layer, inc_addr, done, init} = 5'd0;
        ld_en = 32'd0;

        case(ps)
            IDLE: init = 1'b1;
            H1: {curr_layer, ld_en} = {3'd0, 24'd0, 8'b11111111};
            H2: {curr_layer, ld_en} = {3'd1, 16'd0, 8'b11111111, 8'd0};
            H3: {curr_layer, ld_en} = {3'd2, 8'd0, 8'b11111111, 16'd0};
            H4: {curr_layer, ld_en} = {3'd3, 8'b11111111, 24'd0};
            O1: {curr_layer, ld_en} = {3'd4, 24'd0, 8'b11111111};
            O2: {curr_layer, inc_addr, ld_en} = {3'd5, 1'b1, 16'd0, 8'b00000011, 8'd0};
            DONE: done = 1'b1;
        endcase
    end

endmodule