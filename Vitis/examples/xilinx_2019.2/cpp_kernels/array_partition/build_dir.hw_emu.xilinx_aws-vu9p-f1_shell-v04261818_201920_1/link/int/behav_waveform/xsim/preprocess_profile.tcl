# Get hier path inside CU (HLS bug)
proc getHierName {cuName} {
  set hierName inst
  if {[get_objects -quiet /emu_wrapper/emu_i/$cuName/$hierName/ap_idle] == {}} {
    set hierName U0
  }
  return $hierName
}

# Check hierarchical name for only 1 CU instance in a Kernel. All the instances will have same namer, either inst or U0 
  set hierName [getHierName matmul_partition_1]
get_value_database /emu_wrapper/emu_i/matmul_partition_1/$hierName/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/matmul_partition_1/$hierName/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/matmul_partition_1/$hierName/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/matmul_partition_1/$hierName/ap_str_blocking_n -time 0 -quiet
# Check hierarchical name for only 1 CU instance in a Kernel. All the instances will have same namer, either inst or U0 
  set hierName [getHierName matmul_1]
get_value_database /emu_wrapper/emu_i/matmul_1/$hierName/ap_idle -time 0 -quiet
get_value_database /emu_wrapper/emu_i/matmul_1/$hierName/ap_int_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/matmul_1/$hierName/ap_ext_blocking_n -time 0 -quiet
get_value_database /emu_wrapper/emu_i/matmul_1/$hierName/ap_str_blocking_n -time 0 -quiet
