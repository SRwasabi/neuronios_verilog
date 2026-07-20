module RAM # (parameter tam = 16, parameter layer = 2, parameter in_qnt = 2)
    (
        input clk,
        //input wr,
        //input [layer*tam-1:0] data_in,
        input [$clog2(in_qnt):0] addr,
        output reg [layer*tam-1:0] data_out
    );

    //[valores dos pesos em si] mem [endereços do peso em base da entrada]
    reg [layer*tam-1:0] mem [0:in_qnt]; 
    
    initial begin
        $readmemh("../NPU_module/memorys_modules/hidden_hex.txt", mem);
    end

    always @(posedge clk) begin
        //if(wr) mem[addr] <= data_in;
        //else 
        data_out <= mem[addr];
    end

endmodule