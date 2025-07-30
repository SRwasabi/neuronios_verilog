`include "fpu.v"
`include "alu.v"

//==============================================================================
//modulo de teste com ponto flutuante

module teste # (parameter tam = 16)
(
    //precisa ser 16bits por causa do IEEE764
    input [3:0][tam-1:0] in1, //  0101
    input [3:0][tam-1:0] in2, // 0011
    //input [3:0][tam-1:0] d,  // or -> 0111
    output [3:0][tam-1:0]result, 
    input [tam-1:0] w0, //inout para treinamento, input só para teste
    input[tam-1:0] w1, // ''
    input [tam-1:0] w2 // ''
);
wire [3:0][15:0] sum0, v, mult2, mult3;
genvar i;

assign en = 1;

generate
    for(i = 0; i < 4; i = i + 1) begin
        multi16 utt1 (.a(in1[i]), .b(w1), .result(mult2[i]), .en(en));
        multi16 utt2 (.a(in2[i]), .b(w2), .result(mult3[i]), .en(en));

        sum16 utt3 (.a(w0), .b(mult2[i]), .result(sum0[i]), .en(en));
        sum16 utt4 (.a(sum0[i]), .b(mult3[i]), .result(v[i]), .en(en));

        ativacao atv(.v(v[i]), .result(result[i]), .en(1'b1));
    end
endgenerate
endmodule

//==============================================================================
//modulo de teste com ponto fixo
module int_teste # (parameter tam = 16)
(
    //precisa ser 16bits por causa do IEEE764
    input [3:0][tam-1:0] in1, //  0101
    input [3:0][tam-1:0] in2, // 0011
    //input [3:0][tam-1:0] d,  // or -> 0111
    output [3:0][tam-1:0]result, 
    input [tam-1:0] w0, //inout para treinamento, input só para teste
    input[tam-1:0] w1, // ''
    input [tam-1:0] w2 // ''
);
wire [3:0][15:0] sum0, v, mult2, mult3;
genvar i;

assign en = 1;

generate
    for(i = 0; i < 4; i = i + 1) begin
        int_multi16 utt1 (.a(in1[i]), .b(w1), .result(mult2[i]), .en(en));
        int_multi16 utt2 (.a(in2[i]), .b(w2), .result(mult3[i]), .en(en));

        int_sum16 utt3 (.a(w0), .b(mult2[i]), .result(sum0[i]), .en(en));
        int_sum16 utt4 (.a(sum0[i]), .b(mult3[i]), .result(v[i]), .en(en));

        int_ativacao atv(.v(v[i]), .result(result[i]), .en(1'b1));
    end
endgenerate
endmodule


//==============================================================================
//Ativacao
module ativacao # (parameter tam = 16)
(
	input [tam-1:0] v,
	output reg [tam-1:0] result,
    input en
	
);

always @(*) begin 
    if (en) begin
        if(v[15] != 1) 
            result <= 16'b0_01111_0000000000; 
            
        else 
            result <= 16'b0;
        //$display("Ativação");
    end
end

endmodule

module int_ativacao # (parameter tam = 16)
(
	input [tam-1:0] v,
	output reg [tam-1:0] result,
    input en
	
);

always @(*) begin 
    if (en) begin
        if(v[15] != 1) 
            result <= 16'b0_001_000000000000; 
            
        else 
            result <= 16'b0; 
        //$display("Ativação");
    end
end

endmodule