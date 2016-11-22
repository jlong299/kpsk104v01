//-----------------------------------------------------------------
// Module Name:        	dct_vecRot_scaling.v
// Project:             CE RTL
// Description:         
// Author:				Long Jiang
//------------------------------------------------------------------
//  Version 0.1
//  Description :  First version 
//  2016-10-24
//  Change log  :  /2/65536/sqrt(N/2) *64
//                 So the final output of DCT is 64 times of standard value.
//  ----------------------------------------------------------------


module dct_vecRot_scaling #(parameter  
		wDataIn = 28+18+2,  
		wDataOut =24  
	)
	(
	// left side
	input 					rst_n_sync,  // clk synchronous reset active low
	input 					clk,    

	input wire        	sink_valid, // sink.sink_valid
	output wire        	sink_ready, //       .sink_ready
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
	output wire [11:0] fftpts_out,    //       .fftpts_out

	output reg 	overflow
	);

localparam divide_width = 16;

reg overflow_real, overflow_imag;

assign 	source_error = 2'b00;
assign  fftpts_out = fftpts_in;
assign 	sink_ready = source_ready;

always@(posedge clk)
begin
	source_valid <= sink_valid;
	source_sop <= sink_sop;
	source_eop <= sink_eop;
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
			if ( sink_real[wDataIn-1:wDataOut+divide_width-1] == {(wDataIn - wDataOut -divide_width+1){1'b0}} ||
				 sink_real[wDataIn-1:wDataOut+divide_width-1] == {(wDataIn - wDataOut -divide_width+1){1'b1}} )
				source_real <= sink_real[wDataOut+divide_width-1:divide_width]+sink_real[divide_width-1]; //rounding (/65536)
			else if ( sink_real[wDataIn-1] == 1'b0) // saturating
				source_real <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_real <= { 1'b1, {(wDataOut-1){1'b0}} };

			if ( sink_imag[wDataIn-1:wDataOut+divide_width-1] == {(wDataIn - wDataOut -divide_width+1){1'b0}} ||
				 sink_imag[wDataIn-1:wDataOut+divide_width-1] == {(wDataIn - wDataOut -divide_width+1){1'b1}} )
				source_imag <= sink_imag[wDataOut+divide_width-1:divide_width]+sink_imag[divide_width-1]; //rounding (/65536)
			else if ( sink_imag[wDataIn-1] == 1'b0) // saturating
				source_imag <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_imag <= { 1'b1, {(wDataOut-1){1'b0}} };
		end
		12'd1024:
		begin
			if ( sink_real[wDataIn-1:wDataOut+divide_width-1] == {(wDataIn - wDataOut -divide_width+1){1'b0}} ||
				 sink_real[wDataIn-1:wDataOut+divide_width-1] == {(wDataIn - wDataOut -divide_width+1){1'b1}} )
				source_real <= sink_real[wDataOut+divide_width-1:divide_width]+sink_real[divide_width-1]; //rounding (/65536)
			else if ( sink_real[wDataIn-1] == 1'b0) // saturating
				source_real <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_real <= { 1'b1, {(wDataOut-1){1'b0}} };

			if ( sink_imag[wDataIn-1:wDataOut+divide_width-1] == {(wDataIn - wDataOut -divide_width+1){1'b0}} ||
				 sink_imag[wDataIn-1:wDataOut+divide_width-1] == {(wDataIn - wDataOut -divide_width+1){1'b1}} )
				source_imag <= sink_imag[wDataOut+divide_width-1:divide_width]+sink_imag[divide_width-1]; //rounding (/65536)
			else if ( sink_imag[wDataIn-1] == 1'b0) // saturating
				source_imag <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_imag <= { 1'b1, {(wDataOut-1){1'b0}} };
		end
		12'd512:
		begin
			if ( sink_real[wDataIn-1:wDataOut+divide_width-1-1] == {(wDataIn - wDataOut -divide_width+1+1){1'b0}} ||
				 sink_real[wDataIn-1:wDataOut+divide_width-1-1] == {(wDataIn - wDataOut -divide_width+1+1){1'b1}} )
				source_real <= sink_real[wDataOut+divide_width-1-1:divide_width-1]+sink_real[divide_width-1-1]; //rounding (/65536)
			else if ( sink_real[wDataIn-1] == 1'b0) // saturating
				source_real <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_real <= { 1'b1, {(wDataOut-1){1'b0}} };

			if ( sink_imag[wDataIn-1:wDataOut+divide_width-1-1] == {(wDataIn - wDataOut -divide_width+1+1){1'b0}} ||
				 sink_imag[wDataIn-1:wDataOut+divide_width-1-1] == {(wDataIn - wDataOut -divide_width+1+1){1'b1}} )
				source_imag <= sink_imag[wDataOut+divide_width-1-1:divide_width-1]+sink_imag[divide_width-1-1]; //rounding (/65536)
			else if ( sink_imag[wDataIn-1] == 1'b0) // saturating
				source_imag <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_imag <= { 1'b1, {(wDataOut-1){1'b0}} };
		end
		12'd256:
		begin
			if ( sink_real[wDataIn-1:wDataOut+divide_width-1-1] == {(wDataIn - wDataOut -divide_width+1+1){1'b0}} ||
				 sink_real[wDataIn-1:wDataOut+divide_width-1-1] == {(wDataIn - wDataOut -divide_width+1+1){1'b1}} )
				source_real <= sink_real[wDataOut+divide_width-1-1:divide_width-1]+sink_real[divide_width-1-1]; //rounding (/65536)
			else if ( sink_real[wDataIn-1] == 1'b0) // saturating
				source_real <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_real <= { 1'b1, {(wDataOut-1){1'b0}} };

			if ( sink_imag[wDataIn-1:wDataOut+divide_width-1-1] == {(wDataIn - wDataOut -divide_width+1+1){1'b0}} ||
				 sink_imag[wDataIn-1:wDataOut+divide_width-1-1] == {(wDataIn - wDataOut -divide_width+1+1){1'b1}} )
				source_imag <= sink_imag[wDataOut+divide_width-1-1:divide_width-1]+sink_imag[divide_width-1-1]; //rounding (/65536)
			else if ( sink_imag[wDataIn-1] == 1'b0) // saturating
				source_imag <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_imag <= { 1'b1, {(wDataOut-1){1'b0}} };
		end
		12'd128:
		begin
			if ( sink_real[wDataIn-1:wDataOut+divide_width-1-2] == {(wDataIn - wDataOut -divide_width+1+2){1'b0}} ||
				 sink_real[wDataIn-1:wDataOut+divide_width-1-2] == {(wDataIn - wDataOut -divide_width+1+2){1'b1}} )
				source_real <= sink_real[wDataOut+divide_width-1-2:divide_width-2]+sink_real[divide_width-1-2]; //rounding (/65536)
			else if ( sink_real[wDataIn-1] == 1'b0) // saturating
				source_real <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_real <= { 1'b1, {(wDataOut-1){1'b0}} };

			if ( sink_imag[wDataIn-1:wDataOut+divide_width-1-2] == {(wDataIn - wDataOut -divide_width+1+2){1'b0}} ||
				 sink_imag[wDataIn-1:wDataOut+divide_width-1-2] == {(wDataIn - wDataOut -divide_width+1+2){1'b1}} )
				source_imag <= sink_imag[wDataOut+divide_width-1-2:divide_width-2]+sink_imag[divide_width-1-2]; //rounding (/65536)
			else if ( sink_imag[wDataIn-1] == 1'b0) // saturating
				source_imag <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_imag <= { 1'b1, {(wDataOut-1){1'b0}} };
		end
		12'd64:
		begin
			if ( sink_real[wDataIn-1:wDataOut+divide_width-1-2] == {(wDataIn - wDataOut -divide_width+1+2){1'b0}} ||
				 sink_real[wDataIn-1:wDataOut+divide_width-1-2] == {(wDataIn - wDataOut -divide_width+1+2){1'b1}} )
				source_real <= sink_real[wDataOut+divide_width-1-2:divide_width-2]+sink_real[divide_width-1-2]; //rounding (/65536)
			else if ( sink_real[wDataIn-1] == 1'b0) // saturating
				source_real <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_real <= { 1'b1, {(wDataOut-1){1'b0}} };

			if ( sink_imag[wDataIn-1:wDataOut+divide_width-1-2] == {(wDataIn - wDataOut -divide_width+1+2){1'b0}} ||
				 sink_imag[wDataIn-1:wDataOut+divide_width-1-2] == {(wDataIn - wDataOut -divide_width+1+2){1'b1}} )
				source_imag <= sink_imag[wDataOut+divide_width-1-2:divide_width-2]+sink_imag[divide_width-1-2]; //rounding (/65536)
			else if ( sink_imag[wDataIn-1] == 1'b0) // saturating
				source_imag <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_imag <= { 1'b1, {(wDataOut-1){1'b0}} };
		end
		default:
		begin
			if ( sink_real[wDataIn-1:wDataOut+divide_width-1] == {(wDataIn - wDataOut -divide_width+1){1'b0}} ||
				 sink_real[wDataIn-1:wDataOut+divide_width-1] == {(wDataIn - wDataOut -divide_width+1){1'b1}} )
				source_real <= sink_real[wDataOut+divide_width-1:divide_width]+sink_real[divide_width-1]; //rounding (/65536)
			else if ( sink_real[wDataIn-1] == 1'b0) // saturating
				source_real <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_real <= { 1'b1, {(wDataOut-1){1'b0}} };

			if ( sink_imag[wDataIn-1:wDataOut+divide_width-1] == {(wDataIn - wDataOut -divide_width+1){1'b0}} ||
				 sink_imag[wDataIn-1:wDataOut+divide_width-1] == {(wDataIn - wDataOut -divide_width+1){1'b1}} )
				source_imag <= sink_imag[wDataOut+divide_width-1:divide_width]+sink_imag[divide_width-1]; //rounding (/65536)
			else if ( sink_imag[wDataIn-1] == 1'b0) // saturating
				source_imag <= { 1'b0, {(wDataOut-1){1'b1}} };
			else
				source_imag <= { 1'b1, {(wDataOut-1){1'b0}} };
		end
		endcase
	end
end

always@(*)
begin
	if ( source_real == {1'b0, {(wDataOut-1){1'b1}}} || source_real == {1'b1, {(wDataOut-1){1'b0}}} )
		overflow_real <= 1'b1;
	else
		overflow_real <= 1'b0;
end
always@(*)
begin
	if ( source_imag == {1'b0, {(wDataOut-1){1'b1}}} || source_imag == {1'b1, {(wDataOut-1){1'b0}}} )
		overflow_imag <= 1'b1;
	else
		overflow_imag <= 1'b0;
end
always@(*)
begin
	overflow <= (overflow_real | overflow_imag) & source_valid ;
end

endmodule