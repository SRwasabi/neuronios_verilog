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
    input clk, reset,
    input [3:0][tam-1:0] in1, //  0101
    input [3:0][tam-1:0] in2, // 0011
    input [3:0][tam-1:0] d,  // or -> 0111
    input [tam-1:0] u, //  Taxa de Aprendizado
    output reg [3:0][tam-1:0]result, 
    inout [tam-1:0] w0, w1, w2// pesos entrada
);

//Registros e wires =================================================
//Parametros
parameter entrada = 1'b0, saida = 1'b1;
reg [2:0] state, next_state;

//Bias sempre sendo 1 
wire[15:0] in0 = 16'b0011110000000000;

//Fios de contas
wire [15:0] mult1;
wire [3:0][15:0] sum0, v, mult2, mult3;
wire [15:0] fio_erro;

reg [3:0] y;
genvar i;

//Controle
reg direction = 0;
wire [15:0] y_aux;
reg [3:0] erro = 0;

//Pesos auxiliares para inout
wire [15:0] w0_aux = 0, w1_aux = 0, w2_aux = 0;
reg [15:0] w0_in = 0, w1_in = 0, w2_in = 0;
reg [15:0] w0_out = 0, w1_out = 0, w2_out = 0;

//Lógica =================================================

always @(posedge clk) begin
    if (reset)
        state <= entrada;
    else
        state <= next_state;        
end

//Máquina de estado para controlar inout
always @ (posedge clk) begin
    case (state)
        entrada: begin
            direction <= 0;
        end
        saida: begin
            direction <= 1;
        end
    endcase
end


//direction = 1 -> ajuste |||| direction = 0 -> leitura
assign w0 = direction ? w0_out : 16'bz;
assign w1 = direction ? w1_out : 16'bz;
assign w2 = direction ? w2_out : 16'bz;

always @ (posedge clk) begin
    if(!direction) begin
        w0_in <= w0;
        w1_in <= w1;
        w2_in <= w2;
        next_state <= saida;
    end
end

always @ (posedge clk) begin
    w0_out <= w0_aux;
    w1_out <= w1_aux;
    w2_out <= w2_aux;
end

generate
    for(i = 0; i < 4; i = i + 1) begin
        //Calculos
        multi16 utt0 (.a(in0), .b(w0_in), .result(mult1), .en(1'b1));
        multi16 utt1 (.a(in1[i]), .b(w1_in), .result(mult2[i]), .en(1'b1));
        multi16 utt2 (.a(in2[i]), .b(w2_in), .result(mult3[i]), .en(1'b1));

        sum16 utt3 (.a(mult1), .b(mult2[i]), .result(sum0[i]), .en(1'b1));
        sum16 utt4 (.a(sum0[i]), .b(mult3[i]), .result(v[i]), .en(1'b1));
        $display("Fazendo contas");
        
        always @ (v) begin
            if(v[i][15] != 1) result[i] = 16'b0011110000000000;
            else result[i] = 16'b0;
            next_state <= entrada;
            $display("Ativação");
        end

        //Ajusta os pesos
        //negativa d para poder subtrair
        assign y_aux = {~result[i][15], result[i][14:0]};
        att_peso peso_w0(.d(d[i]), .y(y_aux), .in(in0), .u(u), .w_in(w0_in), .w_out(w0_aux), .en(1'b1));
        att_peso peso_w1(.d(d[i]), .y(y_aux), .in(in1[i]), .u(u), .w_in(w1_in), .w_out(w1_aux), .en(1'b1));
        att_peso peso_w2(.d(d[i]), .y(y_aux), .in(in2[i]), .u(u), .w_in(w2_in), .w_out(w2_aux), .en(1'b1));

    end
endgenerate

endmodule





//==============================================================================





// Atualização de pesos (funcionando)
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