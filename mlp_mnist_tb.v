`include "mlp_mnist.v"
`timescale 1ns/100ps
`define tam 16
`define data_size 4

/*
module mac_tb;
reg clk;
reg rst;
reg [(`tam-1):0] in;
reg [(`tam-1):0] weight;
reg [(`tam-1):0] d_out;
wire [(`tam-1):0] out;

MAC #(.tam(`tam)) mac0 (.data_in(in), .initial_weight(weight), .clk(clk), .rst(rst), .mac_out(out));

initial begin
    //$dumpfile("mac_mlp_tb.vcd");
    //$dumpvars(0);
    rst = 1;
    #1;
    in = 16'b0100000000000000;
    weight = 16'b0011100000000000;
    d_out = 16'b0011110000000000;
    #6;
    rst = 0;

    $display("esperado: %b\nobtido: %b", d_out, out);
    $finish;
end

initial begin
    clk = 0;
    forever #5 clk = ~clk; 
end

endmodule
*/

//===============================================================

module PE_tb;
reg [`tam-1:0] in;
reg [`tam-1:0] bias;
reg [`data_size-1:0][`tam-1:0] weights;
reg clk;
reg rst;
reg [`tam-1:0] d_acc;
wire [`tam-1:0] acc;

PE # (.tam(`tam), .data_size(`data_size)) PE0 (.bus_in(in), .bias(bias), .initial_weight(weights), .clk(clk), .rst(rst), .acc_out(acc));

initial begin
    $dumpfile("pe_mlp_tb.vcd");
    $dumpvars(0);
    rst = 1;
    in = 16'b0011110000000000;
    weights[0] = 16'b0011110000000000;
    weights[1] = 16'b0100000000000000;
    weights[2] = 16'b0100001000000000;
    weights[3] = 16'b0100010000000000;
    bias = 16'b0;
    d_acc = 16'b0100100100000000;
    #5;
    rst = 0;

    $monitor("Obtido: %b\n", acc);
    #200;
    $display("Esperado: %b\n", d_acc);
    $finish;
end

initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

endmodule