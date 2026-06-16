
module FSM  # (parameter layer = 100, parameter in_qnt = 784, parameter out_layer = 10)
    (
        input clk,
        input rst,
        input over_input,
        input over_input_out,
        input [$clog2(in_qnt):0] addr_wei,
        input [$clog2(layer):0] addr_wei_out,

        output reg count_init,
        output reg count_init_out,
        output reg weight_wr,
        output reg weight_out_wr,
        output reg [layer-1:0] PE_en,
        output reg [out_layer-1:0] PE_out_en,
        output reg atv_en,
        output reg atv_out_en,
        output reg att_out,
		
		output [3:0] current_state
    );

    parameter RST = 4'b0000;
    parameter DUMP_WEIGHTS = 4'b0001;
    parameter DUMP_WEIGHTS_OUT = 4'b0010;

    parameter SUM = 4'b0011;
    parameter SUM_delay1 = 4'b0100;
    parameter SUM_delay2 = 4'b0101;
    parameter BIAS = 4'b0110;

    parameter ATV = 4'b0111;

    parameter OUT_SUM = 4'b1000;
    parameter OUT_delay1 = 4'b1001;
    parameter OUT_delay2 = 4'b1010;
    parameter OUT_BIAS = 4'b1011;

    parameter FINAL_RESULT = 4'b1100;
	 parameter ATT_OUT = 4'b1101;


    reg [3:0] state ;
    reg [3:0] next_state;
    
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
                next_state = SUM_delay1;
            end

            SUM_delay1: begin
                next_state = SUM_delay2;
            end

            SUM_delay2: begin
                if (addr_wei == in_qnt)
                    next_state = BIAS;
                else
                    next_state = SUM_delay2;
            end

            BIAS: begin
                next_state = ATV;
            end

            ATV: begin
                next_state = OUT_SUM;
            end

            OUT_SUM: begin
                next_state = OUT_delay1;
            end

            OUT_delay1: begin
                next_state = OUT_delay2;
            end

            OUT_delay2: begin
                if (addr_wei_out == layer)
                    next_state = OUT_BIAS;
                else
                    next_state = OUT_delay2;
            end

            OUT_BIAS: begin
                next_state = FINAL_RESULT;
            end

            FINAL_RESULT: begin
                next_state = ATT_OUT;
            end
				
				ATT_OUT: begin
					 next_state = SUM;
				end

            default: next_state = RST;
        endcase
    end

    always @(*) begin
        count_init = 0;
        count_init_out = 0;
        PE_en = 0;
        PE_out_en = 0;
        weight_wr = 0;
        weight_out_wr = 0;
        att_out = 0;
        atv_en = 0;
        atv_out_en = 0;

        case (state)

            RST: begin
                count_init = 0;
                count_init_out = 0;
                PE_en = 0;
                PE_out_en = 0;
                weight_wr = 0;
                weight_out_wr = 0;
                att_out = 0;
                atv_en = 0;
                atv_out_en = 0;
            end

            DUMP_WEIGHTS: begin

                count_init = 1;
                weight_wr = 1;
            end

            DUMP_WEIGHTS_OUT: begin
                weight_out_wr = 1;
                count_init_out = 1;
            end

            SUM: begin
                count_init = 1;

            end

            SUM_delay1: begin
                count_init = 1;
            end

            SUM_delay2: begin
                PE_en = {layer{1'b1}};
            end

            BIAS: begin
                PE_en = {layer{1'b1}};
            end
            
            ATV: begin
                atv_en = 1;
            end

            OUT_SUM: begin
                count_init_out = 1;
            end

            OUT_delay1: begin
                count_init_out = 1;
            end

            OUT_delay2: begin
                PE_out_en = {out_layer{1'b1}};
                count_init_out = 1;
            end

            OUT_BIAS: begin
                PE_out_en = {out_layer{1'b1}};
            end
				
            FINAL_RESULT: begin
				atv_out_en = 1;
            end 
					
            ATT_OUT: begin
                att_out = 1;
            end

        endcase
    end

    assign current_state = state;
    
endmodule