`include "treino.v"

`timescale 1ns/100ps
`define tam 16

module peso_teste;

reg en;
reg [(`tam-1):0] d, y, in, u;
wire [(`tam-1):0] w_in;
wire [(`tam-1):0] w_out;

att_peso teste_attpeso (.d(d), .y(y), .in(in), .u(u), .w_in(w_in), .w_out(w_out), .en(en));

assign w_in = 16'b0;

initial begin
    $dumpfile("attpeso.vcd");
    $dumpvars(0);
    en = 1;
    u = 16'b0011100000000000;
    d = 16'b0011110000000000;
    y = 16'b0;
    in = 16'b0011110000000000;

    #20;
    $finish;
end

endmodule