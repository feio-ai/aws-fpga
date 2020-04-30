
# Call debug/profiling automation
set dpa_dict [list \
              [get_bd_intf_pins /monte_sim_1/m_axi_gmem]  {TYPE data DETAIL all CLK_SRC /monte_sim_1/ap_clk RST_SRC /slr1/peripheral_aresetn MON_ID {{monte_sim_1:m_axi_gmem-DDR[1]}} MEMORY {{DDR[1]}}} \
              [get_bd_intf_pins /monte_sim_dev_1/m_axi_gmem]  {TYPE data DETAIL all CLK_SRC /monte_sim_dev_1/ap_clk RST_SRC /slr1/peripheral_aresetn MON_ID {{monte_sim_dev_1:m_axi_gmem-DDR[1]}} MEMORY {{DDR[1]}}} \
              [get_bd_cells monte_sim_1]  {TYPE exec DETAIL all CLK_SRC /monte_sim_1/ap_clk RST_SRC /slr1/peripheral_aresetn} \
              [get_bd_cells monte_sim_dev_1]  {TYPE exec DETAIL all CLK_SRC /monte_sim_dev_1/ap_clk RST_SRC /slr1/peripheral_aresetn} \
             ]

# Platform options
set_property HDL_ATTRIBUTE.DPA_AXILITE_MASTER true [get_bd_intf_pins /slr1/interconnect_axilite_user_1/M03_AXI]
set_property HDL_ATTRIBUTE.DPA_TRACE_SLAVE true [get_bd_cells /memory_subsystem]
set dpa_opts [list \
              SETTINGS  {HW_EMU true IS_EMBEDDED false} \
              AXILITE  {MASTER /slr1/interconnect_axilite_user_1/M03_AXI CLK_SRC /slr1/interconnect_axilite_user_1/M00_ACLK RST_SRC /dma_pcie_arst} \
              TRACE_OFFLOAD  {SLAVE /memory_subsystem MASTER /xtlm_simple_intercon_0/M04_AXI CLK_SRC /xtlm_simple_intercon_0/m04_axi_aclk RST_SRC /xtlm_simple_intercon_0/m04_axi_aresetn SLR SLR0 DEDICATED true MEM_SPACE FIFO MEM_INDEX 0 FIFO_ADDR_SEG 0x0000008000000000 FIFO_ADDR_RANGE 0x0000000000400000 DEPTH 8192} \
             ]

set_param bd.enable_dpa 1
set_param bd.debug_profile.script /home/centos/src/project_data/aws-fpga/Vitis/examples/xilinx_2019.2/cpp_kernels/monte_sim/build_dir.hw_emu.xilinx_aws-vu9p-f1_shell-v04261818_201920_1/link/vivado/vpl/.local/debug_profile_automation.tcl
apply_bd_automation -rule xilinx.com:bd_rule:debug_profile -opts $dpa_opts -dict $dpa_dict

# Assign addresses and write debug_ip_layout
assign_bd_address
debug_profile::write_debug_ip_layout true "xilinx:aws-vu9p-f1:shell-v04261818:201920.1" "output"
