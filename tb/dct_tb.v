// dct_fft.v

// Generated using ACDS version 15.1 185

`timescale 1 ns / 1 ns
module dct_tb (

	);

	// left side
	reg 					rst_n;  // clk Asynchronous reset active low
	reg 					clk;    

	reg        sink_valid;   //   sink.sink_valid
	wire        sink_ready;   //       .sink_ready
	reg [1:0]  sink_error;   //       .sink_error
	reg        sink_sop;     //       .sink_sop
	reg        sink_eop;     //       .sink_eop
	reg [15:0] sink_real;    //       .sink_real
	reg [15:0] sink_imag;    //       .sink_imag
	reg [11:0] fftpts_in;    //       .fftpts_in
	reg [0:0]  inverse;      //       .inverse

	wire        source_valid; // source.source_valid
	reg         source_ready; //       .source_ready
	wire [1:0]  source_error; //       .source_error
	wire        source_sop;   //       .source_sop
	wire        source_eop;   //       .source_eop
	wire [15:0] source_real;  //       .source_real
	wire [15:0] source_imag;  //       .source_imag
	//wire [15:0] source_real_rev;  //       .source_real
	//wire [15:0] source_imag_rev;  //       .source_imag

	wire        source_valid_t0; // source.source_valid
	reg         source_ready_t0; //       .source_ready
	wire [1:0]  source_error_t0; //       .source_error
	wire        source_sop_t0;   //       .source_sop
	wire        source_eop_t0;   //       .source_eop
	wire [23:0] source_real_t0;  //       .source_reals
	wire [23:0] source_imag_t0;  //       .source_imag
	wire [23:0] source_real_rev_t0;  //       .source_real
	wire [23:0] source_imag_rev_t0;  //       .source_imag

	reg [15:0] cnt_rd, cnt_file_end;
	integer 	data_file, scan_file, wr_file;
	reg [31:0] 	captured_data, captured_data_imag;
	localparam reg [11:0] fftpts_cnst = 12'd16;
	localparam reg [15:0] cnt_rd_end = {{4{1'b0}}, fftpts_cnst};
	localparam reg [15:0] param_cnt_file_end = 16'd2;  //Number of frames to be processed.

	initial	begin
		rst_n = 0;
		clk = 0;
		source_ready = 0;

		# 100 rst_n = 1'b1;
		source_ready = 1'b1;
	end

	initial begin
		data_file = $fopen("dct_src.dat","r");
		if (data_file == 0) begin
			$display("fft_src handle was NULL");
			$finish;
		end
		wr_file = $fopen("dct_result.dat","w");
		if (wr_file == 0) begin
			$display("fft_result handle was NULL");
			$finish;
		end
	end

	always # 5 clk = ~clk; //100M

	always@(posedge clk)
	begin
		if (!rst_n)
		begin
			sink_valid <= 0;
			sink_real <= 0;
			sink_imag <= 0;
			sink_sop <= 0;
			sink_eop <= 0;
			sink_error <= 0;
			fftpts_in <= 0;
			inverse <= 0;
			cnt_rd <= 0;
			captured_data <= 0;
			captured_data_imag <= 0;
			cnt_file_end <= 0;
		end
		else
		begin
			sink_error <= 0;
			inverse <= 0;
			fftpts_in <= fftpts_cnst;

			//cnt_rd <= (cnt_rd == cnt_rd_end+16'd1) ? cnt_rd : cnt_rd+16'd1;
			cnt_rd <= (cnt_rd == cnt_rd_end+16'd20) ? 16'd0 : cnt_rd+16'd1;

			if (cnt_file_end <= (param_cnt_file_end-1'd1) )
			begin
				if (cnt_rd >= 16'd1 && cnt_rd <= cnt_rd_end) begin
					if (!$feof(data_file)) begin
						scan_file = $fscanf(data_file, "%d %d\n", captured_data, captured_data_imag);
						sink_real = captured_data[15:0];
						sink_imag = captured_data_imag[15:0];
					end
					else begin
						sink_real = 0;
						sink_imag = 0;
					end
				end
				else
				begin
					if ($feof(data_file))
					begin
						$fseek(data_file,0,0);
						cnt_file_end = cnt_file_end + 16'd1;
						if (cnt_file_end==param_cnt_file_end) $fclose(data_file);
					end
				end
			end

			sink_sop = (cnt_rd==16'd1 && cnt_file_end < param_cnt_file_end) ? 1'b1 : 1'b0;
			sink_eop = (cnt_rd==cnt_rd_end && cnt_file_end < param_cnt_file_end)? 1'b1 : 1'b0;
			sink_valid = (cnt_rd>=16'd1 && cnt_rd<=cnt_rd_end && cnt_file_end < param_cnt_file_end)? 1'b1 : 1'b0;
		end
	end


	dct_top dct_top_inst (
		.clk          (clk),          //    clk.clk
		.rst_n_sync   (rst_n),      //    rst.reset_n
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
		.source_real_rev	(source_real_rev_t0),  
		.source_imag_rev	(source_imag_rev_t0),  
		.fftpts_out(),

		.overflow()
	);

	idct_top  #(
		.wDataIn  (24),  
		.wDataOut  (16) 	)
	idct_top_inst
	(
		.clk          (clk),          //    clk.clk
		.rst_n_sync   (rst_n),      //    rst.reset_n
		.sink_valid   (source_valid_t0),   //   sink.sink_valid
		.sink_ready   (source_ready_t0),   //       .sink_ready
		.sink_error   (source_error_t0),   //       .sink_error
		.sink_sop     (source_sop_t0),     //       .sink_sop
		.sink_eop     (source_eop_t0),     //       .sink_eop
		.sink_real    (source_real_t0),    //       .sink_real
		.sink_imag    (source_imag_t0),    //       .sink_imag
		.sink_real_rev    (source_real_rev_t0),    //       .sink_real
		.sink_imag_rev    (source_imag_rev_t0),    //       .sink_imag
		.fftpts_in    (fftpts_in),    //       .fftpts_in

		//right side
		.source_valid	(source_valid), 
		.source_ready	(source_ready), 
		.source_error	(source_error), 
		.source_sop		(source_sop),   
		.source_eop		(source_eop),   
		.source_real	(source_real),  
		.source_imag	(source_imag),  
		.fftpts_out(),

		.overflow()
	);

	reg signed [15:0] source_real_r, source_imag_r;
	reg [15:0] 	cnt_source_eop;
	assign source_real_r = source_real;
	assign source_imag_r = source_imag;

	always@(posedge clk)
	begin
		if (!rst_n)
			cnt_source_eop <= 0;
		else
		begin
			if (cnt_source_eop <= (param_cnt_file_end-1'd1) )
			begin
				if (source_valid)
				begin
					$fwrite(wr_file, "%d %d\n", source_real_r, source_imag_r,);
				end

				cnt_source_eop = (source_eop)? cnt_source_eop + 1'd1 : cnt_source_eop;
				if (cnt_source_eop==param_cnt_file_end)  $fclose(wr_file);
			end
		end

	end



endmodule