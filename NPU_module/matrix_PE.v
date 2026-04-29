`include "../NPU_module/PE.v"

module matrix_PE # (parameter tam = 16, parameter layer = 100)
    (
        input [tam-1:0] bus_input, 
        input [layer*tam-1:0] bus_weights,
        input clk,
        input rst,
        input [layer-1:0] PE_en,
        output [layer*tam-1:0] acc_out
    );

    genvar i;
    generate
        for (i=0; i < layer; i = i + 1) begin: PEs
            PE # (
                .tam(tam)
            ) pe_unit (
                .data_in(bus_input), 
                .bus_w(bus_weights[i*tam +: tam]), 
                .clk(clk), 
                .rst(rst), 
                .acc_out(acc_out[i*tam +: tam]), 
                .en(PE_en[i])
            );
        end
    endgenerate

endmodule
