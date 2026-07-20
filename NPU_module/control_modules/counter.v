
module counter # (parameter weights = 784, parameter layer = 100)
    (
        input clk,
        input init,
        input rst,
        input mode,
        output reg over,
        output reg over_second,
        //output reg [$clog2(weights):0] count,
        output reg [$clog2(weights):0] second_count
    );

    parameter WRITING = 1'b1;
    parameter READING = 1'b0;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            //count <= 0;
            second_count <= 0;
            over <= 0;
        end


        else if(!init) begin
            //count <= 0;
            second_count <= 0;
            over <= 0;
            over_second <= 0;
        end 
        /*
        else if (mode == WRITING) begin
            over_second <= 0;
            over <= 0;

            if (count >= layer-1 && (second_count) < weights) begin
                count <= 0;
                over <= 1;
                second_count <= second_count + 1;
            end
            else if(((second_count+1) >= weights) && (count >= layer-1) )begin
                    over_second <= 1;
            end 
            else count <= count + 1;
        end
        */
        else if (mode == READING) begin
            if(second_count == weights) begin
                second_count <= 0;
            end
            else second_count <= second_count + 1;
        end
    end

endmodule
