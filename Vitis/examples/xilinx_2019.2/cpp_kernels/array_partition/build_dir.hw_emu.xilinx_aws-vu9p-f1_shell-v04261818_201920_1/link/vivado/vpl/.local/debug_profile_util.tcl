package require math::bignum

namespace eval debug_profile {

  ########################################
  # Global variables used in both hardware
  # and hardware emulation flows
  ########################################

  # HW platform-specific info (e.g., clocks, resets)
  set xdp_platform_info {}

  # Separator between CU port and memory resource (must match xclperf.h in XRT)
  variable port_mem_sep "-"

  # Host designator used in debug_ip_layout (must match xclperf.h in XRT)
  variable ip_layout_host_name "HOST"
  variable ip_layout_pipe_name "PIPE"
  
  # Identifying AWS and SoC platforms
  # NOTE: SoC used to be identified by (platform state == "pre_synth" && uses_pr == "false")
  variable is_aws_platform false
  variable is_soc_platform false

  # Design intent
  variable server_managed false
  variable external_host false
  variable data_center false
  variable embedded false

  #################################################################
  # dict_get_default
  #  Description:
  #    Get value from dictionary; if not found, return default
  #  Arguments:
  #    adict          Dictionary
  #    key            Key to search for in dict
  #    default        Default value returned if key not found
  #  Return value: 
  #    None
  #################################################################
  proc dict_get_default {adict key default} {
    if { [dict exists $adict $key] } {
      return [dict get $adict $key]
    }
    return $default
  }
  
  #################################################################
  # fill_global_information
  #  Description:
  #    Extract all information used across all VPL debug/profile insertion
  #  Arguments:
  #    hw_platform_info     HW platform dictionary
  #    config_info          configuration dictionary
  #    debug_profile_info   debug/profile dict
  #  Return value: 
  #    None
  #################################################################
  proc fill_global_information {hw_platform_info config_info debug_profile_info} {
    set output_dir             [dict get $config_info output_dir]
    set hw_platform_uses_pr    [dict get $hw_platform_info hw_platform_uses_pr]
    set hw_platform_vbnv       [dict get $hw_platform_info hw_platform_vbnv]
    set hw_platform_type       [lindex [split $hw_platform_vbnv ":"] 1]
    
    # Determine if we are targeting AWS
    variable ::debug_profile::is_aws_platform
    set is_aws_platform [expr {$hw_platform_type == "aws-vu9p-f1-04261818" ? true : false}]
    
    # Get bus interfaces and associated SP tags
    # set bus_sp_tags    [dict get $config_info bus_sp_tags]
    # set bus_sp_indices [dict get $config_info bus_sp_indeces]
    set bus_sp_tags    [dict get $hw_platform_info bus_sp_tags]
    set bus_sp_indices [dict get $hw_platform_info bus_sp_indeces]

    variable ::debug_profile::server_managed 
    variable ::debug_profile::external_host
    variable ::debug_profile::data_center
    variable ::debug_profile::embedded

    set server_managed [dict_get_default $hw_platform_info design_intent_server_managed false]
    set external_host [dict_get_default $hw_platform_info design_intent_external_host false]
    set data_center [dict_get_default $hw_platform_info design_intent_datacenter false]
    set embedded [dict_get_default $hw_platform_info design_intent_embedded false]

    global xdp_platform_info
    dict set xdp_platform_info BUS_SP_TAGS $bus_sp_tags
    dict set xdp_platform_info BUS_SP_INDICES $bus_sp_indices

    if {[get_xdp_platform_info $hw_platform_info $config_info $debug_profile_info]} {
      ocl_util::warning2file $output_dir "CRITICAL WARNING: Unable to properly extract Platform-specific information.  Debug or profiling may not work."
    }
  }; # end fill_global_information

  #################################################################
  # get_xdp_platform_info
  #  Description:
  #    Set up the global dictionary "xdp_platform_info" that will be
  #    used to determine the correct clocks, resets, and control
  #    interfaces to connect our additional IP to.
  #  Arguments:
  #    xdp_platform_info    Platform dictionary used for debug/profiling
  #    config_info          Configuration dictionary
  #    debug_profile_info   Debug/profile dict
  #  Return value: 
  #    0 on success, 1 otherwise
  #################################################################
  proc get_xdp_platform_info {hw_platform_info config_info debug_profile_info} {
    global xdp_platform_info

    set is_hw_emu         [dict get $config_info is_hw_emu]

    # No need to get this if shell is decorated
    # TODO: uncomment once DPA_TRACE_MASTER is set in xilinx_u200_xdma_201920_1
    #if { [is_decorated_shell] && !$is_hw_emu} {
    #  ocl_util::warning2file $output_dir "INFO: Found decorated platform."
    #  return 0
    #}
    
    set errorFound false
    set output_dir        [dict get $config_info output_dir]
    set hw_platform_vbnv  [dict get $hw_platform_info hw_platform_vbnv]
    set xpfm_file         [dict get $hw_platform_info xpfm_file]
    
    # if HW platform doesn't contain the "extension" metadata for "profile_debug", it returns empty string
    if { [catch { set hw_platform_dict [::platform::get_hw_ext_dict $xpfm_file profile_debug] } catch_res] } {
      ocl_util::warning2file $output_dir "CRITICAL WARNING: Could not extract profile_debug dictionary from xpfm."
      set errorFound true
    }

    # NOTE: This proc call was really slow so moved to HPIKernelCompiler.cxx (CR 1015834)
    # Get bus interfaces and associated SP tags
    #get_bus_sp_tags $xpfm_file $output_dir

    set version [lindex [split $hw_platform_vbnv ":"] 3]

    # Use defaults only when necessary
    if {$hw_platform_dict == {} || $errorFound || $is_hw_emu} {
      set hw_platform_type [lindex [split $hw_platform_vbnv ":"] 1]
      set hw_platform_name [lindex [split $hw_platform_vbnv ":"] 2]
      set 201820Platform [expr {([string first "201820" $version] >= 0) ? true : false}]
      set awsPlatform [expr {$hw_platform_type == "aws-vu9p-f1-04261818" ? true : false}]
      set oldPlatform [expr {(($version == "5.0") || ($version == "5.1") || $awsPlatform) ? true : false}]
      puts "--- DEBUG: vbnv = $hw_platform_vbnv, version = $version, old Platform = $oldPlatform, 2018.2 Platform = $201820Platform"
    
      # Catch special case of all VU9P parts (i.e., vcu1525 and u200)
      if {[string equal $hw_platform_type "vcu1525"] || [string equal $hw_platform_type "u200"]} {
        dict lappend xdp_platform_info SLR_ASSIGNMENT "SLR1"
        set slrHierName "slr1"
      } else {
        dict lappend xdp_platform_info SLR_ASSIGNMENT "SLR0"
        set slrHierName "slr0"
      }
    
      set notDedicated [expr {($oldPlatform || ([string equal $hw_platform_type "u200"] && $201820Platform)) ? true : false}]
      dict lappend xdp_platform_info DEDICATED_MASTER [expr {$notDedicated ? false : true}]
      if {$is_hw_emu} {
         dict lappend xdp_platform_info AXIMM_MASTER "xtlm_simple_intercon_0"
      } else {
         dict lappend xdp_platform_info AXIMM_MASTER [expr {$notDedicated ? "interconnect_aximm_host" : "regslice_data_periph_M_AXI"}]
      }
      set monClock [expr {(!$is_hw_emu && $awsPlatform) ? "/clk_extra_b0" : "clkwiz_kernel_clk_out1"}]
      dict lappend xdp_platform_info MONITOR_CLOCK $monClock

      # Find a default reset
      set monReset [expr {($is_hw_emu) ? "psr_kernel_clk/peripheral_aresetn" : "memory_subsystem/aresetn"}]
      if { $is_hw_emu && ([get_bd_pins -quiet $monReset] == {}) } {
        set monReset "/kernel_clk/sync_rst"
      }
      if { !$is_hw_emu && $awsPlatform } {
        set monReset "reset_controllers/interconnect_aresetn"
      }
      if {[get_bd_pins -quiet $monReset] == {}} {
        puts "--- DEBUG: Unable to find Monitor Reset."
      }
      dict lappend xdp_platform_info MONITOR_RESET $monReset
      
      # Get AXI-Lite interconnect from first CU (if not found then guess)
      set axilite_intercon {}
      set first_cu_cell [lindex [get_bd_cells -quiet -hier -filter "SDX_KERNEL==true"] 0]
      if {$first_cu_cell != {}} {
        set axilite_pin [get_bd_intf_pins -quiet -of_objects $first_cu_cell -filter {CONFIG.PROTOCOL == AXI4LITE && MODE == Slave}]
        set axilite_obj [find_bd_objs -quiet -relation connected_to -stop_at_interconnect -thru_hier $axilite_pin]
        set axilite_intercon [get_bd_cells -quiet -of_objects $axilite_obj]
      }
      if {$axilite_intercon == {}} {
        set axilite_intercon "interconnect_axilite_user"
        if {[get_bd_cells -quiet $axilite_intercon] == {}} { 
          set axilite_intercon "interconnect_axilite_user_slr0"
          if {[get_bd_cells -quiet $axilite_intercon] == {}} {
            set bd_cells [get_bd_cells -quiet -hierarchical]
            set indexes [lsearch -all $bd_cells "*${slrHierName}/inter*"]
            foreach index $indexes {
              set axilite_intercon [get_bd_cells -quiet [lindex $bd_cells $index] -filter {VLNV=~"xilinx.com:ip:axi_interconnect*"}]
              if {$axilite_intercon != {}} {
                break
              }
            }
            if {$axilite_intercon == {}} {
              puts "--- DEBUG: Unable to find AXI-Lite interconnect."
            }
            #return 1
          }
        }
      }
      
      dict lappend xdp_platform_info AXILITE_INTERCONNECT "$axilite_intercon"
      dict lappend xdp_platform_info AXILITE_MASTER "$axilite_intercon/M00_AXI"
      if {$notDedicated} {
        dict lappend xdp_platform_info TRACE_CLOCK "$axilite_intercon/S00_ACLK"
        if {[string first "x4" $hw_platform_name] >= 0} {
          dict lappend xdp_platform_info TRACE_RESET "$slrHierName/reset_controllers/psreset_gate_pr_control_interconnect_aresetn"
        } else {
          dict lappend xdp_platform_info TRACE_RESET "$axilite_intercon/S00_ARESETN"
        }
      } else {
        dict lappend xdp_platform_info TRACE_CLOCK "dma_pcie_axi_aclk"
        dict lappend xdp_platform_info TRACE_RESET "$slrHierName/reset_controllers/psreset_gate_pr_data_interconnect_aresetn"
      }
      
      if {!$is_hw_emu} {
        puts "--- DEBUG: Using default values for profile instrumentation."
      }
      puts "--- DEBUG: Using default values: $xdp_platform_info"
      return 0
    }
    
    puts "--- DEBUG: Parsing Platform-specific information for debug and profiling..."
    puts "--- DEBUG: -----------------------------------------------------------"
    
    # Host masters
    # NOTE: In 2019.2, this is only used for non-dedicated trace masters 
    set host_masters [list]
    set host_dict [dict_get_default $hw_platform_dict host {}]
    puts "--- DEBUG:    Host dict: $host_dict"

    foreach slr [dict keys $host_dict] {
      foreach connection [dict get $host_dict $slr] {
        set host_net [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins $connection]]
        set host_master [get_bd_intf_pins -quiet -of_objects $host_net -filter {MODE == Master}]
        # Make sure it's not a kernel
        set host_master_cell [get_bd_cells -quiet -hier -of_objects $host_master -filter {SDX_KERNEL != true}]
        if {$host_master_cell != {}} {
          lappend host_masters $host_master
        }
      }
    }
    dict set xdp_platform_info HOST_MASTERS $host_masters
    puts "--- DEBUG:    Host masters: $host_masters"
    
    # AXI-Lite master
    # TODO: grab all masters, not just the fallback
    set axlite_intercon "interconnect_axilite_user"
    set axlite_master "M00_AXI"
    set axilite_dict [dict_get_default $hw_platform_dict axilite {}]
    puts "--- DEBUG:    Axilite dict: $axilite_dict"

    foreach slr [dict keys $axilite_dict] {  
      set fallback [dict get $axilite_dict $slr fallback]
      
      foreach key [dict keys [dict get $axilite_dict $slr]] {
        set value [dict get $axilite_dict $slr $key]
        if {$fallback} {
          if {$key == "ip"} {  
            set axilite_intercon $value
          }
          if {$key == "mi"} {  
            set axilite_master $value
          }
        }
      }
    }
    
    dict lappend xdp_platform_info AXILITE_INTERCONNECT $axilite_intercon
    dict lappend xdp_platform_info AXILITE_MASTER "$axilite_intercon/$axilite_master"
    puts "--- DEBUG:    AXI-Lite interconnect: $axilite_intercon"
    puts "--- DEBUG:    AXI-Lite master: $axilite_intercon/$axilite_master"
    
    # Trace (AXI-MM master, clock/reset, SLR assignment)
    set slrAssignmentTrace "SLR0"
    set dedicated_master false
    set aximm_master "interconnect_aximm_host/M01_AXI"
    set trace_clock "dma_pcie_axi_aclk"
    set trace_reset "slr1/reset_controllers/psreset_gate_pr_data_interconnect_aresetn"
    set trace_dict [dict_get_default $hw_platform_dict trace {}]
    puts "--- DEBUG:    Trace dict: $trace_dict"

    foreach slr [dict keys $trace_dict] {
      set slrAssignmentTrace $slr
      
      foreach key [dict keys [dict get $trace_dict $slr]] {
        set value [dict get $trace_dict $slr $key]
        
        if {$key == "mi"} {
          set aximm_master $value
          set dedicated_master true
        } elseif {$key == "clk"} {
          set trace_clock $value
        } elseif {$key == "rst"} {
          set trace_reset $value
        }
      }
    }
    
    dict lappend xdp_platform_info SLR_ASSIGNMENT $slrAssignmentTrace
    dict lappend xdp_platform_info DEDICATED_MASTER $dedicated_master
    dict lappend xdp_platform_info AXIMM_MASTER $aximm_master
    dict lappend xdp_platform_info TRACE_CLOCK $trace_clock
    dict lappend xdp_platform_info TRACE_RESET $trace_reset
    puts "--- DEBUG:    SLR assigment: $slrAssignmentTrace"
    puts "--- DEBUG:    AXI-MM master: $aximm_master (dedicated: $dedicated_master)"
    puts "--- DEBUG:    Trace clock: $trace_clock"
    puts "--- DEBUG:    Trace reset: $trace_reset"
    
    # Monitor clock/reset
    set monitor_clock "clkwiz_kernel_clk_out1"
    set monitor_reset "slr1/reset_controllers/psreset_gate_pr_kernel/peripheral_aresetn"
    set monitor_dict [dict_get_default $hw_platform_dict monitor {}]
    puts "--- DEBUG:    Monitor dict: $monitor_dict"

    foreach slr [dict keys $monitor_dict] {  
      set fallback [dict get $monitor_dict $slr fallback]
      
      foreach key [dict keys [dict get $monitor_dict $slr]] {
        set value [dict get $monitor_dict $slr $key]
        #puts "  ${key}: ${value}"
        if {$fallback == true} {
          if {$key == "clk"} {
            set monitor_clock $value
          } elseif {$key == "rst"} {
            set monitor_reset $value
          }
        }
      }
    }
  
    dict lappend xdp_platform_info MONITOR_CLOCK $monitor_clock
    dict lappend xdp_platform_info MONITOR_RESET $monitor_reset
    puts "--- DEBUG:    Monitor clock: $monitor_clock"
    puts "--- DEBUG:    Monitor reset: $monitor_reset"
    puts "--- DEBUG: -----------------------------------------------------------"
    return 0
  }; # end get_xdp_platform_info

  ###########################################################
  # min_max_addresses
  #  Description:
  #  Arguments:
  #    port        The port we are monitoring
  #  Return Value:
  #    A dictionary of dictionaries that contain min/max addresses
  ###########################################################
  proc min_max_addresses { port } {
    set currSegs [get_bd_addr_segs -of_objects [get_bd_intf_pins $port]]

    set minAddresses {}
    set maxAddresses {}
    foreach seg $currSegs {
      set minAddress [get_property offset $seg]
      set range      [get_property range $seg]
      set maxAddress [format 0x%X [expr $minAddress + $range - 1]]

      set memoryResource [get_memory_from_addr_seg $seg]
      if { [dict exists $minAddresses $memoryResource] } {
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
    set addressEntry {}
    dict set addressEntry MIN_ADDRESSES $minAddresses
    dict set addressEntry MAX_ADDRESSES $maxAddresses
    return $addressEntry
  }; # end min_max_addresses
  
  ###########################################################
  # num_monitors_per_pin
  #  Description:
  #    Determine the number of SPMs that we will need to 
  #    instantiate based upon the port we are monitoring.
  #    This varies based upon the number of memory resources
  #    the port can read from
  #  Arguments:
  #    The port that is being monitored
  #  Return Values:
  #    An integer specifying the number of SPMs on this port
  ###########################################################
  proc num_monitors_per_pin { pin } {
    # AXI-S is 1 monitor
    if { [is_stream $pin] } { return 1 }
    
    # AXI-MM depends on the address ranges
    set currSegs [get_bd_addr_segs -quiet -of_objects [get_bd_intf_pins -quiet $pin]]
    if { [llength $currSegs] <= 1 } { return 1 } 

    set addressDictionary [min_max_addresses $pin]
    set minAddresses [dict get $addressDictionary MIN_ADDRESSES]
    return [llength [dict keys $minAddresses]]
  }; # end num_monitors_per_pin
  
  ################################################################################
  # get_clk_from_intf_pin
  #   Description:
  #     Get clock pin given AXI interface pin
  #   Arguments:
  #     intfPin          AXI interface pin
  ################################################################################
  proc get_clk_from_intf_pin {intfPin} {
    set currPin [get_bd_intf_pins $intfPin -quiet]
    set currCell [get_bd_cells -of_objects $currPin -quiet]
    if {$currCell eq ""} {
      puts "WARNING: unable to find clock from interface pin $intfPin"
      return ""   
    }
    
    # Non-hierarchy method
    set pinName [string range $intfPin [expr [string last "/" $intfPin]+1] [string length $intfPin]]
    #puts "--- DEBUG get_clk_from_intf_pin: pin = $intfPin, cell = $currCell, pinName = $pinName"

    set clockPins [get_bd_pins -of_objects $currCell -filter {TYPE == clk}]
    #puts "--- DEBUG get_clk_from_intf_pin: clock pins = $clockPins"
    foreach clockPin $clockPins {
      set associatedBusif [get_property CONFIG.ASSOCIATED_BUSIF $clockPin]
      if {[string first $pinName $associatedBusif] >= 0} {
        return $clockPin
      }
    }
    
    # Hierarchical method
    #puts "--- DEBUG get_clk_from_intf_pin: use hierarchical method..."
    set connObj [find_bd_objs -quiet -relation connected_to -boundary_type lower -stop_at_interconnect -thru_hier $currPin]
    set connCell [get_bd_cells -quiet -of_objects $connObj]
    set pinName [string range $connObj [expr [string last "/" $connObj]+1] [string length $connObj]]
    #puts "--- DEBUG get_clk_from_intf_pin: object = $connObj, cell = $connCell, pin = $pinName"

    set clockPins [get_bd_pins -of_objects $connCell -filter {TYPE == clk}]
    #puts "--- DEBUG get_clk_from_intf_pin: clock pins = $clockPins"
    foreach clockPin $clockPins {
      set associatedBusif [get_property CONFIG.ASSOCIATED_BUSIF $clockPin]
      if {[string first $pinName $associatedBusif] >= 0} {
        return $clockPin
      }
    }
    
    return ""
  }; # end get_clk_from_intf_pin
   
  ################################################################################
  # get_reset_from_intf_pin
  #   Description:
  #     Get reset pin given AXI interface pin
  #   Arguments:
  #     intfPin          AXI interface pin
  ################################################################################
  proc get_reset_from_intf_pin {intfPin} {
    global xdp_platform_info
    set default_reset [get_bd_pins -quiet [dict_get_default $xdp_platform_info MONITOR_RESET {}]]
    
    set clockPin [get_clk_from_intf_pin $intfPin]
    set currPin [get_bd_intf_pins $intfPin -quiet]
    set currCell [get_bd_cells -of_objects $currPin -quiet]
    if {$currCell eq ""} {
      puts "WARNING: unable to find reset from interface pin $intfPin"
      return "" 
    }
    
    set resetPin [string tolower [get_property CONFIG.ASSOCIATED_RESET $clockPin -quiet]]
    #puts "--- DEBUG get_reset_from_intf_pin: ASSOCIATED_RESET clockPin = $clockPin, resetPin = $resetPin"
    # Grab first one if multiple ones are listed
    if {[string first ":" $resetPin] >= 0} {
      set resetPin [string range $resetPin 0 [expr [string first ":" $resetPin] - 1]]
    }
    
    if {$resetPin eq ""} {
      # Hierarchical method
      set connObj [find_bd_objs -quiet -relation connected_to -boundary_type lower -stop_at_interconnect -thru_hier $currPin]
      set connCell [get_bd_cells -quiet -of_objects $connObj]
      set pinName [string range $connObj [expr [string last "/" $connObj]+1] [string length $connObj]]
      #puts "--- DEBUG get_reset_from_intf_pin: object = $connObj, cell = $connCell, pin = $pinName"

      set resetPins [get_bd_pins -quiet -of_objects $connCell -filter {TYPE == rst} -quiet]
      foreach resetPin $resetPins {
        return $resetPin
      }
    
      # Find it another way
      set resetPin [lindex [get_bd_pins -of_objects $currCell -filter {TYPE == rst} -quiet] 0]
      if {$resetPin eq ""} {
        puts "WARNING: unable to find reset from interface pin $intfPin"
        set resetPin $default_reset
      }
      return "$resetPin"
    }
    
    set hierName [string range $clockPin 0 [expr [string last "/" $clockPin] - 1]]
    set hierNet [get_bd_nets -quiet -of_objects [get_bd_pins -quiet $hierName/$resetPin]]
    set hierDriverPin [lindex [get_bd_pins -quiet -of_objects $hierNet -filter {DIR == O}] 0]
    puts "--- DEBUG get_reset_from_intf_pin: name = $hierName, net = $hierNet, driver pin = $hierDriverPin"
    if {$hierDriverPin eq ""} {
      return "$currCell/$resetPin"
    }
    return $hierDriverPin
  }; # end get_reset_from_intf_pin
  
  ################################################################################
  # get_memory_from_addr_seg
  #   Description:
  #     Get the name of the memory resource attached to an address segment
  #   Arguments:
  #     addrSeg         address segment object
  ################################################################################
  proc get_memory_from_addr_seg {addrSeg} {
    global xdp_platform_info
    set bus_sp_tags [dict_get_default $xdp_platform_info BUS_SP_TAGS {}]
    if {($bus_sp_tags == {}) || ($addrSeg == {})} {
      return "DDR"
    }

    set segName [get_property name $addrSeg]
    
    foreach key [dict keys $bus_sp_tags] {
    	set value [dict get $bus_sp_tags $key]
    	if {[string first $key $segName] >= 0} {
    	  return $value
    	}
    }

    set memoryType "DDR"
    if {[string first "HBM"   $segName] >= 0} {set memoryType "HBM"}
    if {[string first "PLRAM" $segName] >= 0} {set memoryType "PLRAM"}
    if {[string first "HP"    $segName] >= 0} {set memoryType "HP"}
    if {[string first "ACP"   $segName] >= 0} {set memoryType "ACP"}
    if {[string first "MIG"   $segName] >= 0} {set memoryType "MIG"}
    return $memoryType
  }; # end get_memory_from_addr_seg

  ################################################################################
  # get_memory_indices_from_addr_segs
  #   Description:
  #     Get the indices of the memory resource attached to address segments.
  #   Arguments:
  #     addrSegs        address segments
  #     memoryType      memory resource type
  ################################################################################
  proc get_memory_indices_from_addr_segs {addrSegs memoryType} {
    # Indices are only applicable for DDR, HBM, and PLRAM
    if {([string first "DDR" $memoryType] < 0) && ([string first "HBM" $memoryType] < 0) 
    	  && ([string first "PLRAM" $memoryType] < 0) } {
      return ""
    }
    
    global xdp_platform_info
    set bus_sp_tags [dict_get_default $xdp_platform_info BUS_SP_TAGS {}]
    set bus_sp_indices [dict_get_default $xdp_platform_info BUS_SP_INDICES {}]
    if {$bus_sp_tags == {} || $bus_sp_indices == {}} {
      return ""
    }
    
    set minIndex 100
    set numSegments 0
    
    foreach seg $addrSegs {
      set segName [get_property name $seg]
      
      # Ignore segments targeting different memory types
      set currMemoryType [get_memory_from_addr_seg $seg]
      if {$currMemoryType != $memoryType} {
        continue
      }
      
      incr numSegments
      
      # First look at known segment names
      set found 0
      foreach key [dict keys $bus_sp_tags] {
        set value [dict get $bus_sp_tags $key]
        
    	  if {[string first $key $segName] >= 0} {
    	    set currIndex [dict get $bus_sp_indices $key]
          set minIndex [expr { ($currIndex < $minIndex) ? $currIndex : $minIndex } ]
          set found 1
          break
    	  }
      }
      
      # If not found, then search for index expressed in segment name
      if {!$found} {
        for { set i 16 } { $i >= 0 } { incr i -1} {
          if {$i >= 10} {set ii "${i}"} else {set ii "0${i}"}
          if {[string first $ii $segName] >= 0} {
            set minIndex [expr { ($i < $minIndex) ? $i : $minIndex } ]
            break
          }
        }
      }
    }
     
    if {$numSegments == 0} {
      return ""
    }
    
    set maxIndex [expr $minIndex + $numSegments - 1]
    
    # Specify either as single value or as range
    if {$minIndex == $maxIndex} {
      set indices $minIndex
    } else {
      set indices "${minIndex}:${maxIndex}"
    }
    
    #puts "--- DEBUG: segs = $addrSegs, type = $memoryType, indices = $indices"
    return $indices
  }; # end get_memory_indices_from_addr_segs

  ###########################################################
  # get_address_space_from_memory_type
  #  Description:
  #    Given a memory resource (e.g., DDR[3], find the address space
  #  Arguments:
  #    memoryName   Name of memory resource
  #    memoryIndex  Index of memory resource
  #  Return Value:
  #    name of associated address space
  ###########################################################
  proc get_address_space_from_memory_type {memoryName memoryIndex} {
    global xdp_platform_info
    set bus_sp_tags [dict_get_default $xdp_platform_info BUS_SP_TAGS {}]
    set bus_sp_indices [dict_get_default $xdp_platform_info BUS_SP_INDICES {}]
    
    if {$bus_sp_tags == {} || $bus_sp_indices == {}} {
      return [list $memoryName $memoryIndex]
    }
    
    #puts "--- DEBUG: get address space from memory $memoryName (index: $memoryIndex)"
    
    set i 0
    foreach key [dict keys $bus_sp_tags] {
      set name  [dict get $bus_sp_tags $key]
      set index [dict get $bus_sp_indices $key]
      #puts "--- DEBUG: key = $key, name = $name, index = $index"
      
      if {[string first $name $memoryName] >= 0} {
        if {($memoryIndex == {}) || ([string first $index $memoryIndex] >= 0)} {
          puts "--- DEBUG: address space found: $key"
          return [list $key $i]
        }
      }
      incr i
    }
  }; # end get_address_space_from_memory_type
  
  #####################################################################
  # get_axilite_master
  #  Description:
  #    Quieres the BD to find the AXI-Lite master via properties.
  #  Arguments:
  #    None
  #  Return Value:
  #    AXI-Lite master object
  #####################################################################
  proc get_axilite_master { } {
    # Check in the following order:
    #   1. BD cell (e.g., interconnect) marked as primary
    #   2. BD cell marked as fallback (TBD: which one do we choose?)
    #   3. BD interface pin (e.g., dedicated master on an interconnect)
    set axiliteMaster [get_bd_cells -quiet -hier -filter {HDL_ATTRIBUTE.DPA_AXILITE_MASTER == primary}]
    if {$axiliteMaster == {}} {
      set axiliteMaster [get_bd_cells -quiet -hier -filter {HDL_ATTRIBUTE.DPA_AXILITE_MASTER == fallback}]
      
      if {$axiliteMaster == {}} {
        set axiliteMaster [get_bd_intf_pins -quiet -hier -filter {HDL_ATTRIBUTE.DPA_AXILITE_MASTER == primary}]
      }
    }
    return $axiliteMaster
  }; # end get_axilite_master
  
  #####################################################################
  # get_trace_offload_master
  #  Description:
  #    Quieres the BD to find the trace offload master via properties.
  #  Arguments:
  #    None
  #  Return Value:
  #    Trace offload master object
  #####################################################################
  proc get_trace_offload_master { } {
    global xdp_platform_info
  	
    set traceOffloadMaster [get_bd_intf_pins -quiet -hier -filter {HDL_ATTRIBUTE.DPA_TRACE_MASTER == true}]
    #puts "traceOffloadMaster = $traceOffloadMaster"
    
    # Absolute worst case, use metadata (if available)
    if {$traceOffloadMaster == {}} {
      set axifullMasterName [dict_get_default $xdp_platform_info AXIMM_MASTER {}]
      set traceOffloadMaster [get_bd_intf_pins -quiet $axifullMasterName]
    }
    
    return $traceOffloadMaster
  }; # end get_trace_offload_master
  
  #####################################################################
  # get_trace_offload_reset
  #  Description:
  #    Quieres the BD to find the trace offload reset via properties.
  #  Arguments:
  #    traceOffloadClock    Trace offload clock
  #  Return Value:
  #    Trace offload reset object
  #####################################################################
  proc get_trace_offload_reset {traceOffloadClock} {
    global xdp_platform_info
 
  	set traceOffloadReset     [bd::clkrst::get_src_rst  $traceOffloadClock]
    if {$traceOffloadReset == {}} {
      set traceOffloadSink    [bd::clkrst::get_sink_rst $traceOffloadClock]
      set traceOffloadReset   [find_bd_objs -quiet -relation connected_to -thru_hier $traceOffloadSink]
      
      if {$traceOffloadReset == {}} {
        set traceOffloadReset [get_bd_pins -quiet -hier -filter {HDL_ATTRIBUTE.DPA_TRACE_MASTER_RESET == true}]
      }
    }
    
    # Absolute worst case, use metadata (if available)
    if {$traceOffloadReset == {}} {
      set traceOffloadReset   [dict_get_default $xdp_platform_info TRACE_RESET {}]  
    }
    
    #puts "traceOffloadReset = $traceOffloadReset"
    return $traceOffloadReset
  }; # end get_trace_offload_reset
  
  #####################################################################
  # is_decorated_shell
  #  Description:
  #    Quieres the BD and determines if this shell is decorated with
  #    properties to identify anchor points for BD automation.
  #  Arguments:
  #    None
  #  Return Value:
  #    1 if this shell is decorated, 0 otherwise
  #####################################################################
  proc is_decorated_shell { } {
  	set axiliteMaster [get_axilite_master]
    set traceOffloadMaster [get_trace_offload_master]
    if {($axiliteMaster != {}) && ($traceOffloadMaster != {})} { return 1 }
    return 0
  }; # end is_decorated_shell
  
  #####################################################################
  # is_soc_shell
  #  Description:
  #    Quieres the BD and determines if this is an SoC or embedded
  #    specific shell.
  #  Arguments:
  #    None
  #  Return Value:
  #    1 if this is an SoC (embedded) Shell, 0 otherwise
  #####################################################################
  proc is_soc_shell { } {
    # Test 1 - Do we have a PS7 IP?
    set ps7 [get_bd_cells -quiet -filter {VLNV =~ "xilinx.com:ip:processing_system7*"}]
    if { $ps7 != {} } { return 1 }
    # Test 2 - Do we have a Zynq IP?
    set zync [get_bd_cells -quiet -filter {VLNV =~ "xilinx.com:ip:zynq*"}]
    if { $zync != {} } { return 1 } 
    # Test 3 - Design intent is embedded
    variable ::debug_profile::embedded
    if { $embedded } { return 1 }
    
    return 0 
  }; # end is_soc_shell

  #####################################################################
  # is_versal_shell
  #  Description:
  #    Quieres the BD and determines if this is a Versal specific shell.
  #  Arguments:
  #    None
  #  Return Value:
  #    1 if this is a Versal Shell, 0 otherwise
  #####################################################################
  proc is_versal_shell { } {
    set versal [get_bd_cells -quiet -filter {VLNV =~ "*axi_noc*"}]
    if { $versal != {} } { return 1 }
    return 0
  }; # end is_versal_shell

  #####################################################################
  # is_aie_present
  #  Description:
  #    Quieres the BD and determines if AI engines are in this design.
  #  Arguments:
  #    None
  #  Return Value:
  #    1 if this contains AI engines, 0 otherwise
  #####################################################################
  proc is_aie_present { } {
    set aie [get_bd_cells -quiet -filter {VLNV =~ "*ai_engine*"}]
    if { $aie != {} } { return true }
    return false
  }; # end is_aie_present
  
  ###########################################################
  # is_stream
  #  Description:
  #    Given an interface pin, check if stream
  #  Arguments:
  #    intf_pin  Name of bd_intf_pin        
  #  Return Value:
  #    true: pin is AXI-Stream; false: pin is not AXI Stream
  ###########################################################
  proc is_stream {intf_pin} {
    set pin [get_bd_intf_pins -quiet $intf_pin]
    if { [string first axis [get_property -quiet VLNV $pin] ] >= 0 } {
      return true
    }
    return false
  }; # end is_stream
  
  #####################################################################
  # is_stream_connected_to_pipe
  #  Description:
  #    Checks if the specified interface pin is connected to a pipe 
  #  Arguments:
  #    intfPin
  #  Return Value:
  #    1 if this is connected to a pipe, 0 otherwise
  #####################################################################
  proc is_stream_connected_to_pipe { intfPin } {
    set pinObj [get_bd_intf_pins -quiet $intfPin]
  	
    # Catch if not an AXI stream (or pin doesn't exist)
    if {[string first "axis" [get_property -quiet VLNV $pinObj]] < 0} {
      return 0
    }

    set connectedCells [get_bd_cells -of_objects [find_bd_objs -relation connected_to $pinObj]]
    foreach cell $connectedCells {
      set vlnv [get_property -quiet VLNV $cell]
      if {[string first "axis_data_fifo" $vlnv] >= 0} {
        return 1
      }
    }
    
    return 0
  }; # end is_stream_connected_to_pipe
  
}; # end namespace
