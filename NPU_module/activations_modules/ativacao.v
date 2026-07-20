module ativacao # (parameter tam = 16)
    (
        input [tam-1:0] v,
        output reg [tam-1:0] result,
        input en,
        input clk
    );

    always @(posedge clk) begin
        if (en) begin
            if(v[15] != 1) result = 16'b0011110000000000;
            else result = 16'b0;
            //$display("Ativação");
        end
    end
endmodule
