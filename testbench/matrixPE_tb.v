`include "../NPU_module/matrix_PE.v"

`timescale 1ns/100ps
`define tam 16
`define layer 2
`define in_qnt 2


module matrixPE_tb;
reg clk;
reg rst;
reg [`layer * `tam-1:0]  RAM_weights [0:`in_qnt];      // 6 elements: 5 down to 0
wire [`layer * `tam-1:0] weights_in;
wire [`layer * `tam-1:0]out;
reg [(`tam-1):0] buffer_data [`in_qnt:0];
wire [(`tam-1):0] data;
reg [(`layer-1):0] PE_en;
reg [$clog2(`in_qnt):0] addr_data;
integer i;

reg last_selection; // When last selection is made, all PEs are enabled at the same time

matrix_PE # (.tam(`tam), .layer(`layer)) matrix_1 (.bus_input(data), .bus_weights(weights_in), .clk(clk), .rst(rst), .acc_out(out), .PE_en(PE_en));

always @(posedge clk, posedge rst) begin

    if(rst) begin 
        addr_data = 0;
        PE_en <= 2'b00; // Disable all PEs on reset
    end
    else PE_en <= 2'b11; // Enable all PEs after reset

    if (PE_en == 2'b11 && addr_data < `in_qnt) begin
        addr_data <= addr_data + 1; // Increment address to read next set of weights
    end
    else if (PE_en == 2'b11 && addr_data >= `in_qnt) begin
       PE_en <= 2'b00; // Disable PEs after last selection
       addr_data <= 0; // Reset address for next round
    end

end

initial begin
    $dumpfile("../vcds/matrix_pe.vcd");
    $dumpvars(0);
	$display("teste");
	rst = 1;
    buffer_data[0] = 16'b0;
    buffer_data[1] = 16'b0;
    buffer_data[2] = 16'h3c00;

    RAM_weights[0] = 32'b0011100000000000_1011110000000000; // entrada 1, neurônio 0 e neurônio 1    
    RAM_weights[1] = 32'b1011110000000000_0011100000000000; // entrada 2, neurônio 0 e neurônio 1
    RAM_weights[2] = 32'b1011100000000000_1011100000000000; // BIAS, neurônio 0 e neurônio 1

    #10;
    rst = 0;

    #100;

    $finish;
end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

assign weights_in = RAM_weights[addr_data];
assign data = buffer_data[addr_data];

endmodule
