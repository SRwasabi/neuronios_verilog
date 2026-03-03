`include "neuro_modules.v"


//==============================================================================

module MAC # (parameter tam = 16)
    (
        input [tam-1:0] data_in,
        input [tam-1:0] w_in,
        input clk,
        input rst,
        output reg [tam-1:0] mac_out
    );

    wire [tam-1:0] wire_mult;
    wire [tam-1:0] wire_sum;

    always @ (posedge clk, posedge rst) begin
        if (rst) mac_out <= 0;
        else mac_out <= wire_sum;
    end
    
    multi16 utt0 ( .a(data_in), .b(w_in), .en(1'b1), .result(wire_mult));
    sum16 sum0 (.a(mac_out), .b(wire_mult), .result(wire_sum), .en(1'b1));



endmodule

//==============================================================================

module PE # (parameter tam = 16)
    (
        input [tam-1:0] bus_in,
        input [tam-1:0] bus_w,
        input clk,
        input rst,
        // PIPELINE
        //output reg [tam-1:0] bus_out,
        //output reg [tam-1:0] w_out,
        output [tam-1:0] acc_out
    );


    MAC mac_unit (.data_in(bus_in), .w_in(bus_w), .clk(clk), .rst(rst), .mac_out(acc_out));

endmodule

//==============================================================================

module matrix_PE # (parameter tam = 16, parameter layer = 100)
    (
        input [tam-1:0] bus_input,
        input [tam-1:0] bias,
        input [layer-1:0][tam-1:0] bus_weights,
        input clk,
        input rst,
        output [layer-1:0][tam-1:0] acc_out
    );

    genvar i;
    for (i=0; i < layer; i = i + 1) begin: PEs
        PE # (.tam(tam)) pe_unit (.bus_in(bus_input), .bus_w(bus_weights[i]), .clk(clk), .rst(rst), .acc_out(acc_out[i]));
    end

endmodule

//==============================================================================
/*
module moduleName #(parameters) 
    (
        ports
    );
    
endmodule