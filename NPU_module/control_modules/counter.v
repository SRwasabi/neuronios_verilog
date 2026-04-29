
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
