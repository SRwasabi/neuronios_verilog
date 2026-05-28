`include "../NPU_module/matrix_PE.v"
`include "../NPU_module/control_modules/counter.v"
`include "../NPU_module/control_modules/fsm.v"
`include "../NPU_module/control_modules/mux.v"
`include "../NPU_module/individual_neurons/activations.v"
`include "../NPU_module/control_modules/memory.v"

//==============================================================================

module Core_NPU #(parameter tam = 16, parameter layer = 2, parameter in_qnt = 2, parameter out_layer = 1) 
    (
        input clk,
        input rst,

        input [tam-1:0] bus_input,
        input [tam-1:0] bus_weights,
        input [tam-1:0] bus_weights_out,
        
        output [$clog2(in_qnt):0] input_count,
        output [$clog2(layer):0] input_count_out,
        
        output [$clog2(in_qnt):0] weight_count,
        output [$clog2(layer):0] weight_count_out,

        output relu_en,

        output reg [tam-1:0] npu_out
    );

    // Mem Controls
    reg [layer*tam-1:0] buffer_weights;
    reg [out_layer*tam-1:0] buffer_weights_out;
    reg [$clog2(in_qnt):0] addr_wei;
    reg [$clog2(layer):0] addr_wei_out;
    reg ram_wr;
    reg ram_wr_out;

    //FSM wires
    wire [layer-1:0] PE_en;
    wire [out_layer-1:0] PE_out_en;
    wire init_wire;
    wire init_out_wire;
    wire weight_wr;
    wire weight_out_wr;
    wire over;
    wire over_out;
    wire over_input;
    wire over_input_out;
    wire att_out;

    reg buffer_wr;
    reg buffer_out_wr;

    // Internal outputs
    wire [layer*tam-1:0] acc_out;
    wire [out_layer*tam-1:0] acc_out_2;
    wire [(layer+1)*tam-1:0] relu_out;
    reg  [tam-1:0] relu_buffer [layer:0];
    wire [out_layer*tam-1:0] linear_out;

    //Mux wires
    reg [tam-1:0] bus_input_out;
    wire [layer*tam-1:0] bus_weights_internal;
    wire [out_layer*tam-1:0] bus_weights_out_internal;

    //En for Activations
    //wire relu_en;
    wire linear_en;

    genvar i, j, k;
    integer idx, w;

    always @(posedge clk, posedge rst) begin
        if(rst) buffer_wr <= 0;
        else if (input_count == in_qnt && weight_count == layer-1) buffer_wr <= 0;
        else buffer_wr <= 1;
    end

    always @(posedge clk, posedge rst) begin
        if(rst) buffer_out_wr <= 0;
        else if (input_count_out == layer && weight_count_out == out_layer-1) buffer_out_wr <= 0;
        else buffer_out_wr <= 1;
    end

    // Write weights in RAM
    always @(posedge clk, posedge rst, posedge weight_wr, posedge weight_out_wr) begin

        ram_wr <= 0;
        ram_wr_out <= 0;

        if(rst) begin
            idx <= 0;
            w <= 0;
        end
        else if(weight_wr) begin
            if(buffer_wr) begin
                buffer_weights[weight_count*tam +: tam] <= bus_weights;
            end
            ram_wr <= (weight_count == layer-1) ? 1 : 0;

        end
        else if(weight_out_wr) begin
            if(buffer_out_wr) begin
                buffer_weights_out[weight_count_out*tam +: tam] <= bus_weights_out;
            end
            ram_wr_out <= (weight_count_out == out_layer-1) ? 1 : 0;
        end

        addr_wei <= input_count;
        addr_wei_out <= input_count_out;
    end

    always @(posedge clk) begin
        for (idx = 0; idx < layer+1; idx = idx + 1) begin
            relu_buffer[idx] <= relu_out[idx*tam +: tam];
        end
        bus_input_out <= relu_buffer[addr_wei_out];
    end

    // Mux for output
    always @(posedge clk, posedge rst) begin
        if(rst) npu_out <= 0;
        else if(att_out) begin
            npu_out <= linear_out[0 +: tam];
            for (idx = 1; idx < out_layer; idx = idx + 1) begin
                if(linear_out[idx*tam +: tam] > npu_out) npu_out <= linear_out[idx*tam +: tam];
            end
        end
    end

    RAM # (
        .tam(tam), 
        .layer(layer), 
        .in_qnt(in_qnt)
    ) RAM_weights (
        .clk(clk), 
        .wr(ram_wr), 
        .data_in(buffer_weights), 
        .addr(addr_wei), 
        .data_out(bus_weights_internal)
    );

    RAM # (
        .tam(tam), 
        .layer(out_layer), 
        .in_qnt(layer)
    ) RAM_weights_out (
        .clk(clk), 
        .wr(ram_wr_out), 
        .data_in(buffer_weights_out), 
        .addr(addr_wei_out), 
        .data_out(bus_weights_out_internal)
    );

    // Instatiation of modules
    counter # (
            .weights(in_qnt),
            .layer(layer)
        ) 
        counter_layer (
            .clk(clk), 
            .rst(rst), 
            .init(init_wire),
            .mode(weight_wr),
            .count(weight_count),
            .second_count(input_count),
            .over(over),
            .over_second(over_input)
        );

    counter # (
            .weights(layer),
            .layer(out_layer)
        ) 
        counter_out_layer (
            .clk(clk), 
            .rst(rst), 
            .init(init_out_wire), 
            .mode(weight_out_wr),
            .count(weight_count_out),
            .second_count(input_count_out),
            .over(over_out),
            .over_second(over_input_out)
        );

    FSM # (
            .layer(layer), 
            .in_qnt(in_qnt),
            .out_layer(out_layer)
        ) 
        FSM_unit (
            .clk(clk), 
            .rst(rst), 
            .count_init(init_wire),
            .count_init_out(init_out_wire),
            .addr_wei(addr_wei),
            .addr_wei_out(addr_wei_out),
            .PE_en(PE_en),
            .PE_out_en(PE_out_en),
            .weight_wr(weight_wr),
            .weight_out_wr(weight_out_wr),
            .att_out(att_out),
            .over_input(over_input),
            .over_input_out(over_input_out),
            .atv_en(relu_en),
            .atv_out_en(linear_en)
        );

    matrix_PE # (
            .tam(tam), 
            .layer(layer)
        ) 
        matrix_unit (
            .bus_input(bus_input), 
            .bus_weights(bus_weights_internal), 
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
                .v(acc_out[i*tam +: tam]), 
                .result(relu_out[i*tam +: tam]), 
                .en(relu_en),
                .clk(clk)
            );
        end
    endgenerate
	
    matrix_PE # (
            .tam(tam), 
            .layer(out_layer)
        ) matrix_unit2 (
            .bus_input(bus_input_out), 
            .bus_weights(bus_weights_out_internal), 
            .clk(clk), 
            .rst(rst), 
            .PE_en(PE_out_en), 
            .acc_out(acc_out_2)
        );

    generate
        for ( j = 0; j < out_layer; j = j + 1) begin: ativacao_out
            ativacao # (
                .tam(tam)
            ) ativacao_unit2 (
                .clk(clk),
                .v(acc_out_2[j*tam +: tam]), 
                .result(linear_out[j*tam +: tam]), 
                .en(linear_en)
            );
        end
    endgenerate

    assign relu_out[layer*tam +: tam] = 16'b0011110000000000;
	
endmodule