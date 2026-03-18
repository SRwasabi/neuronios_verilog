`include "neuro_modules.v"
`include "aux_modules.v"

//==============================================================================

module Core_NPU #(parameter tam = 16, parameter layer = 100, parameter in_qnt = 784) 
    (
        input clk,
        input rst,
        input [tam-1:0] bus_input,
        input [layer-1:0][tam-1:0] bus_weights
    );

    wire [$clog2(in_qnt):0] count;
    wire [layer-1:0][tam-1:0] acc_out;
    wire [1:0] state_wire;
    wire [layer-1:0] PE_en;

    counter # (
            .tam($clog2(in_qnt)+1)
        ) 
        counter_unit (
            .clk(clk), 
            .rst(rst), 
            .count(count)
        );

    FSM # (
            .count_param($clog2(in_qnt)+1), 
            .layer(layer), 
            .in_qnt(in_qnt)
        ) 
        FSM_unit (
            .clk(clk), 
            .rst(rst), 
            .state(state_wire), 
            .count(count), 
            .next_state(state_wire), 
            .PE_en(PE_en)
        );

    matrix_PE # (
            .tam(tam), 
            .layer(layer)
        ) 
        matrix_unit (
            .bus_input(bus_input), 
            .bus_weights(bus_weights), 
            .clk(clk), 
            .rst(rst), 
            .PE_en(PE_en), 
            .acc_out(acc_out)
        );

    
endmodule


//==============================================================================

module matrix_PE # (parameter tam = 16, parameter layer = 100)
    (
        input [tam-1:0] bus_input, 
        input [layer-1:0][tam-1:0] bus_weights,
        input clk,
        input rst,
        input [layer-1:0] PE_en,
        output [layer-1:0][tam-1:0] acc_out
    );

    genvar i;
    for (i=0; i < layer; i = i + 1) begin: PEs
        PE # (
            .tam(tam)
        ) pe_unit (
            .data_in(bus_input), 
            .bus_w(bus_weights[i]), 
            .clk(clk), 
            .rst(rst), 
            .acc_out(acc_out[i]), 
            .en(PE_en[i])
        );
    end

endmodule

//==============================================================================

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

//==============================================================================

module MAC # (parameter tam = 16)
    (
        input [tam-1:0] data_in,
        input [tam-1:0] w_in,
        input clk,
        input rst,
        input en,
        output reg [tam-1:0] mac_out
    );

    wire [tam-1:0] wire_mult;
    wire [tam-1:0] wire_sum;

    always @ (posedge clk, posedge rst) begin
        if (rst) mac_out <= 0;
        else mac_out <= wire_sum;
    end
    
    multi16 utt0 (
        .a(data_in), 
        .b(w_in), 
        .en(en), 
        .result(wire_mult)
    );
        
    sum16 sum0 (
        .a(mac_out), 
        .b(wire_mult), 
        .result(wire_sum), 
        .en(en)
    );



endmodule

//==============================================================================
