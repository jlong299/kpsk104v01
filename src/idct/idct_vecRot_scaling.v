//-----------------------------------------------------------------
// Module Name:        	idct_vecRot_scaling.v
// Project:             CE RTL
// Description:         
// Author:				Long Jiang
//------------------------------------------------------------------
//  Version 0.1
//  Description :  First version 
//  2016-11-8
//  ----------------------------------------------------------------


module idct_vecRot_scaling #(parameter  
		wDataIn = 36,  
		wDataOut =16  
	)
	(
	// left side
	input 					rst_n_sync,  // clk synchronous reset active low
	input 					clk,    

	input wire        	sink_valid, // sink.sink_valid
	output reg        	sink_ready, //       .sink_ready
	input wire [1:0]  	sink_error, //       .sink_error
	input wire        	sink_sop,   //       .sink_sop
	input wire        	sink_eop,   //       .sink_eop
	input wire [wDataIn-1:0] sink_real,  //       .sink_real
	input wire [wDataIn-1:0] sink_imag,  //       .sink_imag

	input wire [11:0] fftpts_in,    //       .fftpts_in

	//right side
	output reg         source_valid, // source.source_valid
	input  wire        	source_ready, //       .source_ready
	output wire [1:0]  	source_error, //       .source_error
	output reg        	source_sop,   //       .source_sop
	output reg        	source_eop,   //       .source_eop
	output reg [wDataOut-1:0] source_real,  //       .source_real
	output reg [wDataOut-1:0] source_imag,  //       .source_imag
	output wire [11:0] fftpts_out    //       .fftpts_out
	);

assign 	source_error = 2'b00;
assign  fftpts_out = fftpts_in;

always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		sink_ready <= 0;
		source_valid <= 0;
		source_sop <= 0;
		source_eop <= 0;
	end
	else
	begin
		sink_ready <= source_ready;
		source_valid <= sink_valid;
		source_sop <= sink_sop;
		source_eop <= sink_eop;
	end
end


always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		source_real <= 0;
		source_imag <= 0;
	end
	else
	begin
		case (fftpts_in)
		12'd2048:
		begin
			if ( sink_real[wDataIn-1:wDataOut+10] == {(wDataIn - wDataOut -10){1'b0}} ||
				 sink_real[wDataIn-1:wDataOut+10] == {(wDataIn - wDataOut -10){1'b1}} )
				source_real <= sink_real[wDataOut+10:11]+sink_real[10]; //rounding
			else if ( sink_real[wDataIn-1] == 1'b0) // saturating
				source_real <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_real <= { 1'b1, {(wDataOut-1){1'b0}} };

			if ( sink_imag[wDataIn-1:wDataOut+10] == {(wDataIn - wDataOut -10){1'b0}} ||
				 sink_imag[wDataIn-1:wDataOut+10] == {(wDataIn - wDataOut -10){1'b1}} )
				source_imag <= sink_imag[wDataOut+10:11]+sink_imag[10]; //rounding
			else if ( sink_imag[wDataIn-1] == 1'b0) // saturating
				source_imag <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_imag <= { 1'b1, {(wDataOut-1){1'b0}} };
		end
		12'd1024:
		begin
			source_real <= sink_real[wDataOut+10:11]+sink_real[10]; //rounding
			source_imag <= sink_imag[wDataOut+10:11]+sink_imag[10]; //rounding
		end
		12'd512:
		begin
			source_real <= sink_real[wDataOut+9:10]+sink_real[9]; //rounding
			source_imag <= sink_imag[wDataOut+9:10]+sink_imag[9]; //rounding
		end
		12'd256:
		begin
			source_real <= sink_real[wDataOut+9:10]+sink_real[9]; //rounding
			source_imag <= sink_imag[wDataOut+9:10]+sink_imag[9]; //rounding
		end
		12'd128:
		begin
			source_real <= sink_real[wDataOut+8:9]+sink_real[8]; //rounding
			source_imag <= sink_imag[wDataOut+8:9]+sink_imag[8]; //rounding
		end
		12'd64:
		begin
			source_real <= sink_real[wDataOut+8:9]+sink_real[8]; //rounding
			source_imag <= sink_imag[wDataOut+8:9]+sink_imag[8]; //rounding
		end
		12'd32:
		begin
			source_real <= sink_real[wDataOut+7:8]+sink_real[7]; //rounding
			source_imag <= sink_imag[wDataOut+7:8]+sink_imag[7]; //rounding
		end
		default:
		begin
			source_real <= sink_real[wDataOut+10:11]+sink_real[10]; //rounding
			source_imag <= sink_imag[wDataOut+10:11]+sink_imag[10]; //rounding
		end
		endcase
	end
end

endmodule