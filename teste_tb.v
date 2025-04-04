`include "teste.v"

`timescale 1ns/100ps
`define tam 16

module teste;

reg [3:0][(`tam-1):0] in1_tb;
reg [3:0][(`tam-1):0] in2_tb;
reg [3:0][(`tam-1):0] d_tb;
wire [3:0] result_tb;
reg [(`tam-1):0]  w0_tb;
reg [(`tam-1):0]  w1_tb;
reg [(`tam-1):0]  w2_tb;

teste teste1 (.in1(in1_tb), .in2(in2_tb), .d(d_tb), .result(result_tb), .w0(w0_tb), .w1(w1_tb), .w2(w2_tb));

initial begin
    $dumpfile("teste.vcd");
    $dumpvars(0);
    // in1 0101
    in1_tb[0] = 16'b0;
    in1_tb[1] = 16'b0011110000000000;
    in1_tb[2] = 16'b0;
    in1_tb[3] = 16'b0011110000000000;

    // in2 0011
    in2_tb[0] = 16'b0;
    in2_tb[1] = 16'b0;
    in2_tb[2] = 16'b0011110000000000;
    in2_tb[3] = 16'b0011110000000000;
    // d 0111 (or gate)
    d_tb[0] = 16'b0;
    d_tb[1] = 16'b0011110000000000;
    d_tb[2] = 16'b0011110000000000;
    d_tb[3] = 16'b0011110000000000;

    w0_tb = 16'b0011101001100110;
    w1_tb = 16'b0011101001100110;
    w2_tb = 16'b0011101001100110;
    $display("Resultado esperado: %b %b %b %b", d_tb[0], d_tb[1], d_tb[2], d_tb[3]);
    $display("Resultado obitido: %b %b %b %b", result_tb[0], result_tb[1], result_tb[2], result_tb[3]);
    
    #20;
    $finish;
end

endmodule