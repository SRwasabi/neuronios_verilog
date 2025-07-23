`include "fpu.v"


//==============================================================================



//epocas
module epoca_2 # (parameter tam = 16)
(
    //precisa ser 16bits por causa do IEEE764
    input clk, reset,
    input [3:0][tam-1:0] in1, //  0101
    input [3:0][tam-1:0] in2, // 0011
    input [3:0][tam-1:0] d,  // or -> 0111
    input [tam-1:0] u, //  Taxa de Aprendizado
    output [3:0][tam-1:0]result, 
    inout [tam-1:0] w0, w1, w2// pesos entrada
);

//Registros e wires =================================================
//Parametros
parameter entrada = 1'b0, saida = 1'b1;
reg state, next_state;
wire next_wire;

//Bias sempre sendo 1 
wire[15:0] in0 = 16'b0011110000000000;

//Fios de contas
wire [15:0] v; //wire [3:0][15:0] v
reg [3:0] y;
genvar i;

//Controle
reg direction = 0;
wire [15:0] y_aux;
reg [3:0] erro = 0;

reg [3:0] index_atual = 3'b0;
wire [15:0] in1_atual = in1[index_atual];
wire [15:0] in2_atual = in2[index_atual];
wire [15:0] d_atual = d[index_atual];
wire [15:0] result_atual;
reg [3:0][15:0] result_reg;

//reg signed [2:0] qtde = 3'd4;
reg contr_enable = 0;

//Pesos auxiliares para inout
wire [15:0] w0_aux, w1_aux, w2_aux;
reg [15:0] w0_in, w1_in, w2_in;
reg [15:0] w0_out, w1_out, w2_out;

//Lógica =================================================

//Precisa ser mexido para arrumar o problema de leitura e escrita
always @(posedge clk) begin
    if (reset) begin
        index_atual <= 2'b0;
        state <= entrada;
        next_state <= saida;
        contr_enable = 0;
    end
    else begin
        if(index_atual == 3'b00 && !contr_enable )begin
                if(!direction) begin
                    w0_in <= w0;
                    w1_in <= w1;
                    w2_in <= w2;
                    contr_enable <= 1;
                end
        end
        else if(index_atual <= 3'b011) begin
            state = next_state;
            result_reg[index_atual] <= result_atual;
            index_atual <= index_atual + 1;/**/
            if(direction == 1) begin
                w0_in <= w0_aux;
                w1_in <= w1_aux;
                w2_in <= w2_aux;
                w0_out <= w0_aux;
                w1_out <= w1_aux;
                w2_out <= w2_aux;
                
            end
        end
        /*else begin
            w0_out <= w0_aux;
            w1_out <= w1_aux;
            w2_out <= w2_aux;
            state <= saida;
        end*/
    end    
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

/*
always @ (posedge clk) begin

    if(!direction) begin
        w0_in <= w0;
        w1_in <= w1;
        w2_in <= w2;
    end
    else begin
        w0_in <= w0_aux;
        w1_in <= w1_aux;
        w2_in <= w2_aux;
    end
end
*/

//Calculos
calculo_v calc(.in0(in0), .in1(in1_atual), .in2(in2_atual), .w0(w0_in), .w1(w1_in), .w2(w2_in), .v(v), .contr_enable(contr_enable));
        
ativacao atv(.v(v), .nextstate(next_wire), .result(result_atual), .clk(clk), .en(contr_enable));

//negativa d para poder subtrair
multi16 result_neg (.a(result_atual), .b(16'b1011110000000000), .result(y_aux), .en(contr_enable));

//Ajusta os pesos

att_peso peso_w0(.d(d_atual), .y(y_aux), .in(in0), .u(u), .w_in(w0_in), .w_out(w0_aux), .en(contr_enable));
att_peso peso_w1(.d(d_atual), .y(y_aux), .in(in1_atual), .u(u), .w_in(w1_in), .w_out(w1_aux), .en(contr_enable));
att_peso peso_w2(.d(d_atual), .y(y_aux), .in(in2_atual), .u(u), .w_in(w2_in), .w_out(w2_aux), .en(contr_enable));

/*
always @(next_wire) begin
    next_state <= next_wire;
end
*/
assign result = result_reg;
    
endmodule



//==============================================================================



module ativacao # (parameter tam = 16)
(
    input clk,
	input [tam-1:0] v,
	output reg nextstate,
	output reg [tam-1:0] result,
    input en
);

always @(v) begin
    if (en) begin
        if(v[15] != 1) result <= 16'b0011110000000000;
        else result <= 16'b0;
        nextstate = 1'b0; // 0 ou 1?
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
    output reg [tam-1:0] w_out
);

wire [tam-1:0] fio_erro, fio_p1, fio_p2, w_out_fio;

//Erro no fio_erro quando subtrai 
sum16 erro (.a(d), .b(y), .result(fio_erro), .en(en));

multi16 att_p1 (.a(in), .b(u), .result(fio_p1), .en(en));
multi16 att_p2 (.a(fio_p1), .b(fio_erro), .result(fio_p2), .en(en));

sum16 att_sum (.a(fio_p2), .b(w_in), .result(w_out_fio), .en(en));

always @ (w_out_fio) begin
    w_out = w_out_fio;
end

endmodule