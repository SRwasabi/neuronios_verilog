`include "treino_2.v"

`timescale 1ns/100ps
`define tam 16

module epoca_teste;

reg clk;
reg reset;
reg [3:0][(`tam-1):0] in1_tb; //  0101
reg [3:0][(`tam-1):0] in2_tb; // 0011
reg [3:0][(`tam-1):0] d_tb;  // or -> 0111
reg [(`tam-1):0] u_tb; //  Taxa de Aprendizado
wire [3:0][(`tam-1):0] result_tb; 
reg[(`tam-1):0] w0, w1, w2;// pesos entrada
wire [(`tam-1):0] w0_in, w1_in, w2_in;// pesos entrada
//wire [(`tam-1):0] w0_out, w1_out, w2_out; // pesos saida

epoca_2 teste_epoca (.in1(in1_tb), .in2(in2_tb), .d(d_tb), .u(u_tb), .result(result_tb), 
.w0(w0_in), .w1(w1_in), .w2(w2_in),
.reset(reset), .clk(clk)
);

assign w0_in = (teste_epoca.direction == 0) ? w0 : 16'bz;
assign w1_in = (teste_epoca.direction == 0) ? w1 : 16'bz;
assign w2_in = (teste_epoca.direction == 0) ? w2 : 16'bz;

initial begin
    // Inicializando os pesos
    w0 = 16'b0011110000000000;
    w1 = 16'b0011110000000000;
    w2 = 16'b0011110000000000;
end
/*
assign w0_in = 16'b0011110000000000;
assign w1_in = 16'b0011110000000000;
assign w2_in = 16'b0011110000000000;
*/
initial begin
    $dumpfile("epoca.vcd");
    $dumpvars(0);
    // in1 0101
    
    reset = 1; 

    in1_tb[0] = 16'b0;
    in1_tb[1] = 16'b0011110000000000;
    in1_tb[2] = 16'b0;
    in1_tb[3] = 16'b0011110000000000;

    // in2 0011
    in2_tb[0] = 16'b0;
    in2_tb[1] = 16'b0;
    in2_tb[2] = 16'b0011110000000000;
    in2_tb[3] = 16'b0011110000000000;
    // d 0111 (and gate)
    d_tb[0] = 16'b0;
    d_tb[1] = 16'b0;
    d_tb[2] = 16'b0;
    d_tb[3] = 16'b0011110000000000;

    u_tb = 16'b0011100000000000;
    
    $display("Pesos atual: %b %b %b\n", w0_in, w1_in, w2_in);
    #10; reset = 0;
    
    $display("Resultado esperado: %b %b %b %b", d_tb[0], d_tb[1], d_tb[2], d_tb[3]);
    $display("Resultado obitido: %b %b %b %b", result_tb[0], result_tb[1], result_tb[2], result_tb[3]);
    $display("Pesos obitido: %b %b %b", w0_in, w1_in, w2_in);
    #60;
    $finish;
end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

endmodule