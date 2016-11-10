set_global_assignment -entity "idct_ifft" -library "lib_idct_ifft" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "idct_ifft" -library "lib_idct_ifft" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "idct_ifft" -library "lib_idct_ifft" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_idct_ifft" -name SPD_FILE [file join $::quartus(sip_path) "idct_ifft.spd"]
set_global_assignment -library "lib_idct_ifft" -name MISC_FILE [file join $::quartus(sip_path) "../idct_ifft.qsys"]

set_global_assignment -library "lib_idct_ifft" -name MISC_FILE [file join $::quartus(sip_path) "sim/idct_ifft.v"]
set_global_assignment -library "lib_idct_ifft" -name MISC_FILE [file join $::quartus(sip_path) "altera_fft_ii_151/sim/idct_ifft_altera_fft_ii_151_7z74xyy_opt_twr4.hex"]
set_global_assignment -library "lib_idct_ifft" -name MISC_FILE [file join $::quartus(sip_path) "altera_fft_ii_151/sim/idct_ifft_altera_fft_ii_151_7z74xyy_opt_twi1.hex"]
set_global_assignment -library "lib_idct_ifft" -name MISC_FILE [file join $::quartus(sip_path) "altera_fft_ii_151/sim/idct_ifft_altera_fft_ii_151_7z74xyy_opt_twi5.hex"]
set_global_assignment -library "lib_idct_ifft" -name MISC_FILE [file join $::quartus(sip_path) "altera_fft_ii_151/sim/idct_ifft_altera_fft_ii_151_7z74xyy_opt_twr5.hex"]
set_global_assignment -library "lib_idct_ifft" -name MISC_FILE [file join $::quartus(sip_path) "altera_fft_ii_151/sim/idct_ifft_altera_fft_ii_151_7z74xyy_opt_twr1.hex"]
set_global_assignment -library "lib_idct_ifft" -name MISC_FILE [file join $::quartus(sip_path) "altera_fft_ii_151/sim/idct_ifft_altera_fft_ii_151_7z74xyy_opt_twi2.hex"]
set_global_assignment -library "lib_idct_ifft" -name MISC_FILE [file join $::quartus(sip_path) "altera_fft_ii_151/sim/idct_ifft_altera_fft_ii_151_7z74xyy_opt_twi3.hex"]
set_global_assignment -library "lib_idct_ifft" -name MISC_FILE [file join $::quartus(sip_path) "altera_fft_ii_151/sim/idct_ifft_altera_fft_ii_151_7z74xyy_opt_twr2.hex"]
set_global_assignment -library "lib_idct_ifft" -name MISC_FILE [file join $::quartus(sip_path) "altera_fft_ii_151/sim/idct_ifft_altera_fft_ii_151_7z74xyy_opt_twr3.hex"]
set_global_assignment -library "lib_idct_ifft" -name MISC_FILE [file join $::quartus(sip_path) "altera_fft_ii_151/sim/idct_ifft_altera_fft_ii_151_7z74xyy_opt_twi4.hex"]
set_global_assignment -library "lib_idct_ifft" -name MISC_FILE [file join $::quartus(sip_path) "altera_fft_ii_151/sim/idct_ifft_altera_fft_ii_151_7z74xyy.vo"]
