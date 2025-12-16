`include "epoca_treino.v"

`timescale 1ns/100ps
`define tam 16

module epoca_teste;

reg clk;
reg reset_epoca;
reg reset_neuro;
reg [3:0][(`tam-1):0] in1_tb; //  0101
reg [3:0][(`tam-1):0] in2_tb; // 0011
reg [3:0][(`tam-1):0] d_tb;  // or -> 0111
reg [(`tam-1):0] u_tb; //  Taxa de Aprendizado
reg [3:0][(`tam-1):0] result_tb; 
reg [(`tam-1):0] w0, w1, w2;// pesos 
wire [(`tam-1):0] w0_out, w1_out, w2_out;// pesos 

reg [(`tam-1):0] in1_atual, in2_atual, d_atual;
wire [(`tam-1):0] result_atual;
reg [1:0] index;
reg [2:0] epoch_count;

epoca teste_epoca (
    .in1(in1_atual), 
    .in2(in2_atual), 
    .d(d_atual), 
    .u(u_tb), 
    .result(result_atual), 
    .w0(w0), 
    .w1(w1), 
    .w2(w2), 
    .w0_aux(w0_out), 
    .w1_aux(w1_out), 
    .w2_aux(w2_out),
    .clk(clk), 
    .reset(reset_neuro)
);


always @(posedge clk) begin
    if (!reset_epoca) begin
        w0 <= w0_out;
        w1 <= w1_out;
        w2 <= w2_out;
        result_tb[index] <= result_atual;
        if (index < 3) begin
            in1_atual <= in1_tb[index+1];
            in2_atual <= in2_tb[index+1];
            d_atual <= d_tb[index+1];
            index <= index + 1;
        end
        else if(epoch_count < 4) begin
            // Reset for next epoch
            index <= 0;
            in1_atual <= in1_tb[0];
            in2_atual <= in2_tb[0];
            d_atual <= d_tb[0];
            epoch_count <= epoch_count + 1;
            result_tb[0] <= 16'bx;
            result_tb[1] <= 16'bx;
            result_tb[2] <= 16'bx;  
            result_tb[3] <= 16'bx;
        end
    end
end

initial begin
    // Initialize all values before simulation starts
    index = 0;
    epoch_count = 0;
    reset_epoca = 1;
    
    // Initialize arrays
    // in1 0101
    in1_tb[0] = 16'b0;
    in1_tb[1] = 16'b0011110000000000;
    in1_tb[2] = 16'b0;
    in1_tb[3] = 16'b0011110000000000;

    // in2 0011
    in2_tb[0] = 16'b0;
    in2_tb[1] = 16'b0;
    in2_tb[2] = 16'b0011110000000000;
    in2_tb[3] = 16'b0011110000000000;
    
    // d 0111 (and gate)
    d_tb[0] = 16'b0;
    d_tb[1] = 16'b0011110000000000;
    d_tb[2] = 16'b0011110000000000;
    d_tb[3] = 16'b0011110000000000;

    u_tb = 16'b0011100000000000;
    
    // Set initial values at time 0
    in1_atual = in1_tb[0];
    in2_atual = in2_tb[0]; 
    d_atual = d_tb[0];

    w0 = 16'b0; // 0
    w1 = 16'b0; // 0
    w2 = 16'b0; // 0
    
    // Wait a bit and then start
    #10 reset_epoca = 0;
end

initial begin
    $dumpfile("epoca.vcd");
    $dumpvars(0);
    
    // Start with reset active
    reset_neuro = 1;
    #10;  // Hold reset for 10 time units
    
    $display("Pesos atual: %b %b %b", w0, w1, w2);
    $display("Resultado esperado: %b %b %b %b", d_tb[0], d_tb[1], d_tb[2], d_tb[3]);
    
    reset_neuro = 0;  // Release reset
    
    $monitor(
        "%3d ns | index: %d\n| results: %b %b %b %b\n\tweights: %b %b %b\n",
        $time, index, result_tb[0], result_tb[1], result_tb[2], result_tb[3], 
        w0, w1, w2
    );

    #1000;
    $finish;
end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

endmodule