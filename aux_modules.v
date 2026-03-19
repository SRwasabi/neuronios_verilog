module variable_mux # (parameter tam = 16, parameter in_qnt = 784)
    (
        input [in_qnt:0][tam-1:0] in,
        input [$clog2(in_qnt):0] sel,
        output [tam-1:0] out
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

module FSM  # (parameter count_param = 16, parameter layer = 100, parameter in_qnt = 784)
    (
        input clk,
        input rst,
        input [count_param-1:0] count,
        output reg count_init,
        output reg [layer-1:0] PE_en
    );

    parameter RST = 2'b00;
    parameter SUM = 2'b01;
    parameter ADD_BIAS = 2'b10;

    reg [1:0] state;
    reg [1:0] next_state;

    // Sequencial: atualiza estado
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= RST;
        end
        else begin
            state <= next_state;
        end
    end

    // Combinacional: próximo estado
    always @(*) begin
        case (state)
            RST: begin
                next_state = SUM;
            end

            SUM: begin
                if (count == in_qnt - 1)
                    next_state = ADD_BIAS;
                else
                    next_state = SUM;
            end

            ADD_BIAS: begin
                next_state = RST;
            end

            default: next_state = RST;
        endcase
    end

    // Combinacional: saídas
    always @(*) begin
        // Valores padrão
        count_init = 0;
        PE_en = 0;
        
        case (state)
            RST: begin
                // No reset, preparar para próximo ciclo
                PE_en = {layer{1'b1}};
                count_init = 1;
            end
            
            SUM: begin
                PE_en = {layer{1'b1}};
                count_init = 1;
            end
            
            ADD_BIAS: begin
                // Bias - desativa tudo
                PE_en = 0;
                count_init = 0;
            end
        endcase
    end
    
endmodule
