`include "../NPU_module/arithmetic_modules/fpu.v"

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
		  
		  else mac_out <= 0;
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