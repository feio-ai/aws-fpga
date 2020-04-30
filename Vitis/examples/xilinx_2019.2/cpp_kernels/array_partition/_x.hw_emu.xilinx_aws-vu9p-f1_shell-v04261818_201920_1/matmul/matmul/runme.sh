#!/bin/sh

# 
# v++(TM)
# runme.sh: a v++-generated Runs Script for UNIX
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/opt/Xilinx/Vivado/2019.2/bin:/opt/Xilinx/Vitis/2019.2/bin:/opt/Xilinx/Vitis/2019.2/bin
else
  PATH=/opt/Xilinx/Vivado/2019.2/bin:/opt/Xilinx/Vitis/2019.2/bin:/opt/Xilinx/Vitis/2019.2/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/centos/src/project_data/aws-fpga/Vitis/examples/xilinx_2019.2/cpp_kernels/array_partition/_x.hw_emu.xilinx_aws-vu9p-f1_shell-v04261818_201920_1/matmul/matmul'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado_hls -f matmul.tcl -messageDb vivado_hls.pb
