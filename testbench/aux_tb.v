`include "aux_modules.v"
`define layer 2
`define out_layer 1
`define in_qnt 2

module FSM_tb;
reg clk;
reg rst;
wire count_init;
wire [`in_qnt-1:0] count;
wire [`layer-1:0] PE_en;
wire [`out_layer-1:0] PE_out_en;

counter # (
    .tam(`in_qnt)
    ) 
    counter_unit (
        .clk(clk), 
        .rst(rst), 
        .init(count_init),
        .count(count)
    );

FSM # (
        .count_param(`in_qnt), 
        .layer(`layer), 
        .in_qnt(`in_qnt),
        .out_layer(`out_layer)
    ) 
    FSM_unit (
        .clk(clk), 
        .rst(rst), 
        .count(count),
        .count_init(count_init),
        .PE_en(PE_en),
        .PE_out_en(PE_out_en)
    );

initial begin
    $dumpfile("FSM.vcd");
    $dumpvars(0);
    $monitor("State: %b Next State: %b PE_en: %b PE_out_en: %b", FSM_unit.state, FSM_unit.next_state, FSM_unit.PE_en, FSM_unit.PE_out_en);

    rst = 1;
    #10;
    rst = 0;
    #200;

    $finish;
end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end



endmodule