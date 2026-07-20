

//=================================================================
/*

Multiplicador fixed point
Tira os 15 primeiros do inteiro e os 15 ultimos do fracionario

*/
module int_multi16 #(parameter tam = 16)
    (
        input en,
        input [tam-1:0] a, b,
        output reg [tam-1:0] result
    );
    wire [29:0]mult;

    assign mult = a[14:0] * b[14:0];

    always @(*) begin
        if(en) begin
            if(a ==0 || b == 0) begin
                result = 0;
            end 
            else begin
                //Sinal do resultado
                result[15] = a[15] ^ b[15];
                //result é o resultado do produto
                result[14:0] = mult[26:12];
            end
        end
    end
    
endmodule


