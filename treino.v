`include "fpu.v"

//==============================================================================
//treino
/*
module treino # (parameter tam = 16)
(
    input clk,
    input [3:0][tam-1:0] in1, //  0101
    input [3:0][tam-1:0] in2, // 0011
    input [3:0][tam-1:0] d,  // or -> 0111
    input [tam-1:0] u, //  Taxa de Aprendizado
    output [3:0][tam-1:0]result, 
    inout [tam-1:0] w0, // pesos
    inout[tam-1:0] w1, // ''
    inout [tam-1:0] w2 // ''
);

reg [3:0] cont;
reg en;

always @ (posedge clk) begin
    en = 0;
    if(cont < 6) begin
       en = 1;
    end
end

epoca treino_epoca (.in1(in1), .in2(in2), .d(d), .u(u), .result(result), .w0(w0), .w1(w1), .w2(w2));

endmodule

*/

//==============================================================================
//epocas
module epoca # (parameter tam = 16)
(
    //precisa ser 16bits por causa do IEEE764
    input clk,
    input [3:0][tam-1:0] in1, //  0101
    input [3:0][tam-1:0] in2, // 0011
    input [3:0][tam-1:0] d,  // or -> 0111
    input [tam-1:0] u, //  Taxa de Aprendizado
    output reg [3:0][tam-1:0]result, 
    input [tam-1:0] w0_in, w1_in, w2_in,// pesos entrada
    output reg [tam-1:0] w0_out, w1_out, w2_out // pesos saida

);

wire[15:0] in0 = 16'b0011110000000000;
reg [3:0] epoca = 0;
reg [3:0] erro = 1;
wire [15:0] mult1;
wire [3:0][15:0] sum0, v, mult2, mult3;
//reg [15:0] v; 
reg [3:0] y;
genvar i;

//Wires para ajustes
reg en_contas = 1, en_ajuste;
reg comeco = 0;
wire [15:0] y_aux;
wire [15:0] w0_aux = 0, w1_aux = 0, w2_aux = 0;
wire [15:0] fio_erro;

assign w0_aux = (w0_aux == 0) ? w0_in : 0;
assign w1_aux = (w1_aux == 0) ? w1_in : 0;
assign w2_aux = (w2_aux == 0) ? w2_in : 0;

//Inout permite entrada e saída do pesos
always @ (posedge clk) begin
    if(w0_aux != 0 && w1_aux != 0 && w2_aux != 0) begin
        w0_out <= w0_aux;
        w1_out <= w1_aux;
        w2_out <= w2_aux;
    end
end

generate
    for(i = 0; i < 4; i = i + 1) begin
        multi16 utt0 (.a(in0), .b(w0_aux), .result(mult1), .en(en_contas));
        multi16 utt1 (.a(in1[i]), .b(w1_aux), .result(mult2[i]), .en(en_contas));
        multi16 utt2 (.a(in2[i]), .b(w2_aux), .result(mult3[i]), .en(en_contas));

        sum16 utt3 (.a(mult1), .b(mult2[i]), .result(sum0[i]), .en(en_contas));
        sum16 utt4 (.a(sum0[i]), .b(mult3[i]), .result(v[i]), .en(en_contas));

        always @ (v) begin
            en_ajuste <= 0;
            if(v[i][15] != 1) result[i] = 16'b0011110000000000;
            else result[i] = 16'b0;
            if(result[i] != d[i]) en_ajuste <= 1;
            
        end
        //negativa d para poder subtrair
        assign y_aux = {~result[i][15], result[i][14:0]};
        att_peso peso_w0(.d(d[i]), .y(y_aux), .in(in0), .u(u), .w_in(w0_out), .w_out(w0_aux), .en(en_ajuste));
        att_peso peso_w1(.d(d[i]), .y(y_aux), .in(in1[i]), .u(u), .w_in(w1_out), .w_out(w1_aux), .en(en_ajuste));
        att_peso peso_w2(.d(d[i]), .y(y_aux), .in(in2[i]), .u(u), .w_in(w2_out), .w_out(w2_aux), .en(en_ajuste));

    end
endgenerate

endmodule

//==============================================================================
// Atualização de pesos
module att_peso # (parameter tam = 16)
(
    input en,
    input [tam-1:0] d, y, in, u,
    input [tam-1:0] w_in,
    output [tam-1:0] w_out
);

wire [tam-1:0] fio_erro, fio_p1, fio_p2;

sum16 erro (.a(d), .b(y), .result(fio_erro), .en(en));

multi16 att_p1 (.a(in), .b(u), .result(fio_p1), .en(en));
multi16 att_p2 (.a(fio_p1), .b(fio_erro), .result(fio_p2), .en(en));

sum16 att_sum (.a(fio_p2), .b(w_in), .result(w_out), .en(en));

endmodule