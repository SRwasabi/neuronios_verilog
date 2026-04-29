
module ativacao # (parameter tam = 16)
    (
        input [tam-1:0] v,
        output reg [tam-1:0] result,
        input en
    );

    always @(v) begin
        if (en) begin
            if(v[15] != 1) result = 16'b0011110000000000;
            else result = 16'b0;
            $display("Ativação");
        end
    end
endmodule

//==============================================================================

module relu_ativacao # (parameter tam = 16)
    (
        input [tam-1:0] v,
        output reg[tam-1:0] result
    );

    always @(v) begin
        if(v[15] != 1) result = v;
        else result = 16'b0;
    end

endmodule

//==============================================================================

module linear_ativacao # (parameter tam = 16)
    (
        input [tam-1:0] v,
        output reg[tam-1:0] result
    );

    always @(v) begin
        result = v;
    end

endmodule