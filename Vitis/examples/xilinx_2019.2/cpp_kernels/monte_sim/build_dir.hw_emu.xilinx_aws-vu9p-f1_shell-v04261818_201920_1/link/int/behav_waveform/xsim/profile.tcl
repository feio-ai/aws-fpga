#
# File: profile.tcl
# Description: Script to analyze HW emulation results
# Created: 2020-04-30 20:18:52
#

global ofp
global ofp2

# Log results (file 1 for summary)
proc putsLog {str} {
  global ofp

#  puts $str
  puts $ofp $str
}

# Log results (file 2 for trace)
proc putsLog2 {str} {
  global ofp2

#  puts $str
  puts $ofp2 $str
}

# Get end time
proc getEndTime {} {
  return [lindex [now] 0]
}

# Get total time of signal at a specified value
proc getTimeUsec {signal targetValue {requireEnd 0}} {
  if {[get_objects -quiet $signal] == {}} {
    return 0
  }
  set tranx [get_transitions $signal -start 0 -end [getEndTime]]

  set otherValue [expr 1 - $targetValue]
  set startTime 0
  set totalTimeUsec 0
  set factor 6.0

  for { set i 0 } { $i < [llength $tranx] } { incr i } {
    set tr [lindex $tranx $i]
    set currTime  [lindex $tr 0]
    set currUnit  [lindex $tr 1]
    set currValue [lindex $tr 2]
    if {[string first ns $currUnit] == 0} {set factor 3.0}

    if {$currValue == $targetValue} {
      set startTime $currTime
    } elseif {$currValue == $otherValue && $startTime > 0} {
      set totalTimeUsec [expr $totalTimeUsec + (($currTime - $startTime) / pow(10.0, $factor))]
      set startTime 0
    }
  }

  if {$totalTimeUsec == 0 && $requireEnd} {
    set totalTimeUsec [expr (([getEndTime] - $startTime) / pow(10.0, $factor))]
  }
  return $totalTimeUsec
}

# Get events of signal at a specified value
proc getTraceEvents {kernelName cuName moduleName signal targetValue {requireEnd 0}} {
  if {[get_objects -quiet $signal] == {}} {
    return
  }
  set tranx [get_transitions $signal -start 0 -end [getEndTime]]

  set otherValue [expr 1 - $targetValue]
  set startTime 0
  set factor 9.0
  set currDeviceName xilinx_aws-vu9p-f1_shell-v04261818_201920_1-0
  set currBinaryName monte_sim

  for { set i 0 } { $i < [llength $tranx] } { incr i } {
    set tr [lindex $tranx $i]
    set currTime  [lindex $tr 0]
    set currUnit  [lindex $tr 1]
    set currValue [lindex $tr 2]
    if {[string first ns $currUnit] == 0} {set factor 6.0}

    if {$currValue == $targetValue} {
      set startTime $currTime
    } elseif {$currValue == $otherValue && $startTime > 0} {
      set startTimeMsec [expr $startTime / pow(10.0, $factor)]
      set endTimeMsec [expr $currTime / pow(10.0, $factor)]
      set traceStr [format "%s,%s,%s,%s,%s,%s,0,%.6f,%.6f,0" $currDeviceName $currBinaryName $kernelName $cuName $moduleName $moduleName $startTimeMsec $endTimeMsec]
      putsLog2 $traceStr
      set startTime 0
    }
  }
}

# Get events of signal at a specified value
proc getTraceEvents2 {kernelName cuName moduleName type index signal} {
  if {[get_objects -quiet $signal] == {}} {
    puts "Unable to find signal: $signal"
    return
  }
  set tranx [get_transitions $signal]

  set factor 9.0
  set newValue 0
  if {$type == "row"} {
      set newValue 65535
  }
  set startTimeMsec 0
  set currDeviceName xilinx_aws-vu9p-f1_shell-v04261818_201920_1-0
  set currBinaryName monte_sim
  set hasData 0 

  for { set i 0 } { $i < [llength $tranx] } { incr i } {
    set tr [lindex $tranx $i]
    set currTime   [lindex $tr 0]
    if {$currTime == 0} {
      continue
    }
    set currUnit   [lindex $tr 1]
    if {[string first ns $currUnit] == 0} {set factor 6.0}
    set timeMsec [expr $currTime / pow(10.0, $factor)]

    set traceStr [format "%s,%s,%s,%s,%s,%s,%d,%.6f,%.6f,%d" $currDeviceName $currBinaryName $kernelName $cuName $moduleName $type $index $startTimeMsec $timeMsec $newValue]
    putsLog2 $traceStr

    set currValue [lindex $tr 2]
    set currValueInt [expr 0x$currValue]
    if {$type == "row"} {
      set newValue $currValueInt
    } else {
      set newValue [expr {($currValueInt == 65535) ? 0 : $currValueInt}]
    }
    set startTimeMsec $timeMsec
    set hasData 1 
  }

  # Force last value to be 0
  if {$hasData == 1} { 
    set endValue 0
    if {$type == "row"} { set endValue 65535 }
    set traceStr [format "%s,%s,%s,%s,%s,%s,%d,%.6f,%.6f,%d" $currDeviceName $currBinaryName $kernelName $cuName $moduleName $type $index  $startTimeMsec $startTimeMsec $endValue]
    putsLog2 $traceStr
  }
}

# Get hier path inside CU (HLS bug)
proc getHierName {cuName} {
  set hierName inst
  if {[get_objects -quiet /emu_wrapper/emu_i/$cuName/$hierName/ap_idle] == {}} {
    set hierName U0
  }
  return $hierName
}

set outFilename profile_kernels.csv
set ofp [open $outFilename w]
set outFilename2 timeline_kernels.csv
set ofp2 [open $outFilename2 w]

#
# Compute Unit Stalls
#
set computeUnits { monte_sim_dev_1 monte_sim_1 }

putsLog "Compute Units: Running Time and Stalls"
putsLog "Compute Unit, Running Time (us), Intra-Kernel Dataflow Stalls (%), External Memory Stalls (%), External Stream Stalls (%)"

for { set i 0 } { $i < [llength $computeUnits] } { incr i } {
  set cuName [lindex $computeUnits $i]
  set hierName [getHierName $cuName]

  # Runtime
  set signal /emu_wrapper/emu_i/$cuName/$hierName/ap_idle
  set cuTime [getTimeUsec $signal 0 1]

  # Stall times
  set signal /emu_wrapper/emu_i/$cuName/$hierName/ap_int_blocking_n
  set intStallTime [getTimeUsec $signal 0]
  set intStallPercent [expr {$cuTime == 0} ? 0 : min((100.0 * $intStallTime) / $cuTime, 100.0)]

  set signal /emu_wrapper/emu_i/$cuName/$hierName/ap_ext_blocking_n
  set extStallTime [getTimeUsec $signal 0]
  set extStallPercent [expr {$cuTime == 0} ? 0 : min((100.0 * $extStallTime) / $cuTime, 100.0)]

  set signal /emu_wrapper/emu_i/$cuName/$hierName/ap_str_blocking_n
  set strStallTime [getTimeUsec $signal 0]
  set strStallPercent [expr {$cuTime == 0} ? 0 : min((100.0 * $strStallTime) / $cuTime, 100.0)]

  set logStr [format "%s,%.3f,%.3f,%.3f,%.3f" $cuName $cuTime $intStallPercent $extStallPercent $strStallPercent]
  putsLog $logStr
}
putsLog ""

#
# Function Stalls
#
set computeUnits { monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_dev_1 monte_sim_1 }
set modules { grp_pow_32_16_s_fu_411 grp_pow_32_16_s_fu_411/grp_log_67_17_s_fu_144 grp_pow_32_16_s_fu_411/grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_438 grp_pow_32_16_s_fu_438/grp_log_67_17_s_fu_144 grp_pow_32_16_s_fu_438/grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_465 grp_pow_32_16_s_fu_465/grp_log_67_17_s_fu_144 grp_pow_32_16_s_fu_465/grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_492 grp_pow_32_16_s_fu_492/grp_log_67_17_s_fu_144 grp_pow_32_16_s_fu_492/grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_519 grp_pow_32_16_s_fu_519/grp_log_67_17_s_fu_144 grp_pow_32_16_s_fu_519/grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_546 grp_pow_32_16_s_fu_546/grp_log_67_17_s_fu_144 grp_pow_32_16_s_fu_546/grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_573 grp_pow_32_16_s_fu_573/grp_log_67_17_s_fu_144 grp_pow_32_16_s_fu_573/grp_exp_core_32_16_50_s_fu_161 grp_sqrt_fixed_32_16_s_fu_600 grp_sqrt_fixed_32_16_s_fu_369 }
set realModules { pow_32_16_s pow_32_16_s/log_67_17_s pow_32_16_s/exp_core_32_16_50_s pow_32_16_s pow_32_16_s/log_67_17_s pow_32_16_s/exp_core_32_16_50_s pow_32_16_s pow_32_16_s/log_67_17_s pow_32_16_s/exp_core_32_16_50_s pow_32_16_s pow_32_16_s/log_67_17_s pow_32_16_s/exp_core_32_16_50_s pow_32_16_s pow_32_16_s/log_67_17_s pow_32_16_s/exp_core_32_16_50_s pow_32_16_s pow_32_16_s/log_67_17_s pow_32_16_s/exp_core_32_16_50_s pow_32_16_s pow_32_16_s/log_67_17_s pow_32_16_s/exp_core_32_16_50_s sqrt_fixed_32_16_s sqrt_fixed_32_16_s }

putsLog "Functions: Running Time and Stalls"
putsLog "Compute Unit, Function, Running Time (us), Intra-Kernel Dataflow Stalls (%), External Memory Stalls (%), External Stream Stalls (%)"

for { set i 0 } { $i < [llength $computeUnits] } { incr i } {
  set cuName [lindex $computeUnits $i]
  set hierName [getHierName $cuName]
  set moduleName [lindex $modules $i]
  set moduleRealName [lindex $realModules $i]

  # Runtime
  # NOTE: not all modules have ap_start/ap_idle
  set cuSignal /emu_wrapper/emu_i/$cuName/$hierName/ap_idle
  set moduleSignal /emu_wrapper/emu_i/$cuName/$hierName/$moduleName/ap_idle
  if {[get_objects -quiet $moduleSignal] == {}} {
    set moduleSignal $cuSignal
  }
  set cuTime [getTimeUsec $cuSignal 0 1]
  set moduleTime [getTimeUsec $moduleSignal 0 1]

  # Stall times
  set signal /emu_wrapper/emu_i/$cuName/$hierName/$moduleName/ap_int_blocking_n
  set intStallTime [getTimeUsec $signal 0]
  set intStallPercent [expr {$cuTime == 0} ? 0 : min((100.0 * $intStallTime) / $cuTime, 100.0)]

  set signal /emu_wrapper/emu_i/$cuName/$hierName/$moduleName/ap_ext_blocking_n
  set extStallTime [getTimeUsec $signal 0]
  set extStallPercent [expr {$cuTime == 0} ? 0 : min((100.0 * $extStallTime) / $cuTime, 100.0)]

  set signal /emu_wrapper/emu_i/$cuName/$hierName/$moduleName/ap_str_blocking_n
  set strStallTime [getTimeUsec $signal 0]
  set strStallPercent [expr {$cuTime == 0} ? 0 : min((100.0 * $strStallTime) / $cuTime, 100.0)]

  set logStr [format "%s,%s,%.3f,%.3f,%.3f,%.3f" $cuName $moduleName $moduleTime $intStallPercent $extStallPercent $strStallPercent]
  putsLog $logStr
}
putsLog ""

puts "Waiting for protocol analyzers to complete..."
sim_wait_for_processing
puts "Done!"

#
# Compute Unit Ports
#
set computeUnits { monte_sim_dev_1 monte_sim_1 }
set ports { m_axi_gmem m_axi_gmem }
set readBusySignals { /emu_wrapper/emu_i/monte_sim_dev_1/m_axi_gmem.readActive /emu_wrapper/emu_i/monte_sim_1/m_axi_gmem.readActive }
set writeBusySignals { /emu_wrapper/emu_i/monte_sim_dev_1/m_axi_gmem.writeActive /emu_wrapper/emu_i/monte_sim_1/m_axi_gmem.writeActive }

putsLog "Compute Units: Port Data Transfer"
putsLog "Compute Unit, Port, Write Time (us), Outstanding Write (%), Read Time (us), Outstanding Read (%)"

for { set i 0 } { $i < [llength $computeUnits] } { incr i } {
  set cuName [lindex $computeUnits $i]
  set hierName [getHierName $cuName]
  set portName [lindex $ports $i]
  set readBusy [lindex $readBusySignals $i]
  set writeBusy [lindex $writeBusySignals $i]

  # Runtime
  set signal /emu_wrapper/emu_i/$cuName/$hierName/ap_idle
  set moduleTime [getTimeUsec $signal 0 1]

  # Write times
  set writeTime [getTimeUsec $writeBusy 1]
  set writePercent [expr {$moduleTime == 0} ? 0 : min((100.0 * $writeTime) / $moduleTime, 100.0)]

  # Read times
  set readTime [getTimeUsec $readBusy 1]
  set readPercent [expr {$moduleTime == 0} ? 0 : min((100.0 * $readTime) / $moduleTime, 100.0)]

  set logStr [format "%s,%s,%.3f,%.3f,%.3f,%.3f" $cuName $portName $writeTime $writePercent $readTime $readPercent]
  putsLog $logStr
}
putsLog ""

#
# Trace Events
#
putsLog2 "Kernel trace events"
putsLog2 "Device, Binary, Kernel, Compute Unit, Function, Data Type, Index, Start Time (ms), End Time (ms), Value"
# Set list of CU, modules, protoinst for kernel monte_sim_dev at index 0 in " kernels " list declared later 
set cuForKernel0 { monte_sim_dev_1  } 
set moduleForKernel0 { grp_pow_32_16_s_fu_411 grp_pow_32_16_s_fu_411/grp_log_67_17_s_fu_144 grp_pow_32_16_s_fu_411/grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_438 grp_pow_32_16_s_fu_438/grp_log_67_17_s_fu_144 grp_pow_32_16_s_fu_438/grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_465 grp_pow_32_16_s_fu_465/grp_log_67_17_s_fu_144 grp_pow_32_16_s_fu_465/grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_492 grp_pow_32_16_s_fu_492/grp_log_67_17_s_fu_144 grp_pow_32_16_s_fu_492/grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_519 grp_pow_32_16_s_fu_519/grp_log_67_17_s_fu_144 grp_pow_32_16_s_fu_519/grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_546 grp_pow_32_16_s_fu_546/grp_log_67_17_s_fu_144 grp_pow_32_16_s_fu_546/grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_573 grp_pow_32_16_s_fu_573/grp_log_67_17_s_fu_144 grp_pow_32_16_s_fu_573/grp_exp_core_32_16_50_s_fu_161  } 
set protoInstForKernel0 { grp_pow_32_16_s_fu_411 grp_log_67_17_s_fu_144 grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_438 grp_log_67_17_s_fu_144 grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_465 grp_log_67_17_s_fu_144 grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_492 grp_log_67_17_s_fu_144 grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_519 grp_log_67_17_s_fu_144 grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_546 grp_log_67_17_s_fu_144 grp_exp_core_32_16_50_s_fu_161 grp_pow_32_16_s_fu_573 grp_log_67_17_s_fu_144 grp_exp_core_32_16_50_s_fu_161  } 

# Set list of CU, modules, protoinst for kernel monte_sim at index 1 in " kernels " list declared later 
set cuForKernel1 { monte_sim_1  } 
set moduleForKernel1 {  } 
set protoInstForKernel1 {  } 

set kernels { monte_sim_dev monte_sim }
for { set i 0 } { $i < [llength $kernels] } { incr i } {
  set kernelName [lindex $kernels $i]
  set computeUnits [set cuForKernel$i] 
  for { set j 0 } { $j < [llength $computeUnits] } { incr j } {
    set cuName [lindex $computeUnits $j]
    set hierName [getHierName $cuName]
    set signal /emu_wrapper/emu_i/$cuName/$hierName/ap_idle
    getTraceEvents $kernelName $cuName top $signal 0 1
  }
}

for { set i 0 } { $i < [llength $kernels] } { incr i } {
  set kernelName [lindex $kernels $i]
  set computeUnits [set cuForKernel$i] 
  set modules [set moduleForKernel$i] 
  set protoInstNames [set protoInstForKernel$i] 
  for { set j 0 } { $j < [llength $computeUnits] } { incr j } {
    set cuName [lindex $computeUnits $j]
    set hierName [getHierName $cuName]
    for { set k 0 } { $k < [llength $modules] } { incr k } {
      set modulePathName [lindex $modules $k]
      set protoInstName  [lindex $protoInstNames $k]
      set signal /emu_wrapper/emu_i/$cuName/$hierName/$modulePathName/$protoInstName.dataflowTxWaveData.OutStanding
      getTraceEvents2 $kernelName $cuName $modulePathName outstanding 0 $signal
      for { set l 0 } { $l < 64 } { incr l } {
        set signal /emu_wrapper/emu_i/$cuName/$hierName/$modulePathName/$protoInstName.iterationsWave_$l
        getTraceEvents2 $kernelName $cuName $modulePathName row $l $signal
      }
    }
  }
}

close $ofp
close $ofp2
