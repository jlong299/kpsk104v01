# ----------------------------------------
# Auto-generated simulation script msim_setup.tcl
# ----------------------------------------
# This script can be used to simulate the following IP:
#     dct_fft
# To create a top-level simulation script which compiles other
# IP, and manages other system issues, copy the following template
# and adapt it to your needs:
# 
# # Start of template
# If the copied and modified template file is "mentor.do", run it as:
#   vsim -c -do mentor.do
#
# Source the generated sim script
source msim_setup.tcl
# Compile eda/sim_lib contents first
dev_com
# Override the top-level name (so that elab is useful)
set TOP_LEVEL_NAME dct_tb
# Compile the standalone IP.
com
# Compile the user top-level
#------ DCT -----------
vlog -sv ../tb/dct_tb.v
vlog -sv ../src/dct/dct_vecRot_ram.v 
vlog -sv ../src/RAM_FIFO/RAM_dct_vecRot/sim/RAM_dct_vecRot.v
vlog -sv ../src/RAM_FIFO/RAM_dct_vecRot/ram_2port_151/sim/RAM_dct_vecRot_ram_2port_151_byb7zvy.v
vlog -sv ../src/dct/dct_vecRot_twiddle.v 
vlog -sv ../src/dct/dct_vecRot_scaling.v 
vlog -sv ../src/dct/dct_vecRot_coeff.v 
vlog -sv ../src/RAM_FIFO/ROM_cos_dct_vecRot/sim/ROM_cos_dct_vecRot.v
vlog -sv ../src/RAM_FIFO/ROM_cos_dct_vecRot/rom_1port_151/sim/ROM_cos_dct_vecRot_rom_1port_151_6n7d5py.v
vlog -sv ../src/RAM_FIFO/ROM_sin_dct_vecRot/sim/ROM_sin_dct_vecRot.v
vlog -sv ../src/RAM_FIFO/ROM_sin_dct_vecRot/rom_1port_151/sim/ROM_sin_dct_vecRot_rom_1port_151_nni4jta.v
vlog -sv ../src/dct/dct_vecRot.v 
vlog -sv ../src/RAM_FIFO/RAM_dct_preFFT_reod/sim/RAM_dct_preFFT_reod.v
vlog -sv ../src/RAM_FIFO/RAM_dct_preFFT_reod/ram_2port_151/sim/RAM_dct_preFFT_reod_ram_2port_151_nn5gxoa.v
vlog -sv ../src/dct/dct_preFFT_reod.v 
vlog -sv ../src/dct/dct_top.v 
vlog -sv ../src/RAM_FIFO/ROM2_cos_dct_vecRot/sim/ROM2_cos_dct_vecRot.v
vlog -sv ../src/RAM_FIFO/ROM2_cos_dct_vecRot/rom_1port_151/sim/ROM2_cos_dct_vecRot_rom_1port_151_h2jlawq.v
vlog -sv ../src/RAM_FIFO/ROM2_sin_dct_vecRot/sim/ROM2_sin_dct_vecRot.v
vlog -sv ../src/RAM_FIFO/ROM2_sin_dct_vecRot/rom_1port_151/sim/ROM2_sin_dct_vecRot_rom_1port_151_ofi6pdq.v
#-------- IDCT ------------
vlog -sv ../src/idct/idct_top.v 
vlog -sv ../src/idct/idct_vecRot_coeff.v 
vlog -sv ../src/idct/idct_vecRot.v 
vlog -sv ../src/idct/idct_vecRot_twiddle.v 
vlog -sv ../src/idct/idct_vecRot_scaling.v 
vlog -sv ../src/idct/idct_aftIFFt_reod.v 
vlog -sv ../src/RAM_FIFO/ROM_cos_idct_vecRot/sim/ROM_cos_idct_vecRot.v
vlog -sv ../src/RAM_FIFO/ROM_cos_idct_vecRot/rom_1port_151/sim/ROM_cos_idct_vecRot_rom_1port_151_g2udz5i.v
vlog -sv ../src/RAM_FIFO/ROM_sin_idct_vecRot/sim/ROM_sin_idct_vecRot.v
vlog -sv ../src/RAM_FIFO/ROM_sin_idct_vecRot/rom_1port_151/sim/ROM_sin_idct_vecRot_rom_1port_151_hi2hr3i.v
vlog -sv ../src/idct/idct_aftIFFt_scaling.v
vlog -sv ../src/RAM_FIFO/RAM_idct_aftIFFT/sim/RAM_idct_aftIFFT.v 
vlog -sv ../src/RAM_FIFO/RAM_idct_aftIFFT/ram_2port_151/sim/RAM_idct_aftIFFT_ram_2port_151_65vwdsi.v
vlog -sv ../src/RAM_FIFO/ROM2_cos_idct_vecRot/sim/ROM2_cos_idct_vecRot.v
vlog -sv ../src/RAM_FIFO/ROM2_cos_idct_vecRot/rom_1port_151/sim/ROM2_cos_idct_vecRot_rom_1port_151_h3zc72i.v
vlog -sv ../src/RAM_FIFO/ROM2_sin_idct_vecRot/sim/ROM2_sin_idct_vecRot.v
vlog -sv ../src/RAM_FIFO/ROM2_sin_idct_vecRot/rom_1port_151/sim/ROM2_sin_idct_vecRot_rom_1port_151_scljbpy.v
#-------- CE ------------
vlog -sv ../tb/ce_tb.v
vlog -sv ../src/ce/ce_window.v
vlog -sv ../src/ce/ce_LS.v
vlog -sv ../src/ce/ce_LS_scaling.v
vlog -sv ../src/ce/ce_LS_RS_tx.v
vlog -sv ../src/RAM_FIFO/ROM_RS_tx_UE0_real/sim/ROM_RS_tx_UE0_real.v
vlog -sv ../src/RAM_FIFO/ROM_RS_tx_UE0_real/rom_1port_151/sim/ROM_RS_tx_UE0_real_rom_1port_151_gplsvky.v
vlog -sv ../src/RAM_FIFO/ROM_RS_tx_UE0_imag/sim/ROM_RS_tx_UE0_imag.v
vlog -sv ../src/RAM_FIFO/ROM_RS_tx_UE0_imag/rom_1port_151/sim/ROM_RS_tx_UE0_imag_rom_1port_151_2ceuyda.v
vlog -sv ../src/ce/ce_top.v
vlog -sv ../src/dct/dct_preFFT_reod_1200in.v
vlog -sv ../src/IP/lpm_mult_29_18/sim/lpm_mult_29_18.v
vlog -sv ../src/IP/lpm_mult_29_18/lpm_mult_151/sim/lpm_mult_29_18_lpm_mult_151_qp6wzaq.v
vlog -sv ../src/IP/lpm_mult_25_18/sim/lpm_mult_25_18.v
vlog -sv ../src/IP/lpm_mult_25_18/lpm_mult_151/sim/lpm_mult_25_18_lpm_mult_151_lnncfha.v
vlog -sv ../src/IP/lpm_mult_16_18/sim/lpm_mult_16_18.v
vlog -sv ../src/IP/lpm_mult_16_18/lpm_mult_151/sim/lpm_mult_16_18_lpm_mult_151_epm7eay.v

# Elaborate the design.
elab
# Run the simulation

view wave
add wave *
# add wave sim:/ce_tb/ce_top_inst/*
# add wave sim:/ce_tb/ce_top_inst/dct_top_inst/*
# add wave sim:/ce_tb/ce_top_inst/dct_top_inst/dct_vecRot_inst/dct_vecRot_twiddle_inst/*

add wave sim:/dct_tb/dct_top_inst/*
add wave sim:/dct_tb/dct_top_inst/dct_vecRot_inst/dct_vecRot_ram_ping/*


#add wave sim:/dct_tb/idct_top_inst/idct_aftIFFT_reod_ping/*
view structure
view signals
run 3us
# Report success to the shell
# exit -code 0
# End of template
# ----------------------------------------