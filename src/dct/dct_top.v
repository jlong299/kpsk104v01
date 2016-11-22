//-----------------------------------------------------------------
// Module Name:        	dct_top.v
// Project:             CE RTL
// Description:         DCT top level.
// Author:				Long Jiang
//------------------------------------------------------------------
//  Version 0.1
//  Description :  First version 
//  2016-10-31
//  ----------------------------------------------------------------
//  Detail :  (Matlab Code)
//
//  %% Calc dct from fft
//  x_reod = zeros(1,N);
//  x_reod(1:N/2) = x(1:2:N-1);
//  x_reod(N/2+1:N) = x(N:-2:2);
// 
//      F = fft(x_reod);
//      %disp(F);
// 
//  w = sqrt(2/N)*ones(1,N);
//  w(1) = 1/sqrt(N);
// 
//  if complex_sig == 0
//      for k = 1:N
//          D1(k) = exp(-1j*pi*(k-1)/(2*N))* F(k);
//      end
//      % disp(real(D1));
//  else
//      D1(1) = w(1)*F(1);
//      for k = 2:N
//          D1(k) = 1/2*( exp(-1j*pi*(k-1)/(2*N))* F(k) + exp(1j*pi*(k-1)/(2*N))* F(N+2-k));
//          D1(k) = w(k)*D1(k);
//      end
//     % disp(D1);
//  end
//  --------------------------------------------------------------------------------------------------
//  Top structure :
//
//    --> dct_preFFT_reod --> FFT --> dct_vecRot -->
//
//  ---------------------------------------------------------------------------- 
//  Output : 
//         D(1), D(2), ... D(k),  ...,    D(N)
//         0,    D(N), ... D(N+2-k), ..., D(2)
//                                               k = 1, 2, ... , N
//  ---------------------------------------------------------------------------- 
//  Note :  (1) fftpts_in : The number of FFT points is power of 2
//          (2) Ping-pong strutrue to improve throughput
// 


module dct_top #(parameter  
		wDataIn = 16,  
		wDataOut = 24  
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
	output wire [wDataOut-1:0] source_real_rev,  //       .source_real
	output wire [wDataOut-1:0] source_imag_rev,  //       .source_imag
	output wire [11:0] fftpts_out,    //       .fftpts_out

	output wire 		overflow
	);

localparam 	wData_t1 = 28;
reg        source_valid_t0; // source.source_valid
wire        source_ready_t0; //       .source_ready
reg [1:0]  source_error_t0; //       .source_error
reg        source_sop_t0;   //       .source_sop
reg        source_eop_t0;   //       .source_eop
reg [wDataIn-1:0] source_real_t0;  //       .source_real
reg [wDataIn-1:0] source_imag_t0;  //       .source_imag

wire        source_valid_t1; // source.source_valid
wire        source_ready_t1; //       .source_ready
wire [1:0]  source_error_t1; //       .source_error
wire        source_sop_t1;   //       .source_sop
wire        source_eop_t1;   //       .source_eop
wire [wData_t1-1:0] source_real_t1;  //       .source_real
wire [wData_t1-1:0] source_imag_t1;  //       .source_imag

reg is_pong_sink, is_pong_source;

reg        sink_valid_ping, sink_valid_pong; // sink.sink_valid
wire        sink_ready_ping, sink_ready_pong; //       .sink_ready
reg [1:0]  sink_error_ping, sink_error_pong; //       .sink_error
reg        sink_sop_ping, sink_sop_pong;   //       .sink_sop
reg        sink_eop_ping, sink_eop_pong;   //       .sink_eop
reg [wDataIn-1:0] sink_real_ping, sink_real_pong;  //       .sink_real
reg [wDataIn-1:0] sink_imag_ping, sink_imag_pong;  //       .sink_imag

wire        source_valid_ping, source_valid_pong; // source.source_valid
reg        source_ready_ping, source_ready_pong; //       .source_ready
wire [1:0]  source_error_ping, source_error_pong; //       .source_error
wire        source_sop_ping, source_sop_pong;   //       .source_sop
wire        source_eop_ping, source_eop_pong;   //       .source_eop
wire [wDataIn-1:0] source_real_ping, source_real_pong;  //       .source_real
wire [wDataIn-1:0] source_imag_ping, source_imag_pong;  //       .source_imag

assign fftpts_out = fftpts_in;

//-----------------------------------------------------
//-----------  Part 1 :  dct_preFFT_reod   ------------
//-----------------------------------------------------
//---- Change to ping-pong mode to increase throughput. 2016.11.2 ----
//start----------  Ping Pong  --------------
always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		is_pong_sink <= 0;
		sink_ready <= 0;
	end
	else 
	begin
		if (is_pong_sink==1'b0 && sink_eop_ping==1'b1)
			is_pong_sink <= 1'b1;
		else if (is_pong_sink==1'b1 && sink_eop_pong==1'b1)
			is_pong_sink <= 1'b0;

		sink_ready <= (is_pong_sink==1'b0)? sink_ready_ping : sink_ready_pong;
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
			sink_valid_ping <= sink_valid;
			sink_error_ping <= sink_error;
			sink_sop_ping <= sink_sop; 	
			sink_eop_ping <= sink_eop; 	
			sink_real_ping <= sink_real; 
			sink_imag_ping <= sink_imag; 
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
			sink_valid_pong <= sink_valid;
			sink_error_pong <= sink_error;
			sink_sop_pong <= sink_sop; 	
			sink_eop_pong <= sink_eop; 	
			sink_real_pong <= sink_real; 
			sink_imag_pong <= sink_imag;
		end
	end
end
dct_preFFT_reod_1200in #(
	.wDataInOut (wDataIn) 
	)
dct_preFFT_reod_1200in_ping (
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

dct_preFFT_reod_1200in #(
	.wDataInOut (wDataIn) 
	)
dct_preFFT_reod_1200in_pong (
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

		source_ready_ping <= (is_pong_source==1'b0)? source_ready_t0 : 1'b0;
		source_ready_pong <= (is_pong_source==1'b1)? source_ready_t0 : 1'b0;
	end
end

always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		source_valid_t0 <= 0; 
		source_error_t0 <= 0; 
		source_sop_t0 <= 0;   
		source_eop_t0 <= 0;   
		source_real_t0 <= 0;  
		source_imag_t0 <= 0;  
	end
	else
	begin
		if (is_pong_source==1'b0)
		begin
			source_valid_t0 <= source_valid_ping; 
			source_error_t0 <= source_error_ping; 
			source_sop_t0 <= source_sop_ping;   
			source_eop_t0 <= source_eop_ping;   
			source_real_t0 <= source_real_ping;  
			source_imag_t0 <= source_imag_ping;  
		end
		else
		begin
			source_valid_t0 <= source_valid_pong; 
			source_error_t0 <= source_error_pong; 
			source_sop_t0 <= source_sop_pong;   
			source_eop_t0 <= source_eop_pong;   
			source_real_t0 <= source_real_pong;  
			source_imag_t0 <= source_imag_pong;  
		end
	end
end
//end----------  Ping Pong  --------------


//-----------------------------------------------------
//-----------  Part 2 :  FFT    -----------------------
//-----------------------------------------------------
dct_fft u0 (
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
	.inverse      (1'b0),      //       .inverse
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
//-----------  Part 3 :  dct_vecRot -------------------
//-----------------------------------------------------
dct_vecRot #(  
	.wDataIn (wData_t1),  
	.wDataOut (wDataOut)  
)
dct_vecRot_inst
(
	// left side
	.rst_n_sync (rst_n_sync),  // clk synchronous reset active low
	.clk (clk),    
	
	.sink_valid (source_valid_t1), 
	.sink_ready (source_ready_t1), 
	.sink_error (source_error_t1), 
	.sink_sop 	(source_sop_t1  ),   
	.sink_eop 	(source_eop_t1  ),   
	.sink_real 	(source_real_t1 ),  
	.sink_imag 	(source_imag_t1 ),  
	
	.fftpts_in (fftpts_in),    
	
	//right side
	.source_valid	(source_valid), 
	.source_ready	(source_ready), 
	.source_error	(source_error), 
	.source_sop		(source_sop),   
	.source_eop		(source_eop),   
	.source_real	(source_real),  
	.source_imag	(source_imag),  
	.source_real_rev	(source_real_rev),  
	.source_imag_rev	(source_imag_rev),  
	.fftpts_out 	( ),

	.overflow 		(overflow)
);



endmodule