//-----------------------------------------------------------------
// Module Name:        	ce_window.v
// Project:             CE RTL
// Description:         Window between DCT and IDCT.
// Author:				Long Jiang
//------------------------------------------------------------------
//  Version 0.1
//  Description :  First version 
//  2016-11-16
//  ----------------------------------------------------------------
//  Windowing the first window_size data.
//  Input : 
//         D(1), D(2), ... D(k),  ...,    D(N)
//         0,    D(N), ... D(N+2-k), ..., D(2)
//                                               k = 1, 2, ... , N
//  Output : (when window_size = 144)
//         D(1), D(2), ... D(144), 0, ..., 0,    ...,   0,    0
//         0,      0, ...  0, ...,         D(144), ..., D(3), D(2) 
//                                               k = 1, 2, ... , N
//  ------------------------------------------------------------------ 
//  Note :  (1) fftpts_in : The number of FFT points is power of 2


module ce_window #(parameter  
		wDataInOut = 24
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
	input wire [wDataInOut-1:0] sink_real,  //       .sink_real
	input wire [wDataInOut-1:0] sink_imag,  //       .sink_imag
	input wire [wDataInOut-1:0] sink_real_rev,  //       .sink_real
	input wire [wDataInOut-1:0] sink_imag_rev,  //       .sink_imag

	input wire [11:0] fftpts_in,    //       .fftpts_in

	//right side
	output reg        source_valid, // source.source_valid
	input  wire        source_ready, //       .source_ready
	output wire [1:0]  source_error, //       .source_error
	output reg        source_sop,   //       .source_sop
	output reg        source_eop,   //       .source_eop
	output reg [wDataInOut-1:0] source_real,  //       .source_real
	output reg [wDataInOut-1:0] source_imag,  //       .source_imag
	output reg [wDataInOut-1:0] source_real_rev,  //       .source_real
	output reg [wDataInOut-1:0] source_imag_rev,  //       .source_imag
	output wire [11:0] fftpts_out    //       .fftpts_out
	);

localparam 	window_size = 12'd144;

reg [11:0] 	cnt_window;

assign fftpts_out = fftpts_in;
assign sink_ready = source_ready;
assign source_error = 2'b00;

always@(posedge clk)
begin
	source_sop <= sink_sop;
	source_eop <= sink_eop;
	source_valid <= sink_valid;
end

always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		cnt_window <= 0;
		source_real <= 0;
		source_imag <= 0;
		source_real_rev <= 0;
		source_imag_rev <= 0;
	end
	else
	begin
		if (sink_eop)
			cnt_window <= 0;
		else if (sink_valid)
			cnt_window <= cnt_window + 1'd1;
		else
			cnt_window <= cnt_window;

		if (sink_valid)
			if (cnt_window < window_size)
			begin
				source_real <= sink_real;
				source_imag <= sink_imag;
			end
			else
			begin
				source_real <= 0;
				source_imag <= 0;
			end
		else
		begin
			source_real <= source_real;
			source_imag <= source_imag;
		end

		if (sink_valid)
			if ( cnt_window >= ( fftpts_in - window_size ) )
			begin
				source_real_rev <= sink_real_rev;
				source_imag_rev <= sink_imag_rev;
			end
			else
			begin
				source_real_rev <= 0;
				source_imag_rev <= 0;
			end
		else
		begin
			source_real_rev <= source_real_rev;
			source_imag_rev <= source_imag_rev;
		end
	end
end

endmodule