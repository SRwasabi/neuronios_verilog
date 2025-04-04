`include "fpu.v"

//Teste
module teste # (parameter tam = 16)
(
    //precisa ser 16bits por causa do IEEE764
    input en,
    input [3:0][tam-1:0] in1, //  0101
    input [3:0][tam-1:0] in2, // 0011
    input [3:0][tam-1:0] d,  // or -> 0111
    output reg [3:0]result, 
    input [tam-1:0] w0, //inout para treinamento, input só para teste
    input[tam-1:0] w1, // ''
    input [tam-1:0] w2 // ''
);
wire[15:0] in0 = 16'b1011101001100110;
reg [3:0] epoca = 0;
reg [3:0] erro = 1;
wire [15:0] mult1;
wire [3:0][15:0] sum0, v, mult2, mult3;
//reg [15:0] v; 
reg y;
genvar i;

generate
    for(i = 0; i < 4; i = i + 1) begin
        multi16 utt0 (.a(in0), .b(w0), .result(mult1), .en(en));
        multi16 utt1 (.a(in1[i]), .b(w1), .result(mult2[i]), .en(en));
        multi16 utt2 (.a(in2[i]), .b(w2), .result(mult3[i]), .en(en));

        sum16 utt3 (.a(mult1), .b(mult2[i]), .result(sum0[i]), .en(en));
        sum16 utt4 (.a(sum0[i]), .b(mult3[i]), .result(v[i]), .en(en));
    end
endgenerate

always @ (*) begin
    if(v[0][15] != 1) result[0] = 1;
    else result[0] = 0;
    if(v[1][15] != 1) result[1] = 1;
    else result[1] = 0;
    if(v[2][15] != 1) result[2] = 1;
    else result[2] = 0;
    if(v[3][15] != 1) result[3] = 1;
    else result[3] = 0;
end

endmodule