`include "neuro_modules.v"
`include "aux_modules.v"

//==============================================================================

module Core_NPU #(parameter tam = 16, parameter layer = 100, parameter in_qnt = 784, parameter out_layer = 10) 
    (
        input clk,
        input rst,
        input [tam-1:0] bus_input,
        input [layer-1:0][tam-1:0] bus_weights,
        input [out_layer-1:0][tam-1:0] bus_weights_out,
        output [$clog2(in_qnt):0] count,
        output [$clog2(layer):0] hidden_count,
        output [out_layer-1:0][tam-1:0] npu_out
    );

    wire [layer-1:0] PE_en;
    wire [out_layer-1:0] PE_out_en;
    wire init_wire;
    wire init_hid_wire;

    wire [tam-1:0] bus_input_out;
    wire [layer-1:0][tam-1:0] acc_out;
    wire [out_layer-1:0][tam-1:0] out;

    wire [layer:0][tam-1:0] atv_wire;
    genvar i, j;

    counter # (
            .tam($clog2(in_qnt)+1)
        ) 
        counter_unit (
            .clk(clk), 
            .rst(rst), 
            .init(init_wire),

            .count(count)
        );

    counter # (
            .tam($clog2(layer)+1)
        ) 
        counter_unit2 (
            .clk(clk), 
            .rst(rst), 
            .init(init_hid_wire), 
            .count(hidden_count)
        );

    FSM # (
            .tam($clog2(in_qnt)+1), 
            .tamout($clog2(layer)+1),
            .layer(layer), 
            .in_qnt(in_qnt),
            .out_layer(out_layer)
        ) 
        FSM_unit (
            .clk(clk), 
            .rst(rst), 
            .count_init(init_wire),
            .count_init_hid(init_hid_wire),
            .count(count), 
            .hidden_count(hidden_count),
            .PE_en(PE_en),
            .PE_out_en(PE_out_en)
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

    generate
        for ( i = 0; i < layer; i = i + 1) begin: ativacao
            ativacao # (
                .tam(tam)
            ) ativacao_unit (
                .v(acc_out[i]), 
                .result(atv_wire[i]), 
                .en(1'b1)
            );
        end
    endgenerate

    variable_mux # (
        .tam(tam), 
        .in_qnt(layer)
    ) variable_mux_unit (
        .in(atv_wire), 
        .sel(hidden_count), 
        .out(bus_input_out)
    );

    matrix_PE # (
            .tam(tam), 
            .layer(out_layer)
        ) matrix_unit2 (
            .bus_input(bus_input_out), 
            .bus_weights(bus_weights_out), 
            .clk(clk), 
            .rst(rst), 
            .PE_en(PE_out_en), 
            .acc_out(out)
        );

    generate
        for ( j = 0; j < out_layer; j = j + 1) begin: ativacao_out
            ativacao # (
                .tam(tam)
            ) ativacao_unit2 (
                .v(out[j]), 
                .result(npu_out[j]), 
                .en(1'b1)
            );
        end
    endgenerate
    assign atv_wire[layer] = 16'b0011110000000000;

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

        else if(en) begin
            mac_out <= wire_sum;
        end

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
