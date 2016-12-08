% Pls run dct_fft_test first

%% Compare with FPGA simulation result
outf = fopen('../modelsim/ce_result.dat','r');
    FPGA_out = fscanf(outf , '%d %d', [2 Inf]);
fclose(outf);

NN = 2048;
kk = 1;
FPGA_out = FPGA_out(:,1+NN*(kk-1):NN*kk);
FPGA_out = FPGA_out';

H_Est_FPGA_out = (FPGA_out(:,1) + sqrt(-1)*FPGA_out(:,2))/2048;

mse_FPGA_out = abs(H_Est_FPGA_out([end-nSubcarrierUsed/2+1:end,2:nSubcarrierUsed/2+1]) - channelFreqUsed([end-nSubcarrierUsed/2+1:end,2:nSubcarrierUsed/2+1],1,iRxAnte, iUE)).^2;

ttt0 = temp_mse(:,1,1,1);
ttt2 = abs(H_Est2([end-nSubcarrierUsed/2+1:end,2:nSubcarrierUsed/2+1]) - channelFreqUsed([end-nSubcarrierUsed/2+1:end,2:nSubcarrierUsed/2+1],1,iRxAnte, iUE)).^2;

sum(ttt0)
sum(ttt2)
sum(mse_FPGA_out)
mean(ttt0)
mean(ttt2)
mean(mse_FPGA_out)
