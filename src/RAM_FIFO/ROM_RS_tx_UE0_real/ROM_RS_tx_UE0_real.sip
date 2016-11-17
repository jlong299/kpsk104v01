set_global_assignment -entity "ROM_RS_tx_UE0_real" -library "lib_ROM_RS_tx_UE0_real" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "ROM_RS_tx_UE0_real" -library "lib_ROM_RS_tx_UE0_real" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "ROM_RS_tx_UE0_real" -library "lib_ROM_RS_tx_UE0_real" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_ROM_RS_tx_UE0_real" -name SPD_FILE [file join $::quartus(sip_path) "ROM_RS_tx_UE0_real.spd"]
set_global_assignment -library "lib_ROM_RS_tx_UE0_real" -name MISC_FILE [file join $::quartus(sip_path) "../ROM_RS_tx_UE0_real.qsys"]

set_global_assignment -library "lib_ROM_RS_tx_UE0_real" -name MISC_FILE [file join $::quartus(sip_path) "sim/ROM_RS_tx_UE0_real.v"]
set_global_assignment -library "lib_ROM_RS_tx_UE0_real" -name MISC_FILE [file join $::quartus(sip_path) "rom_1port_151/sim/ROM_RS_tx_UE0_real_rom_1port_151_gplsvky.v"]
