//-----------------------------------------------------------------
// Module Name:        	ce_top.v
// Project:             CE RTL
// Description:         CE top level.
// Author:				Long Jiang
//------------------------------------------------------------------
//  Version 0.1
//  Description :  First version 
//  2016-11-17
//  ----------------------------------------------------------------
//
//  --------------------------------------------------------------------------------------------------
//  Top structure :
//
//    --> ce_LS --> DCT --> ce_window --> IDCT -->
//
//  ---------------------------------------------------------------------------- 
//
//  ---------------------------------------------------------------------------- 
//  Note :  (1) fftpts_in : The number of FFT points is power of 2
//  

module ce_top #(parameter  
		wDataIn = 16,  
		wDataOut = 16  
	)
	(
	// left side
	input wire				rst_n_sync,  // clk synchronous reset active low
	input wire				clk,    

	input wire        sink_valid, // sink.sink_valid
	output reg       sink_ready, //       .sink_ready
	input wire [1:0]  sink_error, //       .sink_error
	input wire        sink_sop,   //       .sink_sop
	input wire        sink_eop,   //       .sink_eop
	input wire [wDataIn-1:0] sink_real,  //       .sink_real
	input wire [wDataIn-1:0] sink_imag,  //       .sink_imag

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

	output reg 			overflow
	);

localparam  wData_t0 = 16;
localparam  wData_t1 = 24;

reg        source_valid_t0; // source.source_valid
wire        source_ready_t0; //       .source_ready
reg [1:0]  source_error_t0; //       .source_error
reg        source_sop_t0;   //       .source_sop
reg        source_eop_t0;   //       .source_eop
reg [wData_t0-1:0] source_real_t0;  //       .source_real
reg [wData_t0-1:0] source_imag_t0;  //       .source_imag

wire        source_valid_t1; // source.source_valid
wire        source_ready_t1; //       .source_ready
wire [1:0]  source_error_t1; //       .source_error
wire        source_sop_t1;   //       .source_sop
wire        source_eop_t1;   //       .source_eop
wire [wData_t1-1:0] source_real_t1;  //       .source_real
wire [wData_t1-1:0] source_imag_t1;  //       .source_imag
wire [wData_t1-1:0] source_real_rev_t1;  //       .source_real
wire [wData_t1-1:0] source_imag_rev_t1;  //       .source_imag

wire        source_valid_t2; // source.source_valid
wire        source_ready_t2; //       .source_ready
wire [1:0]  source_error_t2; //       .source_error
wire        source_sop_t2;   //       .source_sop
wire        source_eop_t2;   //       .source_eop
wire [wData_t1-1:0] source_real_t2;  //       .source_real
wire [wData_t1-1:0] source_imag_t2;  //       .source_imag
wire [wData_t1-1:0] source_real_rev_t2;  //       .source_real
wire [wData_t1-1:0] source_imag_rev_t2;  //       .source_imag

wire overflow1, overflow2, overflow3;

assign overflow = overflow1 | overflow2 | overflow3;

assign fftpts_out = fftpts_in;

//-----------------------------------------------------
//-----------  Part 1 :  Least Square   ------------
//-----------------------------------------------------
ce_LS #(
	.wDataIn (wDataIn),
	.wDataOut (wData_t0)
	)
ce_LS_inst (
	.clk          (clk),          //    clk.clk
	.rst_n_sync   (rst_n_sync),      //    rst.reset_n
	.sink_valid   (sink_valid),   //   sink.sink_valid
	.sink_ready   (sink_ready),   //       .sink_ready
	.sink_error   (sink_error),   //       .sink_error
	.sink_sop     (sink_sop),     //       .sink_sop
	.sink_eop     (sink_eop),     //       .sink_eop
	.sink_real    (sink_real),    //       .sink_real
	.sink_imag    (sink_imag),    //       .sink_imag
	.fftpts_in    (fftpts_in),    //       .fftpts_in

	//right side
	.source_valid	(source_valid_t0), 
	.source_ready	(source_ready_t0), 
	.source_error	(source_error_t0), 
	.source_sop		(source_sop_t0),   
	.source_eop		(source_eop_t0),   
	.source_real	(source_real_t0),  
	.source_imag	(source_imag_t0),  
	.fftpts_out 	( ),

	.overflow 		(overflow1)
);

//-----------------------------------------------------
//-----------  Part 2 :  DCT    -----------------------
//-----------------------------------------------------

dct_top dct_top_inst (
	.clk          (clk),          //    clk.clk
	.rst_n_sync   (rst_n_sync),      //    rst.reset_n
	.sink_valid   (source_valid_t0),   //   sink.sink_valid
	.sink_ready   (source_ready_t0),   //       .sink_ready
	.sink_error   (source_error_t0),   //       .sink_error
	.sink_sop     (source_sop_t0),     //       .sink_sop
	.sink_eop     (source_eop_t0),     //       .sink_eop
	.sink_real    (source_real_t0),    //       .sink_real
	.sink_imag    (source_imag_t0),    //       .sink_imag
	.fftpts_in    (fftpts_in),    //       .fftpts_in

	//right side
	.source_valid	(source_valid_t1), 
	.source_ready	(source_ready_t1), 
	.source_error	(source_error_t1), 
	.source_sop		(source_sop_t1),   
	.source_eop		(source_eop_t1),   
	.source_real	(source_real_t1),  
	.source_imag	(source_imag_t1),  
	.source_real_rev	(source_real_rev_t1),  
	.source_imag_rev	(source_imag_rev_t1),  
	.fftpts_out 	( ),

	.overflow 		(overflow2)
);

//-----------------------------------------------------
//-----------  Part 3 :  windowing -------------------
//-----------------------------------------------------

ce_window  #(
	.wDataInOut  (wData_t1)  
		)
ce_window_inst
(
	.clk          (clk),          //    clk.clk
	.rst_n_sync   (rst_n_sync),      //    rst.reset_n
	.sink_valid   (source_valid_t1),   //   sink.sink_valid
	.sink_ready   (source_ready_t1),   //       .sink_ready
	.sink_error   (source_error_t1),   //       .sink_error
	.sink_sop     (source_sop_t1),     //       .sink_sop
	.sink_eop     (source_eop_t1),     //       .sink_eop
	.sink_real    (source_real_t1),    //       .sink_real
	.sink_imag    (source_imag_t1),    //       .sink_imag
	.sink_real_rev    (source_real_rev_t1),    //       .sink_real
	.sink_imag_rev    (source_imag_rev_t1),    //       .sink_imag
	.fftpts_in    (fftpts_in),    //       .fftpts_in

	//right side
	.source_valid	(source_valid_t2), 
	.source_ready	(source_ready_t2), 
	.source_error	(source_error_t2), 
	.source_sop		(source_sop_t2),   
	.source_eop		(source_eop_t2),   
	.source_real	(source_real_t2),  
	.source_imag	(source_imag_t2),  
	.source_real_rev	(source_real_rev_t2),  
	.source_imag_rev	(source_imag_rev_t2),  
	.fftpts_out()
);

//-----------------------------------------------------
//-----------  Part 4 :  IDCT -------------------
//-----------------------------------------------------

idct_top  #(
	.wDataIn  (wData_t1),  
	.wDataOut  (wDataOut) 	)
idct_top_inst
(
	.clk          (clk),          //    clk.clk
	.rst_n_sync   (rst_n_sync),      //    rst.reset_n
	.sink_valid   (source_valid_t2),   //   sink.sink_valid
	.sink_ready   (source_ready_t2),   //       .sink_ready
	.sink_error   (source_error_t2),   //       .sink_error
	.sink_sop     (source_sop_t2),     //       .sink_sop
	.sink_eop     (source_eop_t2),     //       .sink_eop
	.sink_real    (source_real_t2),    //       .sink_real
	.sink_imag    (source_imag_t2),    //       .sink_imag
	.sink_real_rev    (source_real_rev_t2),    //       .sink_real
	.sink_imag_rev    (source_imag_rev_t2),    //       .sink_imag
	.fftpts_in    (fftpts_in),    //       .fftpts_in

	//right side
	.source_valid	(source_valid), 
	.source_ready	(source_ready), 
	.source_error	(source_error), 
	.source_sop		(source_sop),   
	.source_eop		(source_eop),   
	.source_real	(source_real),  
	.source_imag	(source_imag),  
	.fftpts_out 	( ),

	.overflow 		(overflow3)
);

endmodule