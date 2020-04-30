# Get hier path inside CU (HLS bug)
proc getHierName {cuName} {
  set hierName inst
  if {[get_objects -quiet /emu_wrapper/emu_i/$cuName/$hierName/ap_idle] == {}} {
    set hierName U0
  }
  return $hierName
}

# Check hierarchical name for only 1 CU instance in a Kernel. All the instances will have same namer, either inst or U0 
  set hierName [getHierName monte_sim_dev_1]
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_411/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_411/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_411/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_411/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_411/grp_log_67_17_s_fu_144/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_411/grp_log_67_17_s_fu_144/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_411/grp_log_67_17_s_fu_144/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_411/grp_log_67_17_s_fu_144/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_411/grp_exp_core_32_16_50_s_fu_161/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_411/grp_exp_core_32_16_50_s_fu_161/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_411/grp_exp_core_32_16_50_s_fu_161/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_411/grp_exp_core_32_16_50_s_fu_161/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_438/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_438/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_438/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_438/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_438/grp_log_67_17_s_fu_144/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_438/grp_log_67_17_s_fu_144/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_438/grp_log_67_17_s_fu_144/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_438/grp_log_67_17_s_fu_144/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_438/grp_exp_core_32_16_50_s_fu_161/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_438/grp_exp_core_32_16_50_s_fu_161/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_438/grp_exp_core_32_16_50_s_fu_161/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_438/grp_exp_core_32_16_50_s_fu_161/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_465/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_465/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_465/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_465/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_465/grp_log_67_17_s_fu_144/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_465/grp_log_67_17_s_fu_144/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_465/grp_log_67_17_s_fu_144/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_465/grp_log_67_17_s_fu_144/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_465/grp_exp_core_32_16_50_s_fu_161/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_465/grp_exp_core_32_16_50_s_fu_161/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_465/grp_exp_core_32_16_50_s_fu_161/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_465/grp_exp_core_32_16_50_s_fu_161/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_492/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_492/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_492/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_492/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_492/grp_log_67_17_s_fu_144/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_492/grp_log_67_17_s_fu_144/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_492/grp_log_67_17_s_fu_144/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_492/grp_log_67_17_s_fu_144/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_492/grp_exp_core_32_16_50_s_fu_161/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_492/grp_exp_core_32_16_50_s_fu_161/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_492/grp_exp_core_32_16_50_s_fu_161/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_492/grp_exp_core_32_16_50_s_fu_161/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_519/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_519/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_519/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_519/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_519/grp_log_67_17_s_fu_144/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_519/grp_log_67_17_s_fu_144/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_519/grp_log_67_17_s_fu_144/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_519/grp_log_67_17_s_fu_144/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_519/grp_exp_core_32_16_50_s_fu_161/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_519/grp_exp_core_32_16_50_s_fu_161/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_519/grp_exp_core_32_16_50_s_fu_161/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_519/grp_exp_core_32_16_50_s_fu_161/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_546/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_546/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_546/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_546/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_546/grp_log_67_17_s_fu_144/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_546/grp_log_67_17_s_fu_144/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_546/grp_log_67_17_s_fu_144/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_546/grp_log_67_17_s_fu_144/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_546/grp_exp_core_32_16_50_s_fu_161/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_546/grp_exp_core_32_16_50_s_fu_161/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_546/grp_exp_core_32_16_50_s_fu_161/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_546/grp_exp_core_32_16_50_s_fu_161/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_573/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_573/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_573/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_573/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_573/grp_log_67_17_s_fu_144/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_573/grp_log_67_17_s_fu_144/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_573/grp_log_67_17_s_fu_144/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_573/grp_log_67_17_s_fu_144/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_573/grp_exp_core_32_16_50_s_fu_161/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_573/grp_exp_core_32_16_50_s_fu_161/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_573/grp_exp_core_32_16_50_s_fu_161/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_pow_32_16_s_fu_573/grp_exp_core_32_16_50_s_fu_161/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_sqrt_fixed_32_16_s_fu_600/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_sqrt_fixed_32_16_s_fu_600/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_sqrt_fixed_32_16_s_fu_600/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_dev_1/$hierName/grp_sqrt_fixed_32_16_s_fu_600/ap_str_blocking_n -time 0 -quiet
# Check hierarchical name for only 1 CU instance in a Kernel. All the instances will have same namer, either inst or U0 
  set hierName [getHierName monte_sim_1]
get_value_database /emu_wrapper/emu_i/monte_sim_1/$hierName/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_1/$hierName/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_1/$hierName/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_1/$hierName/ap_str_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_1/$hierName/grp_sqrt_fixed_32_16_s_fu_369/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_1/$hierName/grp_sqrt_fixed_32_16_s_fu_369/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_1/$hierName/grp_sqrt_fixed_32_16_s_fu_369/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/monte_sim_1/$hierName/grp_sqrt_fixed_32_16_s_fu_369/ap_str_blocking_n -time 0 -quiet
