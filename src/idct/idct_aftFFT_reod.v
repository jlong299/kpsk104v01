//-----------------------------------------------------------------
// Module Name:        	idct_aftFFT_reod.v
// Project:             CE RTL
// Description:         Signal reorder serves as the last part of IDCT which is right after IFFT.
// Author:				Long Jiang
//------------------------------------------------------------------
//  Version 0.1
//  Description :  First version 
//  2016-11-8
//  ----------------------------------------------------------------
//  Detail :  (Matlab Code)
//
//  %% Calc idct from dct result and ifft
// 
//  F1 = zeros(1,N);
//  F1(1) = 1/w(1) * D1(1);
//  for k=2:N
//      F1(k) = 1/w(k) * (D1(k)-1j*D1(N+2-k))/exp(-1j*pi*(k-1)/2/N);
//  end
//  %disp(F1);
// 
//  x1_reod = ifft(F1);
// 
//  x1 = zeros(1,N);
//  x1(1:2:N-1) = x1_reod(1:N/2);
//  x1(2:2:N) = x1_reod(N:-1:N/2+1);
//  --------------------------------------------------------------------------------------------------
//                      |          |
//  x0,x1,...,x2047 --> |  reoder  | --> x0,x2047,x1,x2046,x2,x2045,...,x1023,x1024
//                      |          |
//  ---------------------------------------------------------------------------- 
//  Note :  (1) fftpts_in : The number of FFT points is power of 2
// 


module idct_aftFFT_reod #(parameter  
		wDataInOut = 16
	)
	(
	// left side
	input 		rst_n_sync,  // clk synchronous reset active low
	input		clk,
	input		sink_valid,
	output	reg	sink_ready,
	input	[1:0]	sink_error,
	input		sink_sop,
	input		sink_eop,
	input	[wDataInOut-1:0]	sink_real,
	input	[wDataInOut-1:0]	sink_imag,
	input	[11:0]	fftpts_in,

	// right side
	output reg		source_valid,
	input			source_ready,
	output	[1:0]	source_error,
	output reg		source_sop,
	output reg		source_eop,
	output 	[wDataInOut-1:0]	source_real,
	output 	[wDataInOut-1:0]	source_imag,
	output	[11:0]	fftpts_out
	);


assign fftpts_out = fftpts_in;
assign source_error = 2'b00;

assign source_real = sink_real;
assign source_imag = source_imag;
assign source_sop = sink_sop;
assign source_eop = sink_eop;
assign source_valid = sink_valid;




endmodule