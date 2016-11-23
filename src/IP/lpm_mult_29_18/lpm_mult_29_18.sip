set_global_assignment -entity "lpm_mult_29_18" -library "lib_lpm_mult_29_18" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "lpm_mult_29_18" -library "lib_lpm_mult_29_18" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "lpm_mult_29_18" -library "lib_lpm_mult_29_18" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_lpm_mult_29_18" -name SPD_FILE [file join $::quartus(sip_path) "lpm_mult_29_18.spd"]
set_global_assignment -library "lib_lpm_mult_29_18" -name MISC_FILE [file join $::quartus(sip_path) "../lpm_mult_29_18.qsys"]

set_global_assignment -library "lib_lpm_mult_29_18" -name MISC_FILE [file join $::quartus(sip_path) "sim/lpm_mult_29_18.v"]
set_global_assignment -library "lib_lpm_mult_29_18" -name MISC_FILE [file join $::quartus(sip_path) "lpm_mult_151/sim/lpm_mult_29_18_lpm_mult_151_qp6wzaq.v"]
