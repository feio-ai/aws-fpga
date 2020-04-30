open_project emu_cuisr_0_0
set_top shell_utils_cuisr
add_files -cflags " -I /home/centos/src/project_data/aws-fpga/Vitis/examples/xilinx_2019.2/cpp_kernels/monte_sim/build_dir.hw_emu.xilinx_aws-vu9p-f1_shell-v04261818_201920_1/link/vivado/vpl/prj/prj.srcs/sources_1/bd/emu/ip/emu_cuisr_0_0/src " /home/centos/src/project_data/aws-fpga/Vitis/examples/xilinx_2019.2/cpp_kernels/monte_sim/build_dir.hw_emu.xilinx_aws-vu9p-f1_shell-v04261818_201920_1/link/vivado/vpl/prj/prj.srcs/sources_1/bd/emu/ip/emu_cuisr_0_0/src/shell_utils_cuisr.cpp

open_solution "prj"
set_part {xcvu9p-flgb2104-2-i}
create_clock -period 10 -name default


config_interface -input_reg_mode both -output_reg_mode both


config_rtl -prefix emu_cuisr_0_0_
csynth_design
export_design -format ip_catalog -vendor xilinx.com -library ip -version 1.0
exit
