module linear_ativacao # (parameter tam = 16)
    (
        input [tam-1:0] v,
        output reg[tam-1:0] result,
        input en,
        input clk
    );

    always @(posedge clk) begin
		if(en) begin
        result = v;
		end
    end

endmodule