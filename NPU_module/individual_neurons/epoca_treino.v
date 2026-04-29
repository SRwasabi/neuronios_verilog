`include "neuro_modules.v"

//epocas
module epoca # (parameter tam = 16)
(
    //precisa ser 16bits por causa do IEEE764
    input clk, reset,
    input [tam-1:0] in1, //  0101
    input [tam-1:0] in2, // 0011
    input [tam-1:0] d,  // or -> 0111
    input [tam-1:0] u, //  Taxa de Aprendizado
    output [tam-1:0]result, 
    input [tam-1:0] w0, w1, w2,// pesos entrada
    output [tam-1:0] w0_aux, w1_aux, w2_aux// pesos saída
);
    //Registros e wires =================================================

    //Bias sempre sendo 1 
    wire[15:0] in0 = 16'b0011110000000000;

    //Fios de contas
    wire [15:0] v; //wire [3:0][15:0] v

    //Controle
    wire [15:0] y_aux;
    reg [3:0] erro;
    reg contr_enable;
    
    //Lógica =================================================
    always @(posedge clk) begin
        if(reset) begin
            contr_enable <= 1;
            erro <= 0;
        end 
    end

    //Calculos
    calculo_v calc(.in0(in0), .in1(in1), .in2(in2), .w0(w0), .w1(w1), .w2(w2), .v(v), .contr_enable(contr_enable));
    ativacao atv(.v(v), .result(result), .en(contr_enable));

    //negativa d para poder subtrair
    multi16 result_neg (.a(result), .b(16'b1011110000000000), .result(y_aux), .en(contr_enable));

    //Ajusta os pesos
    att_peso peso_w0(.d(d), .y(y_aux), .in(in0), .u(u), .w_in(w0), .w_out(w0_aux), .en(contr_enable));
    att_peso peso_w1(.d(d), .y(y_aux), .in(in1), .u(u), .w_in(w1), .w_out(w1_aux), .en(contr_enable));
    att_peso peso_w2(.d(d), .y(y_aux), .in(in2), .u(u), .w_in(w2), .w_out(w2_aux), .en(contr_enable));

endmodule


