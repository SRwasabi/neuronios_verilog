`include "../NPU_module/arithmetic_modules/fpu/compar16.v"

module comparator_out  # (parameter tam = 16, parameter out_layer = 10)
	(
		input [out_layer* tam-1:0] ins,
		input [out_layer* $clog2(out_layer)-1:0] ins_idx,
		input rst,
		input att_out,
		output reg [tam-1:0] out
	);
	
	parameter IDX_TAM = $clog2(out_layer);
	
	parameter LVL_1 = out_layer/2; 			// 10  -> 5
	parameter IDX_1 = LVL_1*$clog2(out_layer);
	
	parameter LVL_2 = (LVL_1 - 1) / 2;	   // 5-1 -> 2
	parameter IDX_2 = LVL_2*$clog2(out_layer);
	
	parameter LVL_3 = LVL_2 / 2;				// 2   -> 1
	parameter IDX_3 = LVL_3*$clog2(out_layer);
	
	wire [LVL_1*tam-1:0] level_1;
	wire [IDX_1-1:0] idx_1;
	
	wire [LVL_2*tam-1:0] level_2;
	wire [IDX_2-1:0] idx_2;
	
	wire [LVL_3*tam-1:0] level_3;
	wire [IDX_3-1:0] idx_3	;
	
	wire [tam-1:0] max_value;
	wire [$clog2(out_layer)-1:0] max_idx;
	
	always@(posedge att_out, posedge rst) begin
		if(rst) out = 0;
		else begin
			out = max_idx;
		end
	end
	
	
	genvar i, j;
	
	generate 
		for (i = 0; i < LVL_1; i = i + 1) begin: level1_compar
			compar16  # (.tam(tam)) compar_1n (
				.a(ins[(i*2)*tam+:tam]),
				.a_idx(ins_idx[(i*2)*IDX_TAM+:IDX_TAM]),
				
				.b(ins[(i*2+1)*tam+:tam]),
				.b_idx(ins_idx[(i*2+1)*IDX_TAM+:IDX_TAM]),
				
				.result(level_1[(i)*tam+:tam]),
				.result_idx(idx_1[(i)*IDX_TAM+:IDX_TAM])
			);
		end
	endgenerate
	
	generate 
		for (j = 0; j < LVL_2; j = j + 1) begin: level2_compar
			compar16 # (.tam(tam)) compar_2n (
				.a(level_1[(j*2)*tam+:tam]),
				.a_idx(idx_1[(j*2)*IDX_TAM+:IDX_TAM]),
				
				.b(level_1[(j*2+1)*tam+:tam]),
				.b_idx(idx_1[(j*2+1)*IDX_TAM+:IDX_TAM]),
				
				.result(level_2[(j)*tam+:tam]),
				.result_idx(idx_2[(j)*IDX_TAM+:IDX_TAM])
			);
		end
	endgenerate
	
	compar16 # (.tam(tam)) compar_3n (
		.a(level_2[0*tam+:tam]),
		.a_idx(idx_2[0*IDX_TAM+:IDX_TAM]),
		
		.b(level_2[1*tam+:tam]),
		.b_idx(idx_2[1*IDX_TAM+:IDX_TAM]),
		
		.result(level_3),
		.result_idx(idx_3)
	);
	
	compar16 # (.tam(tam)) compar_final (
		.a(level_3),
		.a_idx(idx_3),
		
		.b(level_1[(LVL_1-1)*tam+:tam]),
		.b_idx(idx_1[(LVL_1-1)*IDX_TAM+:IDX_TAM]),
		
		.result(max_value),
		.result_idx(max_idx)
	);
	

endmodule