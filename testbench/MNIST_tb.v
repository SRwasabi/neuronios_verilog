`include "../NPU_module/Core_NPU.v"
`timescale 1ns/100ps

module MNIST_tb;

    parameter layer = 100;
    parameter out_layer = 10;
    parameter in_qnt = 784;
    parameter tam = 16;

    wire [tam-1:0] npu_out;
    wire [$clog2(in_qnt):0] input_count;
    wire [$clog2(layer):0] input_count_out;
	// wire [$clog2(in_qnt):0] addr_neuro_weight;
   // wire [$clog2(layer):0] addr_neuro_weight_out;
    wire relu_en;

    reg [15:0] in1;
    reg [15:0] in2;
    reg [15:0] in3; // Bias input

    // {in3, in2, in1}
    reg [tam-1:0] buffer_data [in_qnt:0];
    reg [tam-1:0] data;
    reg [$clog2(in_qnt):0] addr_data;

    reg clk;
    reg rst;
    
    // FIXED: Expanded array sizes to account for the Bias (+1 source per neuron)
    
    initial begin
			$readmemh("../testbench/input_hex.txt", buffer_data);
			buffer_data[in_qnt] = 16'b0;
    end

    integer i;
    always @(posedge clk, posedge rst) begin
        addr_data <= input_count;
        data <= buffer_data[addr_data]; // Start with in1
    end


wire [3:0] current_state;



Core_NPU MNIST_tb (
    .clk(clk),
    .rst(rst),
    .bus_input(data), 
    .input_count(input_count),
    .input_count_out(input_count_out),
	 //.weight_count(addr_neuro_weight),
    //.weight_count_out(addr_neuro_weight_out), 
    .relu_en(relu_en),
	 //.current_state(current_state),
    .npu_out(npu_out)

);

    initial begin 
        $dumpfile("MNIST.vcd");
        $dumpvars(0, MNIST_tb);
        $display("teste");
        rst = 1;
	     #20 rst = 0; // Deassert reset after some time
        #10000;
        $display("| npu_out: %b", npu_out); 
        $finish;
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock with a period of 10 time units
    end
    


endmodule