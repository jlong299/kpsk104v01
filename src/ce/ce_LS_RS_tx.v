//-----------------------------------------------------------------
// Module Name:        	ce_LS_RS_tx.v
// Project:             CE RTL
// Description:         
// Author:				Long Jiang
//------------------------------------------------------------------
//  Version 0.1
//  Description :  First version 
//  2016-11-17
//  ----------------------------------------------------------------
//  ZC sequence in ROM (*65536)
//  --------------------------------------------------------------------------------------------------

module ce_LS_RS_tx #(parameter  
		wDataOut =18  
	)
	(
	// left side
	input wire		rst_n_sync,  // clk synchronous reset active low
	input wire		clk,    

	input wire		sink_valid, 	
	input wire [11:0] 		fftpts_in, 		
	// right side
	// 1 clks delay with sink_valid
	output reg [wDataOut-1:0] 	source_real,
	output reg [wDataOut-1:0] 	source_imag
	);

	reg [10:0] address_real, address_imag;
	wire [wDataOut-1:0] 	source_real1;
	wire [wDataOut-1:0] 	source_imag1;

	ROM_RS_tx_UE0_real ROM_RS_tx_UE0_real_inst (
		.address (address_real), //  rom_input.address
		.clock   (clk),   //           .clk
		.q       (source_real1)        // rom_output.dataout
	);
	ROM_RS_tx_UE0_imag ROM_RS_tx_UE0_imag_inst (
		.address (address_imag), //  rom_input.address
		.clock   (clk),   //           .clk
		.q       (source_imag1)        // rom_output.dataout
	);

	always@(posedge clk)
	begin
		if (!rst_n_sync)
		begin
			source_real <= 0;
			source_imag <= 0;
		end
		else
		begin
			source_real <= source_real1;
			source_imag <= source_imag1;
		end
	end

	always@(posedge clk)
	begin
		if (!rst_n_sync)
		begin
			address_real <= 0;
			address_imag <= 0;
		end
		else
		begin
			if (sink_valid)
			begin
				address_real <= address_real + 10'd1;
				address_imag <= address_imag + 10'd1;
			end
			else
			begin
				address_real <= 0;
				address_imag <= 0;
			end
		end
	end


endmodule