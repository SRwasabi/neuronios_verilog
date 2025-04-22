//==============================================================================
//Somador IEEE 764

//Modulo somador IEEE 754 16bits
module sum16 # (parameter tam = 16)
(
    input en,
    input [tam-1:0] a, b,
    output reg [tam-1:0] result
);


//Infos do num A
wire sign_a = a[tam-1];
wire [4:0] exponent_a = a[14:10];
wire [9:0] mantissa_a = a[9:0];

//Infos do num B
wire sign_b = b[tam-1];
wire [4:0] exponent_b = b[14:10];
wire [9:0] mantissa_b = b[9:0];

//Controle
reg [4:0] exponent_diference;
reg [11:0] mantissa_a_shifted, mantissa_b_shifted, mantissa_sum;
reg [4:0] exponent_result;
reg sign_result;


//Arrumando as mantissas (overflow????)
always @ (*) begin
    if(en) begin
        if(exponent_a > exponent_b) begin
            exponent_diference <= exponent_a - exponent_b;
            mantissa_a_shifted <= {1'b1, mantissa_a}; //Add 1 a frente da mantissa
            mantissa_b_shifted <= {1'b1, mantissa_b} >> exponent_diference; //Add 1 e shifta ela
            exponent_result <= exponent_a;
        end
        else begin
            exponent_diference <= exponent_b - exponent_a;
            mantissa_a_shifted <= {1'b1, mantissa_a} >> exponent_diference; //Add 1 e shifta ela
            mantissa_b_shifted <= {1'b1, mantissa_b}; //Add 1 a frente da mantissa
            exponent_result <= exponent_b;
        end
    end
end

//Somando as mantissas
always @ (*) begin
    if(en) begin
        if(sign_a == sign_b) begin
            mantissa_sum = mantissa_a_shifted + mantissa_b_shifted;
            sign_result = sign_a;
        end
        else begin
            if(mantissa_a_shifted > mantissa_b_shifted) begin
                mantissa_sum = mantissa_a_shifted - mantissa_b_shifted;
                sign_result = sign_a;
            end
            else begin
                mantissa_sum = mantissa_b_shifted - mantissa_a_shifted;
                sign_result = sign_b;
            end
        end
    end
end

//Arrumando mantissa de Sum
always @ (*) begin
    if(en) begin
        if(mantissa_sum[11]) begin
            mantissa_sum = mantissa_sum >> 1;
            exponent_result = exponent_result + 1;
        end
        while(!mantissa_sum[10] && mantissa_sum != 0) begin
            mantissa_sum = mantissa_sum << 1;
            exponent_result = exponent_result - 1;
        end
    end
end

//Juta todo o número
always @ (*) begin
    if(mantissa_sum == 0 && exponent_a == exponent_b && sign_a != sign_b) result = 0;
    else result = {sign_result, exponent_result, mantissa_sum[9:0]};
end

endmodule

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
            exponent = a[tam-2:10] + b[tam-2:10] - 5'd15 + 1;// Soma os expoentes - normalizacao
            mantissa_result = mantissa_a * mantissa_b;
            //mantissa_result[21] eh o 1 inteiro que precisa ser tirado
            while(!mantissa_result[21]) begin
                    mantissa_result = mantissa_result << 1;
                    exponent = exponent - 1;
            end
            if(exponent[5] == 1) result = 16'd0;
            else result = {sign, exponent[4:0], mantissa_result[20:11]};
        end
    end
end

endmodule