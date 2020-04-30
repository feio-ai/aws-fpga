
###########################################################
# This file will write to a Tcl script to instantiate and 
#  stitch together IP for hardware (and eventually hardware 
#  emulation) designs that request profiling.
###########################################################

# Dependencies
# This code relies on the following APIs from IPI automation:
#   bd::clkrst::get_sink_clk [get_bd_intf_pins <intf_pin>]
#   bd::clkrst::get_sink_rst [get_bd_pins <clk-pin>]

namespace eval debug_profile {

  # Global variables
  variable enable_trace false
  
  ###########################################################
  # add_debug_profile
  #  Description:
  #    Top level function to write script that adds debug/profiling to the BD
  #  Arguments:
  #    fp                   File pointer for writing
  #    config_info          Configuration dict
  #    debug_profile_info   Debug/profile dict
  #  Return Value:
  #    None
  ###########################################################
  proc add_debug_profile {fp config_info debug_profile_info} {
    # Before we do anything, save the current state of the bd design
    #  in case we have to revert our changes
    save_bd_design

    variable ::debug_profile::source_dir
    set output_dir [dict get $config_info output_dir]
    if {$debug_profile_info == {}} {
      ocl_util::warning2file $output_dir "WARNING: No debug/profile information found."
    }

    # Collect all debug/profiling metadata from command line and HW platform
    set dpa_dict [get_dpa_dictionary $fp $debug_profile_info]
    if {$dpa_dict == {}} {
      ocl_util::warning2file $output_dir "WARNING: No monitor points found for BD automation."
    }
    
    set dpa_opts {}
    set profile_info [dict_get_default $debug_profile_info profile {}]
        
    # AIE Settings (if specified)
    set dpa_opts [get_dpa_options_aie $profile_info $dpa_opts]
          
    # Only get rest of options if needed
    if {$dpa_dict != {}} {
      set dpa_opts [get_dpa_options $fp $config_info $profile_info $dpa_opts $output_dir]
      if {$dpa_opts == {}} {
        ocl_util::warning2file $output_dir "WARNING: No options found for BD automation."
      }
    }
    
    # NOTE: Add call to BD automation rule (and associated dicts, etc.)
    puts $fp "\n# Call debug/profiling automation"
    puts $fp "set dpa_dict \[list \\"
    foreach { key value } $dpa_dict {
      set printable_name [dict_get_default $value PRINTABLE_KEY {}]
      if { $printable_name != {} } {
        puts $fp "              $printable_name  {$value} \\"
      }
    }
    puts $fp "             \]"
    
    puts $fp "set dpa_opts \[list \\"
    foreach { key value } $dpa_opts {
      puts $fp "              $key  {$value} \\"
    }
    puts $fp "             \]\n"
  
    # Uncomment the next two lines to debug any issues  
    #puts $fp "debug::add_scope DBG_PROFILE"
    #puts $fp "debug::set_visibility 5"
    
    puts $fp "set_param bd.enable_dpa 1"
    puts $fp "set_param bd.debug_profile.script $source_dir/debug_profile_automation.tcl"
    puts $fp "apply_bd_automation -rule xilinx.com:bd_rule:debug_profile -opts \$dpa_opts -dict \$dpa_dict"

    # If the bd_automation didn't actually insert any IP, revert our changes
    puts $fp "\n# If no IP inserted, then revert all changes"
    puts $fp "if {\[get_bd_cells -hier -quiet dpa_*] == {}} {"
    puts $fp "  set currDesignFile \[get_bd_files \[current_bd_design]]" 
    puts $fp "  close_bd_design \[current_bd_design]"
    puts $fp "  open_bd_design \$currDesignFile"
    puts $fp "}"
  }; # end add_debug_profile

  #################################################################################################
  ######                                       Helpers                                        #####
  #################################################################################################
  
  ###########################################################
  # get_cu_dict
  #  Description:
  #    Create a dict for a given CU
  #  Arguments:
  #    type    Type of specified CU profiling (exec or stall)
  #    detail  Detail option (counters or all)
  #    cuName  Name of CU  
  #  Return Value:
  #    A dictionary containing all relevant CU information
  ###########################################################
  proc get_cu_dict {type detail cuName} {
  	variable ::debug_profile::enable_trace
    if {$detail eq "all"} {
      set enable_trace true
    }
        
    set cuDict {}
    dict set cuDict TYPE $type
    dict set cuDict DETAIL $detail
    # TODO: is this correct to use the first clock/reset?
    dict set cuDict CLK_SRC [lindex [get_bd_pins -quiet -of [get_bd_cells $cuName] -filter {TYPE == clk}] 0]
    dict set cuDict RST_SRC [lindex [get_bd_pins -quiet -of [get_bd_cells $cuName] -filter {TYPE == rst}] 0]
    return $cuDict
  }; # end get_cu_dict

  ###########################################################
  # get_offload_dict
  #  Description:
  #    Get trace offload dict of options
  #  Arguments:
  #    profile_info  Dictionary created from v++ profile options
  #    dpa_opts      Dictionary for BD automation options
  #  Return Value:
  #    None
  ###########################################################
  proc get_offload_dict {profile_info dpa_opts} {
    # Trace offload settings (shell agnostic)
    # Temporary: depths of 64K or 128K are converted to DDR offload
    set offloadDict {}
    
    # Differentiate between memory resources
    # We have to be explicit here because we want to support
    # only one of the following memory types
    set isFIFO  [dict exists $profile_info FIFO]
    set isHBM   [dict exists $profile_info HBM]
    set isPLRAM [dict exists $profile_info PLRAM]
    set isDDR   [dict exists $profile_info DDR]
    set isACP   [dict exists $profile_info ACP]
    set isMIG   [dict exists $profile_info MIG]
    set isHP false
    set hpMemoryName ""
    set isNOC false
    set nocMemoryName ""
    set banknum 0
    
    foreach key [dict keys $profile_info] {
      # DDR can be called bank*
      if {[string match "bank*" $key]} {
        set isDDR true
        set banknum [string range $key 4 end]
      }
      
      # Embedded platforms
      if {[string first "HP" $key] >= 0} {
        set hpMemoryName $key
        set isHP true
      }
      
      # Versal platforms
      if {[string first "NOC" $key] >= 0} {
        set nocMemoryName $key
        set isNOC true
      }
      if {[string match "MEMORY" $key]} {
        set nocMemoryName MC_NOC0
        set isNOC true
      }
    }
    
    # Okay, let's default to a FIFO
    if {!$isFIFO && !$isDDR && !$isHBM && !$isPLRAM && !$isHP && !$isNOC && !$isACP && !$isMIG} {
      #return $offloadDict
      puts "WARNING: Did not recognize trace memory option. Using FIFO as default."
      set isFIFO true
    }

    if {$isFIFO} {
      set traceDepth [dict_get_default $profile_info FIFO 8192]
      dict set offloadDict DEPTH $traceDepth
      dict set offloadDict MEM_SPACE "FIFO"
      dict set offloadDict MEM_INDEX 0
      
      set traceMaster [get_bd_intf_pins -quiet -filter {HDL_ATTRIBUTE.DPA_TRACE_MASTER=="true"}]
      if {$traceMaster != {}} {
        dict set offloadDict MASTER $traceMaster
        set traceClock [bd::clkrst::get_sink_clk $traceMaster]
        dict set offloadDict CLK_SRC $traceClock
        dict set offloadDict RST_SRC [bd::clkrst::get_sink_rst $traceClock]
      }
    } else {
    	set memory_type "DDR"
      if {$isHBM}   {set memory_type "HBM"}
      if {$isPLRAM} {set memory_type "PLRAM"}
      if {$isHP}    {set memory_type "HP"}
      if {$isACP}   {set memory_type "ACP"}
      if {$isMIG}   {set memory_type "MIG"}
      # NOTE: When trace_memory = bank*, the value reported is banknum
      set memory_bank [dict_get_default $profile_info $memory_type $banknum]
      set tmp [get_address_space_from_memory_type $memory_type $memory_bank]
    	
      dict set offloadDict MEM_SPACE [lindex $tmp 0]
      dict set offloadDict MEM_INDEX [lindex $tmp 1]
      dict set offloadDict MEM_TYPE $memory_type
      
      set traceSlave [get_bd_intf_pins -quiet -filter {HDL_ATTRIBUTE.DPA_TRACE_SLAVE=="true"}]
      if {$traceSlave != {}} {
        dict set offloadDict SLAVE $traceSlave
        set traceClock [bd::clkrst::get_sink_clk $traceSlave]
        dict set offloadDict CLK_SRC $traceClock
        dict set offloadDict RST_SRC [bd::clkrst::get_sink_rst $traceClock]
      }
    }
    return $offloadDict
  }; # end get_offload_dict
    
  ###########################################################
  # add_nondedicated_interconnect
  #  Description:
  #    On platforms that do not have a dedicated port for
  #    our trace infrastructure, tap onto the same AXI-full port that
  #    is used for host traffic and create the interconnect infrastructure
  #    that we can tap onto.
  #  Arguments:
  #    hostMasters   A list of host master AXI pins/ports
  #  Return Value:
  #    A master interface pin to connect to
  ###########################################################
  proc add_nondedicated_interconnect { hostMasters } {
  	if {$hostMasters == {}} {
  	  return ""
  	}
  	
    # Find the appropriate AXI-Full net and ports based off of
    #  what the meta-data specified as host connections
    set hostMaster [lindex $hostMasters 0]
    set hostClock [bd::clkrst::get_sink_clk $hostMaster]
    set hostReset [bd::clkrst::get_sink_rst $hostClock]
    #puts "Adding interconnect to non-dedicated host master $hostMaster (clock: $hostClock, reset: $hostReset)"
    
    set hostNet    [get_bd_intf_nets -of_objects [get_bd_intf_pins $hostMaster]]
    set hostSlave  [get_bd_intf_pins -of_objects $hostNet -filter {MODE == Slave}]
    
    # If specified master is connected to interconnect, then let's use that
    set hostIntercon [get_bd_cells -quiet -of_objects $hostSlave -filter {VLNV =~ *connect*}]
    if {$hostIntercon != {}} {
      set newMaster [add_master_to_interconnect $hostIntercon $hostClock $hostReset]
      return $newMaster
    }
    
    # Remove the net, and replace it with an interconnect
    delete_bd_objs $hostNet 

    set interconnectName "added_host_interconnect"
    set interconnectObject [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect $interconnectName]
    set_property CONFIG.NUM_SI 1 $interconnectObject
    set_property CONFIG.NUM_MI 2 $interconnectObject

    # Connect the clock and reset of the interconnect
    connect_bd_net [get_bd_pins $hostClock] [get_bd_pins $interconnectName/aclk]
    connect_bd_net [get_bd_pins $hostReset] [get_bd_pins $interconnectName/aresetn]

    # Connect the original AXI-Full master with the slave on the interconnect
    connect_bd_intf_net [get_bd_intf_pins $hostMaster] [get_bd_intf_pins $interconnectName/S00_AXI]
    connect_bd_net [get_bd_pins $hostClock] [get_bd_pins $interconnectName/S00_ACLK]
    connect_bd_net [get_bd_pins $hostReset] [get_bd_pins $interconnectName/S00_ARESETN]

    # Instantiate the register slice to go between the interconnect
    # and the original slave port to maintain the data and address widths
    set hostDataWidth [get_property -quiet CONFIG.DATA_WIDTH [get_bd_intf_pins $hostMaster]]
    if { $hostDataWidth == {} } {
      # Default
      set hostDataWidth 512
    }
    set hostAddrWidth [get_property -quiet CONFIG.ADDR_WIDTH [get_bd_intf_pins $hostMaster]]
    if { $hostAddrWidth == {} } {
      # Default
      set hostAddrWidth 32
    }
    
    set regSliceName "added_host_regslice"
    set regSliceObject [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice $regSliceName]
    set_property CONFIG.DATA_WIDTH.VALUE_SRC USER           $regSliceObject
    set_property CONFIG.DATA_WIDTH           $hostDataWidth $regSliceObject
    set_property CONFIG.ADDR_WIDTH.VALUE_SRC USER           $regSliceObject
    set_property CONFIG.ADDR_WIDTH           $hostAddrWidth $regSliceObject
    set_property CONFIG.REG_AW               0              $regSliceObject
    set_property CONFIG.REG_AR               0              $regSliceObject
    set_property CONFIG.REG_W                0              $regSliceObject
    set_property CONFIG.REG_R                0              $regSliceObject
    set_property CONFIG.REG_B                0              $regSliceObject

    connect_bd_net [get_bd_pins $hostClock] [get_bd_pins $regSliceName/aclk]
    connect_bd_net [get_bd_pins $hostReset] [get_bd_pins $regSliceName/aresetn]

    # Connect the interconnect master to the regslice
    connect_bd_intf_net [get_bd_intf_pins $interconnectName/M00_AXI] [get_bd_intf_pins $regSliceName/S_AXI]
    connect_bd_net [get_bd_pins $hostClock] [get_bd_pins $interconnectName/M00_ACLK]
    connect_bd_net [get_bd_pins $hostReset] [get_bd_pins $interconnectName/M00_ARESETN]

    # Connect the regslice to the original slave port
    connect_bd_intf_net [get_bd_intf_pins $regSliceName/M_AXI] $hostSlave

    return $interconnectName/M01_AXI
  }; # end add_nondedicated_interconnect
  
  ###########################################################
  # add_master_to_interconnect
  #  Description:
  #    For a given interconnect object, create a new master AXI port.
  #  Arguments:
  #    interconnect  The interconnect object to add a new master to
  #    masterClock   The clock to connect
  #    masterReset   The reset to connect
  #  Return Value:
  #    The newly added master AXI port
  ###########################################################
  proc add_master_to_interconnect { interconnect masterClock masterReset } {
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
  }; # end add_master_to_interconnect
  
  ###########################################################
  # add_slave_to_interconnect
  #  Description:
  #    For a given interconnect object, create a new slave AXI port.
  #  Arguments:
  #    interconnect  The interconnect object to add a new slave to
  #    slaveClock    The clock to connect
  #    slaveReset    The reset to connect
  #  Return Value:
  #    The newly added slave AXI port
  ###########################################################
  proc add_slave_to_interconnect { interconnect slaveClock slaveReset } {
    set numSlavePorts [get_property CONFIG.NUM_SI $interconnect]
    set newNumSlavePorts [expr {$numSlavePorts + 1}]
 
    # If we are over 64 ports on this interconnect, stop adding ports.
    set_property CONFIG.NUM_SI $newNumSlavePorts $interconnect

    set slavePrefix [expr { ($numSlavePorts > 9) ? "S${numSlavePorts}" : "S0${numSlavePorts}" } ]

    # Connect new slave clock & reset and add regslices (not applicable to SmartConnect)
    set vlnv [get_property VLNV $interconnect]
    if {[string first "axi_interconnect" $vlnv] >= 0} {
      connect_bd_net $slaveClock [get_bd_pins $interconnect/${slavePrefix}_ACLK]
      connect_bd_net $slaveReset [get_bd_pins $interconnect/${slavePrefix}_ARESETN]

      set_property CONFIG.${slavePrefix}_HAS_REGSLICE 1 $interconnect
    }

    set newSlave [get_bd_intf_pins $interconnect/${slavePrefix}_AXI]
    return $newSlave
  }; # end add_slave_to_interconnect
  
  ###########################################################
  # remove_all_slaves
  #  Description:
  #    Delete all slaves (i.e., a NULL register) connected to a master
  #    Find it, remove it, and then replace it with a new interconnect.
  #  Arguments:
  #    port         The pin/port identified by meta-data connected to the null object
  #  Return Value:
  #    None
  ###########################################################
  proc remove_all_slaves {port} {
    # Find all slaves
    set slavePort [find_bd_objs -quiet -thru_hier -relation connected_to [get_bd_intf_ports -quiet $port]]
    if { $slavePort == {} } {
      set slavePort [find_bd_objs -quiet -thru_hier -relation connected_to [get_bd_intf_pins -quiet $port]]
    }

    set nullObjects [get_bd_cells -quiet -of_objects $slavePort]
    if {$nullObjects != {}} {
      #puts "Removing all slaves on $port: slaves pins: $slavePort, objects: $nullObjects"
      delete_bd_objs $nullObjects
    }
  }; # end remove_all_slaves
  
  #################################################################################################
  ######                                     Dictionary                                       #####
  #################################################################################################
  
  ###########################################################
  # get_dpa_dictionary
  #  Description:
  #    Parse the v++ command-line arguments and tag all ports 
  #    and accelerators for debug/profiling
  #  Arguments:
  #    fp                  File pointer for writing
  #    debug_profile_info  Dictionary (of dicts) created from 
  #                        v++ debug/profile options
  #  Return Value:
  #    A dictionary containing all the relevant information
  ###########################################################
  proc get_dpa_dictionary {fp debug_profile_info} {
    if {$debug_profile_info == {}} {
      return
    }
  	
    set dpa_dict {}
  	
    puts $fp "# Monitor points"
  	
    # Debug
    set debug_info [dict_get_default $debug_profile_info debug {}]
    set dpa_dict [get_dpa_dictionary_debug $fp $debug_info $dpa_dict]
    
    # Profile
    set profile_info [dict_get_default $debug_profile_info profile {}]
    set dpa_dict [get_dpa_dictionary_profile $fp $profile_info $dpa_dict]
    
    puts "--- DEBUG: -----------------------------------------------------------"
    puts "--- DEBUG: Automation Dictionary:"
    foreach { key value } $dpa_dict {
      puts "--- DEBUG:   $key    $value"
    }
    puts "--- DEBUG: -----------------------------------------------------------"
    return $dpa_dict
  }; # end get_dpa_dictionary
  
  ###########################################################
  # get_dpa_dictionary_debug
  #  Description:
  #    Parse the v++ command-line arguments and tag all ports 
  #    for debug (protocol )
  #  Arguments:
  #    fp          File pointer for writing
  #    debug_info  Dictionary created from v++ debug options
  #    dpa_dict    Dictionary of key/dict pairs for subsystem         
  #  Return Value:
  #    Modified dictionary of key/dict pairs
  ###########################################################
  proc get_dpa_dictionary_debug {fp debug_info dpa_dict} {
    if { $debug_info == {} } {
      return $dpa_dict
    }
    set protocol_debugs [dict_get_default $debug_info protocol_debugs {}]
    if {$protocol_debugs == {}} {
      return $dpa_dict
    }
    set compute_units [dict_get_default $protocol_debugs compute_units {}]
    if {$compute_units == {}} {
      error "AXI protocol checker insertion requested but no compute units or ports specified"
      return $dpa_dict
    }
    
    # Iterate over all checkers
    foreach checker_inst $compute_units {
      set name [dict get $checker_inst name]
      set slots [dict get $checker_inst ports]
      set cu [get_bd_cells $name]

      # Add checkers to all master pins
      if { $slots eq "all" } {
        set accelMasters [get_bd_intf_pins -quiet -of_objects $cu -filter {MODE == Master}]
        foreach master $accelMasters {
        	puts $fp "set_property HDL_ATTRIBUTE.DPA_MONITOR true \[get_bd_intf_pins $master]"

          set key [get_bd_intf_pins $master]
          set pinDict [dict_get_default $dpa_dict $key {}]
          set typeList [dict_get_default $pinDict TYPE [list]]
          dict set pinDict TYPE [lappend typeList "protocol"]
          set masterClock [bd::clkrst::get_sink_clk $master]
          dict set pinDict CLK_SRC $masterClock
          dict set pinDict RST_SRC [bd::clkrst::get_sink_rst $masterClock]
          dict set pinDict PRINTABLE_KEY "\[get_bd_intf_pins $master]"
          dict set dpa_dict $key $pinDict
        }
      } else {
      	# Only add checkers to specified pins
        foreach slot $slots {
          # Portnames in kernel.xml are in uppercase while in the BD
          #  they are lower case (i.e. M_AXI_GMEM vs m_axi_gmem).
          #  So, solution is to lowercase the compare if the first compare fails
          #  If this failed, however, a WARNING will be emitted which can be
          #  safely ignored.
          set intf_pin [get_bd_intf_pins -quiet -of $cu -filter NAME=~$slot]
          if {[llength $intf_pin] == 0} {
            set cu_pin_lc [string tolower $slot]
            set intf_pin [get_bd_intf_pins -quiet -of $cu -filter NAME=~${cu_pin_lc}] 
          }

          set key [get_bd_intf_pins $intf_pin]
          set pinDict [dict_get_default $dpa_dict $key {}]
          set typeList [dict_get_default $pinDict TYPE [list]]
          dict set pinDict TYPE [lappend typeList "protocol"]
          puts "Putting protocol in TYPE: $pinDict"
          set masterClock [bd::clkrst::get_sink_clk $intf_pin]
          dict set pinDict CLK_SRC $masterClock
          dict set pinDict RST_SRC [bd::clkrst::get_sink_rst $masterClock]
          dict set pinDict PRINTABLE_KEY "\[get_bd_intf_pins $intf_pin]"
          dict set dpa_dict $key $pinDict
        }
      }
    }
    
    return $dpa_dict
  }; # end get_dpa_dictionary_debug
  
  ###########################################################
  # get_dpa_dictionary_profile
  #  Description:
  #    Parse the v++ command-line arguments and tag all ports 
  #    and accelerators for profiling
  #  Arguments:
  #    fp            File pointer for writing
  #    profile_info  Dictionary created from v++ profile options
  #    dpa_dict      Dictionary of key/dict pairs for automation  
  #  Return Value:
  #    Modified dictionary containing key/dict pairs
  ###########################################################
  proc get_dpa_dictionary_profile {fp profile_info dpa_dict} {
  	if { $profile_info == {} } {
      return $dpa_dict
    }
    
    variable ::debug_profile::enable_trace
    set monitoredCus {} 
    set stallCus  [dict get $profile_info STALL]
    set execCus   [dict get $profile_info EXEC]
    set dataPorts [dict get $profile_info DATA]

    # Stall CUs
    # NOTE: cover stall-based monitoring first
    foreach cu $stallCus {
      set cuName [string trim [dict get $cu port] "/"]
      set cuObj  [get_bd_cells -quiet $cuName]
      
      # Just in case, catch invalid CU objects
      if {$cuObj == {}} {
        continue
      }
      
      lappend monitoredCus $cuObj
      puts $fp "set_property HDL_ATTRIBUTE.DPA_MONITOR true \[get_bd_cells $cuName]"
      
      set cuOption [dict get $cu option]
      if {$cuOption eq "all"} {
        set enable_trace true
      }
      
      set key [get_bd_cells $cuName]
      set printableName "\[get_bd_cells $cuName]"
      set cuDict [get_cu_dict "stall" $cuOption $cuName]
      dict set cuDict PRINTABLE_KEY $printableName
      dict set dpa_dict $key $cuDict
    }
    
    # Execution CUs
    # NOTE: cover non-stall monitoring second
    foreach cu $execCus {
      set cuName [string trim [dict get $cu port] "/"]
      set cuObj  [get_bd_cells -quiet $cuName]
      
      # Make sure it's not already monitored
      set position [lsearch $monitoredCus $cuObj]
      
      if {($cuObj != {}) && ($position < 0)} {
        lappend monitoredCus $cuObj
        puts $fp "set_property HDL_ATTRIBUTE.DPA_MONITOR true \[get_bd_cells $cuName]"
      
        set cuOption [dict get $cu option]
        if {$cuOption eq "all"} {
          set enable_trace true
        }
        
        set key [get_bd_cells $cuName]
        set printableName "\[get_bd_cells $cuName]"
        set cuDict [get_cu_dict "exec" $cuOption $cuName]
        dict set cuDict PRINTABLE_KEY $printableName
        dict set dpa_dict $key $cuDict
      }
    }
    
    # Data pins
    # Add one line item per memory resource type (e.g., DDR, PLRAM, HBM)
    foreach data $dataPorts {
      set pinName [dict get $data port]
      set pinObj  [get_bd_intf_pins -quiet $pinName]
      set cuObj   [get_bd_cells -quiet -of $pinObj]
      
      # Just in case, catch invalid pin objects
      if {$pinObj == {}} {
        continue
      }
      
      # Tag pin with attribute
      puts $fp "set_property HDL_ATTRIBUTE.DPA_MONITOR true \[get_bd_intf_pins $pinObj]"
        
      set pinOption [dict get $data option]
      if {$pinOption eq "all"} {
        set enable_trace true
      }
        
      set currSegs [get_bd_addr_segs -of_objects $pinObj]
      # For embedded flows, the kernels are not mapped yet
      if {$currSegs == {}} {
        assign_bd_address
        set currSegs [get_bd_addr_segs -of_objects $pinObj]
      } 
      set numMons [num_monitors_per_pin $pinObj]
      puts "--- DEBUG: Pin: $pinObj, Monitors: $numMons, Addr segs: $currSegs"

      # Create dictionary for settings, clock/reset
      set key [get_bd_intf_pins $pinName]
      set pinDict [dict_get_default $dpa_dict $key {}]
      set currentType [dict_get_default $pinDict TYPE [list]]
      lappend currentType "data"
      dict set pinDict TYPE $currentType

      dict set pinDict DETAIL $pinOption
      set pinClock [bd::clkrst::get_sink_clk $pinObj]
      dict set pinDict CLK_SRC $pinClock
      dict set pinDict RST_SRC [bd::clkrst::get_sink_rst $pinClock]
    
      # Compile all memory resources attached to this pin
      set memoryName {}
      set minAddress {}
      set maxAddress {}
      
      for { set i 0 } { $i < $numMons } { incr i } {      
        # Set up address filtering
        if { $numMons > 1 } {
          set addressDictionary [min_max_addresses $pinObj]
          set minAddresses [dict get $addressDictionary MIN_ADDRESSES]
          set maxAddresses [dict get $addressDictionary MAX_ADDRESSES]

          set memoryResource [lindex [dict keys $minAddresses] $i]
          set memoryIndices [get_memory_indices_from_addr_segs $currSegs $memoryResource]
          lappend minAddress [dict get $minAddresses $memoryResource]
          lappend maxAddress [dict get $maxAddresses $memoryResource]
        } elseif {[is_stream $pinObj]} {
          set memoryResource "Stream"
          set memoryIndices ""
        } else {
          set memoryResource [get_memory_from_addr_seg [lindex $currSegs 0]]
          set memoryIndices [get_memory_indices_from_addr_segs $currSegs $memoryResource]
        }
      
        set resourceName $memoryResource
        if { $memoryIndices != "" } {
          append resourceName "\[${memoryIndices}\]"
        }
        lappend memoryName $resourceName
      }
      
      # Only add to dict if needed for filtering
      if {($minAddress != {}) && ($maxAddress != {})} {
      	puts "--- DEBUG: minAddress: $minAddress, maxAddress = $maxAddress"
        dict set pinDict MIN_ADDRESS $minAddress
        dict set pinDict MAX_ADDRESS $maxAddress
      }
      
      dict set pinDict MEMORY $memoryName
      set keyName "\[get_bd_intf_pins $pinName]"
      dict set pinDict PRINTABLE_KEY "\[get_bd_intf_pins $pinName]"
      dict set dpa_dict $key $pinDict
        
      # Add CU monitor (if not already existing)
      set position [lsearch $monitoredCus $cuObj]
      
      if {($cuObj != {}) && ($position < 0)} {
      	lappend monitoredCus $cuObj
        puts $fp "set_property HDL_ATTRIBUTE.DPA_MONITOR true \[get_bd_cells $cuObj]"
	set key [get_bd_cells $cuObj]
	set printableName "\[get_bd_cells $cuObj]"
	set cuDict [get_cu_dict "exec" $pinOption $cuObj]	
	dict set cuDict PRINTABLE_KEY $printableName
        dict set dpa_dict $key $cuDict
      }
    }
    
    return $dpa_dict
  }; # end get_dpa_dictionary_profile
  
  #################################################################################################
  ######                                       Options                                        #####
  #################################################################################################
  
  ###########################################################
  # get_dpa_options
  #  Description:
  #    Collect options for trace, AXI-Lite, and other settings
  #    for the BD automation.
  #  Arguments:
  #    fp                  File pointer for writing
  #    config_info         Dictionary of configuration settings
  #    profile_info        Dictionary created from v++ profile options
  #    dpa_opts            Dictionary for BD automation options
  #    output_dir          Output directory
  #  Return Value:
  #    An updated dictionary containing all options for BD automation
  ###########################################################
  proc get_dpa_options {fp config_info profile_info dpa_opts output_dir} {
    variable ::debug_profile::embedded
  	
    if {$profile_info == {}} {
      return $dpa_opts
    }
    
    puts $fp "\n# Platform options"
    
    # Top-level settings
    set topDict {}
    dict set topDict HW_EMU [dict_get_default $config_info is_hw_emu false]
    dict set topDict IS_EMBEDDED $embedded
    dict set dpa_opts SETTINGS $topDict
    
    # AXI-Lite and AXI Full settings
    if { [is_decorated_shell] } {
      puts "--- DEBUG: Getting settings from decorated shell..."
      set dpa_opts [get_dpa_options_decorated $fp $profile_info $dpa_opts $output_dir]
    } elseif { [is_versal_shell] } {
      puts "--- DEBUG: Getting Versal settings..."
      set dpa_opts [get_dpa_options_versal $fp $profile_info $dpa_opts $output_dir] 
    } elseif { [is_soc_shell] } {
      puts "--- DEBUG: Getting SoC settings..."
      set dpa_opts [get_dpa_options_soc $fp $profile_info $dpa_opts $output_dir]
    } else {
      # Default - PCIe platform
      puts "--- DEBUG: Getting PCIe settings..."
      set dpa_opts [get_dpa_options_pcie $fp $profile_info $dpa_opts $output_dir]
    }
    
    puts "--- DEBUG: -----------------------------------------------------------"
    puts "--- DEBUG: Automation Options:"
    foreach { key value } $dpa_opts {
      puts "--- DEBUG:   $key    $value"
    }
    puts "--- DEBUG: -----------------------------------------------------------"
    return $dpa_opts
  }; # end get_dpa_options

  ###########################################################
  # get_dpa_options_aie
  #  Description:
  #    Collect options for AI engine trace for BD automation.
  #  Arguments:
  #    profile_info  Dictionary created from v++ profile options
  #    dpa_opts      Dictionary for BD automation options
  #  Return Value:
  #    An updated dictionary containing AIE options for BD automation
  ###########################################################
  proc get_dpa_options_aie {profile_info dpa_opts} {
    if {$profile_info == {}} {
      return $dpa_opts
    }
    
    set aieTraceBaseAddr [dict_get_default $profile_info AIE_TRACE_BASE_ADDR {}]
    if {$aieTraceBaseAddr == {}} {
      return $dpa_opts
    }
     
    set aieTraceDict {}
    dict set aieTraceDict BASE_ADDRESS $aieTraceBaseAddr
    set aieTraceDepth [dict_get_default $profile_info AIE_TRACE_DEPTH {}]
    if {$aieTraceDepth != {}} {
      dict set aieTraceDict DEPTH $aieTraceDepth
    }
    dict set dpa_opts AIE_TRACE $aieTraceDict
    return $dpa_opts
  }; # get_dpa_options_aie
  
  ###########################################################
  # get_dpa_options_decorated
  #  Description:
  #    Collect metadata from platforms previously decorated
  #    with properties.
  #  Arguments:
  #    fp            File pointer for writing
  #    profile_info  Dictionary created from v++ profile options
  #    dpa_opts      Dictionary for BD automation options
  #    output_dir    Output directory
  #  Return Value:
  #    An updated dictionary containing options for BD automation
  ###########################################################
  proc get_dpa_options_decorated {fp profile_info dpa_opts output_dir} {
    variable ::debug_profile::enable_trace
    
    #
    # AXI-Lite
    #
    set axiliteMaster  [get_axilite_master]
    
    # If interconnect, then add master; otherwise, assume intf pin
    if {[get_bd_cells -quiet $axiliteMaster] != {}} {
      # Find the master we're suppose to use
      set foundMaster false
      set masterPins [get_bd_intf_pins -quiet -of_objects [get_bd_cells $axiliteMaster] -filter {Mode=="Master"}]
      foreach master $masterPins {
        set slavePins [find_bd_objs -quiet -relation connected_to -thru_hier $master]
        
        # Catch unconnected master and use it
        if {$slavePins == {}} {
          set foundMaster true
        } else {
          # Check if master is connected to a cell called "*null*" 
          foreach slavePin $slavePins {
            set slaveCell [get_bd_cells -of $slavePin]
        	  set slaveName [get_property Name $slaveCell]
            if {[string first "null" $slaveName] >= 0} {
            	remove_all_slaves $master
              set foundMaster true
              break
            }
          }
        }
        
        if {$foundMaster} {
          set axiliteMaster $master
          set axiliteClock  [bd::clkrst::get_sink_clk $axiliteMaster]
          set axiliteSink   [bd::clkrst::get_sink_rst $axiliteClock]
          set axiliteReset  [find_bd_objs -quiet -relation connected_to -thru_hier $axiliteSink]
          #puts "axilite: clock = $axiliteClock, reset = $axiliteReset"
          break
        }
      }
      
      # Last resort, add a master to existing interconnect
      if {!$foundMaster} {
      	# TODO: Is this the right clock?
        set axiliteClock    [lindex [get_bd_pins -quiet -of [get_bd_cells $axiliteMaster] -filter {TYPE == clk}] 0]
        set axiliteReset    [lindex [get_bd_pins -quiet -of [get_bd_cells $axiliteMaster] -filter {TYPE == rst}] 0]
        set axiliteMaster   [add_master_to_interconnect $axiliteMaster $axiliteClock $axiliteReset]
      }
    } else {
      # Now we're dealing with an intf pin
      set axiliteClock      [bd::clkrst::get_sink_clk $axiliteMaster]
      set axiliteReset      [bd::clkrst::get_src_rst  $axiliteClock]
      if {$axiliteReset == {}} {
        set axiliteSink     [bd::clkrst::get_sink_rst $axiliteClock]
        set axiliteReset    [find_bd_objs -quiet -relation connected_to -thru_hier $axiliteSink]
      }
    }

    set controlDict {}
    dict set controlDict MASTER  $axiliteMaster
    dict set controlDict CLK_SRC $axiliteClock
    dict set controlDict RST_SRC $axiliteReset
    dict set dpa_opts AXILITE    $controlDict
    
    # Trace info not needed
    if {!$enable_trace} {
      return $dpa_opts
    }
    
    #
    # Trace Offload
    #
    
    # Get offload slave (for non-FIFO memory resources)
    # Check in the following order:
    #   1. BD cell (e.g., memory subsystem) marked as trace slave
    #   2. BD interface pin marked as trace slave
    #   3. BD cell that is a memory subsystem
    set traceOffloadSlave     [get_bd_cells -quiet -hier -filter {HDL_ATTRIBUTE.DPA_TRACE_SLAVE == true}]
    if {$traceOffloadSlave == {}} {
      set traceOffloadSlave   [get_bd_intf_pins -quiet -hier -filter {HDL_ATTRIBUTE.DPA_TRACE_SLAVE == true}]
      if {$traceOffloadSlave == {}} {
        set traceOffloadSlave [get_bd_cells -quiet -filter {VLNV=~"*sdx_memory_subsystem*"}]
      }
    }
    
    set traceOffloadMaster    [get_trace_offload_master]
    set traceOffloadClock     [bd::clkrst::get_sink_clk $traceOffloadMaster]
    set traceOffloadReset     [get_trace_offload_reset $traceOffloadClock]
    
    # Remove all slaves
    # NOTE: This assumes we have a dedicated trace master!!
    remove_all_slaves $traceOffloadMaster
    
    # TODO: get the SLR from the platform
    set slrAssignment "SLR1"
    set dedicatedTracePort true
    
    set offloadDict [get_offload_dict $profile_info $dpa_opts]
    dict set offloadDict MASTER $traceOffloadMaster
    dict set offloadDict SLAVE $traceOffloadSlave
    dict set offloadDict CLK_SRC $traceOffloadClock
    dict set offloadDict RST_SRC $traceOffloadReset
    dict set offloadDict SLR $slrAssignment
    dict set offloadDict DEDICATED $dedicatedTracePort
    dict set dpa_opts TRACE_OFFLOAD $offloadDict
    
    return $dpa_opts
  }; # end get_dpa_options_decorated
    
  ###########################################################
  # get_dpa_options_soc
  #  Description:
  #    On SoC platforms, collect the metadata we need
  #    by querying the block diagram.
  #  Arguments:
  #    fp            File pointer for writing
  #    profile_info  Dictionary created from v++ profile options
  #    dpa_opts      Dictionary for BD automation options
  #    output_dir    Output directory
  #  Return Value:
  #    An updated dictionary containing options for BD automation
  ###########################################################
  proc get_dpa_options_soc {fp profile_info dpa_opts output_dir} {
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
    puts "--- DEBUG: monitorClock = $monitorClock, monitorReset = $monitorReset"
    
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
        ocl_util::warning2file $output_dir "CRITICAL WARNING: Unable to find trace clock or reset cell."
        return $dpa_opts
      }
      
      set monitorClock [get_bd_pins -quiet $clockCell/$traceClock]
      set monitorReset [get_bd_pins -quiet $traceReset/peripheral_aresetn]
      if { ($monitorClock == {}) || ($monitorReset == {}) } { 
        ocl_util::warning2file $output_dir "CRITICAL WARNING: Unable to find monitor clock or reset pins."
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
    
    set offloadDict [get_offload_dict $profile_info $dpa_opts]
    set memoryType  [dict_get_default $offloadDict MEM_TYPE "FIFO"]
    set traceClock $monitorClock
    set traceReset $monitorReset
      
    if {[string first "FIFO" $memoryType] >= 0} {
      #
      # Step 5: Trace master
      #
      set slrAssignment "SLR0"
      set dedicatedTracePort true
      
      set axifullMaster [add_master_to_interconnect $masterInterconnect $traceClock $traceReset]
      puts $fp "set_property HDL_ATTRIBUTE.DPA_TRACE_MASTER $dedicatedTracePort \[get_bd_intf_pins $axifullMaster]"
      if {[get_property -quiet CONFIG.SLR_ASSIGNMENTS $axifullMaster] == {}} {
        puts $fp "set_property CONFIG.SLR_ASSIGNMENTS $slrAssignment \[get_bd_intf_pins $axifullMaster]"
      }
      
      # Define offload dict
      dict set offloadDict MASTER $axifullMaster
      dict set offloadDict CLK_SRC $traceClock
      dict set offloadDict RST_SRC $traceReset
      dict set offloadDict SLR $slrAssignment
      dict set offloadDict DEDICATED $dedicatedTracePort
    } else {
      #
      # Step 6: Trace slave
      #
    
    	#   Option A: Use decoration
      set slaveInterconnect [get_bd_cells -quiet -hier -filter {HDL_ATTRIBUTE.DPA_TRACE_SLAVE != {}}]
      set aximmSlave {}
      
      #   Option B: Search for PS slave
      if {($slaveInterconnect == {}) && ($ps != {})} {
        # Find the HP slave (for trace offload buffer)
        set psSlavePorts [get_bd_intf_pins -quiet -of_objects $ps -filter {Mode=="Slave"}]
        # Default to first one in list
        set aximmSlave [lindex $psSlavePorts 0]
        
        foreach slavePort $psSlavePorts { 
          if {[string first $memoryType $slavePort] >= 0} {
            set aximmSlave $slavePort
            break
          }
        }
        #puts "aximmSlave = $aximmSlave"
        
        # Trace the AXI-MM slave port to the interconnect
        set interfaceNets [get_bd_intf_nets -quiet -of_objects $aximmSlave]
        set masterPort [get_bd_intf_pins -quiet -of_objects $interfaceNets -filter {Mode=="Master"}]
        set slaveInterconnect [get_bd_cells -quiet -of_objects $masterPort]
      }
    
      # If we found an interconnect, then add a slave
      if {$slaveInterconnect != {}} {
        set traceSlave [add_slave_to_interconnect $slaveInterconnect $traceClock $traceReset]
      } else {
        set traceSlave $aximmSlave
      }
      
      if {$traceSlave != {}} {
        puts $fp "set_property HDL_ATTRIBUTE.DPA_TRACE_SLAVE true \[get_bd_intf_pins $traceSlave]"
        dict set offloadDict SLAVE $traceSlave
      }
    }
    
    dict set dpa_opts TRACE_OFFLOAD $offloadDict

    return $dpa_opts
  }; # end get_dpa_options_soc

  ###########################################################
  # get_dpa_options_pcie
  #  Description:
  #    On PCIe platforms, collect the meta-data from the passed
  #    in dictionaries.
  #    TODO: remove dependency on xdp_platform_info
  #  Arguments:
  #    fp            File pointer for writing
  #    profile_info  Dictionary created from v++ profile options
  #    dpa_opts      Dictionary for BD automation options
  #    output_dir    Output directory
  #  Return Value:
  #    An updated dictionary containing options for BD automation
  ###########################################################
  proc get_dpa_options_pcie {fp profile_info dpa_opts output_dir} {
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
    
    if {$axiliteMaster == {}} { 
      ocl_util::warning2file $output_dir "CRITICAL WARNING: Unable to find AXI-Lite master."
      return $dpa_opts
    }
    
    set traceClock        [dict_get_default $xdp_platform_info TRACE_CLOCK {}]
    set traceReset        [dict_get_default $xdp_platform_info TRACE_RESET {}]
    set axifullMasterName [dict_get_default $xdp_platform_info AXIMM_MASTER {}]
    if {[get_bd_intf_ports -quiet $axifullMasterName] != {}} {
      set axifullMaster    [get_bd_intf_ports -quiet $axifullMasterName]
    } else {
      set axifullMaster    [get_bd_intf_pins -quiet $axifullMasterName]
    }
    
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
    	
    # On platforms without a dedicated trace port, we need to tap into
    # the host ports and add our own interconnect infrastructure
    if {!$dedicatedTracePort} {
      set axifullMaster [add_nondedicated_interconnect $hostMasters]
      set_property CONFIG.DATA_WIDTH 64 $axifullMaster  
    }
      
    set axifullClock {}
    set axifullReset {} 
     
    if {$axifullMaster != {}} {
      set axifullClock  [bd::clkrst::get_sink_clk $axifullMaster]
      set axifullReset  [bd::clkrst::get_src_rst $axifullClock]
      if {$axifullClock == {}} { set axifullClock $traceClock }
      if {$axifullReset == {}} { set axifullReset $traceReset }
      puts "AXI Full: master = $axifullMaster, clock = $axifullClock, reset = $axifullReset"
      
      # Only delete null object if trace is enabled
      remove_all_slaves $axifullMaster
      #set fullInterconnect [replace_null_object_with_interconnect $axifullMaster 1 $axifullClock $axifullReset $axifullClock $traceReset]
        
      if {[get_bd_intf_ports -quiet $axifullMaster] != {}} {
        set api "get_bd_intf_ports"
      } else {
        set api "get_bd_intf_pins"
      }
      
      puts $fp "set_property HDL_ATTRIBUTE.DPA_TRACE_MASTER $dedicatedTracePort \[$api $axifullMaster]"
      #if {[get_property -quiet CONFIG.SLR_ASSIGNMENTS $axifullMaster] == {}} {
      #  puts $fp "set_property CONFIG.SLR_ASSIGNMENTS $slrAssignment \[$api $axifullMaster]"
      #}
    }
      
    # Add TRACE_OFFLOAD dictionary to options
    set offloadDict [get_offload_dict $profile_info $dpa_opts]
    if {$offloadDict == {}} {
      return $dpa_opts
    }

    # Tell BD automation where to put the trace S2MM core.
    # NOTE: This covers a bug in older (2018.3 and 2019.1) u280 platforms.
    set useHierarchy true
    
    if {[dict_get_default $offloadDict MEM_TYPE ""] == "HBM"} {
      set useHierarchy false
      set traceSlave [get_bd_cells -quiet -filter {VLNV=~"*hbm_memory_subsystem*"}] 
    } else {
      set traceSlave [get_bd_cells -quiet -filter {VLNV=~"*sdx_memory_subsystem*"}] 
    }

    if {$traceSlave != {}} {
      dict set offloadDict SLAVE $traceSlave
      puts $fp "set_property HDL_ATTRIBUTE.DPA_TRACE_SLAVE true \[get_bd_cells $traceSlave]"
    }
      
    dict set offloadDict MASTER $axifullMaster
    dict set offloadDict CLK_SRC $axifullClock
    dict set offloadDict RST_SRC $axifullReset
    dict set offloadDict SLR $slrAssignment
    dict set offloadDict DEDICATED $dedicatedTracePort
    dict set offloadDict USE_HIERARCHY $useHierarchy
    dict set dpa_opts TRACE_OFFLOAD $offloadDict

    return $dpa_opts
  }; # end get_dpa_options_pcie

  ###########################################################
  # get_dpa_options_versal
  #  Description:
  #    On Versal platforms, collect the metadata from the passed
  #    in dictionaries.
  #  Arguments:
  #    fp            File pointer for writing
  #    profile_info  Dictionary created from v++ profile options
  #    dpa_opts      Dictionary for BD automation options
  #    output_dir    Output directory
  #  Return Value:
  #    An updated dictionary containing options for BD automation
  ###########################################################
  proc get_dpa_options_versal {fp profile_info dpa_opts output_dir} {
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
    
    set offloadDict [get_offload_dict $profile_info $dpa_opts]
    
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
  }; # end get_dpa_options_versal

}; # end namespace
