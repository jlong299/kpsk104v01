//-----------------------------------------------------------------
// Module Name:        	dct_preFFT_reod_1200in.v
// Project:             CE RTL
// Description:         Signal reorder serves as the first part of DCT which is right before FFT.
// Author:				Long Jiang
//------------------------------------------------------------------
//  Version 0.1
//  Description :  First version 
//  2016-11-17
//  --------------------------------------------------------------------------------------------------
//                      |          |
//  x0,x1,...,x2047 --> |  reoder  | --> x0,x2,...,x2046,x2047,x2045,...,x3,x1
//                      |          |
//  ---------------------------------------------------------------------------- 
//  This version is for the 1200 length data input condition.
//  The input order is : x1448,x1449,...,x2047,x1,x2,...,x600   (amount:1200)
//  ----------------------------------------------------------------------------
//  Note :  (1) fftpts_in : The number of FFT points is power of 2
// 


module dct_preFFT_reod_1200in #(parameter  
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
	output reg	[wDataInOut-1:0]	source_real,
	output reg	[wDataInOut-1:0]	source_imag,
	output	[11:0]	fftpts_out
	);

localparam 	wraddress_end = 11'd600;
localparam 	wraddress_start = 11'd1448;   // wraddress_end + wraddress_start = fftpts_in

reg [1:0] fsm;
reg [10:0] 	wraddress, rdaddress, rdaddress_r;
wire wren;
//reg [10:0] cnt_wren;
wire [2*wDataInOut-1:0] 	data, q;
reg  read_latter_half;

reg		source_valid_pre,
reg		source_sop_pre,
reg		source_eop_pre,

assign fftpts_out = fftpts_in;
assign source_error = 2'b00;
assign data = {sink_real, sink_imag};
//assign source_real = q[2*wDataInOut-1:wDataInOut];
//assign source_imag = q[wDataInOut-1:0];
assign wren = sink_valid;


//--------------  RAM ----------------- 
// depth: 2048  datawidth: 2*wDataInOut  
RAM_dct_preFFT_reod u0 (
	.data      (data),      //  ram_input.datain
	.wraddress (wraddress), //           .wraddress
	.rdaddress (rdaddress), //           .rdaddress
	.wren      (wren),      //           .wren
	.clock     (clk),     //           .clock
	.q         (q)          // ram_output.dataout
); //constant width

//-------------- FSM -----------------
always@(posedge clk)
begin
	if (!rst_n_sync)
		fsm <= 0;
	else
	begin
		case(fsm)
		2'd0:
			fsm <= (sink_sop)? 2'd1 : 2'd0;
		2'd1: //write half data (ready to read)
			fsm <= (wraddress == wraddress_end)? 2'd2 : 2'd1;
		2'd2:
			fsm <= (source_ready) ? 2'd3 : 2'd2;
		2'd3: // begin to read
			fsm <= (source_eop_pre) ? 2'd0 : 2'd3;
		default:
			fsm <= 0;
		endcase
	end
end

always@(posedge clk)
begin
	if (!rst_n_sync)
		sink_ready <= 0;
	else
	begin
		if (fsm==2'd0)
			sink_ready <= 1'b1;
		else if (sink_eop)
			sink_ready <= 1'b0;
		else if (source_eop_pre)
			sink_ready <= 1'b1;
		else
			sink_ready <= sink_ready;
	end
end
//------------ Write logic ------------
always@(posedge clk)
begin
	if(!rst_n_sync)
		wraddress <= 0;
	else
	begin
		if (fsm==2'd0)
			wraddress <= wraddress_start;
		else if (wren==1'b1)
		begin
			if (wraddress == (fftpts_in-1'd1) )
				wraddress <= 11'd1;
			else
				wraddress <= wraddress + 1'd1;
		end
		else
			wraddress <= wraddress;
	end
end

//---------- Read logic -----------
always@(posedge clk)
begin
	if(!rst_n_sync)
		rdaddress <= 0;
	else
	begin
		if(fsm==2'd3)
			read_latter_half <= (rdaddress== (fftpts_in-2'd2))? 1'b1 : read_latter_half;
		else
			read_latter_half <= 0;

		if(fsm==2'd3)
		begin
			if(rdaddress== (fftpts_in-2'd2))
				rdaddress <= fftpts_in-1'd1;
			else if (read_latter_half == 1'b0)
				rdaddress <= rdaddress + 2'd2;
			else
				rdaddress <= rdaddress - 2'd2;
		end
		else
			rdaddress <= 0;
	end
end

//---------- Output --------------
always@(posedge clk)
begin
	if(!rst_n_sync)
	begin
		source_valid_pre <= 0;
		source_sop_pre <= 0;
		source_eop_pre <= 0;
	end
	else
	begin
		source_sop_pre <= (fsm==2'd3 && rdaddress==1'd0 && source_eop_pre==1'b0)? 1'b1 : 1'b0;

		source_eop_pre <= (fsm==2'd3 && rdaddress==2'd1)? 1'b1 : 1'b0;

		if(fsm==2'd3 && rdaddress==1'd0 && source_eop_pre==1'b0)
			source_valid_pre <= 1'b1;
		else if (source_eop_pre)
			source_valid_pre <= 1'b0;
		else
			source_valid_pre <= source_valid_pre;

	end
end

//  ------------------ Set x0, x601, x602, ... , x1447  all = 0 ------------------
always@(posedge clk)
begin
	if (!rst_n_sync)
	begin
		source_real <= 0;
		source_imag <= 0;
	end
	else
	begin
		if (rdaddress_r == 11'd0)
		begin
			source_real <= 0;
			source_imag <= 0;
		end
		else if (rdaddress_r > wraddress_end && rdaddress_r < wraddress_start)
		begin
			source_real <= 0;
			source_imag <= 0;
		end
		else
		begin
			source_real <= q[2*wDataInOut-1:wDataInOut];
			source_imag <= q[wDataInOut-1:0];
		end
	end
end

always@(posedge clk)
begin
	source_valid <= source_valid_pre;
	source_sop <= source_sop_pre;
	source_eop <= source_eop_pre;
	rdaddress_r <= rdaddress;
end

endmodule