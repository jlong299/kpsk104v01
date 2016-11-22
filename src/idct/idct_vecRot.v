//-----------------------------------------------------------------
// Module Name:        	idct_vecRot.v
// Project:             CE RTL
// Description:         The first part of IDCT, before IFFT.
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
//      | idct_vecRot_coeff |--> |                    | --> ST_source_t0
//      -------------------      | idct_vecRot_twiddle|
//                               |                    |
//  ---------ST_sink --------->  |                    |
//  --------------------------------------------------------------------------------------------------
//
//  --->  | idct_vecRot_scaling | --> ST_source
//
//  ---------------------------------------------------------------------------- 
//  Note :  (1) fftpts_in : The number of FFT points is power of 2
// 


module idct_vecRot #(parameter  
		wDataIn = 24,  
		wDataOut =24  
	)
	(
	// left side
	input wire				rst_n_sync,  // clk synchronous reset active low
	input wire				clk,    

	input wire        sink_valid, // sink.sink_valid
	output wire        sink_ready, //       .sink_ready
	input wire [1:0]  sink_error, //       .sink_error
	input wire        sink_sop,   //       .sink_sop
	input wire        sink_eop,   //       .sink_eop
	input wire [wDataIn-1:0] sink_real,  //       .sink_real
	input wire [wDataIn-1:0] sink_imag,  //       .sink_imag
	input wire [wDataIn-1:0] sink_real_rev,  //       .sink_real
	input wire [wDataIn-1:0] sink_imag_rev,  //       .sink_imag

	input wire [11:0] fftpts_in,    //       .fftpts_in

	//right side
	output wire        source_valid, // source.source_valid
	input  wire        source_ready, //       .source_ready
	output wire [1:0]  source_error, //       .source_error
	output wire        source_sop,   //       .source_sop
	output wire        source_eop,   //       .source_eop
	output wire [wDataOut-1:0] source_real,  //       .source_real
	output wire [wDataOut-1:0] source_imag,  //       .source_imag

	output wire [11:0] fftpts_out,    //       .fftpts_out

	output wire 		overflow
	);



//localparam 	wData_t0 = 34;
localparam 	wCoeff = 18;

wire        source_valid_t0; // source.source_valid
wire        source_ready_t0; //       .source_ready
wire [1:0]  source_error_t0; //       .source_error
wire        source_sop_t0;   //       .source_sop
wire        source_eop_t0;   //       .source_eop
wire [wDataIn+wCoeff+2-1:0] source_real_t0;  //       .source_real
wire [wDataIn+wCoeff+2-1:0] source_imag_t0;  //       .source_imag

wire [wCoeff-1:0] 	coeff_cos, coeff_sin;

assign fftpts_out = fftpts_in;
assign source_error = 2'b00;


//-----------------------------------------------------
//-----------  Part 1 :  idct_vecRot_twiddle -----------
//-----------------------------------------------------
idct_vecRot_twiddle #(
	.wDataIn (wDataIn),  
	.wDataOut (wDataIn+wCoeff+2),
	.wCoeff (wCoeff)  
	)
idct_vecRot_twiddle_inst (
	// left side
	.rst_n_sync 	(rst_n_sync),
	.clk 			(clk),

	.sink_valid 	(sink_valid),
	.sink_ready 	(sink_ready),
	.sink_error 	(sink_error),
	.sink_sop 		(sink_sop ),    
	.sink_eop 		(sink_eop ),    
	.sink_real 		(sink_real ), 
	.sink_imag 		(sink_imag ),
	.sink_real_rev 	(sink_real_rev ),  
	.sink_imag_rev 	(sink_imag_rev ),  

	.fftpts_in 		(fftpts_in),

	// 1 clks delay with sink_valid
	.sink_cos 		(coeff_cos ),  
	.sink_sin 		(coeff_sin ), 

	// right side
	.source_valid 	(source_valid_t0), 
	.source_ready 	(source_ready_t0), 
	.source_error 	(source_error_t0), 
	.source_sop 	(source_sop_t0 ),   
	.source_eop 	(source_eop_t0 ),   
	.source_real 	(source_real_t0 ),  
	.source_imag 	(source_imag_t0 ),  
	.fftpts_out 	( )   

	);

idct_vecRot_coeff #(
	.wDataOut (wCoeff)  
	)
idct_vecRot_coeff_inst (
	// left side
	.rst_n_sync 	(rst_n_sync),
	.clk 			(clk),

	.sink_valid 	(sink_valid),

	.fftpts_in 		(fftpts_in),

	// right side
	// 1 clks delay with sink_valid
	.source_cos 	(coeff_cos ),  
	.source_sin 	(coeff_sin )
	);

//-----------------------------------------------------
//-----------  Part 3 :  dct_vecRot_scaling -----------
//-----------------------------------------------------
idct_vecRot_scaling #(
	.wDataIn (wDataIn+wCoeff+2),  
	.wDataOut (wDataOut)  
	)
idct_vecRot_scaling_inst (
	// left side
	.rst_n_sync 	(rst_n_sync),
	.clk 			(clk),

	.sink_valid 	(source_valid_t0),
	.sink_ready 	(source_ready_t0),
	.sink_error 	(source_error_t0),
	.sink_sop 		(source_sop_t0 ),    
	.sink_eop 		(source_eop_t0 ),    
	.sink_real 		(source_real_t0 ), 
	.sink_imag 		(source_imag_t0 ), 

	.fftpts_in 		(fftpts_in),

	// right side
	.source_valid 	(source_valid), 
	.source_ready 	(source_ready), 
	.source_error 	( ), 
	.source_sop 	(source_sop ),   
	.source_eop 	(source_eop ),   
	.source_real 	(source_real ),  
	.source_imag 	(source_imag ),  
	.fftpts_out 	( ),   

	.overflow 		(overflow)

	);



endmodule