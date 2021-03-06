// lpm_mult_25_18.v

// Generated using ACDS version 15.1 185

`timescale 1 ps / 1 ps
module lpm_mult_25_18 (
		input  wire [24:0] dataa,  //  mult_input.dataa
		input  wire [17:0] datab,  //            .datab
		input  wire        clock,  //            .clock
		output wire [42:0] result  // mult_output.result
	);

	lpm_mult_25_18_lpm_mult_151_lnncfha lpm_mult_0 (
		.dataa  (dataa),  //  mult_input.dataa
		.datab  (datab),  //            .datab
		.clock  (clock),  //            .clock
		.result (result)  // mult_output.result
	);

endmodule
