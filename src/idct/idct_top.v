//-----------------------------------------------------------------
// Module Name:        	idct_top.v
// Project:             CE RTL
// Description:         IDCT top level.
// Author:				Long Jiang
//------------------------------------------------------------------
//  Version 0.1
//  Description :  First version 
//  2016-11-4
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
//  ---------------------------------------------------------------------------- 
//  Input : 
//         D(1), D(2), ... D(k),  ...,    D(N)
//         0,    D(N), ... D(N+2-k), ..., D(2)
//                                               k = 1, 2, ... , N
//  --------------------------------------------------------------------------------------------------
//  Top structure :
//
//    --> idct_vecRot --> IFFT --> idct_aftFFT_reod --> 
//
//  ---------------------------------------------------------------------------- 
//  Note :  (1) fftpts_in : The number of FFT points is power of 2
//          (2) Ping-pong strutrue to improve throughput
// 


module idct_top #(parameter  
		wDataIn = 24,  
		wDataOut = 16  
	)
	(
	// left side
	input wire				rst_n_sync,  // clk synchronous reset active low
	input wire				clk,    

	input wire        sink_valid, // sink.sink_valid
	output wire       sink_ready, //       .sink_ready
	input wire [1:0]  sink_error, //       .sink_error
	input wire        sink_sop,   //       .sink_sop
	input wire        sink_eop,   //       .sink_eop
	input wire [wDataIn-1:0] sink_real,  //       .sink_real
	input wire [wDataIn-1:0] sink_imag,  //       .sink_imag
	input wire [wDataIn-1:0] sink_real_rev,  //       .sink_real
	input wire [wDataIn-1:0] sink_imag_rev,  //       .sink_imag

	input wire [11:0] fftpts_in,    //       .fftpts_in

	//right side
	output reg        source_valid, // source.source_valid
	input  wire        source_ready, //       .source_ready
	output reg [1:0]  source_error, //       .source_error
	output reg        source_sop,   //       .source_sop
	output reg        source_eop,   //       .source_eop
	output reg [wDataOut-1:0] source_real,  //       .source_real
	output reg [wDataOut-1:0] source_imag,  //       .source_imag
	output wire [11:0] fftpts_out,    //       .fftpts_out

	output  			overflow
	);

localparam 	wData_t0 = 24;
localparam 	wData_t1 = 32;
wire        source_valid_t0; // source.source_valid
reg        source_ready_t0; //       .source_ready
wire [1:0]  source_error_t0; //       .source_error
wire        source_sop_t0;   //       .source_sop
wire        source_eop_t0;   //       .source_eop
wire [wData_t0-1:0] source_real_t0;  //       .source_real
wire [wData_t0-1:0] source_imag_t0;  //       .source_imag

wire        source_valid_t1; // source.source_valid
wire        source_ready_t1; //       .source_ready
wire [1:0]  source_error_t1; //       .source_error
wire        source_sop_t1;   //       .source_sop
wire        source_eop_t1;   //       .source_eop
wire [wData_t1-1:0] source_real_t1;  //       .source_real
wire [wData_t1-1:0] source_imag_t1;  //       .source_imag

wire        source_valid_t2; // source.source_valid
reg        source_ready_t2; //       .source_ready
wire [1:0]  source_error_t2; //       .source_error
wire        source_sop_t2;   //       .source_sop
wire        source_eop_t2;   //       .source_eop
wire [wDataOut-1:0] source_real_t2;  //       .source_real
wire [wDataOut-1:0] source_imag_t2;  //       .source_imag

reg is_pong_sink, is_pong_source;

reg        sink_valid_ping, sink_valid_pong; // sink.sink_valid
wire        sink_ready_ping, sink_ready_pong; //       .sink_ready
reg [1:0]  sink_error_ping, sink_error_pong; //       .sink_error
reg        sink_sop_ping, sink_sop_pong;   //       .sink_sop
reg        sink_eop_ping, sink_eop_pong;   //       .sink_eop
reg [wDataOut-1:0] sink_real_ping, sink_real_pong;  //       .sink_real
reg [wDataOut-1:0] sink_imag_ping, sink_imag_pong;  //       .sink_imag

wire        source_valid_ping, source_valid_pong; // source.source_valid
reg        source_ready_ping, source_ready_pong; //       .source_ready
wire [1:0]  source_error_ping, source_error_pong; //       .source_error
wire        source_sop_ping, source_sop_pong;   //       .source_sop
wire        source_eop_ping, source_eop_pong;   //       .source_eop
wire [wDataOut-1:0] source_real_ping, source_real_pong;  //       .source_real
wire [wDataOut-1:0] source_imag_ping, source_imag_pong;  //       .source_imag

wire overflow1, overflow2;

assign overflow = overflow1 | overflow2;

assign fftpts_out = fftpts_in;

//-----------------------------------------------------
//-----------  Part 1 :  idct_vecRot -------------------
//-----------------------------------------------------
idct_vecRot #(  
	.wDataIn (wDataIn),  
	.wDataOut (wData_t0)  
)
idct_vecRot_inst
(
	// left side
	.rst_n_sync (rst_n_sync),  // clk synchronous reset active low
	.clk (clk),    
	
	.sink_valid (sink_valid), 
	.sink_ready (sink_ready), 
	.sink_error (sink_error), 
	.sink_sop 	(sink_sop  ),   
	.sink_eop 	(sink_eop  ),   
	.sink_real 	(sink_real ),  
	.sink_imag 	(sink_imag ),  
	.sink_real_rev 	(sink_real_rev ),  
	.sink_imag_rev 	(sink_imag_rev ),  
	
	.fftpts_in (fftpts_in),    
	
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
//-----------  Part 2 :  IFFT    -----------------------
//-----------------------------------------------------
idct_ifft idct_ifft_inst (
	.clk          (clk),          //    clk.clk
	.reset_n      (rst_n_sync),      //    rst.reset_n
	.sink_valid   (source_valid_t0),   //   sink.sink_valid
	.sink_ready   (source_ready_t0),   //       .sink_ready
	.sink_error   (source_error_t0),   //       .sink_error
	.sink_sop     (source_sop_t0),     //       .sink_sop
	.sink_eop     (source_eop_t0),     //       .sink_eop
	.sink_real    (source_real_t0),    //       .sink_real
	.sink_imag    (source_imag_t0),    //       .sink_imag
	.fftpts_in    (fftpts_in),    //       .fftpts_in
	//------- IFFT -----------
	.inverse      (1'b1),      //       .inverse   
	//------------------------
	.source_valid (source_valid_t1), // source.source_valid
	.source_ready (source_ready_t1), //       .source_ready
	.source_error (source_error_t1), //       .source_error
	.source_sop   (source_sop_t1),   //       .source_sop
	.source_eop   (source_eop_t1),   //       .source_eop
	.source_real  (source_real_t1),  //       .source_real
	.source_imag  (source_imag_t1),  //       .source_imag
	.fftpts_out   ()    //       .fftpts_out
);

//-----------------------------------------------------
//-----------  Part 3 :  idct_aftIFFT_scaling -----------
//-----------------------------------------------------
idct_aftIFFT_scaling #(
	.wDataIn (wData_t1),  
	.wDataOut (wDataOut)  
	)
idct_aftIFFT_scaling_inst (
	// left side
	.rst_n_sync 	(rst_n_sync),
	.clk 			(clk),

	.sink_valid 	(source_valid_t1),
	.sink_ready 	(source_ready_t1),
	.sink_error 	(source_error_t1),
	.sink_sop 		(source_sop_t1 ),    
	.sink_eop 		(source_eop_t1 ),    
	.sink_real 		(source_real_t1 ), 
	.sink_imag 		(source_imag_t1 ), 

	.fftpts_in 		(fftpts_in),

	// right side
	.source_valid 	(source_valid_t2), 
	.source_ready 	(source_ready_t2), 
	.source_error 	(source_error_t2 ), 
	.source_sop 	(source_sop_t2 ),   
	.source_eop 	(source_eop_t2 ),   
	.source_real 	(source_real_t2 ),  
	.source_imag 	(source_imag_t2 ),  
	.fftpts_out 	( ),   

	.overflow 		(overflow2)

	);


//-----------------------------------------------------
//-----------  Part 4 :  idct_aftFFT_reod   ------------
//-----------------------------------------------------
//---- ping-pong mode to increase throughput  ----
//start----------  Ping Pong  --------------
always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		is_pong_sink <= 0;
		source_ready_t2 <= 0;
	end
	else 
	begin
		if (is_pong_sink==1'b0 && sink_eop_ping==1'b1)
			is_pong_sink <= 1'b1;
		else if (is_pong_sink==1'b1 && sink_eop_pong==1'b1)
			is_pong_sink <= 1'b0;

		source_ready_t2 <= (is_pong_sink==1'b0)? sink_ready_ping : sink_ready_pong;
	end
end

always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		sink_valid_ping <= 0;
		sink_error_ping <= 0;
		sink_sop_ping <= 0; 	
		sink_eop_ping <= 0; 	
		sink_real_ping <= 0; 
		sink_imag_ping <= 0; 
		sink_valid_pong <= 0;
		sink_error_pong <= 0;
		sink_sop_pong <= 0; 	
		sink_eop_pong <= 0; 	
		sink_real_pong <= 0; 
		sink_imag_pong <= 0; 
	end
	else
	begin
		if (is_pong_sink==1'b0)
		begin
			sink_valid_ping <= source_valid_t2;
			sink_error_ping <= source_error_t2;
			sink_sop_ping <= source_sop_t2; 	
			sink_eop_ping <= source_eop_t2; 	
			sink_real_ping <= source_real_t2; 
			sink_imag_ping <= source_imag_t2; 
			sink_valid_pong <= 0;
			sink_error_pong <= 0;
			sink_sop_pong <= 0; 	
			sink_eop_pong <= 0; 	
			sink_real_pong <= 0; 
			sink_imag_pong <= 0;
		end
		else
		begin
			sink_valid_ping <= 0;
			sink_error_ping <= 0;
			sink_sop_ping <= 0; 	
			sink_eop_ping <= 0; 	
			sink_real_ping <= 0; 
			sink_imag_ping <= 0; 
			sink_valid_pong <= source_valid_t2;
			sink_error_pong <= source_error_t2;
			sink_sop_pong <= source_sop_t2; 	
			sink_eop_pong <= source_eop_t2; 	
			sink_real_pong <= source_real_t2; 
			sink_imag_pong <= source_imag_t2;
		end
	end
end
idct_aftIFFT_reod #(
	.wDataInOut (wDataOut) 
	)
idct_aftIFFT_reod_ping (
	// left side
	.rst_n_sync 	(rst_n_sync),
	.clk 			(clk),

	.sink_valid 	(sink_valid_ping), 
	.sink_ready 	(sink_ready_ping), 
	.sink_error 	(sink_error_ping), 
	.sink_sop 		(sink_sop_ping 	),   
	.sink_eop 		(sink_eop_ping 	),   
	.sink_real 		(sink_real_ping ),  
	.sink_imag 		(sink_imag_ping ),  

	.fftpts_in 		(fftpts_in),

	// right side
	.source_valid 	(source_valid_ping), 
	.source_ready 	(source_ready_ping), 
	.source_error 	(source_error_ping), 
	.source_sop 	(source_sop_ping ),   
	.source_eop 	(source_eop_ping ),   
	.source_real 	(source_real_ping ),  
	.source_imag 	(source_imag_ping ),
	.fftpts_out 	( )   

	);

idct_aftIFFT_reod #(
	.wDataInOut (wDataOut) 
	)
idct_aftIFFT_reod_pong (
	// left side
	.rst_n_sync 	(rst_n_sync),
	.clk 			(clk),

	.sink_valid 	(sink_valid_pong), 
	.sink_ready 	(sink_ready_pong), 
	.sink_error 	(sink_error_pong), 
	.sink_sop 		(sink_sop_pong 	),   
	.sink_eop 		(sink_eop_pong 	),   
	.sink_real 		(sink_real_pong ),  
	.sink_imag 		(sink_imag_pong ),  

	.fftpts_in 		(fftpts_in),

	// right side
	.source_valid 	(source_valid_pong), 
	.source_ready 	(source_ready_pong), 
	.source_error 	(source_error_pong), 
	.source_sop 	(source_sop_pong ),   
	.source_eop 	(source_eop_pong ),   
	.source_real 	(source_real_pong ),  
	.source_imag 	(source_imag_pong ),
	.fftpts_out 	( )   

	);

always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		is_pong_source <= 0;
		source_ready_ping <= 0;
		source_ready_pong <= 0;
	end
	else 
	begin
		if (is_pong_source==1'b0 && source_eop_ping==1'b1)
			is_pong_source <= 1'b1;
		else if (is_pong_source==1'b1 && source_eop_pong==1'b1)
			is_pong_source <= 1'b0;

		source_ready_ping <= (is_pong_source==1'b0)? source_ready : 1'b0;
		source_ready_pong <= (is_pong_source==1'b1)? source_ready : 1'b0;
	end
end

always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		source_valid <= 0; 
		source_error <= 0; 
		source_sop <= 0;   
		source_eop <= 0;   
		source_real <= 0;  
		source_imag <= 0;  
	end
	else
	begin
		if (is_pong_source==1'b0)
		begin
			source_valid <= source_valid_ping; 
			source_error <= source_error_ping; 
			source_sop <= source_sop_ping;   
			source_eop <= source_eop_ping;   
			source_real <= source_real_ping;  
			source_imag <= source_imag_ping;  
		end
		else
		begin
			source_valid <= source_valid_pong; 
			source_error <= source_error_pong; 
			source_sop <= source_sop_pong;   
			source_eop <= source_eop_pong;   
			source_real <= source_real_pong;  
			source_imag <= source_imag_pong;  
		end
	end
end
//end----------  Ping Pong  --------------

endmodule