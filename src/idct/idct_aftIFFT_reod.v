//-----------------------------------------------------------------
// Module Name:        	idct_aftIFFT_reod.v
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
//  bit reverse  -->    |  reorder | --> x0,x2047,x1,x2046,x2,x2045,...,x1023,x1024
//                      |          |
//  ---------------------------------------------------------------------------- 
//  Note :  (1) fftpts_in : The number of FFT points is power of 2
// 


module idct_aftIFFT_reod #(parameter  
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
	output reg [wDataInOut-1:0]	source_real,
	output reg [wDataInOut-1:0]	source_imag,
	output reg [11:0]	fftpts_out
	);


reg [11:0] 	fftpts_divd2_reg, fftpts_reg;
reg 	wren0, wren1;
reg	 [9:0]	wraddress0, rdaddress0, wraddress1, rdaddress1;	//constant width
 wire [2*wDataInOut -1:0]  	q0, q1;
//wire [55:0]  	q0, q1;
reg [1:0] 	fsm;
wire [2*wDataInOut-1:0] 	data;
reg [11:0] 		cnt_sink_valid;

reg [11:0] 	cnt_sink_valid_rev;

reg 		duty_cycle;

assign 	source_error = 2'b00;
// assign 	fftpts_divd2 = {1'b0,fftpts_in[11:1]};
assign	data = {sink_real,sink_imag};
// assign  fftpts_out = fftpts_in;

always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		fftpts_reg <= 0;
		fftpts_divd2_reg <= 0;
	end
	else
	begin
		fftpts_reg <= (sink_sop)? fftpts_in : fftpts_reg;
		fftpts_divd2_reg <= (sink_sop)? {1'b0,fftpts_in[11:1]} : fftpts_divd2_reg;
	end
end

//--------------  2 RAMs (Each RAM only stores half of the data)-----------------
RAM_idct_aftIFFT u0 (
	.data      (data),      //  ram_input.datain
	.wraddress (wraddress0), //           .wraddress
	.rdaddress (rdaddress0), //           .rdaddress
	.wren      (wren0),      //           .wren
	.clock     (clk),     //           .clock
	.q         (q0)          // ram_output.dataout
); //constant width

RAM_idct_aftIFFT u1 (
	.data      (data),      //  ram_input.datain
	.wraddress (wraddress1), //           .wraddress
	.rdaddress (rdaddress1), //           .rdaddress
	.wren      (wren1),      //           .wren
	.clock     (clk),     //           .clock
	.q         (q1)          // ram_output.dataout
); //constant width

// ----------------  FSM -------------------------
always@(posedge clk)
begin
if (!rst_n_sync)
begin
	fsm <= 0;
	sink_ready <= 1'b0;
end
else
begin
	case (fsm)
	2'd0: // s0, s_wait
	begin
		if (sink_sop)
			fsm <= 2'd1;
		else
			fsm <= 2'd0;
		sink_ready <= 1'b1;
	end
	2'd1: // s1, s_writeRAM
	begin
		if (sink_eop)
			fsm <= 2'd2;
		else
			fsm <= 2'd1;
		sink_ready <= 1'b1;
	end
	2'd2: // s2, wait for source_ready
	begin
		if (source_ready)
			fsm <= 2'd3;
		else
			fsm <= 2'd2;
		sink_ready <= 1'b0;
	end
	2'd3: //s3, s_readRAM
	begin
		if (source_eop)
			fsm <= 2'd0;
		else
			fsm <= 2'd3;
		sink_ready <= 1'b0;
	end
	default:
	begin
		fsm <= 0;
		sink_ready <= 1'b0;
	end
	endcase
end
end

//-----------------   Write RAM ----------------------
always@(posedge clk)
begin
if (!rst_n_sync)
	cnt_sink_valid <= 0;
else
	if (fsm==2'd0 || fsm==2'd1)
		cnt_sink_valid <= (sink_valid) ? cnt_sink_valid+1'd1 : cnt_sink_valid;
	else
		cnt_sink_valid <= 0;
end
 

always@(*)
begin
case (fftpts_reg)
12'd2048 : 
begin
	cnt_sink_valid_rev[11] = 1'b0;
	cnt_sink_valid_rev[10] =cnt_sink_valid[0];
	cnt_sink_valid_rev[9] = cnt_sink_valid[1];
	cnt_sink_valid_rev[8] = cnt_sink_valid[2];
	cnt_sink_valid_rev[7] = cnt_sink_valid[3];
	cnt_sink_valid_rev[6] = cnt_sink_valid[4];
	cnt_sink_valid_rev[5] = cnt_sink_valid[5];
	cnt_sink_valid_rev[4] = cnt_sink_valid[6];
	cnt_sink_valid_rev[3] = cnt_sink_valid[7];
	cnt_sink_valid_rev[2] = cnt_sink_valid[8];
	cnt_sink_valid_rev[1] = cnt_sink_valid[9];
	cnt_sink_valid_rev[0] = cnt_sink_valid[10];
end
12'd1024 : 
begin
	cnt_sink_valid_rev[11] = 1'b0;
	cnt_sink_valid_rev[10] = 1'b0;
	cnt_sink_valid_rev[9] = cnt_sink_valid[0];
	cnt_sink_valid_rev[8] = cnt_sink_valid[1];
	cnt_sink_valid_rev[7] = cnt_sink_valid[2];
	cnt_sink_valid_rev[6] = cnt_sink_valid[3];
	cnt_sink_valid_rev[5] = cnt_sink_valid[4];
	cnt_sink_valid_rev[4] = cnt_sink_valid[5];
	cnt_sink_valid_rev[3] = cnt_sink_valid[6];
	cnt_sink_valid_rev[2] = cnt_sink_valid[7];
	cnt_sink_valid_rev[1] = cnt_sink_valid[8];
	cnt_sink_valid_rev[0] = cnt_sink_valid[9];
end
12'd512 :
begin
	cnt_sink_valid_rev[11] = 1'b0;
	cnt_sink_valid_rev[10] = 1'b0;
	cnt_sink_valid_rev[9] = 1'b0;
	cnt_sink_valid_rev[8] = cnt_sink_valid[0];
	cnt_sink_valid_rev[7] = cnt_sink_valid[1];
	cnt_sink_valid_rev[6] = cnt_sink_valid[2];
	cnt_sink_valid_rev[5] = cnt_sink_valid[3];
	cnt_sink_valid_rev[4] = cnt_sink_valid[4];
	cnt_sink_valid_rev[3] = cnt_sink_valid[5];
	cnt_sink_valid_rev[2] = cnt_sink_valid[6];
	cnt_sink_valid_rev[1] = cnt_sink_valid[7];
	cnt_sink_valid_rev[0] = cnt_sink_valid[8];
end
12'd256 :
begin
	cnt_sink_valid_rev[11] = 1'b0;
	cnt_sink_valid_rev[10] = 1'b0;
	cnt_sink_valid_rev[9] = 1'b0;
	cnt_sink_valid_rev[8] = 1'b0;
	cnt_sink_valid_rev[7] = cnt_sink_valid[0];
	cnt_sink_valid_rev[6] = cnt_sink_valid[1];
	cnt_sink_valid_rev[5] = cnt_sink_valid[2];
	cnt_sink_valid_rev[4] = cnt_sink_valid[3];
	cnt_sink_valid_rev[3] = cnt_sink_valid[4];
	cnt_sink_valid_rev[2] = cnt_sink_valid[5];
	cnt_sink_valid_rev[1] = cnt_sink_valid[6];
	cnt_sink_valid_rev[0] = cnt_sink_valid[7];
end
12'd128 :
begin
	cnt_sink_valid_rev[11] = 1'b0;
	cnt_sink_valid_rev[10] = 1'b0;
	cnt_sink_valid_rev[9] = 1'b0;
	cnt_sink_valid_rev[8] = 1'b0;
	cnt_sink_valid_rev[7] = 1'b0;
	cnt_sink_valid_rev[6] = cnt_sink_valid[0];
	cnt_sink_valid_rev[5] = cnt_sink_valid[1];
	cnt_sink_valid_rev[4] = cnt_sink_valid[2];
	cnt_sink_valid_rev[3] = cnt_sink_valid[3];
	cnt_sink_valid_rev[2] = cnt_sink_valid[4];
	cnt_sink_valid_rev[1] = cnt_sink_valid[5];
	cnt_sink_valid_rev[0] = cnt_sink_valid[6];
end
12'd64 :
begin
	cnt_sink_valid_rev[11] = 1'b0;
	cnt_sink_valid_rev[10] = 1'b0;
	cnt_sink_valid_rev[9] = 1'b0;
	cnt_sink_valid_rev[8] = 1'b0;
	cnt_sink_valid_rev[7] = 1'b0;
	cnt_sink_valid_rev[6] = 1'b0;
	cnt_sink_valid_rev[5] = cnt_sink_valid[0];
	cnt_sink_valid_rev[4] = cnt_sink_valid[1];
	cnt_sink_valid_rev[3] = cnt_sink_valid[2];
	cnt_sink_valid_rev[2] = cnt_sink_valid[3];
	cnt_sink_valid_rev[1] = cnt_sink_valid[4];
	cnt_sink_valid_rev[0] = cnt_sink_valid[5];
end
12'd32 :
begin
	cnt_sink_valid_rev[11] = 1'b0;
	cnt_sink_valid_rev[10] = 1'b0;
	cnt_sink_valid_rev[9] = 1'b0;
	cnt_sink_valid_rev[8] = 1'b0;
	cnt_sink_valid_rev[7] = 1'b0;
	cnt_sink_valid_rev[6] = 1'b0;
	cnt_sink_valid_rev[5] = 1'b0;
	cnt_sink_valid_rev[4] = cnt_sink_valid[0];
	cnt_sink_valid_rev[3] = cnt_sink_valid[1];
	cnt_sink_valid_rev[2] = cnt_sink_valid[2];
	cnt_sink_valid_rev[1] = cnt_sink_valid[3];
	cnt_sink_valid_rev[0] = cnt_sink_valid[4];
end
12'd16 :
begin
	cnt_sink_valid_rev[11] = 1'b0;
	cnt_sink_valid_rev[10] = 1'b0;
	cnt_sink_valid_rev[9] = 1'b0;
	cnt_sink_valid_rev[8] = 1'b0;
	cnt_sink_valid_rev[7] = 1'b0;
	cnt_sink_valid_rev[6] = 1'b0;
	cnt_sink_valid_rev[5] = 1'b0;
	cnt_sink_valid_rev[4] = 1'b0;
	cnt_sink_valid_rev[3] = cnt_sink_valid[0];
	cnt_sink_valid_rev[2] = cnt_sink_valid[1];
	cnt_sink_valid_rev[1] = cnt_sink_valid[2];
	cnt_sink_valid_rev[0] = cnt_sink_valid[3];
end
default :
begin
	cnt_sink_valid_rev[11] = 1'b0;
	cnt_sink_valid_rev[10] =cnt_sink_valid[0];
	cnt_sink_valid_rev[9] = cnt_sink_valid[1];
	cnt_sink_valid_rev[8] = cnt_sink_valid[2];
	cnt_sink_valid_rev[7] = cnt_sink_valid[3];
	cnt_sink_valid_rev[6] = cnt_sink_valid[4];
	cnt_sink_valid_rev[5] = cnt_sink_valid[5];
	cnt_sink_valid_rev[4] = cnt_sink_valid[6];
	cnt_sink_valid_rev[3] = cnt_sink_valid[7];
	cnt_sink_valid_rev[2] = cnt_sink_valid[8];
	cnt_sink_valid_rev[1] = cnt_sink_valid[9];
	cnt_sink_valid_rev[0] = cnt_sink_valid[10];
end
endcase
end


always@(*)
begin
	wren0 = (cnt_sink_valid_rev < fftpts_divd2_reg) ? sink_valid : 1'b0;
	wren1 = (cnt_sink_valid_rev >= fftpts_divd2_reg) ? sink_valid : 1'b0;
end

always@(*)
begin
	wraddress0 = (cnt_sink_valid_rev < fftpts_divd2_reg) ? cnt_sink_valid_rev : 10'd0;
	wraddress1 = (cnt_sink_valid_rev >= fftpts_divd2_reg) ? (cnt_sink_valid_rev - fftpts_divd2_reg) : 10'd0;
end


//-----------------  Read RAM ------------------------
//  --------------------------------------------------------------------------------------------------
//                      |          |
//  bit reverse  -->    |  reorder | --> x0,x2047,x1,x2046,x2,x2045,...,x1023,x1024
//                      |          |
//  ---------------------------------------------------------------------------- 

always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		rdaddress0 <= 0;
		rdaddress1 <= 0;
		source_sop <= 0;
		source_eop <= 0;
		source_valid <= 0;
		duty_cycle <= 0;
	end
	else
	begin
		if (fsm==2'd3)
		begin
			if (duty_cycle) 
			begin
				rdaddress0 <= (rdaddress0 == (fftpts_divd2_reg-1'd1)) ? (fftpts_divd2_reg-1'd1) : rdaddress0 + 1'd1; 
				rdaddress1 <= rdaddress1 - 1'd1;
			end
			else
			begin 
				rdaddress0 <= rdaddress0; 
				rdaddress1 <= rdaddress1;
			end
			duty_cycle <= !duty_cycle;
		end
		else
		begin
			rdaddress0 <= 0;
			rdaddress1 <= fftpts_divd2_reg;
			duty_cycle <= 0;
		end

		if (fsm==2'd3)
		begin
			source_sop <= (duty_cycle==1'b0 && rdaddress0==1'd1)? 1'b1 : 1'b0;
			source_eop <= (duty_cycle==1'b1 && rdaddress1==1'd0 && source_valid==1'b1)? 1'b1 : 1'b0;
		end
		else 
		begin
			source_sop <= 0;
			source_eop <= 0;
		end

		if (duty_cycle==1'b0 && rdaddress0==1'd1)
			source_valid <= 1'b1;
		else if (source_eop)
			source_valid <= 1'b0;
		else
			source_valid <= source_valid;
	end
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
		if (duty_cycle)
		begin
			source_real <= q1[2*wDataInOut-1:wDataInOut];
			source_imag <= q1[wDataInOut-1:0];
		end
		else 
		begin
			source_real <= q0[2*wDataInOut-1:wDataInOut];
			source_imag <= q0[wDataInOut-1:0];
		end
	end
end

endmodule