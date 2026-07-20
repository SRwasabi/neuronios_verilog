module compar16 # (parameter tam = 16, parameter idx_size = $clog2(10))
	(
		input [tam-1:0] a, b,
		input [idx_size-1:0] a_idx, b_idx,
		output [tam-1:0] result,
		output [idx_size-1:0] result_idx
	);
	
	
    assign {result, result_idx} =   (a[15] == 0 && b[15] == 1) 								? {a, a_idx}: 
                                    (a[15] == 1 && b[15] == 0) 								? {b, b_idx}:
                                    // =================== +A e +B 
                                    (a[15] == 0 && b[15] == 0) && (a[14:10] > b[14:10])     ? {a, a_idx}:
                                    (a[15] == 0 && b[15] == 0) && (a[14:10] < b[14:10])     ? {b, b_idx}:
                                    (a[15] == 0 && b[15] == 0) && (a[9:0] > b[9:0]) 	    ? {a, a_idx}:
                                    (a[15] == 0 && b[15] == 0) && (a[9:0] < b[9:0])	  	    ? {b, b_idx}:
                                    // =================== -A e -B 
                                    (a[14:10] > b[14:10]) 								    ? {b, b_idx}:
                                    (a[14:10] < b[14:10]) 								    ? {a, a_idx}:
                                    (a[9:0] > b[9:0]) 									    ? {b, b_idx}:
                                    {a, a_idx};
                            
endmodule