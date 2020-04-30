#!/bin/sh
lli=${LLVMINTERP-lli}
exec $lli \
    /home/centos/src/project_data/aws-fpga/Vitis/examples/xilinx_2019.2/cpp_kernels/array_partition/_x.hw_emu.xilinx_aws-vu9p-f1_shell-v04261818_201920_1/matmul_partition/matmul_partition/matmul_partition/solution/.autopilot/db/a.g.bc ${1+"$@"}
