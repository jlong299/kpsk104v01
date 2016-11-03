// RAM_dct_preFFT_reod.v

// Generated using ACDS version 15.1 185

`timescale 1 ps / 1 ps
module RAM_dct_preFFT_reod (
		input  wire [31:0] data,      //  ram_input.datain
		input  wire [10:0] wraddress, //           .wraddress
		input  wire [10:0] rdaddress, //           .rdaddress
		input  wire        wren,      //           .wren
		input  wire        clock,     //           .clock
		output wire [31:0] q          // ram_output.dataout
	);

	RAM_dct_preFFT_reod_ram_2port_151_nn5gxoa ram_2port_0 (
		.data      (data),      //  ram_input.datain
		.wraddress (wraddress), //           .wraddress
		.rdaddress (rdaddress), //           .rdaddress
		.wren      (wren),      //           .wren
		.clock     (clock),     //           .clock
		.q         (q)          // ram_output.dataout
	);

endmodule