#!/bin/bash

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/Xilinx/Vivado/2019.2/data/../lib/lnx64.o:/opt/Xilinx/Vivado/2019.2/data/../lib/lnx64.o/Default

xsim.dir/emu_wrapper_behav/axsim $@

if [ $? -ne 0 ] ; then
  echo "FATAL ERROR: Simulation exited unexpectantly"
fi
