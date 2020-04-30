# This script segment is generated automatically by AutoPilot

set id 1
set name monte_sim_dev_monte_sim_dev_mul_81ns_6ns_87_5_1
set corename simcore_mul
set op mul
set stage_num 5
set max_latency -1
set registered_input 1
set clk_width 1
set clk_signed 0
set reset_width 1
set reset_signed 0
set in0_width 81
set in0_signed 0
set in1_width 6
set in1_signed 0
set ce_width 1
set ce_signed 0
set out_width 87
if {${::AESL::PGuard_simmodel_gen}} {
if {[info proc ap_gen_simcore_mul] == "ap_gen_simcore_mul"} {
eval "ap_gen_simcore_mul { \
    id ${id} \
    name ${name} \
    corename ${corename} \
    op ${op} \
    reset_level 1 \
    sync_rst true \
    stage_num ${stage_num} \
    max_latency ${max_latency} \
    registered_input ${registered_input} \
    clk_width ${clk_width} \
    clk_signed ${clk_signed} \
    reset_width ${reset_width} \
    reset_signed ${reset_signed} \
    in0_width ${in0_width} \
    in0_signed ${in0_signed} \
    in1_width ${in1_width} \
    in1_signed ${in1_signed} \
    ce_width ${ce_width} \
    ce_signed ${ce_signed} \
    out_width ${out_width} \
}"
} else {
puts "@W \[IMPL-100\] Cannot find ap_gen_simcore_mul, check your AutoPilot builtin lib"
}
}


if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler ${name}
}


set op mul
set corename MulnS
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_multicycle_mul] == "::AESL_LIB_VIRTEX::xil_gen_multicycle_mul"} {
eval "::AESL_LIB_VIRTEX::xil_gen_multicycle_mul { \
    id ${id} \
    name ${name} \
    corename ${corename} \
    op ${op} \
    reset_level 1 \
    sync_rst true \
    stage_num ${stage_num} \
    max_latency ${max_latency} \
    registered_input ${registered_input} \
    clk_width ${clk_width} \
    clk_signed ${clk_signed} \
    reset_width ${reset_width} \
    reset_signed ${reset_signed} \
    in0_width ${in0_width} \
    in0_signed ${in0_signed} \
    in1_width ${in1_width} \
    in1_signed ${in1_signed} \
    ce_width ${ce_width} \
    ce_signed ${ce_signed} \
    out_width ${out_width} \
}"
} else {
puts "@W \[IMPL-101\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_multicycle_mul, check your platform lib"
}
}


set id 2
set name monte_sim_dev_monte_sim_dev_mul_68ns_4ns_72_5_1
set corename simcore_mul
set op mul
set stage_num 5
set max_latency -1
set registered_input 1
set clk_width 1
set clk_signed 0
set reset_width 1
set reset_signed 0
set in0_width 68
set in0_signed 0
set in1_width 4
set in1_signed 0
set ce_width 1
set ce_signed 0
set out_width 72
if {${::AESL::PGuard_simmodel_gen}} {
if {[info proc ap_gen_simcore_mul] == "ap_gen_simcore_mul"} {
eval "ap_gen_simcore_mul { \
    id ${id} \
    name ${name} \
    corename ${corename} \
    op ${op} \
    reset_level 1 \
    sync_rst true \
    stage_num ${stage_num} \
    max_latency ${max_latency} \
    registered_input ${registered_input} \
    clk_width ${clk_width} \
    clk_signed ${clk_signed} \
    reset_width ${reset_width} \
    reset_signed ${reset_signed} \
    in0_width ${in0_width} \
    in0_signed ${in0_signed} \
    in1_width ${in1_width} \
    in1_signed ${in1_signed} \
    ce_width ${ce_width} \
    ce_signed ${ce_signed} \
    out_width ${out_width} \
}"
} else {
puts "@W \[IMPL-100\] Cannot find ap_gen_simcore_mul, check your AutoPilot builtin lib"
}
}


if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler ${name}
}


set op mul
set corename MulnS
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_multicycle_mul] == "::AESL_LIB_VIRTEX::xil_gen_multicycle_mul"} {
eval "::AESL_LIB_VIRTEX::xil_gen_multicycle_mul { \
    id ${id} \
    name ${name} \
    corename ${corename} \
    op ${op} \
    reset_level 1 \
    sync_rst true \
    stage_num ${stage_num} \
    max_latency ${max_latency} \
    registered_input ${registered_input} \
    clk_width ${clk_width} \
    clk_signed ${clk_signed} \
    reset_width ${reset_width} \
    reset_signed ${reset_signed} \
    in0_width ${in0_width} \
    in0_signed ${in0_signed} \
    in1_width ${in1_width} \
    in1_signed ${in1_signed} \
    ce_width ${ce_width} \
    ce_signed ${ce_signed} \
    out_width ${out_width} \
}"
} else {
puts "@W \[IMPL-101\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_multicycle_mul, check your platform lib"
}
}


set id 3
set name monte_sim_dev_monte_sim_dev_mul_60ns_6ns_66_4_1
set corename simcore_mul
set op mul
set stage_num 4
set max_latency -1
set registered_input 1
set clk_width 1
set clk_signed 0
set reset_width 1
set reset_signed 0
set in0_width 60
set in0_signed 0
set in1_width 6
set in1_signed 0
set ce_width 1
set ce_signed 0
set out_width 66
if {${::AESL::PGuard_simmodel_gen}} {
if {[info proc ap_gen_simcore_mul] == "ap_gen_simcore_mul"} {
eval "ap_gen_simcore_mul { \
    id ${id} \
    name ${name} \
    corename ${corename} \
    op ${op} \
    reset_level 1 \
    sync_rst true \
    stage_num ${stage_num} \
    max_latency ${max_latency} \
    registered_input ${registered_input} \
    clk_width ${clk_width} \
    clk_signed ${clk_signed} \
    reset_width ${reset_width} \
    reset_signed ${reset_signed} \
    in0_width ${in0_width} \
    in0_signed ${in0_signed} \
    in1_width ${in1_width} \
    in1_signed ${in1_signed} \
    ce_width ${ce_width} \
    ce_signed ${ce_signed} \
    out_width ${out_width} \
}"
} else {
puts "@W \[IMPL-100\] Cannot find ap_gen_simcore_mul, check your AutoPilot builtin lib"
}
}


if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler ${name}
}


set op mul
set corename Mul4S
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_multicycle_mul] == "::AESL_LIB_VIRTEX::xil_gen_multicycle_mul"} {
eval "::AESL_LIB_VIRTEX::xil_gen_multicycle_mul { \
    id ${id} \
    name ${name} \
    corename ${corename} \
    op ${op} \
    reset_level 1 \
    sync_rst true \
    stage_num ${stage_num} \
    max_latency ${max_latency} \
    registered_input ${registered_input} \
    clk_width ${clk_width} \
    clk_signed ${clk_signed} \
    reset_width ${reset_width} \
    reset_signed ${reset_signed} \
    in0_width ${in0_width} \
    in0_signed ${in0_signed} \
    in1_width ${in1_width} \
    in1_signed ${in1_signed} \
    ce_width ${ce_width} \
    ce_signed ${ce_signed} \
    out_width ${out_width} \
}"
} else {
puts "@W \[IMPL-101\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_multicycle_mul, check your platform lib"
}
}


set id 4
set name monte_sim_dev_monte_sim_dev_mul_55ns_6ns_61_4_1
set corename simcore_mul
set op mul
set stage_num 4
set max_latency -1
set registered_input 1
set clk_width 1
set clk_signed 0
set reset_width 1
set reset_signed 0
set in0_width 55
set in0_signed 0
set in1_width 6
set in1_signed 0
set ce_width 1
set ce_signed 0
set out_width 61
if {${::AESL::PGuard_simmodel_gen}} {
if {[info proc ap_gen_simcore_mul] == "ap_gen_simcore_mul"} {
eval "ap_gen_simcore_mul { \
    id ${id} \
    name ${name} \
    corename ${corename} \
    op ${op} \
    reset_level 1 \
    sync_rst true \
    stage_num ${stage_num} \
    max_latency ${max_latency} \
    registered_input ${registered_input} \
    clk_width ${clk_width} \
    clk_signed ${clk_signed} \
    reset_width ${reset_width} \
    reset_signed ${reset_signed} \
    in0_width ${in0_width} \
    in0_signed ${in0_signed} \
    in1_width ${in1_width} \
    in1_signed ${in1_signed} \
    ce_width ${ce_width} \
    ce_signed ${ce_signed} \
    out_width ${out_width} \
}"
} else {
puts "@W \[IMPL-100\] Cannot find ap_gen_simcore_mul, check your AutoPilot builtin lib"
}
}


if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler ${name}
}


set op mul
set corename Mul4S
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_multicycle_mul] == "::AESL_LIB_VIRTEX::xil_gen_multicycle_mul"} {
eval "::AESL_LIB_VIRTEX::xil_gen_multicycle_mul { \
    id ${id} \
    name ${name} \
    corename ${corename} \
    op ${op} \
    reset_level 1 \
    sync_rst true \
    stage_num ${stage_num} \
    max_latency ${max_latency} \
    registered_input ${registered_input} \
    clk_width ${clk_width} \
    clk_signed ${clk_signed} \
    reset_width ${reset_width} \
    reset_signed ${reset_signed} \
    in0_width ${in0_width} \
    in0_signed ${in0_signed} \
    in1_width ${in1_width} \
    in1_signed ${in1_signed} \
    ce_width ${ce_width} \
    ce_signed ${ce_signed} \
    out_width ${out_width} \
}"
} else {
puts "@W \[IMPL-101\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_multicycle_mul, check your platform lib"
}
}


set id 5
set name monte_sim_dev_monte_sim_dev_mul_50ns_6ns_56_4_1
set corename simcore_mul
set op mul
set stage_num 4
set max_latency -1
set registered_input 1
set clk_width 1
set clk_signed 0
set reset_width 1
set reset_signed 0
set in0_width 50
set in0_signed 0
set in1_width 6
set in1_signed 0
set ce_width 1
set ce_signed 0
set out_width 56
if {${::AESL::PGuard_simmodel_gen}} {
if {[info proc ap_gen_simcore_mul] == "ap_gen_simcore_mul"} {
eval "ap_gen_simcore_mul { \
    id ${id} \
    name ${name} \
    corename ${corename} \
    op ${op} \
    reset_level 1 \
    sync_rst true \
    stage_num ${stage_num} \
    max_latency ${max_latency} \
    registered_input ${registered_input} \
    clk_width ${clk_width} \
    clk_signed ${clk_signed} \
    reset_width ${reset_width} \
    reset_signed ${reset_signed} \
    in0_width ${in0_width} \
    in0_signed ${in0_signed} \
    in1_width ${in1_width} \
    in1_signed ${in1_signed} \
    ce_width ${ce_width} \
    ce_signed ${ce_signed} \
    out_width ${out_width} \
}"
} else {
puts "@W \[IMPL-100\] Cannot find ap_gen_simcore_mul, check your AutoPilot builtin lib"
}
}


if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler ${name}
}


set op mul
set corename Mul4S
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_multicycle_mul] == "::AESL_LIB_VIRTEX::xil_gen_multicycle_mul"} {
eval "::AESL_LIB_VIRTEX::xil_gen_multicycle_mul { \
    id ${id} \
    name ${name} \
    corename ${corename} \
    op ${op} \
    reset_level 1 \
    sync_rst true \
    stage_num ${stage_num} \
    max_latency ${max_latency} \
    registered_input ${registered_input} \
    clk_width ${clk_width} \
    clk_signed ${clk_signed} \
    reset_width ${reset_width} \
    reset_signed ${reset_signed} \
    in0_width ${in0_width} \
    in0_signed ${in0_signed} \
    in1_width ${in1_width} \
    in1_signed ${in1_signed} \
    ce_width ${ce_width} \
    ce_signed ${ce_signed} \
    out_width ${out_width} \
}"
} else {
puts "@W \[IMPL-101\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_multicycle_mul, check your platform lib"
}
}


set id 6
set name monte_sim_dev_monte_sim_dev_mul_7s_68ns_73_5_1
set corename simcore_mul
set op mul
set stage_num 5
set max_latency -1
set registered_input 1
set clk_width 1
set clk_signed 0
set reset_width 1
set reset_signed 0
set in0_width 7
set in0_signed 1
set in1_width 68
set in1_signed 0
set ce_width 1
set ce_signed 0
set out_width 73
if {${::AESL::PGuard_simmodel_gen}} {
if {[info proc ap_gen_simcore_mul] == "ap_gen_simcore_mul"} {
eval "ap_gen_simcore_mul { \
    id ${id} \
    name ${name} \
    corename ${corename} \
    op ${op} \
    reset_level 1 \
    sync_rst true \
    stage_num ${stage_num} \
    max_latency ${max_latency} \
    registered_input ${registered_input} \
    clk_width ${clk_width} \
    clk_signed ${clk_signed} \
    reset_width ${reset_width} \
    reset_signed ${reset_signed} \
    in0_width ${in0_width} \
    in0_signed ${in0_signed} \
    in1_width ${in1_width} \
    in1_signed ${in1_signed} \
    ce_width ${ce_width} \
    ce_signed ${ce_signed} \
    out_width ${out_width} \
}"
} else {
puts "@W \[IMPL-100\] Cannot find ap_gen_simcore_mul, check your AutoPilot builtin lib"
}
}


if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler ${name}
}


set op mul
set corename MulnS
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_multicycle_mul] == "::AESL_LIB_VIRTEX::xil_gen_multicycle_mul"} {
eval "::AESL_LIB_VIRTEX::xil_gen_multicycle_mul { \
    id ${id} \
    name ${name} \
    corename ${corename} \
    op ${op} \
    reset_level 1 \
    sync_rst true \
    stage_num ${stage_num} \
    max_latency ${max_latency} \
    registered_input ${registered_input} \
    clk_width ${clk_width} \
    clk_signed ${clk_signed} \
    reset_width ${reset_width} \
    reset_signed ${reset_signed} \
    in0_width ${in0_width} \
    in0_signed ${in0_signed} \
    in1_width ${in1_width} \
    in1_signed ${in1_signed} \
    ce_width ${ce_width} \
    ce_signed ${ce_signed} \
    out_width ${out_width} \
}"
} else {
puts "@W \[IMPL-101\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_multicycle_mul, check your platform lib"
}
}


# Memory (RAM/ROM)  definition:
set ID 13
set hasByteEnable 0
set MemName monte_sim_dev_log_67_17_s_log_apfixed_reduce_log_inverse_lut_table_array_V
set CoreName ap_simcore_mem
set PortList { 1 }
set DataWd 6
set AddrRange 64
set AddrWd 6
set TrueReset 0
set IsROM 1
set ROMData { "100000" "100000" "100000" "011111" "011111" "011110" "011110" "011101" "011101" "011101" "011100" "011100" "011011" "011011" "011011" "011010" "011010" "011010" "011001" "011001" "011001" "011001" "011000" "011000" "011000" "011000" "010111" "010111" "010111" "010111" "010110" "010110" "101011" "101011" "101010" "101010" "101001" "101001" "101001" "101000" "101000" "101000" "100111" "100111" "100110" "100110" "100110" "100101" "100101" "100101" "100100" "100100" "100100" "100100" "100011" "100011" "100011" "100010" "100010" "100010" "100010" "100001" "100001" "100001" }
set HasInitializer 1
set Initializer $ROMData
set NumOfStage 2
set MaxLatency -1
set DelayBudget 1.158
set ClkPeriod 4
set RegisteredInput 0
if {${::AESL::PGuard_simmodel_gen}} {
if {[info proc ap_gen_simcore_mem] == "ap_gen_simcore_mem"} {
    eval "ap_gen_simcore_mem { \
    id ${ID} \
    name ${MemName} \
    corename ${CoreName}  \
    op mem \
    hasByteEnable ${hasByteEnable} \
    reset_level 1 \
    sync_rst true \
    stage_num ${NumOfStage}  \
    registered_input ${RegisteredInput} \
    port_num 1 \
    port_list \{${PortList}\} \
    data_wd ${DataWd} \
    addr_wd ${AddrWd} \
    addr_range ${AddrRange} \
    true_reset ${TrueReset} \
    delay_budget ${DelayBudget} \
    clk_period ${ClkPeriod} \
    HasInitializer ${HasInitializer} \
    rom_data \{${ROMData}\} \
 } "
} else {
    puts "@W \[IMPL-102\] Cannot find ap_gen_simcore_mem, check your platform lib"
}
}


if {${::AESL::PGuard_rtl_comp_handler}} {
  ::AP::rtl_comp_handler $MemName
}


set CoreName ROM_nP
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_ROM] == "::AESL_LIB_VIRTEX::xil_gen_ROM"} {
    eval "::AESL_LIB_VIRTEX::xil_gen_ROM { \
    id ${ID} \
    name ${MemName} \
    corename ${CoreName}  \
    op mem \
    hasByteEnable ${hasByteEnable} \
    reset_level 1 \
    sync_rst true \
    stage_num ${NumOfStage}  \
    registered_input ${RegisteredInput} \
    port_num 1 \
    port_list \{${PortList}\} \
    data_wd ${DataWd} \
    addr_wd ${AddrWd} \
    addr_range ${AddrRange} \
    true_reset ${TrueReset} \
    delay_budget ${DelayBudget} \
    clk_period ${ClkPeriod} \
    HasInitializer ${HasInitializer} \
    rom_data \{${ROMData}\} \
 } "
  } else {
    puts "@W \[IMPL-104\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_ROM, check your platform lib"
  }
}


# Memory (RAM/ROM)  definition:
set ID 14
set hasByteEnable 0
set MemName monte_sim_dev_log_67_17_s_log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V
set CoreName ap_simcore_mem
set PortList { 1 }
set DataWd 67
set AddrRange 64
set AddrWd 6
set TrueReset 0
set IsROM 1
set ROMData { "1111111101111100000111101111110100011001001111101110011101010000110" "1111111101111100000111101111110100011001001111101110011101010000110" "1111111101111100000111101111110100011001001111101110011101010000110" "0000011110011100110011011100001000001100111000010000100110001000110" "0000011110011100110011011100001000001100111000010000100110001000110" "0001000000000001101101111011001010110111011110001110110111011001011" "0001000000000001101101111011001010110111011110001110110111011001011" "0001100010101111011111010101101001110010100010000110111111111110111" "0001100010101111011111010101101001110010100010000110111111111110111" "0001100010101111011111010101101001110010100010000110111111111110111" "0010000110101011001111000000000101101001000001111101111100001101001" "0010000110101011001111000000000101101001000001111101111100001101001" "0010101011111010100111111101001111000001101110100100101101000111110" "0010101011111010100111111101001111000001101110100100101101000111110" "0010101011111010100111111101001111000001101110100100101101000111110" "0011010010100011111110010111011000101110111100101010111000101111001" "0011010010100011111110010111011000101110111100101010111000101111001" "0011010010100011111110010111011000101110111100101010111000101111001" "0011111010101110010101111101011010000000101001011101101001001100000" "0011111010101110010101111101011010000000101001011101101001001100000" "0011111010101110010101111101011010000000101001011101101001001100000" "0011111010101110010101111101011010000000101001011101101001001100000" "0100100100100001101001110100000111101100101011010011000100110001101" "0100100100100001101001110100000111101100101011010011000100110001101" "0100100100100001101001110100000111101100101011010011000100110001101" "0100100100100001101001110100000111101100101011010011000100110001101" "0101010000000110110101110001100111111011110011100100011010001001000" "0101010000000110110101110001100111111011110011100100011010001001000" "0101010000000110110101110001100111111011110011100100011010001001000" "0101010000000110110101110001100111111011110011100100011010001001000" "0101111101101000000001111110110001111001100100110101011100001000011" "0101111101101000000001111110110001111001100100110101011100001000011" "1011001111011000100101000001000110010100110010100010010011100000000" "1011001111011000100101000001000110010100110010100010010011100000000" "1011100111011110101011000100111001101010101001101010111101000010010" "1011100111011110101011000100111001101010101001101010111101000010010" "1100000000001001111011100010001001011100110000101001001000110110001" "1100000000001001111011100010001001011100110000101001001000110110001" "1100000000001001111011100010001001011100110000101001001000110110001" "1100011001011100001011110110110111100100000010101010001111111000100" "1100011001011100001011110110110111100100000010101010001111111000100" "1100011001011100001011110110110111100100000010101010001111111000100" "1100110011010111011010011100001100110000100100010111111001100100010" "1100110011010111011010011100001100110000100100010111111001100100010" "1101001101111101101111100001101111001010000101110011111110111111111" "1101001101111101101111100001101111001010000101110011111110111111111" "1101001101111101101111100001101111001010000101110011111110111111111" "1101101001010001011110010000110011011001010101001010000010111000110" "1101101001010001011110010000110011011001010101001010000010111000110" "1101101001010001011110010000110011011001010101001010000010111000110" "1110000101010101000101111000111011101110010011000000000101100110111" "1110000101010101000101111000111011101110010011000000000101100110111" "1110000101010101000101111000111011101110010011000000000101100110111" "1110000101010101000101111000111011101110010011000000000101100110111" "1110100010001011010011000111001000110011110100111001101110110100111" "1110100010001011010011000111001000110011110100111001101110110100111" "1110100010001011010011000111001000110011110100111001101110110100111" "1110111111110111000001101001110100010000100011011001010000100000000" "1110111111110111000001101001110100010000100011011001010000100000000" "1110111111110111000001101001110100010000100011011001010000100000000" "1110111111110111000001101001110100010000100011011001010000100000000" "1111011110011011011110000011100101111011001100100010011100111101100" "1111011110011011011110000011100101111011001100100010011100111101100" "1111011110011011011110000011100101111011001100100010011100111101100" }
set HasInitializer 1
set Initializer $ROMData
set NumOfStage 2
set MaxLatency -1
set DelayBudget 1.158
set ClkPeriod 4
set RegisteredInput 0
if {${::AESL::PGuard_simmodel_gen}} {
if {[info proc ap_gen_simcore_mem] == "ap_gen_simcore_mem"} {
    eval "ap_gen_simcore_mem { \
    id ${ID} \
    name ${MemName} \
    corename ${CoreName}  \
    op mem \
    hasByteEnable ${hasByteEnable} \
    reset_level 1 \
    sync_rst true \
    stage_num ${NumOfStage}  \
    registered_input ${RegisteredInput} \
    port_num 1 \
    port_list \{${PortList}\} \
    data_wd ${DataWd} \
    addr_wd ${AddrWd} \
    addr_range ${AddrRange} \
    true_reset ${TrueReset} \
    delay_budget ${DelayBudget} \
    clk_period ${ClkPeriod} \
    HasInitializer ${HasInitializer} \
    rom_data \{${ROMData}\} \
 } "
} else {
    puts "@W \[IMPL-102\] Cannot find ap_gen_simcore_mem, check your platform lib"
}
}


if {${::AESL::PGuard_rtl_comp_handler}} {
  ::AP::rtl_comp_handler $MemName
}


set CoreName ROM_nP
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_ROM] == "::AESL_LIB_VIRTEX::xil_gen_ROM"} {
    eval "::AESL_LIB_VIRTEX::xil_gen_ROM { \
    id ${ID} \
    name ${MemName} \
    corename ${CoreName}  \
    op mem \
    hasByteEnable ${hasByteEnable} \
    reset_level 1 \
    sync_rst true \
    stage_num ${NumOfStage}  \
    registered_input ${RegisteredInput} \
    port_num 1 \
    port_list \{${PortList}\} \
    data_wd ${DataWd} \
    addr_wd ${AddrWd} \
    addr_range ${AddrRange} \
    true_reset ${TrueReset} \
    delay_budget ${DelayBudget} \
    clk_period ${ClkPeriod} \
    HasInitializer ${HasInitializer} \
    rom_data \{${ROMData}\} \
 } "
  } else {
    puts "@W \[IMPL-104\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_ROM, check your platform lib"
  }
}


# Memory (RAM/ROM)  definition:
set ID 15
set hasByteEnable 0
set MemName monte_sim_dev_log_67_17_s_log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V
set CoreName ap_simcore_mem
set PortList { 1 }
set DataWd 63
set AddrRange 16
set AddrWd 4
set TrueReset 0
set IsROM 1
set ROMData { "000000000000000000000000000000000000000000000000000000000000000" "000100000000000000000001010101010101010110001000100010001001000" "001000000001000000010010101111101100001100101111100011011010110" "001100000011000001010100100111010011101100101010000110001011101" "010000000110000011100111101100111111100110000010010001100101111" "010100001010000111101101001010100001001101111100110110001011011" "011000001111001110000110100011000000111011110011100100011000010" "011100010101010111010101110011011000000111010101001101100001100" "011110011000110101001100010110101011110101101111111111111101000" "100010100000100011101100111110011010010011100110010111010001111" "100110101001010110011010001001101101001110000110001011100111010" "101010110011001101110111010010111101100111100011100001100000001" "101110111110001010101000010000010001000010011110111110111010011" "110011001010001101010001010011110110100001011110010100110100011" "110111010111010110010111001100100100001101001100000110100110111" "111011100101100110011111000110010101100001011010100101011101010" }
set HasInitializer 1
set Initializer $ROMData
set NumOfStage 2
set MaxLatency -1
set DelayBudget 1.158
set ClkPeriod 4
set RegisteredInput 0
if {${::AESL::PGuard_simmodel_gen}} {
if {[info proc ap_gen_simcore_mem] == "ap_gen_simcore_mem"} {
    eval "ap_gen_simcore_mem { \
    id ${ID} \
    name ${MemName} \
    corename ${CoreName}  \
    op mem \
    hasByteEnable ${hasByteEnable} \
    reset_level 1 \
    sync_rst true \
    stage_num ${NumOfStage}  \
    registered_input ${RegisteredInput} \
    port_num 1 \
    port_list \{${PortList}\} \
    data_wd ${DataWd} \
    addr_wd ${AddrWd} \
    addr_range ${AddrRange} \
    true_reset ${TrueReset} \
    delay_budget ${DelayBudget} \
    clk_period ${ClkPeriod} \
    HasInitializer ${HasInitializer} \
    rom_data \{${ROMData}\} \
 } "
} else {
    puts "@W \[IMPL-102\] Cannot find ap_gen_simcore_mem, check your platform lib"
}
}


if {${::AESL::PGuard_rtl_comp_handler}} {
  ::AP::rtl_comp_handler $MemName
}


set CoreName ROM_nP
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_ROM] == "::AESL_LIB_VIRTEX::xil_gen_ROM"} {
    eval "::AESL_LIB_VIRTEX::xil_gen_ROM { \
    id ${ID} \
    name ${MemName} \
    corename ${CoreName}  \
    op mem \
    hasByteEnable ${hasByteEnable} \
    reset_level 1 \
    sync_rst true \
    stage_num ${NumOfStage}  \
    registered_input ${RegisteredInput} \
    port_num 1 \
    port_list \{${PortList}\} \
    data_wd ${DataWd} \
    addr_wd ${AddrWd} \
    addr_range ${AddrRange} \
    true_reset ${TrueReset} \
    delay_budget ${DelayBudget} \
    clk_period ${ClkPeriod} \
    HasInitializer ${HasInitializer} \
    rom_data \{${ROMData}\} \
 } "
  } else {
    puts "@W \[IMPL-104\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_ROM, check your platform lib"
  }
}


# Memory (RAM/ROM)  definition:
set ID 16
set hasByteEnable 0
set MemName monte_sim_dev_log_67_17_s_log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V
set CoreName ap_simcore_mem
set PortList { 1 }
set DataWd 60
set AddrRange 64
set AddrWd 6
set TrueReset 0
set IsROM 1
set ROMData { "000000000000000000000000000000000000000000000000000000000000" "000001000000000000000000000000000001010101010101010101010101" "000010000000000000100000000000010010101010110100101010110000" "000011000000000001100000000001010100000001001110000001001110" "000100000000000011000000000011100101011010000001011011111001" "000101000000000101000000000111100110110111011111000001101111" "000110000000000111100000001101111000011100100110111110111100" "000111000000001010100000010110111010001101001001100110011101" "001000000000001110000000100011001100001101100111010011100001" "001001000000010010000000110011001110100011010000101011000111" "001010000000010110100001000111100001010100000110011101011111" "001011000000011011100001100000100100100110111001100111101110" "001100000000100001000001111110111000100011001011010101001001" "001101000000100111000010100010111101010001001101000000111000" "001110000000101101100011001101010010111010000000010111011010" "001111000000110100100011111110011001100111010111011000000000" "010000000000111100000100110110110001100011110100010110010000" "010001000001000100000101110110111010111010101001111011101000" "010010000001001100100110111111010101110111111011001000111100" "010011000001010101101000010000100010101000011011010111111001" "010100000001011111001001101011000001011001101110011100100011" "010101000001101001001011001111010010011010001000100110111010" "010110000001110011101100111101110101111000101110100100011000" "010111000001111110101110110111001100000101010101100001010101" "011000000010001010010000111011110101010000100011001010100101" "011001000010010110010011001100010001101011101101101110111011" "011010000010100010110101101001000001101000111100000000101100" "011011000010101111111000010010100101011011000101010111001101" "011100000010111101011011001001011101010101110001110000010110" "011101000011001011011110001110001001101101011001110010000100" "011110000011011010000001100001001010110111000110101011111100" "011111000011101001000101000011000001001000110010011000101010" "100000000011111000101000110100001100111001000111011111100001" "100001000100001000101100110101001110011111100001010110000100" "100010000100011001010001000110100110010100001100000001100001" "100011000100101010010101101000110100110000000100011000010100" "100100000100111011111010011100011010001100111000000011101101" "100101000101001101111111100001110111000101000101100001001100" "100110000101100000100100111001101011110011111100000100001001" "100111000101110011101010100100011000110101011011110111010010" "101000000110000111010000100010011110100110010101111110001111" "101001000110011011010110110100011101100100001100010111000100" "101010000110101111111101011010110110001101010001111011110011" "101011000111000101000100010110001001000000101010100011111110" "101100000111011010101011100110110110011110001011000110001010" "101101000111110000110011001101011111000110011001011001100011" "101110001000000111011011001010100011011010101100010111011011" "101111001000011110100011011110100011111101001011111100110000" "110000001000110110001100001010000001010000110001001011101101" "110001001001001110010101001101011011111001000110001101001101" "110010001001100110111110101001010100011010100110010010011110" "110011001010000000001000011110001011011010011101110110100100" "110100001010011001110010101100100001011110101010011111111010" "110101001010110011111101010100110111001101111011000001111010" "110110001011001110101000010111101101001111101111011110011001" "110111001011101001110011110101100100001100011001000111010001" "111000001100000101011111101110111100101100111010011111111110" "111001001100100001101100000100010111011011000111011111000110" "111010001100111110011000110110010101000001100101001111111011" "111011001101011011100110000101010110001011101010010011111101" "111100001101111001010011110001111011100101011110100100011101" "111101001110010111100001111100100101111011111011010100000100" "111110001110110110010000100101110101111100101011010000010100" "111111001111010101011111101110001100010110001010100011001001" }
set HasInitializer 1
set Initializer $ROMData
set NumOfStage 2
set MaxLatency -1
set DelayBudget 1.158
set ClkPeriod 4
set RegisteredInput 0
if {${::AESL::PGuard_simmodel_gen}} {
if {[info proc ap_gen_simcore_mem] == "ap_gen_simcore_mem"} {
    eval "ap_gen_simcore_mem { \
    id ${ID} \
    name ${MemName} \
    corename ${CoreName}  \
    op mem \
    hasByteEnable ${hasByteEnable} \
    reset_level 1 \
    sync_rst true \
    stage_num ${NumOfStage}  \
    registered_input ${RegisteredInput} \
    port_num 1 \
    port_list \{${PortList}\} \
    data_wd ${DataWd} \
    addr_wd ${AddrWd} \
    addr_range ${AddrRange} \
    true_reset ${TrueReset} \
    delay_budget ${DelayBudget} \
    clk_period ${ClkPeriod} \
    HasInitializer ${HasInitializer} \
    rom_data \{${ROMData}\} \
 } "
} else {
    puts "@W \[IMPL-102\] Cannot find ap_gen_simcore_mem, check your platform lib"
}
}


if {${::AESL::PGuard_rtl_comp_handler}} {
  ::AP::rtl_comp_handler $MemName
}


set CoreName ROM_nP
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_ROM] == "::AESL_LIB_VIRTEX::xil_gen_ROM"} {
    eval "::AESL_LIB_VIRTEX::xil_gen_ROM { \
    id ${ID} \
    name ${MemName} \
    corename ${CoreName}  \
    op mem \
    hasByteEnable ${hasByteEnable} \
    reset_level 1 \
    sync_rst true \
    stage_num ${NumOfStage}  \
    registered_input ${RegisteredInput} \
    port_num 1 \
    port_list \{${PortList}\} \
    data_wd ${DataWd} \
    addr_wd ${AddrWd} \
    addr_range ${AddrRange} \
    true_reset ${TrueReset} \
    delay_budget ${DelayBudget} \
    clk_period ${ClkPeriod} \
    HasInitializer ${HasInitializer} \
    rom_data \{${ROMData}\} \
 } "
  } else {
    puts "@W \[IMPL-104\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_ROM, check your platform lib"
  }
}


# Memory (RAM/ROM)  definition:
set ID 17
set hasByteEnable 0
set MemName monte_sim_dev_log_67_17_s_log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V
set CoreName ap_simcore_mem
set PortList { 1 }
set DataWd 55
set AddrRange 64
set AddrWd 6
set TrueReset 0
set IsROM 1
set ROMData { "0000000000000000000000000000000000000000000000000000000" "0000010000000000000000000111110000000000000101000101100" "0000100000000000000000011111100000000000101001101011001" "0000110000000000000001000111010000000010001101110000110" "0001000000000000000001111111000000000101010001010110100" "0001010000000000000011000110110000001010010100011100100" "0001100000000000000100011110100000010001110111000010110" "0001110000000000000110000110010000011100011001001001011" "0010000000000000000111111110000000101010011010110000101" "0010010000000000001010000101110000111100011011111000100" "0010100000000000001100011101100001010010111100100001100" "0010110000000000001111000101010001101110011100101011101" "0011000000000000010001111101000010001111011100010111001" "0011010000000000010101000100110010110110011011100100010" "0011100000000000011000011100100011100011111010010011100" "0011110000000000011100000100010100011000011000100100111" "0100000000000000011111111100000101010100010110011001000" "0100010000000000100100000011110110011000010011110000001" "0100100000000000101000011011100111100100110000101010101" "0100110000000000101101000011011000111010001101001000111" "0101000000000000110001111011001010011001001001001011011" "0101010000000000110111000010111100000010000100110010100" "0101100000000000111100011010101101110101011111111110111" "0101110000000001000010000010011111110011111010110000111" "0110000000000001000111111010010001111101110101001001001" "0110010000000001001110000010000100010011101111001000001" "0110100000000001010100011001110110110110001000101110011" "0110110000000001011011000001101001100101100001111100100" "0111000000000001100001111001011100100010011010110011010" "0111010000000001101001000001001111101101010011010011001" "0111100000000001110000011001000011000110101011011100111" "0111110000000001111000000000110110101111000011010001001" "1000000000000001111111111000101010100110111010110000110" "1000010000000010001000000000011110101110110001111100010" "1000100000000010010000011000010011000111001000110100100" "1000110000000010011001000000000111110000011111011010011" "1001000000000010100001110111111100101011010101101110100" "1001010000000010101010111111110001111000001011110001111" "1001100000000010110100010111100111010111100001100101010" "1001110000000010111101111111011101001001110111001001100" "1010000000000011000111110111010011001111101100011111101" "1010010000000011010001111111001001101001100001101000100" "1010100000000011011100010111000000010111110110100101001" "1010110000000011100110111110110111011011001011010110010" "1011000000000011110001110110101110110011111111111101001" "1011010000000011111100111110100110100010110100011010110" "1011100000000100001000010110011110101000001000110000000" "1011110000000100010011111110010111000100011100111110000" "1100000000000100011111110110001111111000010001000110000" "1100010000000100101011111110001001000100000101001000111" "1100100000000100111000010110000010101000011001000111111" "1100110000000101000100111101111100100101101101000100010" "1101000000000101010001110101110110111100100000111111001" "1101010000000101011110111101110001101101010100111001101" "1101100000000101101100010101101100111000101000110101000" "1101110000000101111001111101101000011110111100110010100" "1110000000000110000111110101100100100000110000110011100" "1110010000000110010101111101100000111110100100111001010" "1110100000000110100100010101011101111000111001000101001" "1110110000000110110010111101011011010000001101011000010" "1111000000000111000001110101011001000101000001110100011" "1111010000000111010000111101010111010111110110011010100" "1111100000000111100000010101010110001001001011001100010" "1111110000000111101111111101010101011001100000001011001" }
set HasInitializer 1
set Initializer $ROMData
set NumOfStage 2
set MaxLatency -1
set DelayBudget 1.158
set ClkPeriod 4
set RegisteredInput 0
if {${::AESL::PGuard_simmodel_gen}} {
if {[info proc ap_gen_simcore_mem] == "ap_gen_simcore_mem"} {
    eval "ap_gen_simcore_mem { \
    id ${ID} \
    name ${MemName} \
    corename ${CoreName}  \
    op mem \
    hasByteEnable ${hasByteEnable} \
    reset_level 1 \
    sync_rst true \
    stage_num ${NumOfStage}  \
    registered_input ${RegisteredInput} \
    port_num 1 \
    port_list \{${PortList}\} \
    data_wd ${DataWd} \
    addr_wd ${AddrWd} \
    addr_range ${AddrRange} \
    true_reset ${TrueReset} \
    delay_budget ${DelayBudget} \
    clk_period ${ClkPeriod} \
    HasInitializer ${HasInitializer} \
    rom_data \{${ROMData}\} \
 } "
} else {
    puts "@W \[IMPL-102\] Cannot find ap_gen_simcore_mem, check your platform lib"
}
}


if {${::AESL::PGuard_rtl_comp_handler}} {
  ::AP::rtl_comp_handler $MemName
}


set CoreName ROM_nP
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_ROM] == "::AESL_LIB_VIRTEX::xil_gen_ROM"} {
    eval "::AESL_LIB_VIRTEX::xil_gen_ROM { \
    id ${ID} \
    name ${MemName} \
    corename ${CoreName}  \
    op mem \
    hasByteEnable ${hasByteEnable} \
    reset_level 1 \
    sync_rst true \
    stage_num ${NumOfStage}  \
    registered_input ${RegisteredInput} \
    port_num 1 \
    port_list \{${PortList}\} \
    data_wd ${DataWd} \
    addr_wd ${AddrWd} \
    addr_range ${AddrRange} \
    true_reset ${TrueReset} \
    delay_budget ${DelayBudget} \
    clk_period ${ClkPeriod} \
    HasInitializer ${HasInitializer} \
    rom_data \{${ROMData}\} \
 } "
  } else {
    puts "@W \[IMPL-104\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_ROM, check your platform lib"
  }
}


# Memory (RAM/ROM)  definition:
set ID 18
set hasByteEnable 0
set MemName monte_sim_dev_log_67_17_s_log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V
set CoreName ap_simcore_mem
set PortList { 1 }
set DataWd 50
set AddrRange 64
set AddrWd 6
set TrueReset 0
set IsROM 1
set ROMData { "00000000000000000000000000000000000000000000000000" "00000100000000000000000000000011111111110000000000" "00001000000000000000000000001111111111100000000000" "00001100000000000000000000100011111111010000000010" "00010000000000000000000000111111111111000000000101" "00010100000000000000000001100011111110110000001010" "00011000000000000000000010001111111110100000010001" "00011100000000000000000011000011111110010000011100" "00100000000000000000000011111111111110000000101010" "00100100000000000000000101000011111101110000111100" "00101000000000000000000110001111111101100001010011" "00101100000000000000000111100011111101010001101110" "00110000000000000000001000111111111101000010001111" "00110100000000000000001010100011111100110010110111" "00111000000000000000001100001111111100100011100100" "00111100000000000000001110000011111100010100011001" "01000000000000000000001111111111111100000101010101" "01000100000000000000010010000011111011110110011001" "01001000000000000000010100001111111011100111100101" "01001100000000000000010110100011111011011000111011" "01010000000000000000011000111111111011001010011010" "01010100000000000000011011100011111010111100000011" "01011000000000000000011110001111111010101101110111" "01011100000000000000100001000011111010011111110101" "01100000000000000000100011111111111010010001111111" "01100100000000000000100111000011111010000100010110" "01101000000000000000101010001111111001110110111000" "01101100000000000000101101100011111001101001101000" "01110000000000000000110000111111111001011100100101" "01110100000000000000110100100011111001001111110000" "01111000000000000000111000001111111001000011001001" "01111100000000000000111100000011111000110110110010" "10000000000000000000111111111111111000101010101010" "10000100000000000001000100000011111000011110110010" "10001000000000000001001000001111111000010011001011" "10001100000000000001001100100011111000000111110100" "10010000000000000001010000111111110111111100101111" "10010100000000000001010101100011110111110001111100" "10011000000000000001011010001111110111100111011100" "10011100000000000001011111000011110111011101001111" "10100000000000000001100011111111110111010011010101" "10100100000000000001101001000011110111001001101111" "10101000000000000001101110001111110111000000011101" "10101100000000000001110011100011110110110111100001" "10110000000000000001111000111111110110101110111010" "10110100000000000001111110100011110110100110101001" "10111000000000000010000100001111110110011110101111" "10111100000000000010001010000011110110010111001011" "11000000000000000010001111111111110110001111111111" "11000100000000000010010110000011110110001001001011" "11001000000000000010011100001111110110000010110000" "11001100000000000010100010100011110101111100101101" "11010000000000000010101000111111110101110111000101" "11010100000000000010101111100011110101110001110110" "11011000000000000010110110001111110101101101000001" "11011100000000000010111101000011110101101000101000" "11100000000000000011000011111111110101100100101010" "11100100000000000011001011000011110101100001001000" "11101000000000000011010010001111110101011110000011" "11101100000000000011011001100011110101011011011010" "11110000000000000011100000111111110101011001001111" "11110100000000000011101000100011110101010111100010" "11111000000000000011110000001111110101010110010100" "11111100000000000011111000000011110101010101100100" }
set HasInitializer 1
set Initializer $ROMData
set NumOfStage 2
set MaxLatency -1
set DelayBudget 1.158
set ClkPeriod 4
set RegisteredInput 0
if {${::AESL::PGuard_simmodel_gen}} {
if {[info proc ap_gen_simcore_mem] == "ap_gen_simcore_mem"} {
    eval "ap_gen_simcore_mem { \
    id ${ID} \
    name ${MemName} \
    corename ${CoreName}  \
    op mem \
    hasByteEnable ${hasByteEnable} \
    reset_level 1 \
    sync_rst true \
    stage_num ${NumOfStage}  \
    registered_input ${RegisteredInput} \
    port_num 1 \
    port_list \{${PortList}\} \
    data_wd ${DataWd} \
    addr_wd ${AddrWd} \
    addr_range ${AddrRange} \
    true_reset ${TrueReset} \
    delay_budget ${DelayBudget} \
    clk_period ${ClkPeriod} \
    HasInitializer ${HasInitializer} \
    rom_data \{${ROMData}\} \
 } "
} else {
    puts "@W \[IMPL-102\] Cannot find ap_gen_simcore_mem, check your platform lib"
}
}


if {${::AESL::PGuard_rtl_comp_handler}} {
  ::AP::rtl_comp_handler $MemName
}


set CoreName ROM_nP
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_ROM] == "::AESL_LIB_VIRTEX::xil_gen_ROM"} {
    eval "::AESL_LIB_VIRTEX::xil_gen_ROM { \
    id ${ID} \
    name ${MemName} \
    corename ${CoreName}  \
    op mem \
    hasByteEnable ${hasByteEnable} \
    reset_level 1 \
    sync_rst true \
    stage_num ${NumOfStage}  \
    registered_input ${RegisteredInput} \
    port_num 1 \
    port_list \{${PortList}\} \
    data_wd ${DataWd} \
    addr_wd ${AddrWd} \
    addr_range ${AddrRange} \
    true_reset ${TrueReset} \
    delay_budget ${DelayBudget} \
    clk_period ${ClkPeriod} \
    HasInitializer ${HasInitializer} \
    rom_data \{${ROMData}\} \
 } "
  } else {
    puts "@W \[IMPL-104\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_ROM, check your platform lib"
  }
}


# clear list
if {${::AESL::PGuard_autoexp_gen}} {
    cg_default_interface_gen_dc_begin
    cg_default_interface_gen_bundle_begin
    AESL_LIB_XILADAPTER::native_axis_begin
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 19 \
    name x_V \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_x_V \
    op interface \
    ports { x_V { I 67 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id -1 \
    name ap_ctrl \
    type ap_ctrl \
    reset_level 1 \
    sync_rst true \
    corename ap_ctrl \
    op interface \
    ports { ap_start { I 1 bit } ap_ready { O 1 bit } ap_done { O 1 bit } ap_idle { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id -2 \
    name ap_return \
    type ap_return \
    reset_level 1 \
    sync_rst true \
    corename ap_return \
    op interface \
    ports { ap_return { O 67 vector } } \
} "
}


# Adapter definition:
set PortName ap_clk
set DataWd 1 
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc cg_default_interface_gen_clock] == "cg_default_interface_gen_clock"} {
eval "cg_default_interface_gen_clock { \
    id -3 \
    name ${PortName} \
    reset_level 1 \
    sync_rst true \
    corename apif_ap_clk \
    data_wd ${DataWd} \
    op interface \
}"
} else {
puts "@W \[IMPL-113\] Cannot find bus interface model in the library. Ignored generation of bus interface for '${PortName}'"
}
}


# Adapter definition:
set PortName ap_rst
set DataWd 1 
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc cg_default_interface_gen_reset] == "cg_default_interface_gen_reset"} {
eval "cg_default_interface_gen_reset { \
    id -4 \
    name ${PortName} \
    reset_level 1 \
    sync_rst true \
    corename apif_ap_rst \
    data_wd ${DataWd} \
    op interface \
}"
} else {
puts "@W \[IMPL-114\] Cannot find bus interface model in the library. Ignored generation of bus interface for '${PortName}'"
}
}



# merge
if {${::AESL::PGuard_autoexp_gen}} {
    cg_default_interface_gen_dc_end
    cg_default_interface_gen_bundle_end
    AESL_LIB_XILADAPTER::native_axis_end
}


