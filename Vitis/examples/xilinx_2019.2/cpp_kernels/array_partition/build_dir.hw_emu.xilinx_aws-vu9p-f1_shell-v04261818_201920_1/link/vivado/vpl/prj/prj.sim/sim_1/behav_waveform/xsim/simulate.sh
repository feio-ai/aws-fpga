#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2019.2 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Wed Apr 29 19:09:55 UTC 2020
# SW Build 2700185 on Thu Oct 24 18:45:48 MDT 2019
#
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
#
# usage: simulate.sh
#
# ****************************************************************************
set -Eeuo pipefail

xv_cxl_lib_path="/opt/Xilinx/Vivado/2019.2/data/xsim"
export xv_cpt_lib_path="/opt/Xilinx/Vivado/2019.2/data/simmodels/xsim/2019.2/lnx64/6.2.0/systemc/protected"
xv_ext_lib_path="/opt/Xilinx/Vivado/2019.2/data/simmodels/xsim/2019.2/lnx64/6.2.0/ext"
xv_lib_path="/opt/Xilinx/Vivado/2019.2/lib/lnx64.o/Default:/opt/Xilinx/Vivado/2019.2/lib/lnx64.o"

xv_ref_path=${VIVADO_LOC:-"/opt/Xilinx/Vivado/2019.2"}
xv_lib_path="$xv_ref_path/lib/lnx64.o/Default:$xv_ref_path/lib/lnx64.o"

export LD_LIBRARY_PATH=$PWD:$xv_lib_path:$xv_ref_path/data/simmodels/xsim/2019.2/lnx64/6.2.0/ext/protobuf:$xv_ref_path/data/xsim/ip/xtlm:$xv_ref_path/data/xsim/ip/xtlm_simple_interconnect_v1_0:$xv_ref_path/data/xsim/ip/common_cpp_v1_0:$xv_ref_path/data/xsim/ip/emu_perf_common_v1_0:$LD_LIBRARY_PATH

echo "xsim emu_wrapper_behav -key {Behavioral:sim_1:Functional:emu_wrapper} -tclbatch emu_wrapper.tcl -protoinst "protoinst_files/bd_d216.protoinst" -protoinst "protoinst_files/pfm_dynamic.protoinst" -protoinst "protoinst_files/emu.protoinst" -log simulate.log $*"
xsim emu_wrapper_behav -key {Behavioral:sim_1:Functional:emu_wrapper} -tclbatch emu_wrapper.tcl -protoinst "protoinst_files/bd_d216.protoinst" -protoinst "protoinst_files/pfm_dynamic.protoinst" -protoinst "protoinst_files/emu.protoinst" -log simulate.log $*

