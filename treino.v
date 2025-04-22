`include "fpu.v"


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
    output [3:0][tam-1:0]result, 
    inout [tam-1:0] w0, w1, w2,// pesos entrada
    output stop
);

//Registros e wires =================================================
//Parametros
parameter entrada = 1'b0, saida = 1'b1;
reg state, next_state;
wire next_wire;

//Bias sempre sendo 1 
wire[15:0] in0 = 16'b0011110000000000;

//Fios de contas
wire [15:0] mult1;
wire [3:0][15:0] sum0, v, mult2, mult3;
wire [15:0] fio_erro;
reg teste;

reg [3:0] y;
genvar i;

//Controle
reg direction = 0;
wire [15:0] y_aux;
reg [3:0] erro = 0;
reg signed [2:0] qtde = 3'd4;
reg contr_enable;

//Pesos auxiliares para inout
wire [15:0] w0_aux = 0, w1_aux = 0, w2_aux = 0;
reg [15:0] w0_in = 0, w1_in = 0, w2_in = 0;
reg [15:0] w0_out = 0, w1_out = 0, w2_out = 0;

//Lógica =================================================

always @(posedge clk) begin
    if (reset) qtde = 3'd4;
    if (reset || contr_enable)
        state <= entrada;
    else
        state <= next_state;        
end

always @(posedge clk) begin
    if (qtde >= 3'd0) begin
        qtde <= qtde - 3'd1;
        contr_enable <= 1;
        teste <= 0;
    end
    else begin
        contr_enable <= 0;    
        teste <= 1;    
    end
end
assign stop = teste;

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
        calculo_v calc(.in0(in0), .in1(in1[i]), .in2(in2[i]), .w0(w0), .w1(w1), .w2(w2), .v(v[i]), .contr_enable(contr_enable));
        
        //Esta dando problema no ativação, quando eu coloco o clk ele n funfa, e quando coloco ele para
	    ativacao atv(.v(v[i]), .nexstate(next_wire), .result(result[i]), .clk(clk), .en(contr_enable));

        //Ajusta os pesos
        //negativa d para poder subtrair
        multi16 result_neg (.a(result[i]), .b(16'b1011110000000000), .result(y_aux), .en(contr_enable));
        //assign y_aux = {~result[i][15], result[i][14:0]};
        /*
        ==========================
        ta dando erro na atualização de peso, quando coloco 16
        Quando eu coloco exatamente 16'b0011110000000000 de resto, ele funciona
        testar o Tb de attpeso com d e y igual a 1, já que só esta acontecendo nesses casos
        ==========================
        */
        att_peso peso_w0(.d(d[i]), .y(y_aux), .in(in0), .u(u), .w_in(w0_in), .w_out(w0_aux), .en(contr_enable));
        att_peso peso_w1(.d(d[i]), .y(y_aux), .in(in1[i]), .u(u), .w_in(w1_in), .w_out(w1_aux), .en(contr_enable));
        att_peso peso_w2(.d(d[i]), .y(y_aux), .in(in2[i]), .u(u), .w_in(w2_in), .w_out(w2_aux), .en(contr_enable));

    end
endgenerate

always @(next_wire) begin
    next_state = next_wire;
end

//Quando eu coloco exatamente 16'b0011110000000000 de resto, ele funciona
/*
always @ (v) begin
    if(v[0][15] != 1) result[0] = 16'b0011110000000000;
    else result[0] = 0;
    if(v[1][15] != 1) result[1] = 16'b0011110000000000;
    else result[1] = 0;
    if(v[2][15] != 1) result[2] = 16'b0011110000000000;
    else result[2] = 0;
    if(v[3][15] != 1) result[3] = 16'b0011110000000000;
    else result[3] = 0;
    next_state = 1'b0; 
end
*/

endmodule





//==============================================================================



module ativacao # (parameter tam = 16)
(
    input clk,
	input [tam-1:0] v,
	output reg nexstate,
	output reg [tam-1:0] result,
    input en
);

always @(posedge clk) begin
    if (en) begin
        if(v[15] != 1) result <= 16'b0011110000000000;
        else result <= 16'b0;
        nexstate = 1'b0; // 0 ou 1?
        $display("Ativação");
    end
end
endmodule






//==============================================================================



module calculo_v # (parameter tam = 16)
(
    input [tam-1:0] in0, in1, in2,
    input [tam-1:0] w0, w1, w2,
    output [tam-1:0] v,
    input contr_enable
);

wire [15:0] mult1;
wire [15:0] sum0, mult2, mult3;

multi16 utt0 (.a(in0), .b(w0), .result(mult1), .en(contr_enable));
multi16 utt1 (.a(in1), .b(w1), .result(mult2), .en(contr_enable));
multi16 utt2 (.a(in2), .b(w2), .result(mult3), .en(contr_enable));

sum16 utt3 (.a(mult1), .b(mult2), .result(sum0), .en(contr_enable));
sum16 utt4 (.a(sum0), .b(mult3), .result(v), .en(contr_enable));

always @(*) begin
    if (contr_enable) 
        $display("Calculo V");
end

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

//Erro no fio_erro quando subtrai 
sum16 erro (.a(d), .b(y), .result(fio_erro), .en(en));

multi16 att_p1 (.a(in), .b(u), .result(fio_p1), .en(en));
multi16 att_p2 (.a(fio_p1), .b(fio_erro), .result(fio_p2), .en(en));

sum16 att_sum (.a(fio_p2), .b(w_in), .result(w_out), .en(en));

endmodule