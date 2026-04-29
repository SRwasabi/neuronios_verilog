
module variable_mux # (parameter tam = 16, parameter in_qnt = 784)
    (
        input [(in_qnt+1)*tam-1:0] in,
        input [$clog2(in_qnt):0] sel,
        output [tam-1:0] out
    );

    assign out = in[sel * tam +: tam];

endmodule

module variable_mux_3d # (parameter tam = 16, parameter in_qnt = 784, parameter layer = 100)
    (
        input [(in_qnt+1)*layer*tam-1:0] in,
        input [$clog2(in_qnt):0] sel,
        output [layer*tam-1:0] out
    );

   assign out = in[sel * (layer * tam) +: (layer * tam)];
endmodule

//==============================================================================

