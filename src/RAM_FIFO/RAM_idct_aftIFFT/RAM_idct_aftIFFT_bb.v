
module RAM_idct_aftIFFT (
	data,
	wraddress,
	rdaddress,
	wren,
	clock,
	q);	

	input	[31:0]	data;
	input	[9:0]	wraddress;
	input	[9:0]	rdaddress;
	input		wren;
	input		clock;
	output	[31:0]	q;
endmodule
