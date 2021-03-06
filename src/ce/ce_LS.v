//-----------------------------------------------------------------
// Module Name:        	ce_LS.v
// Project:             CE RTL
// Description:         Least Square before DCT
// Author:				Long Jiang
//------------------------------------------------------------------
//  Version 0.1
//  Description :  First version 
//  2016-11-17
//  ----------------------------------------------------------------
//  Detail :  (Matlab Code)
//
//  H_freqUsed = rsInUsedSubcarrier_rx(:,iRxAnte) ./ rsInUsedSubcarrier_tx(:,iTxAnte,iUE);
//
//  1200 points
//  --------------------------------------------------------------------------------------------------
//  For ZC sequence, the modulus of dividend is constant (1). So division can be done by multiplication.
//
//  ---------------------------------------------------------------------------- 
//  Note :  (1) fftpts_in : The number of FFT points is power of 2
//          (2) Different UE has different LS dividend coefficients. 
// 


module ce_LS #(parameter  
		wDataIn = 16,  
		wDataOut =16  
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
	input wire signed [wDataIn-1:0] sink_real,  //       .sink_real
	input wire signed [wDataIn-1:0] sink_imag,  //       .sink_imag

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

localparam 	wCoeff = 18;

reg signed [wDataIn-1:0] 	p0 [1:0];
reg signed [wDataIn-1:0] 	p1 [1:0];
reg signed [wDataIn+wCoeff-1:0] 	p2 [3:0];

reg        source_valid_t0; // source.source_valid
reg        source_sop_t0;   //       .source_sop
reg        source_eop_t0;   //       .source_eop
reg signed [wDataIn+wCoeff:0] source_real_t0;  //       .source_real
reg signed [wDataIn+wCoeff:0] source_imag_t0;  //       .source_imag
reg [3:0]  source_valid_t0_r; // source.source_valid
reg [3:0]  source_sop_t0_r;   //       .source_sop
reg [3:0]  source_eop_t0_r;   //       .source_eop

wire signed [wCoeff-1:0] 	LS_RS_tx_real, LS_RS_tx_imag;

assign fftpts_out = fftpts_in;
assign source_error = 2'b00;
assign sink_ready = source_ready;

//-----------------------------------------------------
//-----------  Part 1 :  division (multiplication)  ---
//-----------------------------------------------------
//  (sink_real + j*sink_imag) * (LS_RS_tx_real - j*LS_RS_tx_imag) / 63336

// ---------------- Pipeline 0 -------------------------
always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		p0[0] <= 0;
		p0[1] <= 0;
	end
	else
	begin
		p0[0] <= sink_real;
		p0[1] <= sink_imag;
	end
end

// ---------------- Pipeline 1 -------------------------
always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		p1[0] <= 0;
		p1[1] <= 0;
	end
	else
	begin
		p1[0] <= p0[0];
		p1[1] <= p0[1];
	end
end

// ---------------- Pipeline 2 -------------------------
// always@(posedge clk)
// begin
// 	if (!rst_n_sync)
// 	begin
// 		p2[0] <= 0;
// 		p2[1] <= 0;
// 		p2[2] <= 0;
// 		p2[3] <= 0;
// 	end
// 	else
// 	begin
// 		p2[0] <= p1[0] * LS_RS_tx_real;
// 		p2[1] <= p1[1] * LS_RS_tx_imag;
// 		p2[2] <= p1[0] * LS_RS_tx_imag;
// 		p2[3] <= p1[1] * LS_RS_tx_real;
// 	end
// end

lpm_mult_16_18 lpm_mult_16_18_inst0(
	.dataa  (p1[0]),
	.datab  (LS_RS_tx_real),
	.clock  (clk),
	.result (p2[0])
	);
lpm_mult_16_18 lpm_mult_16_18_inst1(
	.dataa  (p1[1]),
	.datab  (LS_RS_tx_imag),
	.clock  (clk),
	.result (p2[1])
	);
lpm_mult_16_18 lpm_mult_16_18_inst2(
	.dataa  (p1[0]),
	.datab  (LS_RS_tx_imag),
	.clock  (clk),
	.result (p2[2])
	);
lpm_mult_16_18 lpm_mult_16_18_inst3(
	.dataa  (p1[1]),
	.datab  (LS_RS_tx_real),
	.clock  (clk),
	.result (p2[3])
	);

// ---------------- Pipeline 3 -------------------------
always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		source_real_t0 <= 0;
		source_imag_t0 <= 0;
	end
	else
	begin
		source_real_t0 <= p2[0]+p2[1];
		source_imag_t0 <= -p2[2]+p2[3];
	end
end


ce_LS_RS_tx #(  // Reference signal TX
	            //   abs(source_real+j*source_imag) = 63336
	.wDataOut (wCoeff)  
	)
ce_LS_RS_tx_inst (
	// left side
	.rst_n_sync 	(rst_n_sync),
	.clk 			(clk),

	.sink_valid 	(sink_valid),

	.fftpts_in 		(fftpts_in),

	// right side
	// 1 clks delay with sink_valid
	.source_real 	(LS_RS_tx_real ),  
	.source_imag 	(LS_RS_tx_imag )
	);

always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		source_valid_t0 <= 0;
		source_sop_t0 <= 0;
		source_eop_t0 <= 0;
	end
	else
	begin
		source_valid_t0_r[0] <= sink_valid;
		source_sop_t0_r[0] <= sink_sop;
		source_eop_t0_r[0] <= sink_eop;
		source_valid_t0_r[1] <= source_valid_t0_r[0];
		source_sop_t0_r[1] <= source_sop_t0_r[0];
		source_eop_t0_r[1] <= source_eop_t0_r[0];
		source_valid_t0_r[2] <= source_valid_t0_r[1];
		source_sop_t0_r[2] <= source_sop_t0_r[1];
		source_eop_t0_r[2] <= source_eop_t0_r[1];
		source_valid_t0_r[3] <= source_valid_t0_r[2];
		source_sop_t0_r[3] <= source_sop_t0_r[2];
		source_eop_t0_r[3] <= source_eop_t0_r[2];
		source_valid_t0 <= source_valid_t0_r[3];
		source_sop_t0 <= source_sop_t0_r[3];
		source_eop_t0 <= source_eop_t0_r[3];
	end
end

//-----------------------------------------------------
//-----------  Part 2 :  scaling   /65536  -----------
//-----------------------------------------------------
ce_LS_scaling #(
	.wDataIn (wDataIn+wCoeff+1),  
	.wDataOut (wDataOut)  
	)
ce_LS_scaling_inst (
	// left side
	.rst_n_sync 	(rst_n_sync),
	.clk 			(clk),

	.sink_valid 	(source_valid_t0),
	.sink_ready 	( ),
	.sink_error 	(sink_error),
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