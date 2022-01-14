`timescale 1ns/1ns

module TB();
    parameter
        n = 16,
        m = 6,
        number_of_inputs = 62,
        size_of_hidden_layer = 30,
        size_of_output_layer = 10,
        number_of_test_cases = 750,
        clog2_number_of_inputs = 6,
        clog2_size_of_hidden_layer = 5,
        clog2_size_of_output_layer = 4,
        clog2_number_of_test_cases = 10,
        full = 1,
        layers_log = 0, // Enable for logging
        verbose = 1;

    reg clk, clk_en, rst;
    wire [clog2_size_of_output_layer-1:0] label;
    wire ready; 
    MLPWrapper #(
        n,
        m,
        number_of_inputs,
        size_of_hidden_layer,
        size_of_output_layer,
        number_of_test_cases,
        clog2_number_of_inputs,
        clog2_size_of_hidden_layer,
        clog2_size_of_output_layer,
        clog2_number_of_test_cases
    ) mlp_wrapper(clk, clk_en, rst, label, ready);

    initial begin
        clk = 0;
        rst = 1;
        clk_en = 1;
        #170 rst = 0;
    end
    always #50 clk = ~clk;

    integer i, j, fd, rv, wrong;
    integer labels[0:number_of_test_cases-1];
    initial begin
        fd = $fopen("../src/Input and Parameters/te_label_sm.dat","r");
        for(i = 0; i < (full ? number_of_test_cases : 1); i = i + 1) begin
            rv = $fscanf(fd, "%d,", labels[i]);
        end
        $fclose(fd);
        wrong = 0;
    end
    always @(posedge mlp_wrapper.mlp.hidden_layer_ready && mlp_wrapper.mlp.state == 0) begin : Hidden_Layer
        if(layers_log) begin
            $display("Hidden Layer");
            $display("\t%1d: 'h%h", 0, mlp_wrapper.mlp.hidden_layer[0].neuron.result);
            $display("\t%1d: 'h%h", 1, mlp_wrapper.mlp.hidden_layer[1].neuron.result);
            $display("\t%1d: 'h%h", 2, mlp_wrapper.mlp.hidden_layer[2].neuron.result);
            $display("\t%1d: 'h%h", 3, mlp_wrapper.mlp.hidden_layer[3].neuron.result);
            $display("\t%1d: 'h%h", 4, mlp_wrapper.mlp.hidden_layer[4].neuron.result);
            $display("\t%1d: 'h%h", 5, mlp_wrapper.mlp.hidden_layer[5].neuron.result);
            $display("\t%1d: 'h%h", 6, mlp_wrapper.mlp.hidden_layer[6].neuron.result);
            $display("\t%1d: 'h%h", 7, mlp_wrapper.mlp.hidden_layer[7].neuron.result);
            $display("\t%1d: 'h%h", 8, mlp_wrapper.mlp.hidden_layer[8].neuron.result);
            $display("\t%1d: 'h%h", 9, mlp_wrapper.mlp.hidden_layer[9].neuron.result);
            $display("\t%1d: 'h%h", 10, mlp_wrapper.mlp.hidden_layer[10].neuron.result);
            $display("\t%1d: 'h%h", 11, mlp_wrapper.mlp.hidden_layer[11].neuron.result);
            $display("\t%1d: 'h%h", 12, mlp_wrapper.mlp.hidden_layer[12].neuron.result);
            $display("\t%1d: 'h%h", 13, mlp_wrapper.mlp.hidden_layer[13].neuron.result);
            $display("\t%1d: 'h%h", 14, mlp_wrapper.mlp.hidden_layer[14].neuron.result);
            $display("\t%1d: 'h%h", 15, mlp_wrapper.mlp.hidden_layer[15].neuron.result);
            $display("\t%1d: 'h%h", 16, mlp_wrapper.mlp.hidden_layer[16].neuron.result);
            $display("\t%1d: 'h%h", 17, mlp_wrapper.mlp.hidden_layer[17].neuron.result);
            $display("\t%1d: 'h%h", 18, mlp_wrapper.mlp.hidden_layer[18].neuron.result);
            $display("\t%1d: 'h%h", 19, mlp_wrapper.mlp.hidden_layer[19].neuron.result);
            $display("\t%1d: 'h%h", 20, mlp_wrapper.mlp.hidden_layer[20].neuron.result);
            $display("\t%1d: 'h%h", 21, mlp_wrapper.mlp.hidden_layer[21].neuron.result);
            $display("\t%1d: 'h%h", 22, mlp_wrapper.mlp.hidden_layer[22].neuron.result);
            $display("\t%1d: 'h%h", 23, mlp_wrapper.mlp.hidden_layer[23].neuron.result);
            $display("\t%1d: 'h%h", 24, mlp_wrapper.mlp.hidden_layer[24].neuron.result);
            $display("\t%1d: 'h%h", 25, mlp_wrapper.mlp.hidden_layer[25].neuron.result);
            $display("\t%1d: 'h%h", 26, mlp_wrapper.mlp.hidden_layer[26].neuron.result);
            $display("\t%1d: 'h%h", 27, mlp_wrapper.mlp.hidden_layer[27].neuron.result);
            $display("\t%1d: 'h%h", 28, mlp_wrapper.mlp.hidden_layer[28].neuron.result);
            $display("\t%1d: 'h%h", 29, mlp_wrapper.mlp.hidden_layer[29].neuron.result);
        end
    end
    always @(posedge ready) begin : Output_Layer
        if(layers_log) begin
            $display("Output Layer");
            for(i = 0; i < size_of_output_layer; i = i + 1)
                $display("\t%1d: 'h%h", i, mlp_wrapper.mlp.label_finder.numbers[n*i+n-1-:n]);
        end

        // Prediction Result
        if(mlp_wrapper.mlp.label != labels[mlp_wrapper.counter.count]) begin // Wrong
            $display(
                "\tHDL = %1d\tReal = %1d\n",
                mlp_wrapper.mlp.label,
                labels[mlp_wrapper.counter.count]
            );
            wrong = wrong + 1;
        end
        else if(verbose && mlp_wrapper.mlp.label == labels[mlp_wrapper.counter.count]) // Correct
            $display(
                "\tHDL = %1d\tReal = %1d",
                mlp_wrapper.mlp.label,
                labels[mlp_wrapper.counter.count]
            );

        if(mlp_wrapper.counter.count == (full ? number_of_test_cases : 0)) begin
            if(full) begin
                $display("_________________________________");
                $display("\tACR = %.2f %%", (10000 - 10000 * wrong / number_of_test_cases) / 100);
            end
            #150 $stop;
        end
    end
    
    initial $dumpvars;
    initial #10000000 $stop;
endmodule