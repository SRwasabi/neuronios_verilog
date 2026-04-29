`include "../NPU_module/matrix_PE.v"
`include "../NPU_module/control_modules/counter.v"
`include "../NPU_module/control_modules/fsm.v"
`include "../NPU_module/control_modules/mux.v"
`include "../NPU_module/individual_neurons/activations.v"

//==============================================================================

module Core_NPU #(parameter tam = 16, parameter layer = 2, parameter in_qnt = 2, parameter out_layer = 1) 
    (
        input clk,
        input rst,

        input [tam-1:0] bus_input,
        input [tam-1:0] bus_weights,
        input [tam-1:0] bus_weights_out,
        //input [layer*tam-1:0] bus_weights,
        //input [out_layer*tam-1:0] bus_weights_out,
        
        output [$clog2(in_qnt):0] input_count,
        output [$clog2(layer):0] input_count_out,
        
        output [$clog2(in_qnt):0] addr_neuro_weight,
        output [$clog2(layer):0] addr_neuro_weight_out,
		  
		  output [layer*tam-1:0] acc_out_debug_bus,

			output [2:0] fsm_state,
        output reg [tam-1:0] npu_out
    );

    // Register for weights
    /*
    reg [layer*tam-1:0][0:in_qnt] ram_weights ;
    reg [out_layer*tam-1:0][0:layer] ram_weights_out ; 
    */
    reg [in_qnt:0] ram_weights [layer*tam-1:0];
	 
	 // reg [layer*tam-1:0] ram_weights [0:in_qnt]; GEMINI FALOU QUE É ASSIM
    reg [layer:0]ram_weights_out [out_layer*tam-1:0] ; 

    reg [layer*tam-1:0] buffer_weights;
    reg [out_layer*tam-1:0] buffer_weights_out;


    //FSM wires
    wire [layer-1:0] PE_en;
    wire [out_layer-1:0] PE_out_en;
    wire init_wire;
    wire init_hid_wire;
    wire weight_wr;
    wire weight_out_wr;
    wire weight_rd;
    wire weight_out_rd;
    reg buffer_wr;
    reg buffer_out_wr;
    wire over;
    wire over_out;
    wire over_input;
    wire over_input_out;
    wire att_out;

    // Internal outputs
    wire [layer*tam-1:0] acc_out;
    wire [out_layer*tam-1:0] acc_out_2;
    wire [(layer+1)*tam-1:0] Relu_out;
    wire [out_layer*tam-1:0] linear_out;

    //Mux wires
    wire [tam-1:0] bus_input_out;
    wire [layer*tam-1:0] bus_weights_internal;
    wire [out_layer*tam-1:0] bus_weights_out_internal;

    genvar i, j, k;
    integer idx, w;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            buffer_wr <= 0;
        end
        else if (input_count == in_qnt && addr_neuro_weight == layer-1) buffer_wr <= 0;
        else buffer_wr <= 1;
    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            buffer_out_wr <= 0;
        end
        else if (input_count_out == layer && addr_neuro_weight_out == out_layer-1) buffer_out_wr <= 0;
        else buffer_out_wr <= 1;
    end

    // Write weights in RAM
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            idx <= 0;
            w <= 0;


            /*
            for (w = 0; w < in_qnt; w = w + 1) begin
                ram_weights[w] <= 0;
                buffer_weights <= 0;
            end
            for (w = 0; w < layer; w = w + 1) begin
                ram_weights_out[w] <= 0;
                buffer_weights_out <= 0;
            end

            ram_weights <= 0;
            ram_weights_out <= 0;
            buffer_weights <= 0;
            buffer_weights_out <= 0;
            */
        end
        else if(weight_wr) begin
            if(buffer_wr) buffer_weights[addr_neuro_weight*tam +: tam] <= bus_weights;
            if(over) ram_weights[input_count-1] <= buffer_weights;
        end
        else if(weight_out_wr) begin
            if(buffer_out_wr) buffer_weights_out[addr_neuro_weight_out*tam +: tam] <= bus_weights_out;
            if(over_out) ram_weights_out[input_count_out-1] <= buffer_weights_out;
        end
    end

    // Mux for output
    always @(posedge clk, posedge rst) begin
        if(rst) npu_out <= 0;
        else if(att_out) begin
            for (idx = 0; idx < out_layer; idx = idx + 1) begin
                if(linear_out[idx*tam +: tam] > npu_out) npu_out <= linear_out[idx*tam +: tam];
            end
        end
    end

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
            .count(addr_neuro_weight),
            .count_input(input_count),
            .over(over),
            .over_input(over_input)
        );

    counter # (
            .weights(layer),
            .layer(out_layer)
        ) 
        counter_out_layer (
            .clk(clk), 
            .rst(rst), 
            .init(init_hid_wire), 
            .mode(weight_out_wr),
            .count(addr_neuro_weight_out),
            .count_input(input_count_out),
            .over(over_out),
            .over_input(over_input_out)
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
            .count_init_hid(init_hid_wire),
            .input_count(input_count),
            .input_count_out(input_count_out),
            .PE_en(PE_en),
            .PE_out_en(PE_out_en),
            .weight_wr(weight_wr),
            .weight_out_wr(weight_out_wr),
            .att_out(att_out),
            .addr_neuro_weight(addr_neuro_weight),
            .addr_neuro_weight_out(addr_neuro_weight_out),
            .over_input(over_input),
            .over_input_out(over_input_out),
				.current_state(fsm_state)
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
                .result( Relu_out[i*tam +: tam]), 
                .en(1'b1)
            );
        end
    endgenerate

    variable_mux # (
        .tam(tam), 
        .in_qnt(layer)
    ) variable_mux_unit (
        .in( Relu_out), 
        .sel(input_count_out), 
        .out(bus_input_out)
    );
	 
	 // OS PESOS NÃO ESTÃO CHEGANDO

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
                .v(acc_out_2[j*tam +: tam]), 
                .result(linear_out[j*tam +: tam]), 
                .en(1'b1)
            );
        end
    endgenerate

    assign Relu_out[layer*tam +: tam] = 16'b0011110000000000;
    assign bus_weights_internal = ram_weights[input_count];
    assign bus_weights_out_internal = ram_weights_out[input_count_out];
	 assign acc_out_debug_bus = bus_weights_internal;

	 
endmodule