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

	reg [15:0] cnt_rd;
	integer 	data_file, scan_file, wr_file;
	reg [31:0] 	captured_data, captured_data_imag;
	localparam reg [15:0] cnt_rd_end = 16'd2048;
	localparam reg [11:0] fftpts_cnst = 12'd2048;

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
		end
		else
		begin
			sink_error <= 0;
			inverse <= 0;
			fftpts_in <= fftpts_cnst;

			cnt_rd <= (cnt_rd == cnt_rd_end+16'd1) ? cnt_rd : cnt_rd+16'd1;
			//cnt_rd <= (cnt_rd == cnt_rd_end+16'd2400) ? 16'd0 : cnt_rd+16'd1;

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
			if (cnt_rd==cnt_rd_end+16'd1)  $fclose(data_file);

			sink_sop = (cnt_rd==16'd1) ? 1'b1 : 1'b0;
			sink_eop = (cnt_rd==cnt_rd_end)? 1'b1 : 1'b0;
			sink_valid = (cnt_rd>=16'd1 && cnt_rd<=cnt_rd_end)? 1'b1 : 1'b0;
		end
	end


	dct_top u0 (
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
		.source_valid	(source_valid), 
		.source_ready	(source_ready), 
		.source_error	(source_error), 
		.source_sop		(source_sop),   
		.source_eop		(source_eop),   
		.source_real	(source_real),  
		.source_imag	(source_imag),  
		.fftpts_out()
	);

	reg signed [15:0] source_real_r, source_imag_r;
	assign source_real_r = source_real;
	assign source_imag_r = source_imag;

	always@(posedge clk)
	begin
		
			if (source_valid)
			begin
				$fwrite(wr_file, "%d %d\n", source_real_r, source_imag_r,);
			end
			if (source_eop)  $fclose(wr_file);
	end



endmodule