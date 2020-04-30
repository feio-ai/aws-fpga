
namespace eval debug_profile {

  ##################################################################
  # insert_profile_hwemu
  #  Description: 
  #    Insert all requested profile IP, targeting hardware
  #    emulation exclusively.  Emulation profile IP currently includes
  #    SAMs, SPMs, SSPMs, and hardware protocol monitors.
  #  Arguments:
  #    hw_platform_info   HW platform dict
  #    config_info        configuration dict
  #    debug_profile_info debug/profile dict
  ##################################################################
  proc insert_profile_hwemu {hw_platform_info config_info debug_profile_info fp} {
    variable ::debug_profile::source_dir
    set output_dir             [dict get $config_info output_dir]
    set is_hw_emu              [dict_get_default $config_info is_hw_emu false]
    set is_system_dpa          [dict_get_default $config_info system_dpa_enabled true]
    
    # We use per-bank monitoring in the following cases:
    #   * Amazon F1 5.0 HW platform
    #   * Older SDSoC platforms (state is pre_synth and uses_pr=false)
    variable ::debug_profile::is_aws_platform
    variable ::debug_profile::is_soc_platform
	
    set hw_platform_uses_pr    [dict get $hw_platform_info hw_platform_uses_pr]
    set hw_platform_vbnv       [dict get $hw_platform_info hw_platform_vbnv]
    set hw_platform_type       [string tolower [lindex [split $hw_platform_vbnv ":"] 1]]

    # Make sure platform is supported
    if {![is_supported_emu_platform $hw_platform_type]} {
      puts "WARNING: Profiling not supported on platform $hw_platform_type."
      return
    }
    
    set per_bank_monitoring    [expr {($is_aws_platform || $is_soc_platform) ? true : false}]

    set debug_info             [dict_get_default $debug_profile_info debug {}]
    set live_waveform          [dict_get_default $debug_info kernel_debug false]
	
    set is_zynq_platform false
    #Added this check as we are relying on this variable to add the profiling ip 
    #sim_sdx_accel_monitor to the BD in the Zync platforms
    if { [string match "zc*" ${hw_platform_type}] && ${is_hw_emu} } {
       set is_zynq_platform true
    } else {
       set is_zynq_platform false
    }

    # Performance modeling in hardware emulation is different for SoC and PCIe platforms
    if {($per_bank_monitoring || ${is_zynq_platform} ) && ($is_system_dpa == false) } {
      if {[catch {insert_profile_ip_soc_hwemu $hw_platform_info $config_info $debug_profile_info} catch_res]} {
        ocl_util::error2file $output_dir "Could not add profiling on kernel boundary" $catch_res
      }
    } else {
      #if {[catch {insert_profile_ip_pcie_hwemu $hw_platform_info $config_info $debug_profile_info $fp} catch_res]} {
      #  ocl_util::error2file $output_dir "Could not add profiling on kernel boundary" $catch_res
      #}
      set dpa_dict [insert_profile_ip_pcie_hwemu $hw_platform_info $config_info $debug_profile_info $fp]
      if {$is_system_dpa} {
        puts $fp "\n# Call debug/profiling automation"
        puts $fp "set dpa_dict \[list \\"
        foreach { key value } $dpa_dict {
          puts $fp "              $key  {$value} \\"
        }
        puts $fp "             \]"

        set dpa_opts {}
        set profile_info [dict_get_default $debug_profile_info profile {}]
        
        # AIE Settings (if specified)
        set dpa_opts [get_dpa_options_aie $profile_info $dpa_opts]
          
        # Only get rest of options if needed
        if {$dpa_dict != {}} {
          set dpa_opts [get_dpa_options_emu $fp $config_info $profile_info $dpa_opts]
        }
        
        puts $fp "set dpa_opts \[list \\"
        foreach { key value } $dpa_opts {
          puts $fp "              $key  {$value} \\"
        }
        puts $fp "             \]\n"
        
        #puts $fp "debug::add_scope DBG_PROFILE"
        #puts $fp "debug::set_visibility 5"
        puts $fp "set_param bd.enable_dpa 1"
        puts $fp "set_param bd.debug_profile.script $source_dir/debug_profile_automation.tcl"
        puts $fp "apply_bd_automation -rule xilinx.com:bd_rule:debug_profile -opts \$dpa_opts -dict \$dpa_dict"
      }
    }
  }

  ###########################################################
  # is_supported_emu_platform
  #  Description:
  #    Checks if platform is supported in HW emulation.
  #  Arguments:
  #    hw_platform_type    HW platform type
  #  Return Value:
  #    true: platform is supported; false: platform is not supported
  ###########################################################
  proc is_supported_emu_platform {hw_platform_type} {
    if {[info exists ::env(XCL_EMULATION_PROFILE_SUPPORT)]} {
      puts "WARNING: Turning on profiling for unsupported platforms."
      return true
    }
  
    if {[string match "zed*"  $hw_platform_type]} {return false}
    if {[string match "zc70*" $hw_platform_type]} {return false}
    return true
  }; # end is_supported_emu_platform
  
  #################################################################################################
  ######                                       Options                                        #####
  #################################################################################################
  
  ###########################################################
  # get_dpa_options_emu
  #  Description:
  #    Collect options for trace, AXI-Lite, and other settings
  #    for the BD automation.
  #  Arguments:
  #    fp                  File pointer for writing
  #    config_info         Dictionary of configuration settings
  #    profile_info        Dictionary created from v++ profile options
  #    dpa_opts            Dictionary for BD automation options
  #  Return Value:
  #    A dictionary containing all options for BD automation
  ###########################################################
  proc get_dpa_options_emu {fp config_info profile_info dpa_opts} {
    variable ::debug_profile::is_aws_platform
    variable ::debug_profile::enable_trace
    variable ::debug_profile::embedded
  	
    # Trace is always enabled in HW emu
    set enable_trace true
    
    puts $fp "\n# Platform options"
  	
    # Top-level settings
    set topDict {}
    dict set topDict HW_EMU [dict_get_default $config_info is_hw_emu false]
    dict set topDict IS_EMBEDDED $embedded
    dict set dpa_opts SETTINGS $topDict

    # AXI-Lite and AXI Full settings
    if { [is_versal_shell] } {
      puts "--- DEBUG: Getting Versal settings..."
      set dpa_opts [get_dpa_options_emu_versal $fp $profile_info $dpa_opts]
    } elseif { [is_soc_shell] } {
      puts "--- DEBUG: Getting SoC settings..."
      set dpa_opts [get_dpa_options_emu_soc $fp $profile_info $dpa_opts]
    } else {
      # Default - PCIe platform
      puts "--- DEBUG: Getting PCIe settings..."
      set dpa_opts [get_dpa_options_emu_pcie $fp $profile_info $dpa_opts]
    }
    
    puts "--- DEBUG: -----------------------------------------------------------"
    puts "--- DEBUG: Automation Options:"
    foreach { key value } $dpa_opts {
      puts "--- DEBUG:   $key    $value"
    }
    puts "--- DEBUG: -----------------------------------------------------------"
    return $dpa_opts
  }; # end get_dpa_options_emu

  ###########################################################
  # get_dpa_options_emu_soc
  #  Description:
  #    On SoC platforms, collect the meta-data from the passed
  #    in dictionaries.
  #  Arguments:
  #    fp            File pointer for writing
  #    profile_info  Dictionary created from v++ profile options
  #    dpa_opts      Dictionary for BD automation options
  #  Return Value:
  #    An updated dictionary containing options for BD automation
  ###########################################################
  proc get_dpa_options_emu_soc {fp profile_info dpa_opts} {
    variable ::debug_profile::enable_trace
    
    #
    # Step 1: Find a PS (if exists)
    #
    set cells [get_bd_cells -quiet -filter {VLNV =~ "xilinx.com:ip:processing_system7*" || VLNV =~ "xilinx.com:ip:zynq*"}]
    set ps [lindex $cells 0]
     
    # 
    # Step 2: Find interconnect for AXI-Lite and trace masters
    #
    #   Option A: Use decoration
    set masterInterconnect [get_bd_cells -quiet -hier -filter {HDL_ATTRIBUTE.DPA_AXILITE_MASTER != {}}]
    
    #   Option B: Search for PS master with lowest frequency
    if {$masterInterconnect == {}} {
      if {$ps == {}} {
        puts "CRITICAL WARNING: Unable to find PS on an SoC platform."
        return $dpa_opts
      }

      # Traverse all AXI ports on PS to find the interconnect with the lowest frequency
      set axiMasterPins [get_bd_intf_pins -quiet -of_objects $ps -filter {Mode=="Master"}]
      
      # Let's pick the lowest freq one since it's not critical
      set minClockFreq 500000000
      
      foreach masterPin $axiMasterPins {
        # Trace the control port to the interconnect
        set interfaceNets [get_bd_intf_nets -quiet -of_objects $masterPin]
        set slavePins     [get_bd_intf_pins -quiet -of_objects $interfaceNets -filter {Mode=="Slave"}]
        set currIntercon  [get_bd_cells -quiet -of_objects $slavePins]
        if {$currIntercon == {}} {continue}
        
        set currClockFreq [get_property -quiet CONFIG.FREQ_HZ $masterPin]
        if {$currClockFreq < $minClockFreq} {
          set masterInterconnect $currIntercon
          set minClockFreq $currClockFreq
        }
      }
    }

    if { $masterInterconnect == {} } { 
      puts "CRITICAL WARNING: Unable to find a port on PS for control or trace offload."
      return $dpa_opts
    }
   
    #
    # Step 3: Find clock and reset
    #
    set monitorClock {}
    set monitorReset {}
      
    #   Option A: Grab from a CU cell
    set cuCells [get_bd_cells -quiet -hier -filter "SDX_KERNEL==true"]
    foreach cu $cuCells {
      set axilite_pin [get_bd_intf_pins -quiet -of_objects $cu -filter {CONFIG.PROTOCOL == AXI4LITE && MODE == Slave}]
      # NOTE: uncomment next line for additional method to find interconnect
      #set axilite_obj [find_bd_objs -quiet -relation connected_to -stop_at_interconnect -thru_hier $axilite_pin]
      
      if {$axilite_pin != {}} {
        set monitorClock [bd::clkrst::get_sink_clk $axilite_pin]
        set monitorReset [bd::clkrst::get_sink_rst $monitorClock]
        break
      }
    }
    puts "--- DPA: monitorClock = $monitorClock, monitorReset = $monitorReset"
    
    #   Option B: Get reset from proc_sys_reset cell
    #   NOTE: This is needed to support RTL kernels without resets
    if {$monitorReset == {}} {
      set clkDriver    [find_bd_objs -quiet -relation connected_to -thru_hier $monitorClock]
      set clkSinks     [find_bd_objs -quiet -relation connected_to -thru_hier $clkDriver]
      set resetCells   [get_bd_cells -quiet -of $clkSinks -filter {VLNV=~"*proc_sys_reset*"}]
      set monitorReset [lindex [get_bd_pins -quiet -hier -of $resetCells -filter {CONFIG.TYPE == PERIPHERAL && CONFIG.POLARITY == ACTIVE_LOW}] 0]
    }
    
    #   Option C: Grab from PFM.CLOCK cell
    #   NOTE: This is only valid for flat platforms
    if { ($monitorClock == {}) || ($monitorReset == {}) } {
      set clockCell {}
      set traceClock {}
      set traceReset {}
    
      set clockCells [get_bd_cells -quiet -filter {PFM.CLOCK != {}}]
      
      foreach cell $clockCells {
        set clockProperty [get_property PFM.CLOCK $cell]
        
        dict for { key value } $clockProperty {
          set defaultClock [dict_get_default $value is_default {}]
          if { $defaultClock == "true" } {
            set clockCell $cell
            set traceClock $key
            set traceReset [dict_get_default $value proc_sys_reset {}]
            break
          }
        }
        if {$clockCell != {}} {break}
      }
      
      if { ($clockCell == {}) || ($traceClock == {}) || ($traceReset == {}) } { 
        puts "CRITICAL WARNING: Unable to find trace clock or reset cell."
        return $dpa_opts
      }
      
      set monitorClock [get_bd_pins -quiet $clockCell/$traceClock]
      set monitorReset [get_bd_pins -quiet $traceReset/peripheral_aresetn]
      if { ($monitorClock == {}) || ($monitorReset == {}) } { 
        puts "CRITICAL WARNING: Unable to find monitor clock or reset pins."
        return $dpa_opts
      }
    }
    
    #
    # Step 4: AXI-Lite control
    #
    set axiliteMaster [add_master_to_interconnect $masterInterconnect $monitorClock $monitorReset]
    puts $fp "set_property HDL_ATTRIBUTE.DPA_AXILITE_MASTER true \[get_bd_intf_pins $axiliteMaster]"
    
    set controlDict {}
    dict set controlDict MASTER $axiliteMaster
    dict set controlDict CLK_SRC $monitorClock
    dict set controlDict RST_SRC $monitorReset
    dict set dpa_opts AXILITE $controlDict
    
    # Trace info not needed
    if {!$enable_trace} {
      return $dpa_opts
    }
    
    #
    # Step 5: Trace master
    #
    set slrAssignment "SLR0"
    set dedicatedTracePort true
    set traceClock $monitorClock
    set traceReset $monitorReset
    
    set axifullMaster [add_master_to_interconnect $masterInterconnect $traceClock $traceReset]
    puts $fp "set_property HDL_ATTRIBUTE.DPA_TRACE_MASTER $dedicatedTracePort \[get_bd_intf_pins $axifullMaster]"
    if {[get_property -quiet CONFIG.SLR_ASSIGNMENTS $axifullMaster] == {}} {
      puts $fp "set_property CONFIG.SLR_ASSIGNMENTS $slrAssignment \[get_bd_intf_pins $axifullMaster]"
    }
    
    # Define offload dict
    set offloadDict [get_offload_dict $profile_info $dpa_opts]
    dict set offloadDict MASTER $axifullMaster
    dict set offloadDict CLK_SRC $traceClock
    dict set offloadDict RST_SRC $traceReset
    dict set offloadDict SLR $slrAssignment
    dict set offloadDict DEDICATED $dedicatedTracePort
    dict set dpa_opts TRACE_OFFLOAD $offloadDict
    
    return $dpa_opts
  }; # end get_dpa_options_emu_soc
  
  ###########################################################
  # get_dpa_options_emu_versal
  #  Description:
  #    On Versal platforms, collect the meta-data from the passed
  #    in dictionaries.
  #  Arguments:
  #    fp            File pointer for writing
  #    profile_info  Dictionary created from v++ profile options
  #    dpa_opts      Dictionary for BD automation options
  #  Return Value:
  #    An updated dictionary containing options for BD automation
  ###########################################################
  proc get_dpa_options_emu_versal {fp profile_info dpa_opts} {
    variable ::debug_profile::enable_trace
  	
    # Get control interconnect and associated clock and reset
    set intercon {}
    set first_cu_clk {}
    set first_cu_rst {} 
    set cuCells [get_bd_cells -quiet -hier -filter "SDX_KERNEL==true"]
    
    foreach cu $cuCells {
      set axilite_pin [get_bd_intf_pins -quiet -of_objects $cu -filter {CONFIG.PROTOCOL == AXI4LITE && MODE == Slave}]
      set axilite_obj [find_bd_objs -quiet -relation connected_to -stop_at_interconnect -thru_hier $axilite_pin]
      
      if {($axilite_pin != {}) && ($axilite_obj != {})} {
        set intercon [get_bd_cells -quiet -of_objects $axilite_obj]
        set first_cu_clk [bd::clkrst::get_sink_clk $axilite_pin]
        set first_cu_rst [bd::clkrst::get_sink_rst $first_cu_clk]
        break
      }
    }
    puts "--- DEBUG: intercon = $intercon, clock = $first_cu_clk, reset = $first_cu_rst"
    
    # Life cannot go on unless we find an interconnect!
    if {($intercon == {}) || ($first_cu_clk == {})} {
      puts "--- DEBUG: Unable to find an interconnect."
      return $dpa_opts
    }

    # Make another attempt at finding a reset
    if {$first_cu_rst == {}} {
      set clkDriver    [find_bd_objs -quiet -relation connected_to -thru_hier $first_cu_clk]
      set clkSinks     [find_bd_objs -quiet -relation connected_to -thru_hier $clkDriver]
      set resetCells   [get_bd_cells -quiet -of $clkSinks -filter {VLNV=~"*proc_sys_reset*"}]
      set first_cu_rst [lindex [get_bd_pins -quiet -hier -of $resetCells -filter {CONFIG.TYPE == PERIPHERAL && CONFIG.POLARITY == ACTIVE_LOW}] 0]
    }
    
    set axiliteMaster [add_master_to_interconnect $intercon $first_cu_clk $first_cu_rst]
    puts $fp "set_property HDL_ATTRIBUTE.DPA_AXILITE_MASTER true \[get_bd_intf_pins $axiliteMaster]"
    
    set controlDict {}
    dict set controlDict MASTER $axiliteMaster
    dict set controlDict CLK_SRC $first_cu_clk
    dict set controlDict RST_SRC $first_cu_rst
    dict set dpa_opts AXILITE $controlDict
    
    # Trace info not needed
    if {!$enable_trace} {
      return $dpa_opts
    }
    
    # Add an AXI Full master for trace offload (only if needed)
    set axifullMaster [add_master_to_interconnect $intercon $first_cu_clk $first_cu_rst]
      
    set slrAssignment "SLR0"
    set dedicatedTracePort true
    puts $fp "set_property HDL_ATTRIBUTE.DPA_TRACE_MASTER $dedicatedTracePort \[get_bd_intf_pins $axifullMaster]"
    if {[get_property -quiet CONFIG.SLR_ASSIGNMENTS $axifullMaster] == {}} {
      puts $fp "set_property CONFIG.SLR_ASSIGNMENTS $slrAssignment \[get_bd_intf_pins $axifullMaster]"
    }
    
    #set offloadDict [get_offload_dict $profile_info $dpa_opts]
    dict set offloadDict MEM_SPACE "FIFO"
    dict set offloadDict MEM_INDEX 0

    set traceDepth [dict_get_default $profile_info FIFO 8192]
    dict set offloadDict DEPTH $traceDepth
    
    # Get trace slave
    # NOTE: Find the first one that already has an AXI slave
    set nocs [get_bd_cells -quiet -filter {VLNV=~"*axi_noc*"}]
    set traceSlave {}
    foreach noc $nocs {
      set slavePins [get_bd_intf_pins -quiet -of_objects $noc -filter {CONFIG.PROTOCOL == AXI4 && MODE == Slave}]
      if {$slavePins != {}} {
        set traceSlave $noc
        break
      }
    }
    if {$traceSlave != {}} {
      #puts "traceSlave = $traceSlave"
      dict set offloadDict SLAVE $traceSlave
      puts $fp "set_property HDL_ATTRIBUTE.DPA_TRACE_SLAVE true \[get_bd_cells $traceSlave]"
    }
          
    dict set offloadDict MASTER $axifullMaster
    dict set offloadDict CLK_SRC $first_cu_clk
    dict set offloadDict RST_SRC $first_cu_rst
    dict set offloadDict SLR $slrAssignment
    dict set offloadDict DEDICATED $dedicatedTracePort
    dict set dpa_opts TRACE_OFFLOAD $offloadDict

    return $dpa_opts
  }; # end get_dpa_options_emu_versal
  
  ###########################################################
  # get_dpa_options_emu_pcie
  #  Description:
  #    On PCIe platforms, collect the meta-data from the passed
  #    in dictionaries.
  #    TODO: remove dependency on xdp_platform_info
  #  Arguments:
  #    fp            File pointer for writing
  #    profile_info  Dictionary created from v++ profile options
  #    dpa_opts      Dictionary for BD automation options
  #  Return Value:
  #    An updated dictionary containing options for BD automation
  ###########################################################
  proc get_dpa_options_emu_pcie {fp profile_info dpa_opts} {
    global xdp_platform_info
    variable ::debug_profile::enable_trace

    # For PCIe platforms, the information is taken from $xdp_platform_info
    # TODO: Post-2019.2, remove these dependencies!
    set axiliteMasterName [dict_get_default $xdp_platform_info AXILITE_MASTER {}]
    if {[get_bd_intf_ports -quiet $axiliteMasterName] != {}} {
      set axiliteMaster    [get_bd_intf_ports -quiet $axiliteMasterName]
    } else {
      set axiliteMaster    [get_bd_intf_pins -quiet $axiliteMasterName]
    }
    
    set traceClock        [dict_get_default $xdp_platform_info TRACE_CLOCK {}]
    set traceReset        [dict_get_default $xdp_platform_info TRACE_RESET {}]
    set axifullMaster [dict_get_default $xdp_platform_info AXIMM_MASTER {}]
    #if {[get_bd_intf_ports -quiet $axifullMasterName] != {}} {
    #  set axifullMaster    [get_bd_intf_ports -quiet $axifullMasterName]
    #} else {
    #  set axifullMaster    [get_bd_intf_pins -quiet $axifullMasterName]
    #}
    
    set hostMasters        [dict_get_default $xdp_platform_info HOST_MASTERS {}]
    set dedicatedTracePort [dict_get_default $xdp_platform_info DEDICATED_MASTER true]
    set slrAssignment      [dict_get_default $xdp_platform_info SLR_ASSIGNMENT "SLR0"]
    
    set monitorClock       [get_bd_pins -quiet [dict_get_default $xdp_platform_info MONITOR_CLOCK {}]]
    set monitorReset       [get_bd_pins -quiet [dict_get_default $xdp_platform_info MONITOR_RESET {}]]
    
    # AXI-Lite control
    set axiliteClock   [bd::clkrst::get_sink_clk $axiliteMaster]
    set axiliteReset   [bd::clkrst::get_src_rst  $axiliteClock]
    if {$axiliteReset == {}} {
      set axiliteSink  [bd::clkrst::get_sink_rst $axiliteClock]
      set axiliteReset [find_bd_objs -quiet -relation connected_to -thru_hier $axiliteSink]
    }
    
    remove_all_slaves $axiliteMaster
    #set controlInterconnect [replace_null_object_with_interconnect $axiliteMaster 0 $monitorClock $monitorReset $axiliteClock $axiliteReset]
    #Add new port to Interconnect for EMulation
    set axiliteInterconnect [get_bd_cells -quiet -of_objects $axiliteMaster]
    set axiliteclknet [find_bd_objs -relation connected_to $axiliteClock]
    set axiliterstnet [find_bd_objs -relation connected_to $axiliteReset]
    set axiliteMaster [add_master_to_interconnect_emu $axiliteInterconnect $axiliteclknet $axiliteReset]
    puts "AXI-Lite: master = $axiliteMaster, clock = $axiliteClock, reset = $axiliteReset"

    puts $fp "set_property HDL_ATTRIBUTE.DPA_AXILITE_MASTER true \[get_bd_intf_pins $axiliteMaster]"
    
    set controlDict {}
    dict set controlDict MASTER $axiliteMaster
    dict set controlDict CLK_SRC $axiliteClock
    dict set controlDict RST_SRC $axiliteReset
    dict set dpa_opts AXILITE $controlDict
    
    # Trace info not needed
    if {!$enable_trace} {
      return $dpa_opts
    }
    
    set axifullClock  [dict_get_default $xdp_platform_info TRACE_CLOCK {}]
    set axifullReset  [dict_get_default $xdp_platform_info TRACE_RESET {}]
    if {$axifullClock == {}} { set axifullClock $traceClock }
    if {$axifullReset == {}} { set axifullReset $traceReset }

    set traceMaster [get_bd_cells -quiet -filter {NAME=~"xtlm_simple_intercon_0"}]

    if {$traceMaster != {}} {
      set n_mi [get_property CONFIG.C_NUM_MI $traceMaster]
      set_property CONFIG.C_NUM_MI [expr $n_mi + 1] $traceMaster
      if {$n_mi <= 10} {
        set n_mi "0${n_mi}"
      }
      set_property CONFIG.C_M${n_mi}_AXI_DATA_WIDTH 64 $traceMaster
      
      #set the address map...this is going to be on fixed address
      set_property -dict [list CONFIG.C_M${n_mi}_A00_BASE_ADDRESS {0x0000008000000000} CONFIG.C_M${n_mi}_A00_ADDR_RANGE {0x0000000000400000}] $traceMaster
      set mst_clk [get_bd_pins $traceMaster/m${n_mi}_axi_aclk]
      set mst_rst [get_bd_pins $traceMaster/m${n_mi}_axi_aresetn]
      connect_bd_net $mst_clk [get_bd_pins $traceMaster/s00_axi_aclk]
      connect_bd_net $mst_rst [get_bd_pins $traceMaster/s00_axi_aresetn]
      set axifullMaster [get_bd_intf_pins $traceMaster/M${n_mi}_AXI]
      set axifullClock $mst_clk
      set axifullReset $mst_rst
    }
    set base_addr_seg 0x0000008000000000
    set base_addr_range 0x0000000000400000
    puts "AXI Full: master = $axifullMaster, clock = $axifullClock, reset = $axifullReset"

    # Add TRACE_OFFLOAD dictionary to options
    #set offloadDict [get_offload_dict_emu $profile_info $dpa_opts]

    set traceSlave [get_bd_cells -quiet -filter {VLNV=~"*sdx_memory_subsystem*"}] 
    if {$traceSlave != {}} {
      dict set offloadDict SLAVE $traceSlave
      puts $fp "set_property HDL_ATTRIBUTE.DPA_TRACE_SLAVE true \[get_bd_cells $traceSlave]"
    }

    # TODO: Code below always uses FIFO. Should we honor other offload types?
    dict set offloadDict MASTER $axifullMaster
    dict set offloadDict CLK_SRC $axifullClock
    dict set offloadDict RST_SRC $axifullReset
    dict set offloadDict SLR $slrAssignment
    dict set offloadDict DEDICATED $dedicatedTracePort
    dict set offloadDict MEM_SPACE "FIFO"
    dict set offloadDict MEM_INDEX 0
    dict set offloadDict FIFO_ADDR_SEG $base_addr_seg
    dict set offloadDict FIFO_ADDR_RANGE $base_addr_range

    set traceDepth [dict_get_default $profile_info FIFO 8192]
    dict set offloadDict DEPTH $traceDepth
   
    dict set dpa_opts TRACE_OFFLOAD $offloadDict
 
    return $dpa_opts
  }; # end get_dpa_options_emu_pcie

  #################################################################################################
  ######                              Dictionary/Insertion                                    #####
  #################################################################################################
  
  ##################################################################
  # insert_profile_ip_soc_hwemu
  #  Description: 
  #   Specific for SoC platforms, add the appropriate profiling IP
  #  Arguments:
  #    hw_platform_info   HW platform dict           - Unused
  #    config_info        configuration dict
  #    debug_profile_info debug/profile dict - Unused
  ##################################################################
  proc insert_profile_ip_soc_hwemu {hw_platform_info config_info debug_profile_info} {
    set output_dir [dict get $config_info output_dir]
    
    # On SoC platforms, monitor DDR banks only
    if { [catch {add_axi_perf_mons_banks} catch_res] } {
      ocl_util::error2file $output_dir "Could not add axi profilers on ddr banks in hw_em" $catch_res
    }
  }; # end insert_profile_ip_soc_hwemu

  ##################################################################
  # insert_profile_ip_pcie_hwemu
  #  Description:
  #   Specific for PCIe platforms, add the appropriate profiling IP
  #  Arguments:
  #    hw_platform_info   HW platform dict   - Unused
  #    config_info        configuration dict
  #    debug_profile_info debug/profile dict - Unused
  #    fp                 insert_debug_profiling.tcl
  ##################################################################
  proc insert_profile_ip_pcie_hwemu {hw_platform_info config_info debug_profile_info fp} {
    # On PCIe platforms, monitor CU ports and CUs if profiling is turned on
    set hw_emu_profiling   [dict get $config_info hw_emu_profiling]
    set dpa_dict {}

    if {$hw_emu_profiling} {
      set output_dir [dict get $config_info output_dir]

      #if { [catch {add_axi_perf_mons_ports $fp $dpa_dict} catch_res] } {
       # ocl_util::error2file $output_dir "Could not add axi profilers on access ports in hw_em" $catch_res
      #}
      set dpa_dict [add_axi_perf_mons_ports $fp $dpa_dict $config_info]
      #if { [catch {add_accel_mons} catch_res] } {
      #  ocl_util::error2file $output_dir "Could not add accel profilers in hw_em" $catch_res
      #}
      set dpa_dict [add_accel_mons $fp $dpa_dict $config_info]
    } 
    return $dpa_dict
  }; # end insert_profile_ip_pcie_hwemu

  ################################################################################
  # add_axi_perf_mons_banks
  #   Description:
  #     Add profiling for DDR banks (soc platforms; HW emulation only)
  #     NOTE: BD of dynamic region is assumed to be open
  #   Arguments:
  #     none
  ################################################################################
  proc add_axi_perf_mons_banks {} {
    #TODO : Remove this block once generic pcie flow is available
    #get_bd_cell of sdaccel_generic_pcie
    set sdaccel_gen_pcie [get_bd_cells * -filter {VLNV=~xilinx.com:ip:sdaccel_generic_pcie:*} -quiet]
    if { [llength $sdaccel_gen_pcie] > 0 } { 
      set ddr0_ui_clk [get_bd_cells ddr0_ui_clk -quiet]
      set numGlobalMemories [get_property CONFIG.NUMBER_OF_GLOBAL_MEMORIES $sdaccel_gen_pcie]
      for {set i 0} {$i < 4} {incr i} {
        set perf_mon [ create_bd_cell -type ip -vlnv xilinx.com:Debug:sim_axi_perf_mon:1.0 sim_axi_perf_mon_${i} ]
        set_property -dict [list CONFIG.MONITOR_ID BANK${i}] $perf_mon

        connect_bd_net [get_bd_pins sim_axi_perf_mon_${i}/axi_aclk] [get_bd_pins $ddr0_ui_clk/clk]
        connect_bd_net [get_bd_pins sim_axi_perf_mon_${i}/axi_aresetn] [get_bd_pins $ddr0_ui_clk/sync_rst]
        connect_bd_intf_net [get_bd_intf_pins $perf_mon/MON_AXI] [get_bd_intf_pins $sdaccel_gen_pcie/C${i}_DDR_SAXI]
      }
    } else {
      set ddrx [get_bd_cells * -filter {VLNV=~ xilinx.com:user:ddrx:*} -quiet]
      if { [llength $ddrx] > 0 } { 
        set ddr0_ui_clk [get_bd_cells ddr0_ui_clk -quiet]
        set numGlobalMemories [get_property CONFIG.C_NUMBER_OF_GLOBAL_MEMORIES $ddrx]
        for {set i 0} {$i < 4} {incr i} {
          set perf_mon [ create_bd_cell -type ip -vlnv xilinx.com:Debug:sim_axi_perf_mon:1.0 sim_axi_perf_mon_${i} ]
          set_property -dict [list CONFIG.MONITOR_ID BANK${i}] $perf_mon
  
          connect_bd_net [get_bd_pins sim_axi_perf_mon_${i}/axi_aclk] [get_bd_pins $ddr0_ui_clk/clk]
          connect_bd_net [get_bd_pins sim_axi_perf_mon_${i}/axi_aresetn] [get_bd_pins $ddr0_ui_clk/sync_rst]
          connect_bd_intf_net [get_bd_intf_pins $perf_mon/MON_AXI] [get_bd_intf_pins $ddrx/C${i}_DDR_SAXI]
        }
      }
    }
  }; # end add_axi_perf_mons_banks

  ################################################################################
  # add_axi_perf_mons_ports
  #   Description:
  #     Add profiling for accelerator ports (pcie platforms; HW emulation only)
  #     NOTE: BD of dynamic region is assumed to be open
  #   Arguments:
  #     fp  insert_debug_profiling.tcl
  ################################################################################
  proc add_axi_perf_mons_ports {fp dpa_dict config_info} {
    global hw_platform_info
    variable ::debug_profile::port_mem_sep
    variable ::debug_profile::kdma_monitor_name
    variable ::debug_profile::shell_monitor_prop
    variable ::debug_profile::ip_layout_host_name
    variable ::debug_profile::ip_layout_pipe_name
    set is_system_dpa  [dict_get_default $config_info system_dpa_enabled true]
  	
    set i 0
    set monitor_reset [dict_get_default $hw_platform_info MONITOR_RESET {}]
    
    # Find all compute units in the design
    # NOTE: using the -hier option also catches the copy kernels in the static region
    set cu_instances [get_bd_cells -quiet -hier -filter "SDX_KERNEL==true"]
    
    # Find all CU masters and slaves
    set cu_masters [get_bd_intf_pins -quiet -of $cu_instances -filter "Mode==Master"]
    set cu_slaves [get_bd_intf_pins -quiet -of $cu_instances -filter "Mode==Slave"]
    
    #
    # Slaves: Add SSPMs on streams
    #
    puts "--- DEBUG: Adding CU slave monitors..."
    
    foreach slave $cu_slaves {
    	# Catch AXI Streams
      if {[string first axis [get_property -quiet VLNV $slave]] >= 0} {
        set portObj [get_bd_intf_pins $slave]
        set portEp [find_bd_objs -relation connected_to $portObj]
        set nameEp [get_bd_cells -of_objects $portEp]

        # Three types of connections are possible here
        # (1) Pipe (2) Stream connection to Host (3) Kernel to Kernel stream
        if {[is_stream_connected_to_pipe $portObj]} {
          # Pipe
          set portEp $ip_layout_pipe_name
        } elseif {![get_property -quiet SDX_KERNEL $nameEp]} {
          # if connected object is not a "Kernel", then this stream connection is to a Host
          set portEp $ip_layout_host_name
        } else {
          # Kernel 2 Kernel stream connection. SSPM should be inserted on the Master. So, skip inserting on slave. 
          continue
        }

        set numMons [llength [find_bd_objs -relation connected_to -end_type monitor $portObj]]
        if {$numMons >= 1} { continue }

        # Fullname is of format: "Master-Slave"
        # Find endpoint of the port
        set MasterName [string trim $portEp "/"]
        set SlaveName [string trim $portObj "/"]
        variable ::debug_profile::port_mem_sep
        set    fullName $MasterName
        append fullName $port_mem_sep
        append fullName $SlaveName

        set monId [string map {"/" ":"} $fullName]
        
        if {[string is false $is_system_dpa]} {
          puts "SSPM SLAVE: start sitching slave streaming monitor ..."
          set monName "sim_axi_stream_perf_mon_${i}"
          puts "SSPM SLAVE: Adding monitor $monName to CU slave $slave..."
          set str_mon [create_bd_cell -type ip -vlnv xilinx.com:Debug:sim_axi_stream_perf_mon:1.0 $monName]
          puts "SSPM SLAVE: setting monitor ID $monId"
          set_property -dict [list CONFIG.MONITOR_ID $monId ] $str_mon

          # "Slave"
          set monitorPinProperty 1
          set properties [expr ($monitorPinProperty << 1) ]
          #add_debug_ip AXI_STREAM_MONITOR $str_mon $fullName $properties
          set_property HDL_ATTRIBUTE.DPA_IP            true        $str_mon
          set_property HDL_ATTRIBUTE.DPA_IP_PROPERTIES $properties $str_mon
          set_property HDL_ATTRIBUTE.DPA_IP_FULLNAME   $fullName   $str_mon
        }

        set monClock [get_clk_from_intf_pin $slave]
        set monReset [get_reset_from_intf_pin $slave]

        if {$monReset eq ""} {
          puts "SSPM SLAVE WARNING: using default reset in emulation flow"
          set monReset [get_bd_pins $monitor_reset]
        }

        puts "SSPM SLAVE: using clock: $monClock and reset: $monReset"
        #Add dpa_dict 
        set pinDict {}
        dict set pinDict TYPE "data"
        dict set pinDict DETAIL "all"
        dict set pinDict MEMORY "stream"

        dict set pinDict CLK_SRC $monClock
        dict set pinDict RST_SRC $monReset
        dict set pinDict MON_ID $monId
        set keyName "\[get_bd_intf_pins $slave]"
        dict set dpa_dict $keyName $pinDict
        if {[string is false $is_system_dpa]} {
          connect_bd_net [get_bd_pins sim_axi_stream_perf_mon_${i}/axi_aclk] [get_bd_pins $monClock]
          connect_bd_net [get_bd_pins sim_axi_stream_perf_mon_${i}/axi_aresetn] [get_bd_pins $monReset]
          connect_bd_intf_net [get_bd_intf_pins $str_mon/MON_AXI_STRM] [get_bd_intf_pins $slave]
          }
        incr i
      }
    }
    
    #
    # Masters: Add SPMs on AXI-MM or SSPMs on streams 
    #
    puts "--- DEBUG: Adding CU master monitors..."
    
    foreach master $cu_masters {
      if {[string first axis [get_property -quiet VLNV $master]] < 0} {
        set currSegs [get_bd_addr_segs -of_objects $master]
      
        # Calculate number of monitors (1 per memory type) and their min/max addresses for filtering
        # NOTE: the code below assumes a contiguous address space across each memory type 
        if {[llength $currSegs] <= 1} { 
          set numMonitors 1
        } else {
          set minAddresses {}
          set maxAddresses {}
          foreach seg $currSegs {
            set minAddress [get_property offset $seg]
            set range      [get_property range $seg]
            set maxAddress [format 0x%X [expr $minAddress + $range - 1]]
            #puts "--- DEBUG: Calculating # of monitors: min = $minAddress, max = $maxAddress, seg = $seg"
            
            # Get min/max addresses (must be in hex format, e.g., 0xDEADCAFE))
            set memoryResource [get_memory_from_addr_seg $seg]
            if {[dict exists $minAddresses $memoryResource]} {
              set currMin [dict get $minAddresses $memoryResource]
              set newMin [expr {($currMin < $minAddress) ? $currMin : $minAddress}]
              dict set minAddresses $memoryResource [format 0x%X $newMin]
              
              set currMax [dict get $maxAddresses $memoryResource]
              set newMax [expr {($currMax > $maxAddress) ? $currMax : $maxAddress}]
              dict set maxAddresses $memoryResource [format 0x%X $newMax]
            } else {
              dict set minAddresses $memoryResource [format 0x%X $minAddress]
              dict set maxAddresses $memoryResource [format 0x%X $maxAddress]
            }
          }
          
          set numMonitors [llength [dict keys $minAddresses]]
          puts "--- DEBUG: minAddresses = $minAddresses"
          puts "--- DEBUG: maxAddresses = $maxAddresses"  
        }
	        
        ###############################################
        ################New Dict for BD Automation####
        set pinDict {}
        dict set pinDict TYPE "data"
        dict set pinDict DETAIL "all"
        set monClock [get_clk_from_intf_pin $master]
        set monReset [get_reset_from_intf_pin $master]
        dict set pinDict CLK_SRC $monClock
        dict set pinDict RST_SRC $monReset
          
	      # Compile all memory resources attached to this pin
	      set monIds {}
        set memoryName {}
        set minAddress {}
        set maxAddress {}
         
        # Add a monitor for every memory type on this port (e.g., DDR, PLRAM)
        for { set m 0 } { $m < $numMonitors } { incr m } {
          set monName "sim_axi_perf_mon2_${i}"
          if {[string is false $is_system_dpa]} {
            puts "--- DEBUG: Adding monitor $monName to CU master $master..."
            set perf_mon [create_bd_cell -type ip -vlnv xilinx.com:Debug:sim_axi_perf_mon:1.0 $monName]
          }
          # Get full name and specify address filtering (if needed)

          # Catch kernels found in shell   
          # NOTE: assume all CUs found in static region are copy kernels (KDMA)
          if {[string first "static_region" $master] >= 0} {
            set fullName $kdma_monitor_name
            set properties $shell_monitor_prop
          } else {
            set fullName $master
            set properties $i
          
            # Specify address filtering if multiple monitors
            if {$numMonitors > 1} {
              set memoryResource [lindex [dict keys $minAddresses] $m]
              set memoryIndices [get_memory_indices_from_addr_segs $currSegs $memoryResource]
            
              # Set min/max addresses
              set minAddr [dict get $minAddresses $memoryResource]
              set maxAddr [dict get $maxAddresses $memoryResource]
              lappend minAddress $minAddr
              lappend maxAddress $maxAddr
              puts "--- DEBUG: Address filtering for $master: min = $minAddr, max = $maxAddr, memory = $memoryResource"
              
              if {[string is false $is_system_dpa]} {
                # Enable and set address filtering
                # NOTE: these properties are used in RPC call
                set_property CONFIG.ENABLE_ADDR_FILTER 1        $perf_mon
                set_property CONFIG.ADDR_MIN           $minAddr $perf_mon
                set_property CONFIG.ADDR_MAX           $maxAddr $perf_mon
              }
            } else {
              set memoryResource [get_memory_from_addr_seg [lindex $currSegs 0]]
              set memoryIndices [get_memory_indices_from_addr_segs $currSegs $memoryResource]
            }
          
            # Append memory name to port name
            set memName $memoryResource
            if {$memoryIndices != ""} {
              append memName "\[${memoryIndices}\]"
            }
            append fullName $port_mem_sep
            append fullName $memName
            
            lappend memoryName $memName
          }
        
        
          # This property is used in RPC call
          set monId [string trimleft $fullName "/"]
          set monId [string map {"/" ":"} $monId]
          lappend monIds $monId
          if {[string is false $is_system_dpa]} {
            puts "--- DEBUG: setting monitor ID $monId"
            set_property -dict [list CONFIG.MONITOR_ID $monId ] $perf_mon
            #add_debug_ip AXI_MM_MONITOR $perf_mon $fullName $properties
            set_property HDL_ATTRIBUTE.DPA_IP            true        $perf_mon
            set_property HDL_ATTRIBUTE.DPA_IP_PROPERTIES $properties $perf_mon
            set_property HDL_ATTRIBUTE.DPA_IP_FULLNAME   $fullName   $perf_mon
          
            if {$monReset eq ""} {
              puts "WARNING: using default reset in emulation flow"
              set monReset [get_bd_pins -quiet $monitor_reset]
            }
            puts "--- DEBUG: using clock: $monClock and reset: $monReset"
            connect_bd_net [get_bd_pins sim_axi_perf_mon2_${i}/axi_aclk] [get_bd_pins $monClock]
            if {$monReset ne ""} {
              connect_bd_net [get_bd_pins sim_axi_perf_mon2_${i}/axi_aresetn] [get_bd_pins $monReset]  
            }
            connect_bd_intf_net [get_bd_intf_pins $perf_mon/MON_AXI] [get_bd_intf_pins $master]
          }
          incr i
        }
        
        dict set pinDict MON_ID      $monIds
        dict set pinDict MEMORY      $memoryName
        # Only add to dict if needed for filtering
        if {($minAddress != {}) && ($maxAddress != {})} {
          dict set pinDict MIN_ADDRESS $minAddress
          dict set pinDict MAX_ADDRESS $maxAddress
        }
        set keyName "\[get_bd_intf_pins $master]"
        dict set dpa_dict $keyName $pinDict
      } else {
        # Only insert one monitor per interface net
        set portObj [get_bd_intf_pins $master]
        set portEp [find_bd_objs -relation connected_to $portObj]
        set nameEp [get_bd_cells -of_objects $portEp]

        # Three types of connections are possible here
        # (1) Pipe (2) Stream connection to Host (3) Kernel to Kernel stream (No special handling required here)
        if {[is_stream_connected_to_pipe $portObj]} {
          # Pipe
          set portEp "PIPE" 
        } elseif {![get_property -quiet SDX_KERNEL $nameEp]} {
          # if connected object is not a "Kernel", then this stream connection is to a Host
          set portEp "HOST" 
        }

        set numMons [llength [find_bd_objs -relation connected_to -end_type monitor $portObj]]
        if {$numMons >= 1} { continue }

        puts "SSPM: start sitching master streaming monitor ..."
        set monName "sim_axi_stream_perf_mon_${i}"
        
        # Fullname is of format: "Master-Slave"
        # Find endpoint of the port
        set MasterName [string trim $portObj "/"]
        set SlaveName [string trim $portEp "/"]
        variable ::debug_profile::port_mem_sep
        set    fullName $MasterName
        append fullName $port_mem_sep
        append fullName $SlaveName
        
        set monId [string map {"/" ":"} $fullName]
        if {[string is false $is_system_dpa]} {
          puts "SSPM: Adding monitor $monName to CU master $master..."
          set str_mon [create_bd_cell -type ip -vlnv xilinx.com:Debug:sim_axi_stream_perf_mon:1.0 $monName]
          puts "SSPM MASTER: setting monitor ID $monId"
          set_property -dict [list CONFIG.MONITOR_ID $monId ] $str_mon
          
          # "Master"
          set properties 0
          #add_debug_ip AXI_STREAM_MONITOR $str_mon $fullName $properties
          set_property HDL_ATTRIBUTE.DPA_IP            true        $str_mon
          set_property HDL_ATTRIBUTE.DPA_IP_PROPERTIES $properties $str_mon
          set_property HDL_ATTRIBUTE.DPA_IP_FULLNAME   $fullName   $str_mon
        }
        set monClock [get_clk_from_intf_pin $master]
        set monReset [get_reset_from_intf_pin $master]
        
        if {$monReset eq ""} {
          puts "SSPM WARNING: using default reset in emulation flow"
          set monReset [get_bd_pins $monitor_reset]
        }
        
        puts "SSPM: using clock: $monClock and reset: $monReset"
        #Add dpa_dict 
        set pinDict {}
        dict set pinDict TYPE "data"
        dict set pinDict DETAIL "all"
        dict set pinDict MEMORY "stream"

        dict set pinDict CLK_SRC $monClock
        dict set pinDict RST_SRC $monReset
        dict set pinDict MON_ID $monId
        set keyName "\[get_bd_intf_pins $master]"
        dict set dpa_dict $keyName $pinDict
        if {[string is false $is_system_dpa]} {
          connect_bd_net [get_bd_pins sim_axi_stream_perf_mon_${i}/axi_aclk] [get_bd_pins $monClock]
          connect_bd_net [get_bd_pins sim_axi_stream_perf_mon_${i}/axi_aresetn] [get_bd_pins $monReset]
          connect_bd_intf_net [get_bd_intf_pins $str_mon/MON_AXI_STRM] [get_bd_intf_pins $master]
        }
        incr i
      }
    }      
    return $dpa_dict
  }; # end add_axi_perf_mons_ports

  ################################################################################
  # add_accel_mons
  #   Description:
  #     Add accelerator monitors (HW emulation only)
  #     NOTE: BD of dynamic region is assumed to be open
  #   Arguments:
  #     fp : tcl file
  #     dpa_dict : dict for bd_automation
  ################################################################################
  proc add_accel_mons {fp dpa_dict config_info} {
    set is_system_dpa  [dict_get_default $config_info system_dpa_enabled true]
    global hw_platform_info
    
    set i 0
    set monitor_reset [dict_get_default $hw_platform_info MONITOR_RESET {}]
    
    # Find all compute units in the design
    # NOTE: using the -hier option also catches the copy kernels in the static region
    #set cu_instances [get_bd_cells -quiet -hier -filter "SDX_KERNEL==true"]
    set cu_instances [get_bd_cells -quiet -filter "SDX_KERNEL==true"]
    
    puts "--- DEBUG: Adding accelerator monitors..."
    
    foreach cu $cu_instances {
      # Grab the AXI-Lite slave and associated clock/reset
      set monSlave [lindex [get_bd_intf_pins -quiet -of_objects $cu -filter {CONFIG.PROTOCOL == AXI4LITE && MODE == Slave}] 0]
      if {$monSlave == {}} {
        puts "WARNING: Unable to find AXI-Lite slave on $cu. No accelerator monitor inserted."
        continue
      }
      
      set monClock [get_clk_from_intf_pin $monSlave]
      set monReset [get_reset_from_intf_pin $monSlave]
      if {$monReset eq ""} {
        puts "WARNING: using default reset in emulation flow"
        set monReset [get_bd_pins $monitor_reset]
      }
      puts "--- DEBUG: using clock: $monClock, reset: $monReset, slave: $monSlave"
      
      # If all looks good, then insert monitor
      if {($monSlave ne "") && ($monClock ne "") && ($monReset ne "")} {
        puts "--- DEBUG: adding monitor to CU: $cu"
        set cu_name [string trim $cu "/"]
        if {[string is false $is_system_dpa]} {
          set accel_mon [ create_bd_cell -type ip -vlnv xilinx.com:Debug:sim_sdx_accel_monitor sim_accel_mon_${i}]
        
          # This property is used in RPC call
          set_property -dict [list CONFIG.MONITOR_ID $cu_name] $accel_mon
          #add_debug_ip ACCEL_MONITOR $accel_mon $cu_name $i
          set_property HDL_ATTRIBUTE.DPA_IP            true     $accel_mon
          set_property HDL_ATTRIBUTE.DPA_IP_PROPERTIES $i       $accel_mon
          set_property HDL_ATTRIBUTE.DPA_IP_FULLNAME   $cu_name $accel_mon
          
          connect_bd_net [get_bd_pins $accel_mon/axi_aclk] [get_bd_pins $monClock]
          connect_bd_net [get_bd_pins $accel_mon/axi_aresetn] [get_bd_pins $monReset]
          connect_bd_intf_net [get_bd_intf_pins $accel_mon/MON_AXI] [get_bd_intf_pins $monSlave]
        }
        dict set cuDict TYPE "exec"
        dict set cuDict DETAIL "all"
        dict set cuDict CLK_SRC $monClock
        dict set cuDict RST_SRC $monReset
        set key "\[get_bd_cells $cu_name]"
        dict set dpa_dict $key $cuDict
        incr i
      }
    }
    return $dpa_dict
  }; # end add_accel_mons
  
  ###########################################################
  # get_offload_dict_emu
  #  Description:
  #    Get trace offload dict of options
  #  Arguments:
  #    profile_info  Dictionary created from v++ profile options
  #    dpa_opts      Dictionary for BD automation options
  #  Return Value:
  #    None
  ###########################################################
  proc get_offload_dict_emu {profile_info dpa_opts} {
    # Trace offload settings (shell agnostic)
    # Temporary: depths of 64K or 128K are converted to DDR offload
    set offloadDict {}
    set traceDepth [dict get $profile_info FIFO]
    dict set offloadDict DEPTH $traceDepth
    
    # Always FIFO for emulation
    dict set offloadDict MEM_SPACE "FIFO"
    dict set offloadDict MEM_INDEX 0
      
    set traceMaster [get_bd_intf_pins -quiet -filter {HDL_ATTRIBUTE.DPA_TRACE_MASTER=="true"}]
    if {$traceMaster != {}} {
      dict set offloadDict MASTER $traceMaster
      set traceClock [bd::clkrst::get_sink_clk $traceMaster]
      dict set offloadDict CLK_SRC $traceClock
      dict set offloadDict RST_SRC [bd::clkrst::get_sink_rst $traceClock]
    }
    
    return $offloadDict
  }; # end get_offload_dict_emu

  ###########################################################
  # add_master_to_interconnect_emu
  #  Description:
  #    For a given interconnect object, create a new master AXI port.
  #  Arguments:
  #    interconnect  The interconnect object to add a new master to
  #    masterClock   The clock to connect
  #    masterReset   The reset to connect
  #  Return Value:
  #    The newly added master AXI port
  ###########################################################
  proc add_master_to_interconnect_emu { interconnect masterClock masterReset } {
    #variable ::debug_profile::used_interconnect

    #if { [dict_get_default $used_interconnect $interconnect 1] == 0 } {
    #  dict set used_interconnect $interconnect 1 
    #  set masterPrefix "M00"
    #} else {
      set numMasterPorts [get_property CONFIG.NUM_MI $interconnect]
      set newNumMasterPorts [expr {$numMasterPorts + 1}]
 
      # If we are over 64 ports on this interconnect, stop adding ports.
      set_property CONFIG.NUM_MI $newNumMasterPorts $interconnect

      set masterPrefix [expr { ($numMasterPorts > 9) ? "M${numMasterPorts}" : "M0${numMasterPorts}" } ]
    #}

    # Connect new master clock & reset and add regslices (not applicable to SmartConnect)
    set vlnv [get_property VLNV $interconnect]
    if {[string first "axi_interconnect" $vlnv] >= 0} {
      connect_bd_net $masterClock [get_bd_pins $interconnect/${masterPrefix}_ACLK]
      connect_bd_net $masterReset [get_bd_pins $interconnect/${masterPrefix}_ARESETN]

      set_property CONFIG.${masterPrefix}_HAS_REGSLICE 1 $interconnect
    }

    set newMaster [get_bd_intf_pins $interconnect/${masterPrefix}_AXI]
    return $newMaster
  }; # end add_master_to_interconnect_emu

}; # end namespace
