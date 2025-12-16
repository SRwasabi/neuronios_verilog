`include "fpu.v"

//==============================================================================

module ativacao # (parameter tam = 16)
    (
        input [tam-1:0] v,
        output reg [tam-1:0] result,
        input en
    );

    always @(v) begin
        if (en) begin
            if(v[15] != 1) result <= 16'b0011110000000000;
            else result <= 16'b0;
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
    output reg[tam-1:0] w_out
);

    wire [tam-1:0] fio_erro, fio_p1, fio_p2, w_fio;

    sum16 erro (.a(d), .b(y), .result(fio_erro), .en(en));

    multi16 att_p1 (.a(in), .b(u), .result(fio_p1), .en(en));
    multi16 att_p2 (.a(fio_p1), .b(fio_erro), .result(fio_p2), .en(en));

    sum16 att_sum (.a(fio_p2), .b(w_in), .result(w_fio), .en(en));

    always @(w_fio) begin
        if (en) w_out <= w_fio;
    end

endmodule