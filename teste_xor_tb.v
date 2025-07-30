`include "teste_xor.v"

`timescale 1ns/100ps
`define tam 16

module xor_float_tb;

// FPU
    wire en;
    reg [3:0][(`tam-1):0] in1; //  0101
    reg [3:0][(`tam-1):0] in2;// 0011
    reg [3:0][(`tam-1):0] d, dz1, dz2;// or -> 0111
    wire [3:0][(`tam-1):0] result;
    reg [(`tam-1):0] w01, w11, w21; //inout para treinamento, input só para teste
    reg [(`tam-1):0] w02, w12, w22;// ''
    reg [(`tam-1):0] w0, w1, w2;// ''

//FXP
    reg [3:0][(`tam-1):0] int_in1; //  0101
    reg [3:0][(`tam-1):0] int_in2;// 0011
    reg [3:0][(`tam-1):0] int_d, int_dz1, int_dz2;// or -> 0111
    wire [3:0][(`tam-1):0] int_result;
    reg [(`tam-1):0] int_w01, int_w11, int_w21; //inout para treinamento, input só para teste
    reg [(`tam-1):0] int_w02, int_w12, int_w22;// ''
    reg [(`tam-1):0] int_w0, int_w1, int_w2;// ''

    xor_float #(.tam(`tam)) xor1 (.in1(in1), .in2(in2), .result(result), .w01(w01), .w11(w11), .w21(w21), .w02(w02), .w12(w12), .w22(w22), .w0(w0), .w1(w1), .w2(w2));

    xor_fixed #(.tam(`tam)) xor2 (.in1(int_in1), .in2(int_in2), .result(int_result), .w01(int_w01), .w11(int_w11), .w21(int_w21), .w02(int_w02), .w12(int_w12), .w22(int_w22), .w0(int_w0), .w1(int_w1), .w2(int_w2));

    initial begin
        $dumpfile("xor_float.vcd");
        $dumpvars(0);

//====================================================================================
        // float xor 

        // in1 0101
        in1[0] = 16'b0;
        in1[1] = 16'b0011110000000000;
        in1[2] = 16'b0;
        in1[3] = 16'b0011110000000000;

        // in2 0011
        in2[0] = 16'b0;
        in2[1] = 16'b0;
        in2[2] = 16'b0011110000000000;
        in2[3] = 16'b0011110000000000;

        
        dz1[0] = 16'b0;
        dz1[1] = 16'b0;
        dz1[2] = 16'b0011110000000000;
        dz1[3] = 16'b0;

        dz2[0] = 16'b0;
        dz2[1] = 16'b0011110000000000;
        dz2[2] = 16'b0;
        dz2[3] = 16'b0;

        d[0] = 16'b0;
        d[1] = 16'b0011110000000000;
        d[2] = 16'b0011110000000000;
        d[3] = 16'b0;

        // weights
        w01 = 16'b1011100000000000; // 
        w11 = 16'b0011100000000000; // 
        w21 = 16'b1011110000000000; // 

        w02 = 16'b1011100000000000; // 
        w12 = 16'b1011100000000000; // 
        w22 = 16'b0011100000000000; // 

        w0 = 16'b1011100000000000; // 
        w1 = 16'b0011100000000000; // 
        w2 = 16'b0011100000000000; // 

//====================================================================================
        // float xor  b0_001_000000000000

        int_in1[0] = 16'b0;
        int_in1[1] = 16'b0_001_000000000000;
        int_in1[2] = 16'b0;
        int_in1[3] = 16'b0_001_000000000000;

        int_in2[0] = 16'b0;
        int_in2[1] = 16'b0;
        int_in2[2] = 16'b0_001_000000000000;
        int_in2[3] = 16'b0_001_000000000000;

        int_dz1[0] = 16'b0;
        int_dz1[1] = 16'b0;
        int_dz1[2] = 16'b0_001_000000000000;
        int_dz1[3] = 16'b0;

        int_dz2[0] = 16'b0;
        int_dz2[1] = 16'b0_001_000000000000;
        int_dz2[2] = 16'b0;
        int_dz2[3] = 16'b0; 

        int_d[0] = 16'b0;
        int_d[1] = 16'b0_001_000000000000;
        int_d[2] = 16'b0_001_000000000000;
        int_d[3] = 16'b0;

        // weights
        int_w01 = 16'b1_000_100000000000; // 
        int_w11 = 16'b0_000_100000000000; // 
        int_w21 = 16'b1_001_000000000000; //  

        int_w02 = 16'b1_000_100000000000; // 
        int_w12 = 16'b1_000_100000000000; // 
        int_w22 = 16'b0_000_100000000000; //  

        int_w0 = 16'b1_000_100000000000; // 
        int_w1 = 16'b0_000_100000000000; // 
        int_w2 = 16'b0_000_100000000000; //


        #5;
        
        $display("Resultado esperado: %b %b %b %b", d[0], d[1], d[2], d[3]);
        $display("Resultado obitido Float: %b %b %b %b", result[0], result[1], result[2], result[3]);
        $display("Resultado obitido Fixed: %b %b %b %b", int_result[0], int_result[1], int_result[2], int_result[3]);

    end
endmodule