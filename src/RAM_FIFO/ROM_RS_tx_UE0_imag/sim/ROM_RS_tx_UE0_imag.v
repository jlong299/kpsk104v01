// ROM_RS_tx_UE0_imag.v

// Generated using ACDS version 15.1 185

`timescale 1 ps / 1 ps
module ROM_RS_tx_UE0_imag (
		input  wire [10:0] address, //  rom_input.address
		input  wire        clock,   //           .clk
		output wire [17:0] q        // rom_output.dataout
	);

	ROM_RS_tx_UE0_imag_rom_1port_151_2ceuyda rom_1port_0 (
		.address (address), //  rom_input.address
		.clock   (clock),   //           .clk
		.q       (q)        // rom_output.dataout
	);

endmodule
