`include "teste.v"

`timescale 1ns/100ps
`define tam 16

module teste_tb;

// FPU
reg [3:0][(`tam-1):0] in1_tb;
reg [3:0][(`tam-1):0] in2_tb;
reg [3:0][(`tam-1):0] d_tb;
wire [3:0][(`tam-1):0] result_tb;
reg [(`tam-1):0]  w0_tb;
reg [(`tam-1):0]  w1_tb;
reg [(`tam-1):0]  w2_tb;

//FXP
reg [3:0][(`tam-1):0] int_in1_tb;
reg [3:0][(`tam-1):0] int_in2_tb;
reg [3:0][(`tam-1):0] int_d_tb;
wire [3:0][(`tam-1):0]  int_result_tb;
reg [(`tam-1):0]  int_w0_tb;
reg [(`tam-1):0]  int_w1_tb;
reg [(`tam-1):0]  int_w2_tb;

real start_time_fpu, end_time_fpu;
real start_time_fpx, end_time_fpx;


teste teste1 (.in1(in1_tb), .in2(in2_tb), .result(result_tb), .w0(w0_tb), .w1(w1_tb), .w2(w2_tb));
int_teste int_teste1 (.in1(int_in1_tb), .in2(int_in2_tb), .result(int_result_tb), .w0(int_w0_tb), .w1(int_w1_tb), .w2(int_w2_tb));

always@(w0_tb or w1_tb or w2_tb) begin
    start_time_fpu = $realtime;
end

always@(int_w0_tb or int_w1_tb or int_w2_tb) begin
    start_time_fpx = $realtime;
end

always@(result_tb) begin
    end_time_fpu = $realtime;
end

always @(int_result_tb) begin
    end_time_fpx = $realtime;
    
end

initial begin
    $dumpfile("teste.vcd");
    $dumpvars(0);
    // in1 0101
    in1_tb[0] = 16'b0;
    in1_tb[1] = 16'b0011110000000000;
    in1_tb[2] = 16'b0;
    in1_tb[3] = 16'b0011110000000000;

    int_in1_tb[0] = 16'b0;
    int_in1_tb[1] = 16'b0_001_000000000000;
    int_in1_tb[2] = 16'b0;
    int_in1_tb[3] = 16'b0_001_000000000000;

    // in2 0011
    in2_tb[0] = 16'b0;
    in2_tb[1] = 16'b0;
    in2_tb[2] = 16'b0011110000000000;
    in2_tb[3] = 16'b0011110000000000;

    int_in2_tb[0] = 16'b0;
    int_in2_tb[1] = 16'b0;
    int_in2_tb[2] = 16'b0_001_000000000000;
    int_in2_tb[3] = 16'b0_001_000000000000;
    //==================================================================
    //Porta OR
    d_tb[0] = 16'b0;
    d_tb[1] = 16'b0011110000000000;
    d_tb[2] = 16'b0011110000000000;
    d_tb[3] = 16'b0011110000000000;

    int_d_tb[0] = 16'b0;
    int_d_tb[1] = 16'b0_001_000000000000;
    int_d_tb[2] = 16'b0_001_000000000000;
    int_d_tb[3] = 16'b0_001_000000000000;

    w0_tb = 16'b1011100000000000;
    w1_tb = 16'b0011100000000000;
    w2_tb = 16'b0011100000000000;

    int_w0_tb = 16'b1_000_100000000000;
    int_w1_tb = 16'b0_000_100000000000;
    int_w2_tb = 16'b0_000_100000000000;

    #5;
    $display("==========================================================================");
    $display("OR gate");
    $display("Resultado esperado: %b %b %b %b", d_tb[0], d_tb[1], d_tb[2], d_tb[3]);
    $display("Resultado obitido Float: %b %b %b %b", result_tb[0], result_tb[1], result_tb[2], result_tb[3]);
    $display("Resultado obitido Fixed: %b %b %b %b", int_result_tb[0], int_result_tb[1], int_result_tb[2], int_result_tb[3]);
    $display("Tempo de execução FPU: %f ns", end_time_fpu - start_time_fpu);
    $display("Tempo de execução FXP: %f ns", end_time_fpx - start_time_fpx);
    

    #20;

    //==================================================================
    // Porta AND
    d_tb[0] = 16'b0;
    d_tb[1] = 16'b0;
    d_tb[2] = 16'b0;
    d_tb[3] = 16'b0011110000000000;

    int_d_tb[0] = 16'b0;
    int_d_tb[1] = 16'b0;
    int_d_tb[2] = 16'b0;
    int_d_tb[3] = 16'b0_001_000000000000;

    w0_tb = 16'b1011111000000000;
    w1_tb = 16'b0011110000000000;
    w2_tb = 16'b0011100000000000;

    int_w0_tb = 16'b1_001_100000000000;
    int_w1_tb = 16'b0_001_000000000000;
    int_w2_tb = 16'b0_000_100000000000;

    #5;
    $display("==========================================================================");
    $display("AND gate");
    $display("Resultado esperado: %b %b %b %b", d_tb[0], d_tb[1], d_tb[2], d_tb[3]);
    $display("Resultado obitido Float: %b %b %b %b", result_tb[0], result_tb[1], result_tb[2], result_tb[3]);
    $display("Resultado obitido Fixed: %b %b %b %b", int_result_tb[0], int_result_tb[1], int_result_tb[2], int_result_tb[3]);
    $display("Tempo de execução FPU: %f ns", end_time_fpu - start_time_fpu);
    $display("Tempo de execução FXP: %f ns", end_time_fpx - start_time_fpx);

    #20;

    $finish;
end

endmodule


