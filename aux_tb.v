`include "aux_modules.v"
`define layer 2
`define in_qnt 2

module FSM_tb;
reg clk;
reg rst;
wire cont_init;
wire [`in_qnt-1:0] count;
wire [`layer-1:0] PE_en;

counter # (
    .tam(`in_qnt)
    ) 
    counter_unit (
        .clk(clk), 
        .rst(rst), 
        .init(cont_init),
        .count(count)
    );

FSM # (
        .count_param(`in_qnt), 
        .layer(`layer), 
        .in_qnt(`in_qnt)
    ) 
    FSM_unit (
        .clk(clk), 
        .rst(rst), 
        .count(count),
        .cont_init(cont_init),
        .PE_en(PE_en)
    );

initial begin
    $dumpfile("FSM.vcd");
    $dumpvars(0);
    $monitor("State: %b Next State: %b PE_en: %b", FSM_unit.state, FSM_unit.next_state, FSM_unit.PE_en);

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