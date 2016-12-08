//-----------------------------------------------------------------
// Module Name:        	idct_vecRot_twiddle.v
// Project:             CE RTL
// Description:         
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
//------------------------------------------------------------------
//  Input : 
//      sink_cos :  
//          65536*sqrt(2)               k=1
//          65536*(cos(pi*(k-1)/2/N)    k=2:N
//      sink_sin :  
//          0*sqrt(2)                   k=1
//          65536*(sin(pi*(k-1)/2/N)    k=2:N
//  --------------------------------------------------------------------------------------------------
//  Twiddle :
//
//  --------
//  F1(k)
//  --------
//
//                           +    *sink_cos      +           /65536*sqrt(N/2) 
//  R(F(k))     ---------------- -----------> ------- Real ------------------>   
//  sink_real    \          + /                  + /       
//                \          /                    /                /256 in idct_vecRot_scaling
//                 \        /                    /                 /256*sqrt(N/2) after IFFT
//                  \      /                    /    
//                   \    /                    /   
//                    \  /  -     *sink_sin   /        
//  I(F(k))     ---------------- ----------->   
//  sink_imag   \     / \   + /  
//               \   /   \   /  
//                \ /     \ /   
//                 / \     / \  
//                /   \   /   \ +
//               /     \ /   + \  *sink_sin       +          /65536*sqrt(N/2) 
//  I(F(N+2-k)) ---------------- -----------> ------- Imag ------------------>   
//  sink_real_rev     /  \                       + /            
//                   /    \                       /           
//                  /      \                     /           
//                 /        \                   /          
//                /          \ +               /           
//               /          - \   *sink_cos   /         
//  R(F(N+2-k)) ---------------- ----------->   
//  sink_imag_rev
//  ---------------------------------------------------------------------------- 
//  Input : 
//         D(1), D(2), ... D(k),  ...,    D(N)
//         0,    D(N), ... D(N+2-k), ..., D(2)
//     k = 1, 2, ... , N
//  ---------------------------------------------------------------------------- 
//  Note :  (1) N = fftpts_in : The number of FFT points is power of 2


module idct_vecRot_twiddle #(parameter  
		wDataIn =24,
		wDataOut =24+18,  
		wCoeff =18  
	)
	(
	// left side
	input wire				rst_n_sync,  // clk synchronous reset active low
	input wire				clk,    

	input wire        	sink_valid, // sink.sink_valid
	output wire        	sink_ready, //       .sink_ready
	input wire [1:0]  	sink_error, //       .sink_error
	input wire        	sink_sop,   //       .sink_sop
	input wire        	sink_eop,   //       .sink_eop
	input wire signed [wDataIn-1:0] sink_real,  //       .sink_real
	input wire signed [wDataIn-1:0] sink_imag,  //       .sink_imag
	input wire signed [wDataIn-1:0] sink_real_rev,  //       .sink_real
	input wire signed [wDataIn-1:0] sink_imag_rev,  //       .sink_imag
	input wire [11:0] fftpts_in,    //       .fftpts_in

	// 1 clks delay with sink_valid
	input wire signed [wCoeff-1:0] 	sink_cos,
	input wire signed [wCoeff-1:0] 	sink_sin,

	//right side
	output reg         	source_valid, // source.source_valid
	input  wire        	source_ready, //       .source_ready
	output wire [1:0]  	source_error, //       .source_error
	output reg         	source_sop,   //       .source_sop
	output reg         	source_eop,   //       .source_eop
	output wire [wDataOut-1:0] source_real,  //       .source_real
	output wire [wDataOut-1:0] source_imag,  //       .source_imag
	output reg [11:0] fftpts_out    //       .fftpts_out
	);

assign 	source_error = 2'b00;
// assign  fftpts_out = fftpts_in;
assign 	sink_ready = source_ready;

reg signed [wDataIn:0] 	p0 [3:0];
reg signed [wDataIn:0] 	p1 [3:0];
reg signed [wDataIn+wCoeff:0] 	p2 [3:0];
reg signed [wDataIn+wCoeff+1:0] 	p3 [1:0];

reg [3:0] 	valid_r, sop_r, eop_r;

reg [11:0] 	fftpts_reg;

// ---------- PART 1 :  forward direction -------------
// ---------------- Pipeline 0 -------------------------
always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		p0[0] <= 0;
		p0[1] <= 0;
		p0[2] <= 0;
		p0[3] <= 0;
	end
	else
	begin
		p0[0] <= sink_real + sink_imag_rev;
		p0[1] <= -sink_imag + sink_real_rev;
		p0[2] <= sink_real + sink_imag_rev;
		p0[3] <= sink_imag - sink_real_rev;
	end
end

// ---------------- Pipeline 1 -------------------------
always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		p1[0] <= 0;
		p1[1] <= 0;
		p1[2] <= 0;
		p1[3] <= 0;
	end
	else
	begin
		p1[0] <= p0[0];
		p1[1] <= p0[1];
		p1[2] <= p0[2];
		p1[3] <= p0[3];
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
// 		p2[0] <= p1[0]*sink_cos;
// 		p2[1] <= p1[1]*sink_sin;
// 		p2[2] <= p1[2]*sink_sin;
// 		p2[3] <= p1[3]*sink_cos;
// 	end
// end

lpm_mult_25_18 lpm_mult_25_18_inst0 (
	.dataa  (p1[0]),
	.datab  (sink_cos),
	.clock  (clk),
	.result (p2[0])
	);
lpm_mult_25_18 lpm_mult_25_18_inst1 (
	.dataa  (p1[1]),
	.datab  (sink_sin),
	.clock  (clk),
	.result (p2[1])
	);
lpm_mult_25_18 lpm_mult_25_18_inst2 (
	.dataa  (p1[2]),
	.datab  (sink_sin),
	.clock  (clk),
	.result (p2[2])
	);
lpm_mult_25_18 lpm_mult_25_18_inst3 (
	.dataa  (p1[3]),
	.datab  (sink_cos),
	.clock  (clk),
	.result (p2[3])
	);

// ---------------- Pipeline 3 -------------------------
always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		p3[0] <= 0;
		p3[1] <= 0;
	end
	else
	begin
		p3[0] <= p2[0]+p2[1];
		p3[1] <= p2[2]+p2[3];
	end
end

	assign	source_real = p3[0][wDataOut-1:0];
	assign	source_imag = p3[1][wDataOut-1:0];

// ------------- PART 3 :  output  ----------------
always@(posedge clk)
begin
	valid_r[0] <= sink_valid;
	sop_r[0] <= sink_sop;
	eop_r[0] <= sink_eop;
	valid_r[1] <= valid_r[0];
	sop_r[1] <= sop_r[0];
	eop_r[1] <= eop_r[0];
	valid_r[2] <= valid_r[1];
	sop_r[2] <= sop_r[1];
	eop_r[2] <= eop_r[1];
	valid_r[3] <= valid_r[2];
	sop_r[3] <= sop_r[2];
	eop_r[3] <= eop_r[2];
	source_valid <= valid_r[3];
	source_sop <= sop_r[3];
	source_eop <= eop_r[3];
end

always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		fftpts_reg <= 0;
		fftpts_out <= 0;
	end
	else
	begin
		fftpts_reg <= (sink_sop) ? fftpts_in : fftpts_reg;
		fftpts_out <= (sop_r[3]) ? fftpts_reg : fftpts_out;
	end
end

endmodule