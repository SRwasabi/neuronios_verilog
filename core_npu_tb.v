`include "mlp_mnist.v"
`timescale 1ns/100ps
`define layer 2
`define out_layer 1
`define in_qnt 2
`define tam 16

module core_npu_tb;
// Mem
reg [(`in_qnt):0][(`tam)-1:0] full_data;
reg [(`in_qnt):0][(`layer)-1:0][(`tam)-1:0] full_weights;
reg [(`layer):0][(`out_layer)-1:0][(`tam)-1:0] full_weights_hidden_out;

//==============================================================================
// Testbench for Core_NPU
//==============================================================================
reg clk;
reg rst;
reg [(`out_layer-1):0][(`tam-1):0] d;

wire [(`layer-1):0][(`tam-1):0] weights_in;
wire [(`out_layer-1):0][(`tam-1):0] weights_hidden_out;
wire [(`tam-1):0] data;
wire [(`out_layer-1):0][(`tam-1):0] npu_out;
wire [$clog2((`in_qnt)):0] count;
wire [$clog2((`layer)):0] hidden_count;

    Core_NPU # (.tam(`tam), .layer(`layer), .out_layer(`out_layer), .in_qnt(`in_qnt)) core_npu_unit (
        .clk(clk), 
        .rst(rst), 
        .bus_input(data), 
        .bus_weights(weights_in), 
        .bus_weights_out(weights_hidden_out), 
        .npu_out(npu_out),
        .count(count),
        .hidden_count(hidden_count)
    );

    variable_mux # (.tam(`tam), .in_qnt(`in_qnt))
    data_mux (
        .in(full_data),
        .sel(count),
        .out(data)
    );

    variable_mux_3d # (.tam(`tam), .in_qnt(`in_qnt), .layer(`layer))
    weights_mux (
        .in(full_weights),
        .sel(count),
        .out(weights_in)
    );

    variable_mux_3d # (.tam(`tam), .in_qnt(`in_qnt), .layer(`out_layer))
    weights_out_mux (
        .in(full_weights_hidden_out),
        .sel(hidden_count),
        .out(weights_hidden_out)
    );

initial begin
    $dumpfile("Core_NPU.vcd");
    $dumpvars(0);
    $monitor("Primeira: %b, Saída: %b", core_npu_unit.atv_wire , npu_out);

    rst = 1;
    #10;
    rst = 0;

    full_data[0] = 16'b0;
    full_data[1] = 16'b0;
    full_data[2] = 16'b0011110000000000;

    full_weights[0][0] = 16'b0011100000000000; // entrada 1, neurônio 0
    full_weights[0][1] = 16'b1011100000000000; // entrada 1, neurônio 1
    
    full_weights[1][0] = 16'b1011110000000000; // entrada 2, neurônio 0
    full_weights[1][1] = 16'b0011100000000000; // entrada 2, neurônio 1

    full_weights[2][0] = 16'b1011100000000000; // BIAS, neurônio 0
    full_weights[2][1] = 16'b1011100000000000; // BIAS, neurônio 1

    full_weights_hidden_out[0][0] = 16'b0011100000000000; // entrada 1, neurônio de saída 0
    full_weights_hidden_out[1][0] = 16'b0011100000000000;  // entrada 2, neurônio de saída 0
    full_weights_hidden_out[2][0] = 16'b1011100000000000;  // BIAS, neurônio de saída 0

    d = 16'b0;

    #100;
    $finish;
end


initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


endmodule