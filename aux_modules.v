module variable_mux # (parameter tam = 16, parameter in_qnt = 784)
    (
        input [(in_qnt+1)*tam-1:0] in,
        input [$clog2(in_qnt):0] sel,
        output [tam-1:0] out
    );

    assign out = in[sel * tam +: tam];

endmodule

module variable_mux_3d # (parameter tam = 16, parameter in_qnt = 784, parameter layer = 100)
    (
        input [(in_qnt+1)*layer*tam-1:0] in,
        input [$clog2(in_qnt):0] sel,
        output [layer*tam-1:0] out
    );

   assign out = in[sel * (layer * tam) +: (layer * tam)];
endmodule

//==============================================================================

// fazer um modes para a acontagem

module counter # (parameter weights = 784, parameter layer = 100)
    (
        input clk,
        input init,
        input rst,
        input mode,
        output reg over,
        output reg over_input,
        output reg [$clog2(weights):0] count,
        output reg [$clog2(weights):0] count_input
    );

    parameter WRITING = 1'b1;
    parameter READING = 1'b0;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            count_input <= 0;
            over <= 0;
        end


        else if(!init) begin
            count <= 0;
            count_input <= 0;
            over <= 0;
            over_input <= 0;
        end 
        
        else if (mode == WRITING) begin
            over_input <= 0;
            over <= 0;

            if (count == layer-1) begin
                count <= 0;
                over <= 1;
                count_input <= count_input + 1;
                if(count_input == weights)begin
                    over_input <= 1;
                end 
            end 
            else count <= count + 1;
        end

        else if (mode == READING) begin
            if(count_input == weights) begin
                count_input <= 0;
            end
            else count_input <= count_input + 1;
        end
    end

endmodule



//==============================================================================

module FSM  # (parameter layer = 100, parameter in_qnt = 784, parameter out_layer = 10)
    (
        input clk,
        input rst,
        input over_input,
        input over_input_out,
        input [$clog2(in_qnt):0] input_count,
        input [$clog2(layer):0] input_count_out,
        input [$clog2(in_qnt):0] addr_neuro_weight,
        input [$clog2(layer):0] addr_neuro_weight_out,

        output reg count_init,
        output reg count_init_hid,
        output reg weight_wr,
        output reg weight_out_wr,
        output reg [layer-1:0] PE_en,
        output reg [out_layer-1:0] PE_out_en,
        output reg att_out
    );

    parameter RST = 3'b000;
    parameter DUMP_WEIGHTS = 3'b001;
    parameter DUMP_WEIGHTS_OUT = 3'b010;
    parameter SUM = 3'b011;
    parameter ADD_BIAS = 3'b100;
    parameter OUT_SUM = 3'b101;
    parameter OUT_BIAS = 3'b110;
    parameter ATT_OUT = 3'b111;


    reg [2:0] state ;
    reg [2:0] next_state;
    
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= RST;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)

            RST: begin
                next_state = DUMP_WEIGHTS;
            end

            DUMP_WEIGHTS: begin
                if (over_input)
                    next_state = DUMP_WEIGHTS_OUT;
                else
                    next_state = DUMP_WEIGHTS;
            end

            DUMP_WEIGHTS_OUT: begin
                if (over_input_out)
                    next_state = SUM;
                else
                    next_state = DUMP_WEIGHTS_OUT;
            end


            SUM: begin
                if (input_count == in_qnt)
                    next_state = ADD_BIAS;
                else
                    next_state = SUM;
            end

            ADD_BIAS: begin
                next_state = OUT_SUM;
            end

            OUT_SUM: begin
                if (input_count_out == layer)
                    next_state = OUT_BIAS;
                else
                    next_state = OUT_SUM;
            end

            OUT_BIAS: begin
                next_state = ATT_OUT;
            end

            ATT_OUT: begin
                next_state = RST;
            end

            default: next_state = RST;
        endcase
    end

    always @(*) begin
        count_init = 0;
        count_init_hid = 0;
        PE_en = 0;
        PE_out_en = 0;
        weight_wr = 0;
        weight_out_wr = 0;
        att_out = 0;
        
        case (state)

            RST: begin
                PE_en = 0;
                PE_out_en = 0;
                count_init = 0;
                count_init_hid = 0;
            end

            DUMP_WEIGHTS: begin
                PE_en = 0;
                PE_out_en = 0;
                count_init = 1;
                weight_wr = 1;
                weight_out_wr = 0;
                count_init_hid = 0;
            end

            DUMP_WEIGHTS_OUT: begin
                PE_en = 0;
                PE_out_en = 0;
                count_init = 0;
                weight_wr = 0;
                weight_out_wr = 1;
                count_init_hid = 1;
            end

            SUM: begin
                PE_en = {layer{1'b1}};
                count_init = 1;
                count_init_hid = 0;

            end

            ADD_BIAS: begin
                PE_en = {layer{1'b1}};
                PE_out_en = 0;
                count_init = 0;
                count_init_hid = 0;
            end
            
            OUT_SUM: begin
                PE_out_en = {out_layer{1'b1}};
                count_init = 0;
                count_init_hid = 1;
            end

            OUT_BIAS: begin
                PE_out_en = {out_layer{1'b1}};
                count_init = 0;
                count_init_hid = 0;
            end

            ATT_OUT: begin
                att_out = 1;
            end

        endcase
    end
    
endmodule
