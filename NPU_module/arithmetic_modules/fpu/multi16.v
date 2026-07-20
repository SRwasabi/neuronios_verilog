

//==============================================================================
//Multiplicador IEEE 764

module multi16 # (parameter tam = 16)
    (
        input en,
        input [tam-1:0] a, b,
        output reg [tam-1:0] result
    );

    //Infos de "a" e "b"
    wire [10:0] mantissa_a = {1'b1, a[9:0]};
    wire [10:0] mantissa_b = {1'b1, b[9:0]};

    //controle
    reg sign;
    reg [5:0] exponent; // 4bits + 4bits
    reg [21:0] mantissa_result; //11bits + 11bits 

    always @ (*) begin
        if(en) begin
            if(a == 0|| b == 0) result = 0;
            else begin
                sign = a[tam-1] ^ b[tam-1]; // Xor nos sinais
                exponent = a[tam-2:10] + b[tam-2:10] - 5'd15; // Soma os expoentes - normalizacao
                mantissa_result = mantissa_a * mantissa_b;

                //mantissa_result[21] eh o 1 inteiro que precisa ser tirado
                    if(mantissa_result[21]) begin
                        mantissa_result = mantissa_result << 1; 
                        exponent = exponent + 1;
                    end
                    else if(mantissa_result[20]) begin
                        mantissa_result = mantissa_result << 2; 
                        exponent = exponent - 0; 
                    end
                    else if(mantissa_result[19]) begin
                        mantissa_result = mantissa_result << 3; 
                        exponent = exponent - 1; 
                    end
                    else if(mantissa_result[18]) begin
                        mantissa_result = mantissa_result << 4; 
                        exponent = exponent - 2;
                    end
                    else if(mantissa_result[17]) begin
                        mantissa_result = mantissa_result << 5; 
                        exponent = exponent - 3; 
                    end
                    else if(mantissa_result[16]) begin
                        mantissa_result = mantissa_result << 6; 
                        exponent = exponent - 4; 
                    end
                    else if(mantissa_result[15]) begin
                        mantissa_result = mantissa_result << 7; 
                        exponent = exponent - 5; 
                    end
                    else if(mantissa_result[14]) begin
                        mantissa_result = mantissa_result << 8; 
                        exponent = exponent - 6; 
                    end
                    else if(mantissa_result[13]) begin
                        mantissa_result = mantissa_result << 9; 
                        exponent = exponent - 7; 
                    end
                    else if(mantissa_result[12]) begin
                        mantissa_result = mantissa_result << 10; 
                        exponent = exponent - 8;
                end

                if(exponent[5] == 1'b1) result = 16'd0;
                else result = {sign, exponent[4:0], mantissa_result[21:12]};
            end
        end
    end
endmodule