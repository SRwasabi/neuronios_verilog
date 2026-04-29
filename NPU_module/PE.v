`include "../NPU_module/MAC.v"

module PE # (parameter tam = 16)
    (
        input [tam-1:0] data_in,
        input [tam-1:0] bus_w,
        input clk,
        input rst,
        input en,
        // PIPELINE
        //output reg [tam-1:0] bus_out,
        //output reg [tam-1:0] w_out,
        output [tam-1:0] acc_out
    );


    MAC mac_unit (
        .data_in(data_in), 
        .w_in(bus_w), 
        .clk(clk), 
        .rst(rst), 
        .mac_out(acc_out), 
        .en(en)
    );

endmodule