`include "teste.v"

//==============================================================================
// XOR em ponto flutuante

module xor_float # (parameter tam = 16)
(
    input en,
    input [3:0][tam-1:0] in1, //  0101
    input [3:0][tam-1:0] in2, // 0011
    input [3:0][tam-1:0] d, dz1, dz2, // or -> 0111
    output [3:0]result, 
    input [tam-1:0] w01, w11, w21, //inout para treinamento, input só para teste
    input [tam-1:0] w02, w12, w22, // ''
    input [tam-1:0] w0, w1, w2 // ''
);
    wire [3:0] r1, r2;
    reg [3:0][15:0] in_z1, in_z2;

    teste z1 (.in1(in1), .in2(in2), .d(dz1), .result(r1), .w0(w01), .w1(w11), .w2(w21));
    teste z2 (.in1(in1), .in2(in2), .d(dz2), .result(r2), .w0(w02), .w1(w12), .w2(w22));
    teste xor_gate (.in1(in_z1), .in2(in_z2), .d(d), .result(result), .w0(w0), .w1(w1), .w2(w2));


    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin
            always @(*) begin
                if(r1[i] == 1'b1) begin
                    in_z1[i] = 16'b0011110000000000;
                end else begin
                    in_z1[i] = 16'b0;
                end

                if(r2[i] == 1'b1) begin
                    in_z2[i] = 16'b0011110000000000;;
                end else begin
                    in_z2[i] = 16'b0;
                end
            end
        end
    endgenerate
endmodule

//==============================================================================
// XOR em ponto fixo

module xor_fixed # (parameter tam = 16)
(
    input en,
    input [3:0][tam-1:0] in1, //  0101
    input [3:0][tam-1:0] in2, // 0011
    input [3:0][tam-1:0] d, dz1, dz2, // or -> 0111
    output [3:0]result, 
    input [tam-1:0] w01, w11, w21, //inout para treinamento, input só para teste
    input [tam-1:0] w02, w12, w22, // ''
    input [tam-1:0] w0, w1, w2 // ''
);
    wire [3:0] r1, r2;
    reg [3:0][15:0] in_z1, in_z2;

    int_teste z1 (.in1(in1), .in2(in2), .d(dz1), .result(r1), .w0(w01), .w1(w11), .w2(w21));
    int_teste z2 (.in1(in1), .in2(in2), .d(dz2), .result(r2), .w0(w02), .w1(w12), .w2(w22));
    int_teste xor_gate (.in1(in_z1), .in2(in_z2), .d(d), .result(result), .w0(w0), .w1(w1), .w2(w2));


    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin
            always @(*) begin
                if(r1[i] == 1'b1) begin
                    in_z1[i] = 16'b0_001_000000000000;
                end else begin
                    in_z1[i] = 16'b0;
                end

                if(r2[i] == 1'b1) begin
                    in_z2[i] = 16'b0_001_000000000000;;
                end else begin
                    in_z2[i] = 16'b0;
                end
            end
        end
    endgenerate
endmodule