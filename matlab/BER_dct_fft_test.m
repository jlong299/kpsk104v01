% Pls run dct_fft_test first

%% Compare with FPGA simulation result
outf = fopen('../modelsim/dct_result.dat','r');
    FPGA_out = fscanf(outf , '%d %d', [2 Inf]);
fclose(outf);

len_fpga_out = length(FPGA_out(1,:));
repeat_times = len_fpga_out/N;

D1_repeat = zeros(2,len_fpga_out);

for k=1:repeat_times
    D1_repeat(1, (N*(k-1)+1):(N*k)) = real(D1(1:N));
    D1_repeat(2, (N*(k-1)+1):(N*k)) = imag(D1(1:N));
end

max(max(abs(FPGA_out - D1_repeat)) )
