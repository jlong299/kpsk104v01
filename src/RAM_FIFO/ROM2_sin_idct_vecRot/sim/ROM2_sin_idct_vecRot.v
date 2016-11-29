// ROM2_sin_idct_vecRot.v

// Generated using ACDS version 15.1 185

`timescale 1 ps / 1 ps
module ROM2_sin_idct_vecRot (
		input  wire [10:0] address, //  rom_input.address
		input  wire        clock,   //           .clk
		output wire [17:0] q        // rom_output.dataout
	);

	ROM2_sin_idct_vecRot_rom_1port_151_scljbpy rom_1port_0 (
		.address (address), //  rom_input.address
		.clock   (clock),   //           .clk
		.q       (q)        // rom_output.dataout
	);

endmodule
