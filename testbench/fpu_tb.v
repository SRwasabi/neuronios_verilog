`include "fpu.v"
`timescale 1ns/100ps

module fpu16;

wire en;
reg [15:0] a_tb, b_tb;
wire [15:0] result_tb;
wire [15:0] product_tb;

assign en = 1;

sum16 sum_1 (.a(a_tb), .b(b_tb), .result(result_tb), .en(en));
multi16 mult_1 (.a(a_tb), .b(b_tb), .result(product_tb), .en(en));

initial begin
        $dumpfile("fpu.vcd");
        $dumpvars(0);
        
        // Test case 1: 1.5 + 2.25 = 3.75
        a_tb = 16'b0_01111_1000000000;  // 1.5
        b_tb = 16'b0_10000_0010000000;  // 2.25
        #10;
        $display("1.5 + 2.25 = %b (expected 0_10000_1110000000)", result_tb);

        // Test case 2: -1.5 + 2.25 = 0.75
        a_tb = 16'b1_01111_1000000000;  // -1.5
        b_tb = 16'b1_10000_0010000000;  // 2.25
        #10;
        $display("-1.5 + 2.25 = %b (expected 0_01110_1000000000)", result_tb);

        // Test case 3: 0.75 + 0.75 = 1.5
        a_tb = 16'b0_01110_1000000000;  // 0.75
        b_tb = 16'b0_01110_1000000000;  // 0.75
        #10;
        $display("0.75 + 0.75 = %b (expected 0_01111_1000000000)", result_tb);

        $finish;
    end


endmodule