set_global_assignment -entity "RAM_idct_aftIFFT" -library "lib_RAM_idct_aftIFFT" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "RAM_idct_aftIFFT" -library "lib_RAM_idct_aftIFFT" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "RAM_idct_aftIFFT" -library "lib_RAM_idct_aftIFFT" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_RAM_idct_aftIFFT" -name SPD_FILE [file join $::quartus(sip_path) "RAM_idct_aftIFFT.spd"]
set_global_assignment -library "lib_RAM_idct_aftIFFT" -name MISC_FILE [file join $::quartus(sip_path) "../RAM_idct_aftIFFT.qsys"]

set_global_assignment -library "lib_RAM_idct_aftIFFT" -name MISC_FILE [file join $::quartus(sip_path) "sim/RAM_idct_aftIFFT.v"]
set_global_assignment -library "lib_RAM_idct_aftIFFT" -name MISC_FILE [file join $::quartus(sip_path) "ram_2port_151/sim/RAM_idct_aftIFFT_ram_2port_151_65vwdsi.v"]
