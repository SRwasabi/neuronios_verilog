`include "../NPU_module/Core_NPU.v"
`timescale 1ns/100ps

module core_npu_tb;

    parameter layer = 2;
    parameter out_layer = 1;
    parameter in_qnt = 2;
    parameter tam = 16;

    wire [tam-1:0] npu_out;
    wire [$clog2(in_qnt):0] input_count;
    wire [$clog2(layer):0] input_count_out;
    wire [$clog2(in_qnt):0] addr_neuro_weight;
    wire [$clog2(layer):0] addr_neuro_weight_out;
    wire relu_en;

	reg [15:0] in1;
    reg [15:0] in2;
    reg [15:0] in3; // Bias input

    // {in3, in2, in1}
    reg [15:0] buffer_data [in_qnt:0];
    reg [15:0] data;
    reg [$clog2(in_qnt):0] addr_data;
    wire [15:0] weights_in;
    wire [15:0] weights_in_out;

    reg clk;
    reg rst;
    
    // FIXED: Expanded array sizes to account for the Bias (+1 source per neuron)
    reg [tam-1:0] RAM_weights [((in_qnt+1)*layer)-1:0];      // 6 elements: 5 down to 0
    reg [tam-1:0] RAM_weights_out [((layer+1)*out_layer)-1:0]; // 3 elements: 2 down to 0


    integer i;
    always @(posedge clk, posedge rst) begin
        // Concatenate the inputs into a single long vector
        if(relu_en || rst) begin
            buffer_data[0] <= in1;
            buffer_data[1] <= in2;
            buffer_data[2] <= in3; // Bias input
        end

        addr_data <= input_count;
        data <= buffer_data[addr_data]; // Start with in1
    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            in1 = 16'b0000000000000000;
            in2 = 16'b0000000000000000;
            in3 = 16'b0011110000000000;
        end
    end
        

Core_NPU #(
        .tam(tam),
        .layer(layer),
        .in_qnt(in_qnt),
        .out_layer(out_layer)
    ) Test_npu (
        .clk(clk),
        .rst(rst),
        .bus_input(data), 
        
        // FIXED: Flatten the array elements into a single long vector
        .bus_weights(weights_in),
        
        // FIXED: Flatten the output array elements as well
        .bus_weights_out(weights_in_out),
        
        .input_count(input_count),
        .input_count_out(input_count_out),
        .weight_count(addr_neuro_weight),
        .weight_count_out(addr_neuro_weight_out), 
        .relu_en(relu_en),
        .npu_out(npu_out)
    );

    initial begin 
        $dumpfile("../vcds/core_npu.vcd");
        $dumpvars(0, core_npu_tb);
        $display("teste");
        rst = 1;
        // FIXED: Replaced 2D indexing [x][y] with 1D indexing [z]
        RAM_weights[0] = 16'b0011100000000000; // entrada 1, neurônio 0
        RAM_weights[1] = 16'b1011100000000000; // entrada 1, neurônio 1
        
        RAM_weights[2] = 16'b1011110000000000; // entrada 2, neurônio 0
        RAM_weights[3] = 16'b0011100000000000; // entrada 2, neurônio 1

        RAM_weights[4] = 16'b1011100000000000; // BIAS, neurônio 0
        RAM_weights[5] = 16'b1011100000000000; // BIAS, neurônio 1
        
        RAM_weights_out[0] = 16'b0011100000000000; // entrada 1, neurônio de saída 0
        RAM_weights_out[1] = 16'b0011100000000000; // entrada 2, neurônio de saída 0
        RAM_weights_out[2] = 16'b1011100000000000; // BIAS, neurônio de saída 0

        #20 rst = 0; // Deassert reset after some time
        #300;
        $display("Time: %0t | in1: %b | in2: %b | npu_out: %b", $time, in1, in2, npu_out); 

        #5;
        in1 = 16'b0000000000000000; // Update in1 to 1.0
        in2 = 16'b0011110000000000; // Update in2 to 1.0
        #300;
        $display("Time: %0t | in1: %b | in2: %b | npu_out: %b", $time, in1, in2, npu_out); 

        #5;
        in1 = 16'b0011110000000000; // Update in1 to 1.0
        in2 = 16'b0011110000000000; // Update in2 to 1.0
        #300;
        $display("Time: %0t | in1: %b | in2: %b | npu_out: %b", $time, in1, in2, npu_out); 

        #5;
        in1 = 16'b0011110000000000; // Update in1 to 1.0
        in2 = 16'b0000000000000000; // Update in2 to 0.0
        #300;
        $display("Time: %0t | in1: %b | in2: %b | npu_out: %b", $time, in1, in2, npu_out); 

        $finish;
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock with a period of 10 time units
    end
    
	assign weights_in = RAM_weights[(input_count * layer) + addr_neuro_weight];
    assign weights_in_out = RAM_weights_out[(input_count_out * out_layer) + addr_neuro_weight_out];


endmodule