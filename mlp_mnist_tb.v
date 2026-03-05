`include "mlp_mnist.v"

`timescale 1ns/100ps
`define tam 16
`define layer 4


module matrixPE_tb;
reg clk;
reg rst;
reg [(`layer-1):0] [(`tam-1):0] weights_in;
wire [(`layer-1):0] [(`tam-1):0] out;
reg [(`tam-1):0] data;
reg [(`layer-1):0] [(`tam-1):0] d_out;
reg [(`layer-1):0] PE_en;
integer i;

reg last_selection; // When last selection is made, all PEs are enabled at the same time

matrix_PE # (.tam(`tam), .layer(`layer)) matrix_1 (.bus_input(data), .bus_weights(weights_in), .clk(clk), .rst(rst), .acc_out(out), .PE_en(PE_en));

always @(posedge clk, posedge rst) begin
    

    if(rst) begin 
        PE_en <= {`layer{1'b1}};
        last_selection <= 0;
    end
    else if (last_selection)begin
        //PE_en <= PE_en << 1; -> Pipeline enable
        PE_en <= 0; // All PEs enabled at the same time
    end
    
end

initial begin
    $dumpfile("matrix_pe.vcd");
    $dumpvars(0);
	$display("teste");
	rst = 1;
    #10;
    rst = 0;
	data = 16'b0011110000000000;
	weights_in[0] = 16'b0100000000000000;
	weights_in[1] = 16'b0100001000000000;
	weights_in[2] = 16'b0100010000000000;
	weights_in[3] = 16'b0100010100000000;

	d_out[0] = 16'b0100000000000000;
	d_out[1] = 16'b0100001000000000;
	d_out[2] = 16'b0100010000000000;
	d_out[3] = 16'b0100010100000000;
    last_selection = 1;
    #20;

    
    #30;
	$display("2 - Obtido: %b Esperado: %b", out[0], d_out[0]);
	$display("3 - Obtido: %b Esperado: %b", out[1], d_out[1]);
	$display("4 - Obtido: %b Esperado: %b", out[2], d_out[2]);
	$display("5 - Obtido: %b Esperado: %b", out[3], d_out[3]);

    $finish;
end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

endmodule
