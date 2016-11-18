close all;
N = 1200;

xr = rsInUsedSubcarrier_rx(:,1);

scal_factor = 2048;
xr_scal = round(xr*scal_factor);
max(abs(real(xr_scal)))
max(abs(imag(xr_scal)))

outf = fopen('../modelsim/CE_src.dat','w');
for k = 1 : length(xr)
    fprintf(outf , '%d %d\n' , real(xr_scal(k)), imag(xr_scal(k)));
end
fclose(outf);