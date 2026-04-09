`include "mlp_mnist.v"
`timescale 1ns/100ps
`define layer 2
`define out_layer 1
`define in_qnt 2
`define tam 16

module core_npu_tb;

// Mem
reg [(`in_qnt):0][(`tam)-1:0] full_data;
reg [(`tam)-1:0] RAM_weights [0:`in_qnt][0:`layer-1];
reg [(`tam)-1:0] RAM_weights_out [0:`layer][0:`out_layer-1];
reg [(`tam-1):0] d;


//==============================================================================
// Testbench for Core_NPU
//==============================================================================

reg clk;
reg rst;
wire [(`tam-1):0] weights_in;
wire [(`tam-1):0] weights_in_out;
wire [(`tam-1):0] data;
wire [$clog2(`in_qnt):0] addr_count;
wire [$clog2(`layer):0]addr_out_count;
wire [$clog2(`in_qnt):0] input_count;
wire [$clog2(`layer):0] input_count_out;
wire [(`tam-1):0] npu_out;

    Core_NPU # (
        .tam(`tam), 
        .layer(`layer), 
        .out_layer(`out_layer), 
        .in_qnt(`in_qnt)) 
    core_npu_unit (
        .clk(clk), 
        .rst(rst), 
        .bus_input(data), 
        .bus_weights(weights_in), 
        .bus_weights_out(weights_in_out), 

        .addr_neuro_weight(addr_count),
        .addr_neuro_weight_out(addr_out_count),
        .input_count(input_count),
        .input_count_out(input_count_out),

        .npu_out(npu_out)
    );

    variable_mux #(
        .tam(`tam), 
        .in_qnt(`in_qnt)) 
    variable_mux_data (
        .in( full_data), 
        .sel(input_count), 
        .out(data)
    );

    integer f, i;


initial begin
    $dumpfile("Core_NPU.vcd");
    $dumpvars(0);
    //$monitor("ram_weights: %b | ram_weights_out: %b", core_npu_unit.ram_weights, core_npu_unit.ram_weights_out);
    $monitor("Time: %0t | addr_count: %b | addr_out_count: %b | input_count: %b | input_count_out: %b | npu_out: %b", $time, addr_count, addr_out_count, input_count, input_count_out, npu_out);
    //$monitor("Weights_internal: %b ", core_npu_unit.bus_weights_internal);

    rst = 1;
    #20;
    rst = 0;

    full_data[0] = 16'b0011110000000000;
    full_data[1] = 16'b0011110000000000;
    full_data[2] = 16'b0011110000000000;

    RAM_weights[0][0] = 16'b0011100000000000; // entrada 1, neurônio 0
    RAM_weights[0][1] = 16'b1011100000000000; // entrada 1, neurônio 1
    
    RAM_weights[1][0] = 16'b1011110000000000; // entrada 2, neurônio 0
    RAM_weights[1][1] = 16'b0011100000000000; // entrada 2, neurônio 1

    RAM_weights[2][0] = 16'b1011100000000000; // BIAS, neurônio 0
    RAM_weights[2][1] = 16'b1011100000000000; // BIAS, neurônio 1

    RAM_weights_out[0][0] = 16'b0011100000000000; // entrada 1, neurônio de saída 0
    RAM_weights_out[1][0] = 16'b0011100000000000;  // entrada 2, neurônio de saída 0
    RAM_weights_out[2][0] = 16'b1011100000000000;  // BIAS, neurônio de saída 0

    d = 16'b0;

    #300;
    $finish;
end


initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

assign weights_in = RAM_weights[input_count][addr_count];
assign weights_in_out = RAM_weights_out[input_count_out][addr_out_count];

endmodule