//=================================================================
/*
Somador Fixed-point
1 bits - sign
3 bits - inteiro
12 bits -fracionario

*/

//Somador inteiro de 16 bits 
module int_sum16 # (parameter tam = 16)
    (
        input en,
        input [tam-1:0] a, b,
        output reg [tam-1:0] result
    );

    always @(*) begin
        if(en) begin
            if(a[15] == b[15]) begin
                result = {a[15], a[14:0] + b[14:0]};
            end 

            else begin

                if(a[14:0] == b[14:0]) result = 0;

                else if(a[14:0] > b[14:0]) begin
                    result = {a[15], a[14:0] - b[14:0]};
                end 

                else begin
                    result = {b[15], b[14:0] - a[14:0]}; 
                end

            end
        end
    end
endmodule