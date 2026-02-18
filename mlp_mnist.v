`include "neuro_modules.v"

//==============================================================================

module MAC # (parameter tam = 16)
    (
        input [tam-1:0] data_in,
        input [tam-1:0] initial_weight,
        input clk,
        input rst,
        output [tam-1:0] mac_out
    );

    reg [tam-1:0] weight;
    wire [tam-1:0] wire_mult;

    always @ (posedge clk, posedge rst) begin
        if (rst) weight <= initial_weight;
    end

    
    multi16 utt0 ( .a(data_in), .b(initial_weight), .en(1'b1), .result(mac_out));

endmodule


module PE # (parameter tam = 16, parameter data_size = 784)
    (
        input [tam-1:0] bus_in,
        input [tam-1:0] bias,
        input [data_size-1:0][tam-1:0] initial_weight,
        input clk,
        input rst,
        output reg [tam-1:0] acc_out
    );
    wire [data_size:0][tam-1:0] partial_acc; //bias include
    //wire [data_size-1:0][tam-1:0] inside_in;
    wire [tam-1:0] bus_acc;
    reg [$clog2(data_size):0] sel;
    reg [tam-1:0] acc_reg;
    wire [tam-1:0] acc_a;


    always @(posedge clk, posedge rst) begin
        if(rst) begin
            acc_out <= 0;
            sel <= 0;
        end
        else if(sel < data_size+1) begin
            sel <= sel + 1;
            acc_out <= acc_a;
        end
    end

    genvar i;
    generate
        for (i = 0; i < data_size; i = i + 1) begin: Mac_Matrix
            MAC mac_units (.data_in(bus_in), .initial_weight(initial_weight[i]), .clk(clk), .rst(rst), .mac_out(partial_acc[i]));
        end
    endgenerate

    variable_mux #(.tam(tam), .in_qnt(data_size))  mux_acc  (.in(partial_acc), .out(bus_acc), .sel(sel));
    sum16 acc (.a(acc_out), .b(bus_acc), .result(acc_a), .en(1'b1));

    assign partial_acc [data_size] = bias;
    
endmodule


//==============================================================================
