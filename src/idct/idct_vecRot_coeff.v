//-----------------------------------------------------------------
// Module Name:        	idct_vecRot_coeff.v
// Project:             CE RTL
// Description:         
// Author:				Long Jiang
//------------------------------------------------------------------
//  Version 0.1
//  Description :  First version 
//  2016-11-7
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
//  Output : 
//      source_cos :  
//          65536*sqrt(2)               k=1
//          65536*(cos(pi*(k-1)/2/N)    k=2:N
//      source_sin :  
//          0*sqrt(2)                   k=1
//          65536*(sin(pi*(k-1)/2/N)    k=2:N


module idct_vecRot_coeff #(parameter  
		wDataOut =18  
	)
	(
	// left side
	input wire		rst_n_sync,  // clk synchronous reset active low
	input wire		clk,    

	input wire		sink_valid, 	
	input wire [11:0] 		fftpts_in, 		
	// right side
	// 1 clks delay with sink_valid
	output reg [wDataOut-1:0] 	source_cos,
	output reg [wDataOut-1:0] 	source_sin
	);


	reg [10:0] address_cos, address_sin;
	reg [9:0]  step;
	wire [wDataOut-1:0] 	source_cos1, source_cos2;
	wire [wDataOut-1:0] 	source_sin1, source_sin2;

	ROM_cos_idct_vecRot ROM_cos_idct_vecRot_inst (
		.address (address_cos), //  rom_input.address
		.clock   (clk),   //           .clk
		.q       (source_cos1)        // rom_output.dataout
	);
	ROM_sin_idct_vecRot ROM_sin_idct_vecRot_inst (
		.address (address_sin), //  rom_input.address
		.clock   (clk),   //           .clk
		.q       (source_sin1)        // rom_output.dataout
	);

	ROM2_cos_idct_vecRot ROM2_cos_idct_vecRot_inst (
		.address (address_cos), //  rom_input.address
		.clock   (clk),   //           .clk
		.q       (source_cos2)        // rom_output.dataout
	);
	ROM2_sin_idct_vecRot ROM2_sin_idct_vecRot_inst (
		.address (address_sin), //  rom_input.address
		.clock   (clk),   //           .clk
		.q       (source_sin2)        // rom_output.dataout
	);

	always@(*)
	begin
		if (fftpts_in==12'd2048 || fftpts_in==12'd512 || fftpts_in==12'd128 || fftpts_in==12'd32)
		begin
			source_cos = source_cos1;
			source_sin = source_sin1;
		end
		else
		begin
			source_cos = source_cos2;
			source_sin = source_sin2;
		end
	end

	always@(posedge clk)
	begin
		if (!rst_n_sync)
		begin
			address_cos <= 0;
			address_sin <= 0;
			step <= 0;
		end
		else
		begin
			if (sink_valid)
			begin
				address_cos <= address_cos + step;
				address_sin <= address_sin + step;
			end
			else
			begin
				address_cos <= 0;
				address_sin <= 0;
			end

			case (fftpts_in)
			12'd2048:
			begin
				step <= 10'd1;
			end
			12'd1024:
			begin
				step <= 10'd2;
			end
			12'd512:
			begin
				step <= 10'd4;
			end
			12'd256:
			begin
				step <= 10'd8;
			end
			12'd128:
			begin
				step <= 10'd16;
			end
			12'd64:
			begin
				step <= 10'd32;
			end
			12'd32:
			begin
				step <= 10'd64;
			end
			default:
			begin
				step <= 10'd1;
			end
			endcase
		end
	end


endmodule