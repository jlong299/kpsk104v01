% Generate coeffs that used in FFT -> DCT  
close all;
N = 2048;

coeff_rs_tx = zeros(N,1);

coeff_rs_tx(1:length(rsInUsedSubcarrier_tx(:,1,1))) = rsInUsedSubcarrier_tx(:,1,1);

%% Gen mif file
outf = fopen('../src/RAM_FIFO/coeff_RS_tx_UE0_real.mif','w');
width = 18;
depth = N;
fprintf(outf,'WIDTH=%d;\nDEPTH=%d;\n\nADDRESS_RADIX=UNS;\nDATA_RADIX=DEC;\n\nCONTENT BEGIN\n',width,depth);
for k=1:N
    fprintf(outf,'%d:%d;\n',k-1,round(real(65536*coeff_rs_tx(k))));
end
fprintf(outf,'END;\n');
fclose(outf);

outf = fopen('../src/RAM_FIFO/coeff_RS_tx_UE0_imag.mif','w');
width = 18;
depth = N;
fprintf(outf,'WIDTH=%d;\nDEPTH=%d;\n\nADDRESS_RADIX=UNS;\nDATA_RADIX=DEC;\n\nCONTENT BEGIN\n',width,depth);
for k=1:N
    fprintf(outf,'%d:%d;\n',k-1,round(imag(65536*coeff_rs_tx(k))));
end
fprintf(outf,'END;\n');
fclose(outf);