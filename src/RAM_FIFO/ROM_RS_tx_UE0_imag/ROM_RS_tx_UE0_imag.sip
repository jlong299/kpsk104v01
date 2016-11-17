set_global_assignment -entity "ROM_RS_tx_UE0_imag" -library "lib_ROM_RS_tx_UE0_imag" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "ROM_RS_tx_UE0_imag" -library "lib_ROM_RS_tx_UE0_imag" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "ROM_RS_tx_UE0_imag" -library "lib_ROM_RS_tx_UE0_imag" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_ROM_RS_tx_UE0_imag" -name SPD_FILE [file join $::quartus(sip_path) "ROM_RS_tx_UE0_imag.spd"]
set_global_assignment -library "lib_ROM_RS_tx_UE0_imag" -name MISC_FILE [file join $::quartus(sip_path) "../ROM_RS_tx_UE0_imag.qsys"]

set_global_assignment -library "lib_ROM_RS_tx_UE0_imag" -name MISC_FILE [file join $::quartus(sip_path) "sim/ROM_RS_tx_UE0_imag.v"]
set_global_assignment -library "lib_ROM_RS_tx_UE0_imag" -name MISC_FILE [file join $::quartus(sip_path) "rom_1port_151/sim/ROM_RS_tx_UE0_imag_rom_1port_151_2ceuyda.v"]
