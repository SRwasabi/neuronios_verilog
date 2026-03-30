module variable_mux # (parameter tam = 16, parameter in_qnt = 784)
    (
        input [in_qnt:0][tam-1:0] in,
        input [$clog2(in_qnt):0] sel,
        output [tam-1:0] out
    );

    assign out = in[sel];

endmodule

module variable_mux_3d # (parameter tam = 16, parameter in_qnt = 784, parameter layer = 100)
    (
        input [in_qnt:0][layer-1:0][tam-1:0] in,
        input [$clog2(in_qnt):0] sel,
        output [layer-1:0][tam-1:0] out
    );

    assign out = in[sel];
endmodule

//==============================================================================

module counter # (parameter tam = 16)
    (
        input clk,
        input init,
        input rst,
        output reg [tam-1:0] count
    );

    always @(posedge clk, posedge rst) begin
        if (rst) count <= 0;
        else if(!init) count <= 0;
        else count <= count + 1;
    end

endmodule


//==============================================================================

module FSM  # (parameter tam = 16, parameter tamout = 16, parameter layer = 100, parameter in_qnt = 784, parameter out_layer = 10)
    (
        input clk,
        input rst,
        input [tam-1:0] count,
        input [tamout-1:0] hidden_count,
        output reg count_init,
        output reg count_init_hid,
        output reg [layer-1:0] PE_en,
        output reg [out_layer-1:0] PE_out_en
    );

    parameter RST = 3'b000;
    parameter SUM = 3'b001;
    parameter ADD_BIAS = 3'b011;
    parameter OUT_SUM = 3'b010;
    parameter OUT_BIAS = 3'b110;

    reg [2:0] state;
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
                next_state = SUM;
            end


            SUM: begin
                if (count == in_qnt- 1)
                    next_state = ADD_BIAS;
                else
                    next_state = SUM;
            end

            ADD_BIAS: begin
                next_state = OUT_SUM;
            end

            OUT_SUM: begin
                if (hidden_count == layer-1)
                    next_state = OUT_BIAS;
                else
                    next_state = OUT_SUM;
            end

            OUT_BIAS: begin
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
        
        case (state)

            RST: begin
                PE_en = {layer{1'b1}};
                PE_out_en = 0;
                count_init = 0;
                count_init_hid = 0;
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

        endcase
    end
    
endmodule
