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
        if (rst || !init) count <= 0;
        else count <= count + 1;
    end

endmodule


//==============================================================================

module FSM  # (parameter count_param = 16, parameter layer = 100, parameter in_qnt = 784)
    (
        input clk,
        input rst,
        input [count_param-1:0] count,
        output reg cont_init,
        output reg [layer-1:0] PE_en
        
    );

    parameter RST = 2'b00;
    parameter SUM = 2'b01;
    parameter ADD_BIAS = 2'b10;

    reg [1:0] state;
    reg [1:0] next_state;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            next_state <= RST;
            cont_init <= 0;
        end

        else begin
            state <= next_state;
            case (state)

                RST: begin
                    
                    if (state == RST) begin 
                        next_state <= SUM;
                        PE_en <= {layer{1'b1}};
                        cont_init <= 1;
                    end
                    else begin 
                        PE_en <= 0;
                    end
                end

                SUM: begin 
                    if (count == in_qnt - 1) begin
                        next_state <= ADD_BIAS;
                        cont_init <= 0;
                    end
                    if (!cont_init) begin
                        PE_en <= 0;
                    end
                end

                ADD_BIAS: begin
                    next_state = RST;
                end

                default: next_state <= RST;
            endcase
        end
    end
    
endmodule
