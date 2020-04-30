package require math::bignum

namespace eval ocl_util {
  namespace export write_cookie_file_impl report_utilization_impl \
                   report_timing_and_scale_freq  get_achievable_kernel_freq write_new_clk_freq \
                   write_user_impl_clock_constraint get_kernel_cells

  proc get_script_dir {} [list return [file dirname [info script]]]

  proc dict_get_default {adict key default} {
    if { [dict exists $adict $key] } {
      return [dict get $adict $key]
    }
    return $default
  }

  ################################################################################
  # error2file
  #
  # Puts detailed error message and software persona message to execution
  # log; stashes software persona message in a side file.
  #      
  #   Arguments:
  #      dir: A relative path to the directory that encapsulates vivado_error.txt
  #      sw_persona_msg: Software persona (non-hardware savvy) user message
  #      catch_res: The result of script evaluation, which here is expected to be
  #        an error message
  ################################################################################
  proc error2file {dir sw_persona_msg {catch_res ""}} {
    global vivado_error_file
    if { $catch_res ne "" } {
      # The format is coupled with C++ code that does post-processing!
      puts "ERROR: caught error: $catch_res"
    }
    # remove the leading "<spaces>ERROR:<spaces>" from sw_persona_msg
    regsub -nocase {^\s*ERROR\s*:*\s*} $sw_persona_msg {} sw_persona_msg
    set fname [file join $dir $vivado_error_file]
    # puts "--- DEBUG: Writing to file $fname: $sw_persona_msg"
    set fh [open $fname w]
    puts $fh $sw_persona_msg
    close $fh
    # Generates sw_persona_msg in the stack frame above, now that we have had a chance
    # to print it to a side file.
    uplevel 1 error [list $sw_persona_msg]
  }

  ################################################################################
  # exception2file
  #
  # For use when using 'catch' to trap exceptional returns. The frame stack is
  # interesting compared to error2file.
  # Puts detailed error message and software persona message to execution
  # log; stashes software persona message in a side file.
  #      
  #   Arguments:
  #      dir: A relative path to the directory that encapsulates vivado_error.txt
  #      sw_persona_msg: A message targeted to non-hardware savvy user.
  #      catch_res: The result of script evaluation, which here is expected to be
  #        an error message
  #      return_options_dict: A dictionary of return options returned by
  #        evaluation of a script.
  ################################################################################
  proc exception2file {dir sw_persona_msg {catch_res ""} return_options_dict} {
    global vivado_error_file
    if [dict exists $return_options_dict "-errorinfo"] {
      set msg_with_stack [dict get $return_options_dict "-errorinfo"]
      # The format is coupled with C++ code that does post-processing!
      puts "ERROR: caught error: $msg_with_stack"
    } elseif { $catch_res ne "" } {
      # The format is coupled with C++ code that does post-processing!
      puts "ERROR: caught error: $catch_res"
    }
    # remove the leading "<spaces>ERROR:<spaces>" from sw_persona_msg
    regsub -nocase {^\s*ERROR\s*:*\s*} $sw_persona_msg {} sw_persona_msg
    append sw_persona_msg " An error stack with function names and arguments may be available "
    append sw_persona_msg "in the 'vivado.log'."
    set fname [file join $dir $vivado_error_file]
    # puts "--- DEBUG: Writing to file $fname: $sw_persona_msg"
    set fh [open $fname w]
    puts $fh $sw_persona_msg
    close $fh
    # The list command returns a list
    # The uplevel command is used to execute a script in a different stack frame
    # Generates the error in the stack frame above, now that we have had a chance
    # to print it to a side file.
    uplevel 1 error [list $sw_persona_msg]
  }

  proc warning2file {dir msg } {
    global vivado_warn_file
    puts "$msg"
    # remove the leading "<spaces>WARNING:<spaces>" from msg
    regsub -nocase {^\s*(CRITICAL)?\s*WARNING\s*:\s*} $msg {} msg
    set fname [file join $dir $vivado_warn_file]
    # puts "--- DEBUG: Writing warnings to file $fname: $msg"
    # this file may have multiple warning messages, we should use "append" mode
    set fh [open $fname a+]
    puts $fh $msg
    close $fh
  }

  set System "system"
  set Kernel "kernel"

  # Initialize rule-checker functionality if the environment has been configured for it.
  set drcv_connected false
  if {[info exists ::env(XILINX_RS_PORT)]} {
    if { [catch {
      # Load library (shared/common/services/rulecheck/client/tcl), if necessary.
      # We'll search the list of loaded packages to see if it is already there
      # (instead of using package present which throws if it isn't).
      if {[lsearch -exact [package names] DRCVTcl] >= 0} {
        set result true
      } else {
        set result [load librdi_drcvtcl[info sharedlibextension]]
      }
      # Connect, if necessary
      if {$result eq "true"} {
        if { [catch {
          set result [::drcv::connect]
        } catch_res] } {
          # If we are already connected, the code currently gives TCL_ERROR,
          # which needs to be caught, but the throw will give "already connected"
          # and the result should be true. If this isn't what happened, stop.
          if {$catch_res ne "already connected"} {
            set result false
          }
        }
      }
      # Load rules
      if {$result eq "true"} {
        set platformSeparator ":"
        if {[info exist tcl_platform(platform)] && ($tcl_platform(platform) == "windows")} {
          set platformSeparator ";"
        }
        set rule_part [file join scripts ocl ocl_rules.cfg]
        foreach rdiRoot [split "$::env(RDI_APPROOT)" $platformSeparator] {
          set path_test [file join $rdiRoot $rule_part]
          if {[file exists $path_test]} {
            set rule_path $path_test
            break
          }
        }
        if {$rule_path ne ""} {
          set result [::drcv::load_rule_data_file $rule_path]
          set drcv_connected $result    
        }
      }
    } catch_res] } {
      #TODO: This doesn't appear to work so early in the flow because
      # can't read "vivado_warn_file": no such variable
      #warning2file [pwd] "failed to connect to rulecheck server: $catch_res"
      puts "WARNING: failed to connect to rulecheck server - $catch_res"
    }
  }
  proc is_drcv {} {
    if { $ocl_util::drcv_connected } { return true }
    return false
  }

  # Dummy proc "OPTRACE".  Needs to be created in case the real OPTRACE proc
  # isn't inserted
  if { [expr {[llength [info procs ::OPTRACE]] == 0}] } {
    proc ::OPTRACE {{arg1 \"\" } {arg2 \"\"} {arg3 \"\" } {arg4 \"\"} {arg5 \"\" } {arg6 \"\"}} {
        # Do nothing
    }
  }

  # TODO: originally used for non-unified paltform only, might be useful, keep it for now
  proc is_sdaccel_debug {} {
    set is_dbg false
    if { [info exists ::env(SDACCEL_DEBUG)] } {
      set is_dbg [expr bool($::env(SDACCEL_DEBUG))]
    }
    return $is_dbg
  }; # end is_sdaccel_debug


  # added by vamshi, TODO: add comments to explain why this is needed
  proc update_kernel_clocks { kernel_clock_freqs } {

    dict for {kernel_clk dict_clock} $kernel_clock_freqs {
      set kernel_clk_inst [string range $kernel_clk 0 [string last _ $kernel_clk]-1]
      set clk_freq [dict get $dict_clock freq]
      set is_user_set   [dict get $dict_clock is_user_set]

      if { [string equal -nocase $is_user_set "true" ] } {
        set clkFreqHZ [expr {int($clk_freq*1000000)}]
        set kernel_clk_inst_cell [get_bd_cells $kernel_clk_inst]
        if { $kernel_clk_inst_cell ne ""} {
          set_property -dict [list CONFIG.FREQ_HZ $clkFreqHZ] [get_bd_cells $kernel_clk_inst]
        } else {
          puts "Warning: Unable to update the Kernel Frequency. No BD cell matched $kernel_clk_inst"
        }
      }
    }
  }; # end update_kernel_clocks

  #Procedure to return kernel name for a given run
  proc get_kernel_name_from_run {kernel_run} {
    set cand_fs [get_property srcset $kernel_run]
    if {[get_property fileset_type $cand_fs] != "BlockSrcs"} {return}
    set cand_files [get_files -of_objects $cand_fs -norecurse]
    if {[llength $cand_files] != 1} {return}
    set cand_file [lindex $cand_files 0]
    if {[get_property FILE_TYPE $cand_file] != "IP"} {return}
    set cand_ip [get_ips -all [get_property IP_TOP $cand_file]]
    if {$cand_ip == {}} {return}
    set prop_val [get_property SDX_KERNEL $cand_ip]
    if {[get_property SDX_KERNEL $cand_ip] && [get_property SDX_KERNEL_TYPE $cand_ip] eq "hls"} {
      set fields [split [get_property IPDEF $cand_ip] ":"]
      lassign $fields vender slibrary ipname version
      return $ipname
    }
  }

  ################################################################################
  # log_generated_reports
  # utility function called by tcl proc run_synthesis and run_implementation
  #   Description: 
  #      
  #   Arguments:
  #      log_file
  #      runs 
  ################################################################################

  # Procedure for tracking report files
  proc log_generated_reports {log_file runs} {
    set failed [catch {
      set generated_reports_fh [open $log_file a]
      puts $generated_reports_fh [join [get_generated_reports $runs] "\n"]
      close $generated_reports_fh
    } _error]
    if { $failed } {
      puts "WARNING: Failed while trying to create a log with all generated reports, error: '${_error}'"
      puts "         The flow will continue, but generated reports may not be listed correctly."
    }
  }

  # Assemble the content of the generated reports log
  proc get_generated_reports {runs} {
    set log_content {}
    foreach run $runs {
      set props [list_property $run STEPS.*.REPORTS]
      foreach prop $props {
        set run_step_reports [get_property $prop $run]
        foreach run_step_report $run_step_reports {
          set report_obj [get_report_configs $run_step_report]
          if { [llength $report_obj] > 0 } {        
            set output_file [get_property OUTPUT_FILE $report_obj]
            # NOTE: report_type has <report_command>:<version>
            set report_type [get_property REPORT_TYPE $report_obj]
            set report_type_list [split ${report_type} ":"]
            set report_command [lindex ${report_type_list} 0]
            set version [lindex ${report_type_list} 1]
            set report_name [get_property NAME $report_obj]
            set kernel_name [get_kernel_name_from_run $run]
            if { $output_file != "" } {
              set file_path [file join [get_property directory $run] $output_file]
              lappend log_content "${report_command}|${version}|${report_name}|${file_path}|${kernel_name}"
            }
          }
        }
      }
    }
    return $log_content
  }

  ################################################################################
  # create_vivado_project
  # utility function called by create_project step
  #   Description: create the vivado project
  #      
  #   Arguments:
  #      hw_platform_info
  #      config_info 
  ################################################################################
  proc create_vivado_project {hw_platform_info config_info} {
    set hw_platform_state   [dict get $hw_platform_info hw_platform_state] 
    set hw_platform_dr_bd   [dict get $hw_platform_info hw_platform_dr_bd] 
    set hw_platform_part    [dict get $hw_platform_info hw_platform_part]
    set hw_platform_rebuild_tcl  [dict get $hw_platform_info hw_platform_rebuild_tcl] 
    set pre_sys_link_tcl    [dict get $hw_platform_info pre_sys_link_tcl] 

    set project_name        [dict get $config_info proj_name] 
    set is_hw_emu           [dict get $config_info is_hw_emu] 
    set steps_log           [dict get $config_info steps_log] 
    set output_dir          [dict get $config_info output_dir]

    # NOTES: The location where pre_sys_link should be sourced has a long history
    # 1.source the pre_sys_link_tcl before sourcing the rebuild.tcl (soc platform case)
    # 2.pre_sys_link_tcl must be sourced before importing bd (pcie platform case)
    # 3.http://jira.xilinx.com/browse/CR-1009391
    # Ben: The error occurs during generation, but the root problem occurs if that parameter has not been set 
    # before the IP catalog is loaded. Anything that triggers interaction with IP will cause a catalog load.  
    # 4.Susheel: We assume that pre_sys_link_tcl will not be written assuming a project is open
    # Currently, it is only allowed to set envars and params. 
    # This Tcl is more like an init.tcl that is exercised even before creating a project
    source_pre_sys_link_tcl $hw_platform_info $config_info

    OPTRACE "START" "Create project" 

    if { [string equal $hw_platform_state "pre_synth"] } {
      # pre_synth platform 
      #   soc platform (usesPR = false)  
      #     hw flow    : source rebuild.tcl to populate vivado project (including importing dr bd)
      #     hw_emu flow: source rebuild.tcl to populate vivado project
      #   pcie platform (i.e. kyle's usecase) (usesPR = true)
      #     hw flow    : source rebuild.tcl to populate vivado project
      #     hw_emu flow: create vivado project
      # note: example of running hw_emu flow for soc platform, /proj/testcases/fisusr/sdaccel/sdx_canary_HEAD/sdsoc/cosim_hello_vadd_ocl_102/
      # note: hw_platform_dr_bd is empty for soc platform 
      if { $is_hw_emu && $hw_platform_dr_bd ne "" && [file exists $hw_platform_dr_bd] } {
        # pcie platform + hw_emu flow 
        add_to_steps_log $steps_log "internal step: create_project -part $hw_platform_part -force $project_name $project_name" [fileName]:[lineNumber [info frame]]
        create_project -part $hw_platform_part -force $project_name $project_name
      } else {
        # The purpose for using a rebuild.tcl flow is to guarantee a match with the behavior of
        # open_hw_platform.

        # soc platform + hw/hw_emu flow; pcie_platform + hw flow
        set hw_platform_prj_dir [file dirname $hw_platform_rebuild_tcl]
        set ::origin_dir_loc $hw_platform_prj_dir
        puts "INFO: \[OCL_UTIL\] set ::origin_dir_loc $hw_platform_prj_dir"
        set ::user_project_name $project_name
        puts "INFO: \[OCL_UTIL\] set ::user_project_name $project_name"
 
        add_to_steps_log $steps_log "internal step: source $hw_platform_rebuild_tcl to create $project_name project" [fileName]:[lineNumber [info frame]]
        if { [catch {source $hw_platform_rebuild_tcl} result return_options_dict] } {
          # Return code is not zero, so result is an error message
          set sw_persona_msg "Failed to rebuild a project required for hardware synthesis. "
          append sw_persona_msg "The project is '$project_name'. The rebuild script is "
          append sw_persona_msg "'$hw_platform_rebuild_tcl'. The rebuild script was delivered as "
          append sw_persona_msg "part of the hardware platform. Consult with the hardware platform "
          append sw_persona_msg "provider to investigate the rebuild script contents."
          OPTRACE "END" "Create project"
          exception2file $output_dir $sw_persona_msg $result $return_options_dict
        }
      }
    } else {
      # post_impl platform (pcie only at least for 2019.1)
      #   hw_emu flow: create vivado project 
      #   hw flow    : create vivado project, create reconfigurable module and pr configuration
      if { $is_hw_emu } {
        # hw_emu flow, create the vivado project 
        add_to_steps_log $steps_log "internal step: create_project -part $hw_platform_part -force $project_name $project_name" [fileName]:[lineNumber [info frame]]
        create_project -part $hw_platform_part -force $project_name $project_name
      } else {
        # hw flow, create the vivado porject, add the bb_locked dcp to the design, 
        #          create partition def and reconfig module for pcie platform
        create_project_and_init_rm_pcie $hw_platform_info $config_info
      }
    }
    set_property tool_flow SDx [current_project]

    OPTRACE "END" "Create project"
  }

  ################################################################################
  #   create_system_diagram_metadata
  #
  #   Description: Updates an existing system diagram metadata file in the input
  #                directory with kernel utilization data from the 
  #                run steps: synthed, placed, and routed.
  #      
  #   Arguments:
  #     run_step   - The run step being examined: synthed, placed, or routed.
  #     input_dir  - The input directory (where systemDiagramModel.json can be found)
  #     output_dir - The output directory (where the utilization json files can be found)
  ################################################################################
  proc create_system_diagram_metadata { run_step input_dir output_dir } {
    # -- Predetermined files
    set system_diagram_model_file "$input_dir/systemDiagramModel.json"
    set kernel_util_synthed_file "$output_dir/kernel_util_synthed.json"
    set kernel_util_placed_file "$output_dir/kernel_util_placed.json"
    set kernel_util_routed_file "$output_dir/kernel_util_routed.json"
    set output_file "$output_dir/systemDiagramModel_${run_step}.json"
    set valid_run_step 0

    set command_and_options [list "merge_kernel_utilization"]

    # -- Remove any files that shouldn't be part of a given run step
    if { [expr {$run_step eq "synthed"}] } {
      set kernel_util_placed_file ""
      set kernel_util_routed_file ""
      set valid_run_step 1
    }

    if { [expr {$run_step eq "placed"}] } {
      set kernel_util_routed_file ""
      set valid_run_step 1
    }

    if { [expr {$run_step eq "routed"}] } {
      set valid_run_step 1
    }

    if { $valid_run_step == 0} {
      puts "CRITICAL WARNING: Run step '${run_step}' not supported for merge_kernel_utilization. Skipping operation."
      return
    }

    # -- Check to see if the files exist
    # SystemDiagramModel.json
    if { [file exists $system_diagram_model_file] == 1} {  
      lappend command_and_options "-diagram_json_file"
      lappend command_and_options "$system_diagram_model_file"
    } else {
      puts "CRITICAL WARNING: Input file '${system_diagram_model_file}' for merge_kernel_utilization missing. Skipping operation."
      return
    }

    # kernel_util_synthed.json
    if { [expr {$kernel_util_synthed_file ne ""}] } {
      if { [file exists $kernel_util_synthed_file] == 1} {  
        lappend command_and_options "-merge_utilization_file"
        lappend command_and_options "${kernel_util_synthed_file}"
      }
    }

    # kernel_util_placed_file.json
    if {[expr {$kernel_util_placed_file ne ""}] } {
      if { [file exists $kernel_util_placed_file] == 1} {  
        lappend command_and_options "-merge_utilization_file"
        lappend command_and_options "${kernel_util_placed_file}"
      }
    }

    # kernel_util_routed_file.json
    if {[expr {$kernel_util_routed_file ne ""}] } {
      if { [file exists $kernel_util_routed_file] == 1} {  
        lappend command_and_options "-merge_utilization_file"
        lappend command_and_options "${kernel_util_routed_file}"
      }
    }

    # Output option
    lappend command_and_options "-output_file"
    lappend command_and_options "${output_file}"

    # -- Execute rtd2SystemDiagram
    puts "sub-cmd: ${command_and_options}"

    # Catch ALL errors and continue if they should occur
    if {[catch {eval $command_and_options} results]} {
      puts -nonewline "CRITICAL WARNING: "
    } 

    # Print out the output results from executing merge_kernel_utilization
    puts ${results}
  }


  ################################################################################
  # Expected to be used by VPL script generator
  #
  ################################################################################
  proc source_pre_sys_link_tcl {hw_platform_info config_info} {
    set pre_sys_link_tcl    [dict get $hw_platform_info pre_sys_link_tcl] 
    set steps_log           [dict get $config_info steps_log] 
    set output_dir          [dict get $config_info output_dir] 
    set project_name        [dict get $config_info proj_name]

    if { ![string equal $pre_sys_link_tcl ""] && [file exists $pre_sys_link_tcl] } {
      OPTRACE "START" "Source pre_sys_link Tcl script" 
      global env
      add_to_steps_log $steps_log "internal step: source $pre_sys_link_tcl" [fileName]:[lineNumber [info frame]]
      if { [catch {source $pre_sys_link_tcl} result return_options_dict] } {
        set sw_persona_msg "Failed to configure a project required for hardware synthesis. "
        append sw_persona_msg "The project is '$project_name'. The configuration script is "
        append sw_persona_msg "'$pre_sys_link_tcl'. The configuration script was delivered as "
        append sw_persona_msg "part of the hardware platform."
        OPTRACE "END" "Source pre_sys_link Tcl script"
        exception2file $output_dir $sw_persona_msg $result $return_options_dict
      }
      OPTRACE "END" "Source pre_sys_link Tcl script"
    }
  }

  ################################################################################
  # create_project_and_init_rm_pcie
  # utility function called by tcl proc create_vivado_project
  #   Description: Directly creates and configures a project with a reconfigurable
  #     module; this tcl proc is used for pcie platform and hw flow only
  # 
  #   Assumptions:
  #   - The hardware platform state is 'impl' (supports implementation)
  #   - build target is 'hw'
  #
  #   Arguments:
  #      hw_platform_info
  #      config_info 
  ################################################################################
  proc create_project_and_init_rm_pcie {hw_platform_info config_info} {
    set hw_platform_dr_bd   [dict get $hw_platform_info hw_platform_dr_bd] 
    set hw_platform_part    [dict get $hw_platform_info hw_platform_part]
    set bb_locked_dcp       [dict get $hw_platform_info bb_locked_dcp]
    set uses_pr_shell_dcp   [dict get $hw_platform_info uses_pr_shell_dcp]
    set link_output_format  [dict get $hw_platform_info link_output_format]
    set pr_shell_dcp        [dict get $hw_platform_info pr_shell_dcp]
    set ocl_inst_path       [dict get $hw_platform_info ocl_region]

    set project_name        [dict get $config_info proj_name] 
    set steps_log           [dict get $config_info steps_log] 
    set partition_def       [dict get $config_info partition_def]
    set reconfig_module     [dict get $config_info reconfig_module]
    set output_dir          [dict get $config_info output_dir]

    # -- Create the project --
    add_to_steps_log $steps_log "internal step: create_project -part $hw_platform_part -force $project_name $project_name" [fileName]:[lineNumber [info frame]]
    create_project -part $hw_platform_part -force $project_name $project_name

    puts "INFO: \[OCL_UTIL\] set_property design_mode GateLvl \[current_fileset\]"
    set_property design_mode GateLvl [current_fileset]
    puts "INFO: \[OCL_UTIL\] set_property PR_FLOW 1 \[current_project\]"
    if { [catch {set_property PR_FLOW 1 [current_project]} catch_res return_options_dict] } {
      add_to_steps_log $steps_log "status: fail" [fileName]:[lineNumber [info frame]] 
      set sw_persona_msg "Failed to configure a project required for hardware synthesis. "
      append sw_persona_msg "The project is '$project_name'. Exception when setting project properties "
      append sw_persona_msg "for dynamic function exchange. Consult with the hardware platform provider "
      append sw_persona_msg "to investigate the platform state."
      OPTRACE "END" "Create project"
      exception2file $output_dir $sw_persona_msg $catch_res $return_options_dict
    }

    # Memory initialization isn't support, speed up flow by disabling creation
    # of the BMM / MMI file.
    set_property mem.enable_memory_map_generation 0 [current_project]

    # support bb_locked dcp (enhanced link_design pr flow)
    # bb_locked dcp should always be there for unified platforms since 2018.1
    # abstract shell dcp in 2018.2 only supports FaaS
    # if AcceleratorBinaryContent is set to "bitstream" or "pdi", we should use bb_locked dcp
    # if AcceleratorBinaryContent is set to "dcp", abstract shell dcp should take precedence
    # necessary error check has already been done in frontend, we can only consider the valid usecase here
    if { $bb_locked_dcp ne "" || $uses_pr_shell_dcp} {
      if { [string equal $link_output_format "bitstream"] || [string equal $link_output_format "pdi"] } {  
        set hw_platform_dcp $bb_locked_dcp
      } else {
        set hw_platform_dcp [expr { $uses_pr_shell_dcp ? $pr_shell_dcp : $bb_locked_dcp} ] 
      }

      add_to_steps_log $steps_log "internal step: add_files $hw_platform_dcp" [fileName]:[lineNumber [info frame]]
      add_files $hw_platform_dcp

      # -- Create the partion and rm that will contain the bd
      # use dr_bd base name as the dr top
      set dr_top [file rootname [file tail $hw_platform_dr_bd]]
      add_to_steps_log $steps_log "internal step: create_partition_def -name $partition_def -module $dr_top" [fileName]:[lineNumber [info frame]]
      create_partition_def -name $partition_def -module $dr_top
      add_to_steps_log $steps_log "internal step: create_reconfig_module -name $reconfig_module -partition_def \[get_partition_defs $partition_def \] -top $dr_top" [fileName]:[lineNumber [info frame]]
      create_reconfig_module -name $reconfig_module -partition_def [get_partition_defs $partition_def ] -top $dr_top

      puts "INFO: \[OCL_UTIL\] set_property use_blackbox_stub false \[get_filesets $reconfig_module -of_objects \[get_reconfig_modules $reconfig_module\]\]"
      set_property use_blackbox_stub false [get_filesets $reconfig_module -of_objects [get_reconfig_modules $reconfig_module]]
      puts "INFO: \[OCL_UTIL\] set_property USE_BLACKBOX_STUB 0 \[get_partition_defs $partition_def\]"
      set_property USE_BLACKBOX_STUB 0 [get_partition_defs $partition_def]

      # create pr configuration and set properties on it
      # set_pr_config $hw_platform_info $config_info
      # -- Create the PR configuration alone with data on where the BD will go --
      set config_name "config_1"
      add_to_steps_log $steps_log "internal step: create_pr_configuration -name $config_name -partitions \[list $ocl_inst_path:$reconfig_module\]" [fileName]:[lineNumber [info frame]]
      create_pr_configuration -name $config_name -partitions [list $ocl_inst_path:$reconfig_module]
      # disable the generation of the cell level checkpoints for RMs during post bitstream 
      set_property AUTO_IMPORT 0 [get_pr_configuration $config_name]
      # disable the generation of wrapper black box checkpoint during post bitstream
      set_property USE_BLACKBOX 0 [get_pr_configuration $config_name]
      puts "INFO: \[OCL_UTIL\] set_property PR_CONFIGURATION $config_name \[get_runs impl_1\]"
      set_property PR_CONFIGURATION $config_name [get_runs impl_1]
    }
  }

  ################################################################################
  # apply_constrs_for_impl
  # utility function called by generate_target step
  #   Description: add _post_sys_link_gen_constrs.xdc which is generated by sourcing post_sys_link_tcl 
  #      
  #   Arguments:
  #      hw_platform_info
  #      config_info 
  ################################################################################
  proc apply_constrs_for_impl {hw_platform_info config_info} {
    set impl_xdc            [dict get $hw_platform_info impl_xdc] 

    set steps_log           [dict get $config_info steps_log] 
    set output_dir          [dict get $config_info output_dir] 
    set enable_dont_partition  [dict get $config_info enable_dont_partition]

    # impl_constrs support
    add_xdc_files $impl_xdc $steps_log
  
    # read the _post_sys_link_gen_constrs.xdc generated by sourcing post_sys_link_tcl
    set post_sys_link_gen_xdc "_post_sys_link_gen_constrs.xdc"
    if { [file exists $post_sys_link_gen_xdc] } {
      add_to_steps_log $steps_log "internal step: add_files $post_sys_link_gen_xdc" [fileName]:[lineNumber [info frame]]
      add_files $post_sys_link_gen_xdc
    }
  
    # when executed in the non-design environment, read_xdc is same as add_files
    apply_dont_partition $enable_dont_partition $steps_log $output_dir

  }

  ################################################################################
  # check_impl_run_status
  # utility function called by impl step
  #   Description: log generated implementation report files, check the implementation
  #                run status
  #      
  #   Arguments:
  #      hw_platform_info
  #      config_info
  ################################################################################
  proc check_impl_run_status {hw_platform_info config_info} {
    set steps_log           [dict get $config_info steps_log] 
    set output_dir          [dict get $config_info output_dir] 

    # capture impl reports
    set run_dir [get_property DIRECTORY [get_runs impl_1]]
    set generated_reports_log [file join $output_dir "generated_reports.log"]
    set report_impl_runs [get_runs -filter {IS_IMPLEMENTATION==1}]
    add_to_steps_log $steps_log "internal step: log_generated_reports for implementation '${generated_reports_log}'" [fileName]:[lineNumber [info frame]]
    log_generated_reports $generated_reports_log $report_impl_runs

    # check impl run status
    set run_status [get_property STATUS [get_runs impl_1]]
    # puts "--- DEBUG: run_status is $run_status"
    if { [string match "*ERROR" $run_status] } {
      add_to_steps_log $steps_log "internal step: problem implementing dynamic region, ($run_status)" [fileName]:[lineNumber [info frame]]
      add_to_steps_log $steps_log "status: fail ($run_status)" [fileName]:[lineNumber [info frame]]
      add_to_steps_log $steps_log "log: $run_dir/runme.log" [fileName]:[lineNumber [info frame]]
      error2file $output_dir "problem implementing dynamic region, $run_status, please look at the run log file '$run_dir/runme.log' for more information" 
    }
  }

  ################################################################################
  # copy_impl_run_output_files
  # utility function called by impl step
  #   Description: log generated implementation report files, check the implementation
  #                run status
  #      
  #   Arguments:
  #      hw_platform_info
  #      config_info
  ################################################################################
  proc copy_impl_run_output_files {hw_platform_info config_info} {
    set link_output_format  [dict get $hw_platform_info link_output_format]
    set hw_platform_uses_pr [dict get $hw_platform_info hw_platform_uses_pr]

    set output_dir          [dict get $config_info output_dir] 
    set out_partial_bit     [dict get $config_info out_partial_bitstream]
    set out_partial_pdi     [dict get $config_info out_partial_pdi]
    set out_partial_clear_bit  [dict get $config_info out_partial_clear_bit]
    set out_full_bit        [dict get $config_info out_full_bitstream]
    set out_full_pdi        [dict get $config_info out_full_pdi] 
    set encrypt_impl_dcp    [dict get $config_info encrypt_impl_dcp]
    set clbinary_name       [dict get $config_info clbinary_name]
    set reconfig_module     [dict get $config_info reconfig_module]

    # aws dcp support
    set run_dir [get_property DIRECTORY [get_runs impl_1]]
    # copy the post-route dcp to vivado output directory
    if { [string equal $link_output_format "dcp"] } {
      if { $encrypt_impl_dcp} {
        set routed_dcp [glob -nocomplain "$run_dir/encrypted_routed.dcp"]
      } else {
        set routed_dcp [glob -nocomplain "$run_dir/*_routed.dcp"]
      }
      set out_routed_dcp "$output_dir/routed.dcp"
      if { ![string equal $routed_dcp ""] } {
        file copy -force $routed_dcp $out_routed_dcp
      }
    } elseif { [string equal $link_output_format "bitstream"] } {
      # copy the generated bit files to vivado output dir 
      if { $hw_platform_uses_pr } {
        # there could be one partial bit and one partial clear bit files.
        # kcu1500 generates both bit files while vcu1525 only generats the partial bit file
        set partial_bit [glob -nocomplain "$run_dir/*_partial.bit"]
        set partial_clear_bit [glob -nocomplain "$run_dir/*_partial_clear.bit"]
        # puts "--- DEBUG: partial_bit is $partial_bit"
        # puts "--- DEBUG: partial_clear_bit is $partial_clear_bit"

        if { ![string equal $partial_bit ""] && [file exists $partial_bit] } {
          file copy -force $partial_bit $out_partial_bit
        }
        if { ![string equal $partial_clear_bit ""] && [file exists $partial_clear_bit] } {
          file copy -force $partial_clear_bit $out_partial_clear_bit
        }

      } else {
        # flat flow (i.e. zynq)
        set full_bit [glob -nocomplain "$run_dir/*.bit"]
        if { ![string equal $full_bit ""] && [file exists $full_bit] } {
          file copy -force $full_bit $out_full_bit
        }
      }
    } elseif { [string equal $link_output_format "pdi"] } {
      # copy the generated pdi file to vivado output dir
      if { $hw_platform_uses_pr } {
        set partial_pdi [glob -nocomplain "$run_dir/*_partial.pdi"]
        # when run property "GEN_FULL_BITSTREAM" is set to true, we may end up with multiple 
        # partial pdi files. as of 07/26/19, the write_device_image command that generates the full
        # pdi file doesn't have "-no_partial_pdifile"
        if {[llength $partial_pdi] > 1} {
          set partial_pdi [glob -nocomplain "$run_dir/*${reconfig_module}_partial.pdi"]
          if {$partial_pdi ne ""} {
            puts "INFO: multiple partial pdi files detected, use '$partial_pdi' as the primary output"
          } else {
            puts "ERROR: multiple partial pdi files detected, but there is none that matches '*${reconfig_module}_partial.pdi'"
            error2file $output_dir "no proper partial pdi file generated"
          }
        }
        if { ![string equal $partial_pdi ""] && [file exists $partial_pdi] } {
          file copy -force $partial_pdi $out_partial_pdi
        }
      } else {
        set full_pdi [glob -nocomplain "$run_dir/*.pdi"] 
        if { ![string equal $full_pdi ""] && [file exists $full_pdi] } { 
          file copy -force $full_pdi $out_full_pdi
        }
      } 
    } 

    # Copy LTX files up to ipi dir
    # CR 1011484: copy *just* debug_nets.ltx and rename it to <binary>.ltx
    set ltx_file [glob -nocomplain "$run_dir/debug_nets.ltx"]
    if {$ltx_file ne ""} {
       set out_ltx_file "$clbinary_name.ltx"
       catch {file copy -force $ltx_file $output_dir/$out_ltx_file}
    }
  }

  ################################################################################
  # set_board_part_repo_and_connections
  # utility function called by create_bd step
  #   Description: set board_part_repo_paths and board_connections properties on current project
  #      
  #   Arguments:
  #      config_info 
  #      bd_file is an output argument
  #
  #   Reference: http://confluence.xilinx.com/display/XSW/Support+Board+DIMM+Modeling+-+Framework+Spec
  ################################################################################
  proc set_board_part_repo_and_connections {hw_platform_info config_info} {
    set hw_platform_board_repo     [dict get $hw_platform_info hw_platform_board_repo]
    set hw_platform_board_part     [dict get $hw_platform_info hw_platform_board_part]
    set hw_platform_bconn_locked   [dict get $hw_platform_info hw_platform_bconn_locked]
    set hw_platform_bconn_unlocked [dict get $hw_platform_info hw_platform_bconn_unlocked]
   
    set user_board_repo            [dict get $config_info user_board_repo]
    set user_bconn                 [dict get $config_info user_bconn]

    # set board_part_repo_paths property on current project. $user has higher priority than $hw_platform (first one wins)
    # set_board_repo_paths_property $user_board_repo $hw_platform_board_repo
    set board_repo [list]
    if { $user_board_repo ne "" } {
      lappend board_repo {*}$user_board_repo
    }
    if { $hw_platform_board_repo ne "" } {
      lappend board_repo {*}$hw_platform_board_repo
    }
    if { $board_repo ne "" } {
      puts "INFO: \[OCL_UTIL\] set_property board_part_repo_paths $board_repo \[current_project\]"
      set_property board_part_repo_paths $board_repo [current_project]
    } 

    # set the board part
    if {$hw_platform_board_part ne ""} {
      puts "INFO: \[OCL_UTIL\] set_property board_part $hw_platform_board_part \[current_project\]"
      set_property board_part $hw_platform_board_part [current_project]
    }
 
    # set board_connections property on current project. $user has higher priority than $hw_platform_unlocked.
    # $hw_platform_locked cannot be overwritten (last one wins) 
    # set_board_connections_property $hw_platform_bconn_unlocked $user_bconn $hw_platform_bconn_locked
    set board_connections [list]
    if { $hw_platform_bconn_unlocked ne "" } {
      lappend board_connections {*}$hw_platform_bconn_unlocked
    }
    if { $user_bconn ne "" } {
      lappend board_connections {*}$user_bconn
    }
    if { $hw_platform_bconn_locked ne "" } {
      lappend board_connections {*}$hw_platform_bconn_locked
    }
    if { $board_connections ne "" } {
      puts "INFO: \[OCL_UTIL\] set_property board_connections $board_connections \[current_project\]"
      set_property board_connections $board_connections [current_project]
    }

  }

  ################################################################################
  # source_user_pre_sys_link_tcl
  #   utility function called by create_bd step
  #   Description: source the user specified pre_sys_link tcl hook
  #      
  #   Arguments:
  #      hw_platform_info
  #      config_info 
  ################################################################################
  proc source_user_pre_sys_link_tcl {hw_platform_info config_info} {
    set user_pre_sys_link_tcl   [dict get $hw_platform_info user_pre_sys_link_tcl] 

    set dr_bd_tcl           [dict get $config_info dr_bd_tcl] 
    set steps_log           [dict get $config_info steps_log] 
    set output_dir          [dict get $config_info output_dir] 
    set project_name        [dict get $config_info proj_name]
    set return_pre_sys_link_tcl [dict get $config_info return_pre_sys_link_tcl]

    if { ![string equal $user_pre_sys_link_tcl ""] && [file exists $user_pre_sys_link_tcl] } {
      OPTRACE "START" "Sourcing user pre_sys_link Tcl script" 
      add_to_steps_log $steps_log "internal step: source $user_pre_sys_link_tcl" [fileName]:[lineNumber [info frame]]
      if { [catch {source $user_pre_sys_link_tcl} result return_options_dict] } {
        set sw_persona_msg "Failed to update block diagram in project required for hardware synthesis. "
        append sw_persona_msg "The project is '$project_name'. The user supplied update script is "
        append sw_persona_msg "'$user_pre_sys_link_tcl'. The script was provided using parameter "
        append sw_persona_msg "'compiler.userPreSysLinkTcl'."
        OPTRACE "END" "Sourcing user pre_sys_link Tcl script"
        exception2file $output_dir $sw_persona_msg $result $return_options_dict
      }
      OPTRACE "END" "Sourcing user pre_sys_link Tcl script"
    }

    if { $return_pre_sys_link_tcl } {
      puts "INFO: return_pre_sys_link_tcl enabled, skip sourcing $dr_bd_tcl and everything after"
      return
    }
  }

  ################################################################################
  # import_dr_bd
  #   utility function called by create_bd step
  #   Description: import the dr bd 
  #      
  #   Arguments:
  #      hw_platform_info 
  #      config_info 
  ################################################################################
  proc import_dr_bd {hw_platform_info config_info} {
    set hw_platform_dr_bd   [dict get $hw_platform_info hw_platform_dr_bd] 
    set hw_platform_state   [dict get $hw_platform_info hw_platform_state] 
    set emu_src_dir         [dict get $hw_platform_info emu_src_dir]

    set is_hw_emu           [dict get $config_info is_hw_emu] 
    set steps_log           [dict get $config_info steps_log] 
    set reconfig_module     [dict get $config_info reconfig_module]
    set explicit_emu_data   [dict get $config_info enable_explicit_emu_data]

    # post_impl platform (pcie: platformState = post_impl && usesPR = true`)
    #   hw flow    : import the dr bd from hw_platform, and associate it with the reconfigurable module 
    #   hw_emu flow: import the emu dr bd (i.e. emu/emu.bd) from hw_platform
    #
    # pre_synth platform
    #   soc platform (usesPR = false)
    #     hw     flow: no need to import the dr bd, it is already done as part of rebuild.tcl
    #     hw_emu flow: no need to import the dr bd, it is already done as part of rebuild.tcl
    #   pcie platform (i.e. kyle' usecase) (usesPR = true)
    #     hw     flow: no need to import the dr bd, it is already done as part of rebuild.tcl
    #     hw_emu flow: import the emu dr bd (i.e. emu.bd) from hw_platform
      # note: hw_platform_dr_bd is empty for soc platform
    if { [string equal $hw_platform_state "pre_synth"] } {
      # pre_synth platform
      if { $is_hw_emu && $hw_platform_dr_bd ne "" && [file exists $hw_platform_dr_bd] } {
        # pcie platform + hw_emu flow (for kyle)
        add_to_steps_log $steps_log "internal step: import_files -norecurse $hw_platform_dr_bd" [fileName]:[lineNumber [info frame]]
        import_files -norecurse $hw_platform_dr_bd 
      }
    } else {
      # post_impl platform
      set rm_switch ""
      if { !$is_hw_emu} {
        set rm_switch "-of_objects [get_reconfig_modules $reconfig_module]"
      }
      add_to_steps_log $steps_log "internal step: import_files -norecurse $hw_platform_dr_bd $rm_switch" [fileName]:[lineNumber [info frame]]
      # we should use import_files to copy the bd file to the local project
      #   1. the temporaray location might be read-only 
      #   2. user could potentially delete the temporary location
      import_files -norecurse $hw_platform_dr_bd {*}$rm_switch

      # hw_emu re-arch 2019.2 (explicity emu data support)
      # import all the sources files in the emu src directory
      if {$is_hw_emu && $explicit_emu_data} {
        if {$emu_src_dir ne ""} {
          set emu_source_files [glob -nocomplain "$emu_src_dir/*"]
          foreach emu_source $emu_source_files {
            add_to_steps_log $steps_log "internal step: import_files -fileset sim_1 -norecurse $emu_source" [fileName]:[lineNumber [info frame]]
            import_files -fileset sim_1 -norecurse $emu_source
          }
          update_compile_order -fileset sim_1
        }
      }
    }
  }

  proc get_bd_file {hw_platform_info config_info} {
    set hw_platform_dr_bd   [dict get $hw_platform_info hw_platform_dr_bd] 
    set dr_bd_name          [dict get $hw_platform_info dr_bd_name] 
    set hw_platform_state   [dict get $hw_platform_info hw_platform_state] 

    set is_hw_emu           [dict get $config_info is_hw_emu] 

    # starting 2018.3 hw_platform captures the dr_bd_name (the bd file name)
    # for pcie platform, the dr_bd_name refers to the regular dr bd used by hw flow,
    # so, we can *not* use dr_bd_name for hw_emu flow
    # note: we should be able to use dr_bd_name for soc platform + hw_emu flow
    if {$dr_bd_name ne "" && !$is_hw_emu} {
      # pcie platform + hw flow; soc platform + hw flow
      set bd_file $dr_bd_name
    } else {
      # pcie platform + hw_emu flow
      # get the base file name of $hw_platform_dr_bd (i.e. emu.bd)
      set bd_file [file tail $hw_platform_dr_bd]

      # old soc platform (where dr_bd_name is not captured in the hw platform metadata)
      # for soc platform, there is no dr_bd file captured in the hw platform
      # we assume there is only bd in the project after sourcing rebuild.tcl
      if { [string equal $hw_platform_state "pre_synth"] } {
        set bd_file [file tail [lindex [get_files *.bd] 0]]
      }
    }
    return $bd_file
  }

  ################################################################################
  # source_post_sys_link_tcls
  #   utility function called by update_bd step
  #   Description: source post_sys_link and user_post_sys_link tcl hooks
  #      
  #   Arguments:
  #      hw_platform_info 
  #      config_info 
  ################################################################################
  proc source_post_sys_link_tcls {hw_platform_info config_info} {
    set post_sys_link_tcl   [dict get $hw_platform_info post_sys_link_tcl] 
    set user_post_sys_link_tcl [dict get $hw_platform_info user_post_sys_link_tcl] 

    set steps_log           [dict get $config_info steps_log] 
    set output_dir          [dict get $config_info output_dir] 
    set project_name        [dict get $config_info proj_name]

    # post_sys_link_tcl needs to be sourced after sourcing dr_bd_tcl
    if { ![string equal $post_sys_link_tcl ""] && [file exists $post_sys_link_tcl] } {
      OPTRACE "START" "Sourcing hardware platform post_sys_link Tcl script" 
      add_to_steps_log $steps_log "internal step: source $post_sys_link_tcl" [fileName]:[lineNumber [info frame]]
      if { [catch {source $post_sys_link_tcl} result return_options_dict] } {
        set sw_persona_msg "Failed to update block diagram in project required for hardware synthesis. "
        append sw_persona_msg "The project is '$project_name'. The update script is "
        append sw_persona_msg "'$post_sys_link_tcl'. The update script was delivered as "
        append sw_persona_msg "part of the hardware platform."
        OPTRACE "END" "Sourcing hardware platform post_sys_link Tcl script"
        exception2file $output_dir $sw_persona_msg $result $return_options_dict
      }
      # this generates a xdc file _post_sys_link_gen_constrs.xdc

      # bd validation is not needed here. sourcing a post-sys-link tcl hook *could* change the bd, in 
      # which case, it is hw_platform developer's responsibility to call validation in that tcl hook

      set post_sys_link_gen_xdc "_post_sys_link_gen_constrs.xdc"
      if { ![file exists $post_sys_link_gen_xdc] } {
        puts "WARNING: the output of $post_sys_link_gen_xdc doesn't exist - $post_sys_link_gen_xdc"
      } else {
        # move the file to output_dir
        if { ![file exists $output_dir/$post_sys_link_gen_xdc] } {
          file rename $post_sys_link_gen_xdc $output_dir
        }
      }
      OPTRACE "END" "Sourcing hardware platform post_sys_link Tcl script"
    }

    if { ![string equal $user_post_sys_link_tcl ""] && [file exists $user_post_sys_link_tcl] } {
      OPTRACE "START" "Validate BD" 
      add_to_steps_log $steps_log "internal step: validate_bd_design -force" [fileName]:[lineNumber [info frame]]
      validate_bd_design -force
      OPTRACE "END" "Validate BD" 

      OPTRACE "START" "Sourcing user post_sys_link Tcl script" 
      add_to_steps_log $steps_log "internal step: source $user_post_sys_link_tcl" [fileName]:[lineNumber [info frame]]
      if { [catch {source $user_post_sys_link_tcl} result return_options_dict] } {
        set sw_persona_msg "Failed to update block diagram in project required for hardware synthesis. "
        append sw_persona_msg "The project is '$project_name'. The user provided update script is "
        append sw_persona_msg "'$user_post_sys_link_tcl'. The script was provided using parameter "
        append sw_persona_msg "'compiler.userPostSysLinkTcl'."
        OPTRACE "END" "Sourcing user post_sys_link Tcl script"
        exception2file $output_dir $sw_persona_msg $result $return_options_dict
      }
      OPTRACE "END" "Sourcing user post_sys_link Tcl script"
    }
  }

  ################################################################################
  # ip_cache_export_and_report
  #   utility function called by generate_target step
  #   Description: ip earch cache check and (optionally) generate ip cache report file
  #      
  #   Arguments:
  #      config_info 
  #      bd_file 
  ################################################################################
  proc ip_cache_export_and_report {config_info bd_file} {
    set no_ip_cache         [dict get $config_info no_ip_cache] 
    set ip_cache_report     [dict_get_default $config_info ip_cache_report {}]
    set steps_log           [dict get $config_info steps_log] 

    # ip early cache check (if an ip is already generated, this prevents an occ run to be created for that ip)
    if { !$no_ip_cache } { 
      add_to_steps_log $steps_log "internal step: config_ip_cache -export \[get_ips -all -of_object \[get_files $bd_file\]\]" [fileName]:[lineNumber [info frame]]
      catch {config_ip_cache -export [get_ips -all -of_object [get_files $bd_file]]}

      if { $ip_cache_report ne "" } {
        # Create a single file with all the information correctly formatted as JSON.
        # It would be nice to just have the ::debug::debug_cache_miss build the file,
        # but it only takes one IP at a time. And just appending to a file doesn't add
        # the JSON open and close braces, and separator commas needed. JSON is nice,
        # but not entirely flexible in its application. And this is probably slightly
        # more efficient since we aren't opening and closing the file repeatedly.
        set report_file [open $ip_cache_report "w"]
        puts $report_file "{ \"ips\": \["
        set first_entry true
        foreach file [get_files *.xci] { 
          if {$first_entry} {
            set first_entry false
          } else { 
            puts $report_file ","
          }
          set json_entry [::debug::debug_cache_miss $file -json]
          puts -nonewline $report_file $json_entry
        }
        puts $report_file ""
        puts $report_file "\] }"
      }
    }
  }

  ################################################################################
  # set_ip_repo_and_caching
  #   utility function called by create_bd step
  #   Description: set ip_repo_path and ip caching environment
  #      
  #   Arguments:
  #      hw_platform_info
  #      config_info 
  ################################################################################
  proc set_ip_repo_and_caching {hw_platform_info config_info} {
    set hw_platform_ip_repo     [dict get $hw_platform_info hw_platform_ip_repo] 
    set hw_platform_ip_cache    [dict get $hw_platform_info hw_platform_ip_cache] 
    set emu_user_ip_repo        [dict get $hw_platform_info emu_user_ip_repo] 

    set is_hw_emu               [dict get $config_info is_hw_emu] 
    set user_ip_repo            [dict get $config_info user_ip_repo] 
    # set emu_user_ip_repo        [dict get $config_info emu_user_ip_repo] 
    set kernel_ip_dirs          [dict get $config_info kernel_ip_dirs] 
    set install_ip_cache        [dict get $config_info install_ip_cache] 
    set remote_ip_cache         [dict get $config_info remote_ip_cache] 
    set no_ip_cache             [dict get $config_info no_ip_cache] 
    set no_hw_platform_ip_cache [dict get $config_info no_hw_platform_ip_cache] 
    set no_install_ip_cache     [dict get $config_info no_install_ip_cache] 
    set ip_cache_report         [dict_get_default $config_info ip_cache_report {}]
    set steps_log               [dict get $config_info steps_log] 

    OPTRACE "START" "Create IP caching environment" 
    # construct ip_repo_paths with the order below (first one wins)
    #  1. User IP repo from --user_ip_repo_paths
    #  2. User emulation IP repo  -- hw_emu only 
    #     2.1 $::env(SDX_EM_REPO)) 
    #         Obsolete in Vitis, use --user_ip_repo_paths instead
    #     2.2 emu_user_ip_repo from hardware platform emu directory (see "USER_IP_REPO" in emu.xml)
    #  3. Kernel IP definitions (vpl --iprepo switch value)
    #  4. IP definitions from hw_platform IP repo -- hw only
    #  5. IP cache dir from Install area (/proj/xbuilds/2019.2_daily_latest/installs/lin64/Vitis/2019.2/data/cache/xilinx)
    #  6. IP cache stored inside hw_platform
    #  7. $::env(XILINX_VITIS)/data/emulation/hw_em/ip_repo  -- hw_emu only
    #  8. $::env(XILINX_VIVADO)/data/emulation/hw_em/ip_repo  -- hw_emu only
    #  9. Vitis Specific Xilinx IP repo from install area (/proj/xbuilds/2019.2_daily_latest/installs/lin64/Vitis/2019.2/data/ip/)
    # 10. General Xilinx IP repo from install area (/proj/xbuilds/2018.2_daily_latest/installs/lin64/Vivado/2018.2/data/ip/)
    # note: 10 is automatically handled by IP Services as the final fallback, so we don't need to add it explicitly

    # 1. append the user ip repo
    if { $user_ip_repo ne "" } {
      lappend ip_repo_paths {*}$user_ip_repo 
    } 
    # 2. append user emulation ip repo (hw_emu only)
    #    SDX_EM_REPO is not supported in Vitis, use the command line switch
    #    v++ --user_ip_repo_paths (SDX_EM_REPO was introduced for testing
    #    purposes before the command line switch was available)
    # if { $is_hw_emu && [info exists ::env(SDX_EM_REPO)] } {
    #   lappend ip_repo_paths $::env(SDX_EM_REPO)
    # }
    if { $is_hw_emu && $emu_user_ip_repo ne "" } {
      lappend ip_repo_paths $emu_user_ip_repo
    }
    # 3. append kernel ip repo
    lappend ip_repo_paths {*}$kernel_ip_dirs
    # 4. append hw_platform ip repo (hw only) 
    # hw_emu flow uses its own copy of these ip's from $(XILINX_VITIS)/data/emulation/hw_em/ip_repo
    if { $hw_platform_ip_repo ne "" && !$is_hw_emu} {
      lappend ip_repo_paths $hw_platform_ip_repo 
    }
    # 5. append xilinx ip cache dir from install area
    if { !$no_ip_cache && !$no_install_ip_cache && $install_ip_cache ne "" } {
      lappend ip_repo_paths $install_ip_cache 
    }
    # 6. append hw_platform ip cache
    if { !$no_ip_cache && !$no_hw_platform_ip_cache && $hw_platform_ip_cache ne "" } {
      lappend ip_repo_paths $hw_platform_ip_cache 
    }
    # for debug and profiling (hw_emu only)
    if { $is_hw_emu } {
      # 7. append SDX specific xilinx emulation ip repo
      if { [info exists ::env(XILINX_VITIS)] } {
        lappend ip_repo_paths $::env(XILINX_VITIS)/data/emulation/hw_em/ip_repo 
      }
      # 8. append General xilinx emulation ip repo
      if { [info exists ::env(XILINX_VIVADO)] } {
        lappend ip_repo_paths $::env(XILINX_VIVADO)/data/emulation/hw_em/ip_repo 
      }
    }
    # 9. append Vitis Specific xilinx ip repo from install area
    if { [info exists ::env(XILINX_VITIS)] } {
      lappend ip_repo_paths $::env(XILINX_VITIS)/data/ip
    }

    if { $ip_repo_paths ne "" } {
      puts "INFO: \[OCL_UTIL\] setting ip_repo_paths: $ip_repo_paths"
      set_property ip_repo_paths $ip_repo_paths [current_project] 
      add_to_steps_log $steps_log "internal step: update_ip_catalog" [fileName]:[lineNumber [info frame]]
      update_ip_catalog
    }

    # ip caching
    if { $no_ip_cache } { 
      add_to_steps_log $steps_log "internal step: config_ip_cache -disable_cache" [fileName]:[lineNumber [info frame]]
      config_ip_cache -disable_cache
    } else {
      if { $remote_ip_cache ne ""} {
        add_to_steps_log $steps_log "internal step: config_ip_cache -use_cache_location $remote_ip_cache" [fileName]:[lineNumber [info frame]]
        config_ip_cache -use_cache_location $remote_ip_cache
      } 
      # from nabeel: project level cache became default in 2016.3, no need
      # to explicitly call "config_ip_cache -use_project_cache" in else clause
    }

    OPTRACE "END" "Create IP caching environment"
  }

  ################################################################################
  # copy_ooc_xdc_files
  #   utility function called by generate_target step
  #   Description: Copy the OOC constraint files in BD, and add them to the top level 
  #      design in order for the clock constraints to be applied
  #      
  #   Arguments:
  #      bd_file is_hw_emu kernel_clock_freqs output_dir
  ################################################################################
  proc copy_ooc_xdc_files {bd_file kernel_clock_freqs config_info} {
    set is_hw_emu           [dict get $config_info is_hw_emu] 
    set steps_log           [dict get $config_info steps_log] 
    set output_dir          [dict get $config_info output_dir] 

    set var [lineNumber [info frame]]
    set ooc_xdc_files [get_files -of_object [get_files $bd_file] -norecurse -filter { FILE_TYPE == "XDC" && USED_IN =~ "*out_of_context*" }]
    
    foreach ooc_xdc_file $ooc_xdc_files {
      if {![string equal $ooc_xdc_file ""] && [file exists $ooc_xdc_file]} {
        set used_in_value [get_property used_in $ooc_xdc_file]
        set xdc_file_copy "[file rootname [file tail $ooc_xdc_file]]_copy.xdc"
        set xdc_file_copy $output_dir/$xdc_file_copy
        # file copy $ooc_xdc_file ./$xdc_file_copy
        file copy -force $ooc_xdc_file $xdc_file_copy

        if { !$is_hw_emu } { 
          # create a kernel clock constraint for synthesis, and overwrite the default frequency from hw_platform
          add_to_steps_log $steps_log "internal step: writing user synth clock constraints in $xdc_file_copy" [fileName]:[expr [lineNumber [info frame]] + $var]
          write_user_synth_clock_constraint $xdc_file_copy $kernel_clock_freqs
        } 

        add_to_steps_log $steps_log "internal step: add_files $xdc_file_copy -fileset \[current_fileset -constrset\]" [fileName]:[expr [lineNumber [info frame]] + $var]
        set xdc_file_obj [add_files $xdc_file_copy -fileset [current_fileset -constrset]]
        if {$xdc_file_obj ne ""} {
          puts "INFO: \[OCL_UTIL\] set_property used_in $used_in_value $xdc_file_obj"
          set_property used_in $used_in_value $xdc_file_obj
          puts "INFO: \[OCL_UTIL\] set_property processing_order early $xdc_file_obj"
          set_property processing_order "early" $xdc_file_obj
        }
      }
    }
  }

  ################################################################################
  # write_address_map
  #   utility function called by update_bd step
  #   Description: write the address_map.xml file
  #      
  #   Arguments:
  #      output_dir
  ################################################################################
  proc write_address_map { output_dir } {
    # Note: there is already an open bd design

    # create Address Map file
    set xml_file $output_dir/address_map.xml
    set fp [open $xml_file w] 
    set addr_segs [get_bd_addr_segs -hier]
    # puts "--- DEBUG: current_bd_design: [current_bd_design]"
    # puts "--- DEBUG: addr_segs is $addr_segs"
    puts $fp "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    puts $fp "<xd:addressMap xmlns:xd=\"http://www.xilinx.com/xd\">"
    foreach addr_seg $addr_segs {
      set path [get_property PATH $addr_seg]
      set offset [get_property OFFSET $addr_seg]
      # puts "--- DEBUG: addr_seg: $addr_seg\n\tpath: $path\n\toffset: $offset"
      if {$offset != ""} {
        set range [format 0x%X [get_property RANGE $addr_seg]]
        set high_addr [format 0x%X [expr $offset + $range - 1]]
        set slave [get_bd_addr_segs -of_object $addr_seg]

        if { [regexp {([^/]+)/([^/]+)/([^/]+)$} $path match componentRef addressSpace segment] } {

        } elseif { [regexp {([^/]+)/([^/]+)$} $path match addressSpace segment] }  {
          # In this case, address space is an external interface. For now, 
          # just use addressSpace as componentRef
          set componentRef $addressSpace
        } else {
          puts "warning: path doesn't match the regular expression ($path)"
          continue
        }

        if { [regexp {([^/]+)/([^/]+)/([^/]+)$} $slave match slaveRef slaveMemoryMap slaveSegment] } {
          set slaveIntfPin [get_bd_intf_pins -of_objects $slave]                      
        
        } elseif { [regexp {/([^/]+)/([^/]+)$} $slave match slaveMemoryMap slaveSegment] }  {
          # In this case, address segement is an external interface.
          set slaveIntfPin [get_bd_intf_ports -of_objects $slave]                      
          set slaveRef $slaveMemoryMap
        } else {
           puts "warning: slave doesn't match the regular expression ($slave)"
           continue
        }
        # set slaveIntfPin [get_bd_intf_pins -of_objects $slave]

        if { ![regexp {([^/]+)$} $slaveIntfPin match slaveInterface] } {
          puts "warning: slaveIntfPin doesn't match the regular expression ($slaveIntfPin)"
          continue
        }

        puts $fp "  <xd:addressRange xd:componentRef=\"${componentRef}\" xd:addressSpace=\"${addressSpace}\" xd:segment=\"${segment}\" xd:slaveRef=\"${slaveRef}\"\
xd:slaveInterface=\"${slaveInterface}\" xd:slaveSegment=\"${slaveSegment}\" xd:baseAddr=\"${offset}\" xd:range=\"${range}\"/>" 
      } 
    } 
    puts $fp "</xd:addressMap>"
    close $fp
  }

  ################################################################################
  # create_bitstreams_without_implementation
  # utility function called by interactive step
  #   Description: open the implemented checkpoint and run through bitstream
  #      
  #   Arguments:
  #      hw_platform_info
  #      config_info 
  ################################################################################
  # used by --reuse_impl
  proc create_bitstreams_without_implementation { hw_platform_info config_info clk_info } {
    set hw_platform_uses_pr  [dict get $hw_platform_info hw_platform_uses_pr]
    set ocl_inst_path        [dict get $hw_platform_info ocl_region]
    set is_unified           [dict get $hw_platform_info is_unified]

    set design_name      [dict get $config_info design_name]
    set out_partial_bit  [dict get $config_info out_partial_bitstream]
    set out_full_bit     [dict get $config_info out_full_bitstream]
    set steps_log        [dict get $config_info steps_log] 
    set reuse_impl_dcp   [dict get $config_info reuse_impl_dcp] 
    set output_dir       [dict get $config_info output_dir] 
    set clbinary_name    [dict get $config_info clbinary_name]

    set cwd [pwd]

    # open reuse_impl_dcp and run write_bistream
    # open_checkpoint creates a diskless project
    add_to_steps_log $steps_log "internal step: open_checkpoint $reuse_impl_dcp" [fileName]:[lineNumber [info frame]]
    open_checkpoint $reuse_impl_dcp

    # Make sure the part in the checkpoint matches the part in the project.
    set hw_platform_part [dict get $hw_platform_info hw_platform_part]
    set dcp_part [get_property part [current_design]]
    if {[string compare -nocase $hw_platform_part $dcp_part] != 0} {
      puts "ERROR: The supplied design '$reuse_impl_dcp' with part '$dcp_part' does not match the project part '$hw_platform_part'. Please supply a design with the appropriate part when using the --reuse_impl option."
      add_to_steps_log $steps_log "status: fail" [fileName]:[lineNumber [info frame]]
      error2file $output_dir "improper dcp supplied (part mismatch)"
    }

    # Make sure the design is fully routed
    if { ![report_route_status -boolean_check ROUTED_FULLY] } {
      puts "ERROR: The supplied design '$reuse_impl_dcp' is not fully routed. Please supply a routed design when using the --reuse_impl option."
      add_to_steps_log $steps_log "status: fail" [fileName]:[lineNumber [info frame]]
      error2file $output_dir "improper dcp supplied (not routed)"
    }

    # timing check and frequency scaling
    set is_in_run false
    if { ![report_timing_and_scale_freq $ocl_inst_path $is_unified $design_name $output_dir $clk_info $clbinary_name $is_in_run] } {
      return false
    }

    set out_bit $out_full_bit
    set cell_switch ""
    if { $hw_platform_uses_pr } {
      set out_bit $out_partial_bit
      set cell_switch "-cell $ocl_inst_path"
    }

    # to disable the generation of webtalk files (e.g. usage_statistics_webtalk.xml)
    # we want to keep the vivado directory as clean as possible
    config_webtalk -user off

    # TODO: we should add write_device_image support
    add_to_steps_log $steps_log "internal step: write_bitstream $cell_switch -force $out_bit" [fileName]:[lineNumber [info frame]]
    write_bitstream {*}$cell_switch -force $out_bit
  }

  # used to add synth_constrs and impl_constrs files in hw_platform
  proc add_xdc_files {xdc_dict steps_log} { 
    set var [lineNumber [info frame]] 
    foreach xdc_name [dict keys $xdc_dict] {
      set xdc_info [dict get $xdc_dict $xdc_name]
      set file_path [dict get $xdc_info file_path]
      set used_in [dict get $xdc_info used_in]
      set processing_order [dict get $xdc_info processing_order]
  
      if { [string equal $file_path ""] || ![file exists $file_path] } {
        continue;
      }

      add_to_steps_log $steps_log "internal step: add_files $file_path -fileset \[current_fileset -constrset\]" [fileName]:[expr [lineNumber [info frame]] + $var]
      add_files $file_path -fileset [current_fileset -constrset]
      if {$used_in ne ""} {
        puts "INFO: \[OCL_UTIL\] set_property USED_IN \"$used_in\" \[get_files $file_path\]"
        set_property USED_IN $used_in [get_files $file_path]
      }
      if {$processing_order ne ""} {
        puts "INFO: \[OCL_UTIL\] set_property PROCESSING_ORDER \"$processing_order\" \[get_files $file_path\]"
        set_property PROCESSING_ORDER $processing_order [get_files $file_path]
      }
    }
  }

  ################################################################################
  # generate_kernel_inst_path_data
  #   utility function called by config_simualtion step for hw_emu flow
  #   Description: write the _kernel_inst_paths.dat file
  #      
  #   Arguments:
  #      steps_log, output_dir
  ################################################################################
  proc generate_kernel_inst_path_data { steps_log output_dir} { 
    add_to_steps_log $steps_log "internal step: creating $output_dir/_kernel_inst_paths.dat" [fileName]:[lineNumber [info frame]]
    set outfile [open "$output_dir/_kernel_inst_paths.dat" w]
    puts $outfile "# This file was automatically generated by Vpl"
    puts $outfile "version: 1.0"

    # bd is already open at this point, verify with get_bd_design or current_bd_design
    # puts "--- DEBUG: current_bd_design:\n[join [current_bd_design] \n]"

    set bd_name [get_property name [current_bd_design]]

    set instances [get_bd_cells -quiet -hier -filter "SDX_KERNEL==true"]
    # puts "--- DEBUG: bd cells: $instances:"
    if { [llength $instances] > 0 } { 
      foreach instance $instances {
        # $instance returns "/OCL_Region_0/adder_stage_cu0"
        # we need to prepend the wrapper and bd name
        # puts "--- DEBUG: instance properties:"
        # report_property $instance
        # get the ip component name (xilinx.com:hls:vadd:1.0)
        set vlnv [get_property VLNV $instance]
        # we are only interested in the "name" portion
        set vlnv_list [split $vlnv ":"]
        set name [lindex $vlnv_list 2]
        
        set kernel_inst [get_property SDX_KERNEL_INST $instance]
        set kernel_type [get_property SDX_KERNEL_TYPE $instance]
        # puts "--- DEBUG: bd cell: $instance; kernel_inst: $kernel_inst; kernel_type: $kernel_type"
        set instance "/${bd_name}_wrapper/${bd_name}_i$instance"
        puts $outfile "$name:"
        puts $outfile "   instance path: $instance"
        puts $outfile "   type: $kernel_type"
      }
    }

    close $outfile
  }

  ################################################################################
  # check_synth_runs_status
  # utility function called by tcl proc run_synthesis
  #   Description: log generated synthesis report files and check the synthesis runs status
  #      
  #   Arguments:
  #      steps_log err_str
  #   
  #   return false if any run fails
  ################################################################################
  proc check_synth_runs_status { steps_log output_dir} {
    # upvar $err_str _err_str

    # capture synth reports
    set generated_reports_log [file join $output_dir "generated_reports.log"]
    set report_synth_runs [get_runs -filter {IS_SYNTHESIS==1}]
    add_to_steps_log $steps_log "internal step: log_generated_reports for synthesis '${generated_reports_log}'" [fileName]:[lineNumber [info frame]]
    log_generated_reports $generated_reports_log $report_synth_runs

    # check for any run failure
    # and write the "cookie file" for Dennis' messaging support
    set any_run_not_done false
    set runs [get_runs -filter {IS_SYNTHESIS == 1}]
    # puts "--- DEBUG: get_filesets: [get_filesets]"
    set var [lineNumber [info frame]]

    foreach _run $runs {
      set run_name [get_property NAME $_run]
      # puts "--- DEBUG: run: $run_name"
      set run_status [get_property STATUS $_run]
      set run_dir [get_property DIRECTORY $_run]
      set run_fileset [get_property SRCSET $_run]
      # puts "--- DEBUG: run_fileset: $run_fileset"

      # having a run returned by get_runs does NOT guarantee the run dir would exist
      if { ![file exists $run_dir] } {
        puts "INFO: \[OCL_UTIL\] the run directory for run '$run_name' doesn't exist"
        continue;
      }
      #info frame returns line number of current stack inside foreach loop. So adding the line numbers to get current line number
      add_to_steps_log $steps_log "internal step: launched run $run_name" [fileName]:[expr [lineNumber [info frame]] + $var]

      # generate the cookie file for Dennis' messaging support
      set cookie_file $run_dir/.runmsg.txt
      set outfile [open $cookie_file w]
      
      # single project flow, the "top" level synthesis run is not synth_1, it is <rm>_synth_1
      # it is associated with reconfig module
      set fs_obj [get_filesets $run_fileset]
      # puts "--- DEBUG: fs_obj is '$fs_obj'"
      if { $fs_obj == "" } {
        # this fileset is associated with reconfig module, get_filesets without -of_object returns empty
        puts $outfile "Compiling (reconfig module level synthesis checkpoint) dynamic region"
      } elseif { [string equal $run_name "synth_1"] } {
        # TODO: hard-coded "synth_1
        puts $outfile "Compiling (top level synthesis checkpoint) dynamic region"
      } else {
        set ip_file [get_files -norecurse -of_objects $fs_obj]
        # puts "--- DEBUG: ip_file: $ip_file"
        # ip_top is only applicable to ip file type
        set file_type [get_property FILE_TYPE $ip_file]
        set ip_top ""
        if { [string equal -nocase $file_type "ip"] } {
          set ip_top [get_property IP_TOP $ip_file] 
          # puts "--- DEBUG: ip_top: $ip_top"
        }

        puts $outfile "Compiling (synthesis checkpoint) kernel/IP: $ip_top"
      }
      puts $outfile "Log file: $run_dir/runme.log"
      close $outfile

      # puts "--- DEBUG: run '$_run' has status '$run_status'"
      if { [string equal $run_status "synth_design ERROR"] } {
        puts "ERROR: run '$_run' failed, please look at the run log file '$run_dir/runme.log' for more information"
        append _err_str "\nrun '$_run' failed, please look at the run log file '$run_dir/runme.log' for more information"
        add_to_steps_log $steps_log "status: fail" [fileName]:[expr [lineNumber [info frame]] + $var]
        add_to_steps_log $steps_log "log: $run_dir/runme.log" [fileName]:[expr [lineNumber [info frame]] + $var]
        set any_run_not_done true
      }
      if { [string equal $run_status "Scripts Generated"] } {
        puts "ERROR: run '$_run' couldn't start because one or more of the prerequisite runs failed"
        append _err_str "\nrun '$_run' couldn't start because one or more of the prerequisite runs failed"
        set any_run_not_done true
      }
    }

    if {$any_run_not_done} {
      error2file $output_dir "One or more synthesis runs failed during dynamic region dcp generation $_err_str"
      # return false
    }

    # return true
  }

  proc get_hw_platform_resources { xpfm_file } {

    # Set default values until we find valid ones.
    dict set resources brams -1
    dict set resources dsps -1
    dict set resources luts -1
    dict set resources registers -1

    # Look for resource data in the platform.
    set devices_q [::platform::query -xpfm $xpfm_file -key hardwarePlatform.devices]
    # Even if devices_q is empty, we can call the following:
    set devices_dict [::json::json2dict $devices_q]
    if {[dict exists $devices_dict devices]} {
      # The following just navigates over the "devices" key of the tree.
      set devices_dict [dict get $devices_dict devices]
    }
    if {[llength $devices_dict] == 1 && [dict exists [lindex $devices_dict 0] core]} {
      set core_dict [dict get [lindex $devices_dict 0] core]
      if {[dict exists $core_dict bramCount] && [dict exists $core_dict dspCount] &&
          [dict exists $core_dict lutCount] && [dict exists $core_dict registerCount]} {
        dict set resources brams [dict get $core_dict bramCount]
        dict set resources dsps [dict get $core_dict dspCount]
        dict set resources luts [dict get $core_dict lutCount]
        dict set resources registers [dict get $core_dict registerCount]
      }
    }

    if {[dict get $resources brams] == -1} {
      puts "Could not find expected resource data in platform '$xpfm_file'. Utilization will not be reported."
    }
    return $resources
  }

  proc write_utilization_drc { config_info hw_platform_info outfile } {
    set enable_util_report  [dict get $config_info enable_util_report] 
    if { [string length $enable_util_report] eq 0 } {
      puts "INFO: post-synthesis utilization DRC check skipped"
      return
    }

    set xpfm_file [dict get $hw_platform_info xpfm_file]
    set ocl_inst_path [dict get $hw_platform_info ocl_region]
    set threshold   [dict get $config_info utilization_threshold] 
    set steps_log   [dict get $config_info steps_log] 
    set output_dir  [dict get $config_info output_dir] 
    set input_dir   [dict get $config_info input_dir] 

    # when this tcl hook runs, we know we are in prj/prj.runs/impl_1/, so we need to go 3 levels up
    set output_dir "../../../$output_dir"
    set input_dir "../../../$input_dir"
    # ocl_inst_path may be empty for SoC platforms
    puts $outfile "ocl_util::report_utilization_drc $xpfm_file \"$ocl_inst_path\" $threshold $steps_log $input_dir $output_dir"
  }

  ################################################################################
  # after open_bd_design report on the status of the IPs.
  #
  # Look for all the IPs and get the locked status property on the
  # vivado netlist. The rule is in the ocl_rules.cfg file.
  ################################################################################
  proc report_ips_drc { config_info } {
    set output_dir          [dict get $config_info output_dir] 
    set steps_log           [dict get $config_info steps_log] 

    set all_kernel_ips [get_ips -quiet -all]
    set size_all_ips [llength $all_kernel_ips]

    if { $size_all_ips > 0 } {
      foreach kernel_ip $all_kernel_ips {
        set lockstatus   [get_property IS_LOCKED $kernel_ip]
        set lockdetails  [get_property LOCK_DETAILS $kernel_ip]

        if { $lockstatus == 1 } {
          warning2file $output_dir "WARNING: IP is locked."
          if {[is_drcv]} { 
            ::drcv::create_violation IP-LOCK-01 -s $kernel_ip -s $lockdetails 
          }
        }
      }
      add_to_steps_log $steps_log "internal step: report locked IPs" [fileName]:[lineNumber [info frame]] 
    }
  }

  # After synthesis, check utilization of the device and report problems
  proc report_utilization_drc { xpfm_file ocl_inst_path threshold steps_log input_dir output_dir } {
    
    # Get resources available from the hw_platform
    set utilization [get_hw_platform_resources $xpfm_file]
    set availluts   [dict get $utilization luts]
    set availregisters      [dict get $utilization registers]
    set availbrams  [dict get $utilization brams]
    set availdsps   [dict get $utilization dsps]

    set cwd [pwd]

    puts "Post-synthesis utilization DRC check..."
    puts "available resources:" 
    puts "   luts      : $availluts"
    puts "   registers : $availregisters"
    puts "   brams     : $availbrams"
    puts "   dsps      : $availdsps"

    # get the utilization numbers for dynamic region
    # The following would include platform logic
    # puts "utilization: [get_utilization]"
    set cells {}
    if {$ocl_inst_path ne ""} {
      set cells [get_cells $ocl_inst_path]
    }
    if {[llength $cells] eq 0} {
      # Couldn't find the dynamic region (SoC platform?), so look for kernels
      set cells [get_cells -hier -filter SDX_KERNEL==true]
      if {[llength $cells] eq 0} {
        puts "WARNING: Could not find any kernels, nor the dynamic region, in the design. Utilization DRC skipped."
        return
      }
    }
    set ocl_utils [get_utilization -cells $cells]

    # Compare the utilization with ones from hw_platform
    # First set values to 0, in case the utilization doesn't report any.
    set luts 0
    set registers 0
    set brams 0
    set dsps 0
    foreach util $ocl_utils {
      # puts "demand utilization is $util"
      set utilspec [split $util ":"]
      # puts "[lindex $utilspec 0] [lindex $utilspec 1] [lindex $utilspec 2]"
      if {[string equal -nocase [lindex $utilspec 0] "LUT"]} {
        set luts [lindex $utilspec 1]
      }
      if {[string equal -nocase [lindex $utilspec 0] "REG"]} {
        set registers [lindex $utilspec 1]
      }
      if {[string equal -nocase [lindex $utilspec 0] "BRAM"]} {
        set brams [lindex $utilspec 1]
      }
      if {[string equal -nocase [lindex $utilspec 0] "DSP"]} {
        set dsps [lindex $utilspec 1]
      }
    } 
    puts "required resources:"
    puts "   luts      : $luts"
    puts "   registers : $registers"
    puts "   brams     : $brams"
    puts "   dsps      : $dsps"
    
    # if hw_platform doesn't contains utilization data, the avilable resource number would be set to -1
    if { $availluts == -1 || $availregisters == -1 || $availbrams == -1 || $availbrams == -1 } {
      puts "WARNING: There is no resource utilization data in hardware platform, utilization DRC is skipped"
    }

    if { $availluts != -1 && $luts >= $threshold * $availluts} {
      warning2file $output_dir "CRITICAL WARNING: The available LUTs may not be sufficient to accommodate the kernels"
      if {[is_drcv]} { ::drcv::create_violation ACCELERATOR-FIT-04 -d $luts -d $availluts -f $threshold }
    }
    if { $availregisters != -1 && $registers >= $threshold * $availregisters} {
      warning2file $output_dir "CRITICAL WARNING: The available Registers may not be sufficient to accommodate the kernels"
      if {[is_drcv]} { ::drcv::create_violation ACCELERATOR-FIT-03 -d $registers -d $availregisters -f $threshold }
    }
    if { $availbrams != -1 && $brams >= $threshold * $availbrams} {
      warning2file $output_dir "CRITICAL WARNING: The available BRAMs may not be sufficient to accommodate the kernels"
      if {[is_drcv]} { ::drcv::create_violation ACCELERATOR-FIT-02 -f $brams -f $availbrams -f $threshold }
    }
    if { $availdsps != -1 && $dsps >= $threshold * $availdsps} {
      warning2file $output_dir "CRITICAL WARNING: The available DSPs may not be sufficient to accommodate the kernels"
      if {[is_drcv]} { ::drcv::create_violation ACCELERATOR-FIT-01 -d $dsps -d $availdsps -f $threshold }
    }
    
    # generate the utilization reports, one for each kernel
    set kernel_util_string ""
    # puts "--- DEBUG:  generating kernel utilization reports after dynamic region dcp synthesis"
    foreach kernel_inst [get_kernel_cells $ocl_inst_path] {
      if { ![string equal $kernel_inst ""] } {
        # puts "--- DEBUG: kernel instance is $kernel_inst"
        # report_property $kernel_inst
        # get the kernel name (for hls kernel, the orig_ref_name seems to be the kernel name) 
        set kernel [get_property ORIG_REF_NAME $kernel_inst]

        # vadd_cu0/inst
        set ki_split [split $kernel_inst "/"]
        # assume the second to the last element is the kernel instance name (i.e. "mmult_cu1")
        # this is not reliable, but couldn't figure out a better way
        set kernel_inst_base [lindex $ki_split end-1]

        set kernel_util_string "$kernel_util_string $kernel:$kernel_inst:$kernel_inst_base"
      }
    }

    if {$kernel_util_string ne ""} {
      # report_sdx_utilization is replace by report_accelerator_utilization
      # puts "INFO: \[OCL_UTIL\] report_accelerator_utilization -kernels \"$kernel_util_string\" -file \"$output_dir/kernel_util_synthed.rpt\" -name kernel_util_synthed"
      report_accelerator_utilization -kernels "$kernel_util_string" -file "$output_dir/kernel_util_synthed.rpt" -name kernel_util_synthed -json
      create_system_diagram_metadata "synthed" $input_dir $output_dir
    }
  }

  ################################################################################
  # create_run_script_map_file
  # utility function called by config_hw_runs step
  #   Description: used for "--export_script"
  #      
  #   Arguments:
  ################################################################################
  proc create_run_script_map_file { run_type output_dir {kernels ""} } {
    # get all the kernels
    if { $kernels eq "" && [string equal $run_type "synth"] } {
      set instances [get_bd_cells -quiet -hier -filter "SDX_KERNEL==true"]
      # puts "--- DEBUG: bd cells: $instances:"
      if { [llength $instances] > 0 } { 
        foreach instance $instances {
          # $instance returns "/OCL_Region_0/adder_stage_cu0"
          # get the ip component name (xilinx.com:hls:vadd:1.0)
          set vlnv [get_property VLNV $instance]
          # we are only interested in the "name" portion
          set vlnv_list [split $vlnv ":"]
          set name [lindex $vlnv_list 2]
          lappend kernels $name
        }
      }
    }
    # puts "--- DEBUG: kernels: $kernels"

    # the cwd is "ipi"
    set file_exist [file exists "$output_dir/run_script_map.dat"]
    set outfile [open "$output_dir/run_script_map.dat" a+]
    
    # header
    if { !$file_exist} {
      puts $outfile "#"
      puts $outfile "# Run script mapping file created by Vpl"
      puts $outfile "#"
      puts $outfile "# This is the template file for user to use custom script feature"
      puts $outfile "# Format: <run name>: <custom script>"
      puts $outfile "# Usage:"
      puts $outfile "#   User can modify this file directly, to specify a custom script for a particular run,"
      puts $outfile "#   first find the entry below that matches the run name, uncomment it, replace the default"
      puts $outfile "#   run script with the *absolute* path to the custom script"
      puts $outfile "#   note: do NOT use the original (default) run script as the custom script"
      puts $outfile "# Note: if the custom script doesn't exist, it will be ignored by vivado"
    }

    # <run name> : <run driver script>
    if { [string equal $run_type "synth"] } { 
      set runs [get_runs -filter {IS_SYNTHESIS == 1}]
      puts $outfile ""
      puts $outfile "# ################"
      puts $outfile "# Synthesis runs"
      puts $outfile "# ################"
    } else {
      set runs [get_runs -filter {IS_IMPLEMENTATION == 1}]
      puts $outfile ""
      puts $outfile "# #################"
      puts $outfile "# Implmentation runs"
      puts $outfile "# #################"
    }

    # group the runs, list the kernel ooc runs first
    # for synthesis, there are three groups - top level, kernel ooc, other ip ooc
    set top_level ""
    set kernel_ooc ""
    set other_ooc ""
    foreach _run $runs {
      set run_name [get_property NAME [get_runs $_run]]
      if { [string equal $run_name "synth_1"] || [string equal $run_name "impl_1"] } {
        lappend top_level $_run
        continue;
      } 
     
      set kernel_ooc_run_found false
      foreach _kernel $kernels {
        if { [string match "*_${_kernel}_*" $run_name] } {
          lappend kernel_ooc $_run
          set kernel_ooc_run_found true
          break;
        }
      }
      if { $kernel_ooc_run_found } {
        continue;
      }
      
      lappend other_ooc $_run
    }

    # top level runs, i.e. synth_1 or impl_1
    if { [llength $top_level] > 0 } {
      puts $outfile "#"
      puts $outfile "# top level runs"
      puts $outfile "# ---------------------------------------"
    }

    foreach _run $top_level {
      set run_dir [get_property DIRECTORY [get_runs $_run]]
      set run_name [get_property NAME [get_runs $_run]]
      # get the run driver script
      set run_script [glob -nocomplain "$run_dir/*.tcl"]

      puts $outfile ""
      puts $outfile "# $run_name: $run_script"
    }

    # kernel ooc runs
    if { [llength $kernel_ooc] > 0 } {
      puts $outfile "#"
      puts $outfile "# kernel ooc runs"
      puts $outfile "# ---------------------------------------"
    }

    foreach _run $kernel_ooc {
      set run_dir [get_property DIRECTORY [get_runs $_run]]
      set run_name [get_property NAME [get_runs $_run]]
      # get the run driver script
      set run_script [glob -nocomplain "$run_dir/*.tcl"]

      if { $run_script ne ""} { 
        puts $outfile ""
        puts $outfile "# $run_name: $run_script"
      }
    }

    # other ooc runs (supporting ips)
    if { [llength $other_ooc] > 0 } {
      puts $outfile "#"
      puts $outfile "# supporting ip ooc runs"
      puts $outfile "# ---------------------------------------"
    }

    foreach _run $other_ooc {
      set run_dir [get_property DIRECTORY [get_runs $_run]]
      set run_name [get_property NAME [get_runs $_run]]
      # get the run driver script
      set run_script [glob -nocomplain "$run_dir/*.tcl"]

      if { $run_script ne ""} { 
        puts $outfile ""
        puts $outfile "# $run_name: $run_script"
      }
    }

    close $outfile
  }
  
  proc lineNumber {frame_info} {
    set result [dict get [info frame $frame_info] line]
    return "$result"
  }
  
  proc fileName {} {
    set script_path [dict get [info frame 0] file] 
    return "$script_path"
  }
  
  proc extFileName {} {
    set script_path [ info script ]
    return "$script_path"
  }
  
  proc add_to_steps_log { steps_log content file_name {indent "   "} } {
    # this is not a fatal problem from flow's perspective, hence using WARNING
    if { [catch {set outfile [open $steps_log a+]} catch_res] } {
      puts "WARNING: problem opening file $steps_log: $catch_res"
    }

    # echo the message
    puts "INFO: \[OCL_UTIL\] $content"

    set tool_flow "VPL"
    if { [string match "internal step:*" $content] } {
      puts $outfile "${indent}-----------------------"
      puts $outfile "${indent}$tool_flow $content"
      puts $outfile "${indent}File: $file_name"
    
      # get current timestamp
      set systemTime [clock seconds]
      puts $outfile "${indent}timestamp: [clock format $systemTime -format {%d %B %Y %H:%M:%S}]"
    } else {
      puts $outfile "${indent}$tool_flow $content"
    }

    close $outfile
  }

  ################################################################################
  # write_vpl_tcl_hooks
  # utility function called by config_hw_runs step
  #   Description: write the _vpl_* tcl hooks
  #      
  #   Arguments:
  #     hw_platform_info
  #     config_info
  #     clk_info
  ################################################################################
  proc write_vpl_tcl_hooks {hw_platform_info config_info clk_info} {
    set steps_log        [dict get $config_info steps_log] 

    add_to_steps_log $steps_log "internal step: creating vpl tcl hooks for implementation run" [fileName]:[lineNumber [info frame]]
    write_vpl_pre_init_hook $config_info
    write_vpl_post_init_hook $hw_platform_info $config_info $clk_info 
    write_vpl_pre_opt_hook $config_info $hw_platform_info
    write_vpl_post_opt_hook $config_info $hw_platform_info
    write_vpl_pre_place_hook $hw_platform_info $config_info $clk_info 
    write_vpl_post_place_hook $config_info $hw_platform_info
    write_vpl_post_route_hook $hw_platform_info $config_info $clk_info 
    write_vpl_post_post_route_phys_opt_hook $config_info
    write_vpl_post_write_bit_pdi_hook $config_info
  }

  proc write_init_cmds_for_run {outfile local_dir} {
    global vivado_error_file
    global vivado_warn_file

    puts $outfile "if { !\[info exists _is_init_cmds\] } {"
    puts $outfile "  set vivado_error_file $vivado_error_file"
    puts $outfile "  set vivado_warn_file $vivado_warn_file"
    puts $outfile ""

    # import ocl_util::* tcl procs so that 'ocl_util::' prefix is not needed
    # puts $outfile "source [ dict get [ info frame 0 ] file ]"
    # to increase the portability, we copy ocl_util to local (ipi directory)
    puts $outfile "  source ../../../$local_dir/ocl_util.tcl"
    puts $outfile "  source ../../../$local_dir/platform.tcl"
    puts $outfile "  namespace import ocl_util::*"
    # puts $outfile "# get_script_dir returns [get_script_dir]"
    puts $outfile ""
    puts $outfile "  set _is_init_cmds true"
    puts $outfile "}"
    puts $outfile ""
  }

  proc write_vpl_pre_init_hook { config_info } {
    set scripts_dir      [dict get $config_info scripts_dir] 
    set local_dir        [dict get $config_info local_dir] 
    set tclhook_prefix   [dict get $config_info tclhook_prefix] 
  
    set vpl_pre_init_tcl "$scripts_dir/${tclhook_prefix}_pre_init.tcl"
    set outfile [open $vpl_pre_init_tcl w]
    # puts $outfile "puts \"sourcing $vpl_pre_init_tcl\""

    puts $outfile "# This file was automatically generated by Vpl"
    write_init_cmds_for_run $outfile $local_dir

    close $outfile
  }

  # --kernel_frequency support for implementation (i.e. adding clock constraints)
  # for single project flow only
  proc write_vpl_post_init_hook { hw_platform_info config_info clk_info } {
    set ocl_inst_path    [dict get $hw_platform_info ocl_region]
    set steps_log        [dict get $config_info steps_log] 
    set scripts_dir      [dict get $config_info scripts_dir] 
    set output_dir       [dict get $config_info output_dir]  
    set tclhook_prefix   [dict get $config_info tclhook_prefix] 
    set kernel_clock_freqs     [dict get $clk_info kernel_clock_freqs]  

    set vpl_post_init_tcl "$scripts_dir/${tclhook_prefix}_post_init.tcl"
    set outfile [open $vpl_post_init_tcl w]
    puts $outfile "# This file was automatically generated by Vpl"
    puts $outfile "write_user_impl_clock_constraint \"$ocl_inst_path\" \"$kernel_clock_freqs\" \"\" \"../../../$output_dir\"" 

    close $outfile
  }

  proc write_vpl_pre_opt_hook { config_info hw_platform_info } {
    set ocl_inst_path    [dict get $hw_platform_info ocl_region]
    set scripts_dir      [dict get $config_info scripts_dir] 
    set local_dir        [dict get $config_info local_dir] 
    set tclhook_prefix   [dict get $config_info tclhook_prefix] 
    
    # failfast_config is only available for unified platform
    set failfast_config ""
    if { [dict exists $config_info failfast_config] } {
      set failfast_config  [dict get $config_info failfast_config]  
    }

    set vpl_pre_opt_tcl "$scripts_dir/${tclhook_prefix}_pre_opt.tcl"
    set outfile [open $vpl_pre_opt_tcl w]

    puts $outfile "# This file was automatically generated by Vpl"
    write_init_cmds_for_run $outfile $local_dir

    write_utilization_drc $config_info $hw_platform_info $outfile

    if { [dict exists $failfast_config pre_opt_design] } {
      set failfast_args [dict get $failfast_config pre_opt_design]
      if { [llength $failfast_args] == 0} {
        set failfast_args ""
      }
      # added on 4/9/2018 - to support macro expansion for reporting
      report_failfast_helper $config_info $hw_platform_info $failfast_args $outfile
    }
    
    close $outfile
  }

  ## helper for failfast macro expansion
  proc report_failfast_helper {config_info hw_platform_info failfast_args outfile} {
      # added on 4/9/2018 - to support macro expansion for reporting
      set ocl_inst_path [dict get $hw_platform_info ocl_region]
      if { [string equal $failfast_args "__OCL_TOP__"] } {
        # If the ocl_region is empty (SoC), then drop the -pblock and -cell
        if { [string equal $ocl_inst_path ""] } {
          puts $outfile "if {\[catch {::tclapp::xilinx::designutils::report_failfast -detailed_report full.postopt -file full.postopt.failfast.rpt} _error\]} {"
          puts $outfile "  puts \"The report_failfast command failed with message '\${_error}', the flow will continue but this report will be missing.\""
          puts $outfile "}"
        } else {
          set ocl_inst_escaped [string map {/ _} $ocl_inst_path]
          puts $outfile "set oclPblock \[get_pblocks -quiet -filter {PARENT==ROOT && EXCLUDE_PLACEMENT} -of \[get_cells $ocl_inst_path/*\]\] "
          puts $outfile "if {\[catch {::tclapp::xilinx::designutils::report_failfast -detailed_report $ocl_inst_escaped.postopt -file $ocl_inst_escaped.postopt.failfast.rpt -pblock \$oclPblock -cell $ocl_inst_path} _error\]} {"
          puts $outfile "  puts \"The report_failfast command failed with message '\${_error}', the flow will continue but this report will be missing.\""
          puts $outfile "}"
        }
      } elseif { [string equal $failfast_args "__SLR__"] } {
        puts $outfile "if {\[catch {::tclapp::xilinx::designutils::report_failfast -detailed_report bySLR.postplace -file bySLR.postplace.failfast.rpt -by_slr} _error\]} {"
        puts $outfile "  puts \"The report_failfast command failed with message '\${_error}', the flow will continue but this report will be missing.\""
        puts $outfile "}"
      } elseif { [string equal $failfast_args "__KERNEL_NAMES__"] } {
        puts $outfile "foreach kernel_inst \[::ocl_util::get_kernel_cells \"$ocl_inst_path\"\] {"
        # get the kernel name (for hls kernel, the orig_ref_name seems to be the kernel name) 
        puts $outfile "  set kernel_name \[get_property ORIG_REF_NAME \$kernel_inst\]"
        puts $outfile "  set oclPblock \[get_pblocks -quiet -filter {PARENT==ROOT && EXCLUDE_PLACEMENT} -of \[get_cells \$kernel_inst\]\] "
        puts $outfile "  # Skip if oclPblock is empty, SoC Platforms will match this criteria"
        puts $outfile "  if {!\[string equal \$oclPblock \"\"\]} {"
        puts $outfile "    if {\[catch {::tclapp::xilinx::designutils::report_failfast -show_resource -detailed_report \$kernel_name.postsynth -file \$kernel_name.postsynth.failfast.rpt -cell \$kernel_inst -pblock  \$oclPblock} _error\]} {"
        puts $outfile "      puts \"The report_failfast command failed with message '\${_error}', the flow will continue but this report will be missing.\""
        puts $outfile "    }"
        puts $outfile "  }"
        puts $outfile "}"
      } else {
        puts $outfile "if {\[catch {::tclapp::xilinx::designutils::report_failfast $failfast_args} _error\]} {"
        puts $outfile "  puts \"The report_failfast command failed with message '\${_error}', the flow will continue but this report will be missing.\""
        puts $outfile "}"
      }
    }

  proc write_vpl_post_opt_hook { config_info hw_platform_info} {
    set ocl_inst_path    [dict get $hw_platform_info ocl_region]
    set scripts_dir      [dict get $config_info scripts_dir] 
    set tclhook_prefix   [dict get $config_info tclhook_prefix] 
    set failfast_config  [dict get $config_info failfast_config]  

    set vpl_post_opt_tcl "$scripts_dir/${tclhook_prefix}_post_opt.tcl"
    set outfile [open $vpl_post_opt_tcl w]
    puts $outfile "# This file was automatically generated by Vpl"

    if { [dict exists $failfast_config post_opt_design] } {
      set failfast_args [dict get $failfast_config post_opt_design]
      if { [llength $failfast_args] == 0} {
        set failfast_args ""
      }
      # added on 4/9/2018 - to support macro expansion for reporting
      report_failfast_helper $config_info $hw_platform_info $failfast_args $outfile
    }
    
    close $outfile
  }

  proc write_vpl_pre_place_hook { hw_platform_info config_info clk_info } {
    set optimize_level  [dict get $config_info optimize_level]
    set scripts_dir          [dict get $config_info scripts_dir] 
    set local_dir            [dict get $config_info local_dir] 
    set tclhook_prefix       [dict get $config_info tclhook_prefix] 

    # write the kernel clock info file for Steven Li
    set vpl_pre_place_tcl "$scripts_dir/${tclhook_prefix}_pre_place.tcl"
    set outfile [open $vpl_pre_place_tcl w]
    # puts $outfile "puts \"sourcing $vpl_pre_place_tcl\""

    puts $outfile "# This file was automatically generated by Vpl"
    write_init_cmds_for_run $outfile $local_dir

    # move post_init tcl hook to here
    # not sure if we can rename this tcl variable, is it used by any other step, e.g. place_design?
    puts $outfile "set xocc_optimize_level $optimize_level"
    puts $outfile "set_property SEVERITY {Warning} \[get_drc_checks HDPR-5\]"
    # CR 955574 - Turn off BUFG insertion during opt_design
    puts $outfile "set_param logicopt.enableBUFGinsertHFN 0"
    puts $outfile ""

    close $outfile
  }

  proc write_vpl_post_place_hook { config_info hw_platform_info } {
    set enable_util_report   [dict get $config_info enable_util_report] 
    set kernels              [dict get $config_info kernels]
    set scripts_dir          [dict get $config_info scripts_dir] 
    set tclhook_prefix       [dict get $config_info tclhook_prefix] 
    set output_dir           [dict get $config_info output_dir] 
    set input_dir            [dict get $config_info input_dir] 
    set ocl_inst_path        [dict get $hw_platform_info ocl_region]

    set vpl_post_place_tcl "$scripts_dir/${tclhook_prefix}_post_place.tcl"
    set outfile [open $vpl_post_place_tcl w]
    # puts $outfile "puts \"DEBUG: sourcing $vpl_post_place_tcl\""
    puts $outfile "# This file was automatically generated by Vpl"

    # when this tcl hook runs, we know we are in prj/prj.runs/impl_1/, so we need to go 3 levels up
    set output_dir "../../../$output_dir"
    set input_dir "../../../$input_dir"

    # generate the utilization reports after place_design
    puts $outfile "# utilization reports"
    puts $outfile "report_utilization_impl $enable_util_report \"$kernels\" \"placed\" \"$ocl_inst_path\" \"$input_dir\" \"$output_dir\""

    close $outfile
  }

  # timing report/frequency scaling operations are done here
  # if post_route_phys_opt_design is not enabled
  proc write_vpl_post_route_hook { hw_platform_info config_info clk_info } {
    # set hw_platform_dir      [dict get $hw_platform_info hw_platform_dir]
    set ocl_inst_path        [dict get $hw_platform_info ocl_region]
    set is_unified           [dict get $hw_platform_info is_unified]
    set bb_locked_dcp        [dict get $hw_platform_info bb_locked_dcp]
    set pr_shell_dcp         [dict get $hw_platform_info pr_shell_dcp]
    set uses_pr_shell_dcp    [dict get $hw_platform_info uses_pr_shell_dcp]
    set link_output_format   [dict get $hw_platform_info link_output_format]

    set design_name          [dict get $config_info design_name]
    set enable_util_report   [dict get $config_info enable_util_report] 
    set kernels              [dict get $config_info kernels]
    set clbinary_name        [dict get $config_info clbinary_name]
    set encrypt_impl_dcp     [dict get $config_info encrypt_impl_dcp]
    set encrypt_key_file     [dict get $config_info encrypt_key_file]
    set enable_pr_verify     [dict get $config_info enable_pr_verify]
    set local_dir            [dict get $config_info local_dir] 
    set scripts_dir          [dict get $config_info scripts_dir] 
    set output_dir           [dict get $config_info output_dir] 
    set input_dir            [dict get $config_info input_dir] 
    set failfast_config      [dict get $config_info failfast_config]  
    set tclhook_prefix       [dict get $config_info tclhook_prefix] 

    # when this tcl hook runs, we know we are in prj/proj.runs/impl_1/, so we need to go 3 levels up
    set output_dir "../../../$output_dir" 
    set input_dir "../../../$input_dir"

    set vpl_post_route_tcl "$scripts_dir/${tclhook_prefix}_post_route.tcl"
    set outfile [open $vpl_post_route_tcl w]
    # puts $outfile "puts \"DEBUG: sourcing $vpl_post_route_tcl\""

    puts $outfile "# This file was automatically generated by Vpl"
    write_init_cmds_for_run $outfile $local_dir

    puts $outfile ""
    if { $encrypt_impl_dcp } {
      puts $outfile "# generate encrypted implemented checkpoint file"
      puts $outfile "if { !\[file exists encrypted_routed.dcp\] } {"
      puts $outfile "  if { !\[string equal \"$encrypt_key_file\" \"\"\] && \[file exists \"$encrypt_key_file\"\] } {"
      puts $outfile "    write_checkpoint -encrypt encrypted_routed.dcp -key \"$encrypt_key_file\""
      puts $outfile "  } else {"
      puts $outfile "    write_checkpoint -encrypt encrypted_routed.dcp" 
      puts $outfile "  }"
      puts $outfile "}"
      puts $outfile ""
    }
    puts $outfile "# generate cookie file for messaging"
    puts $outfile "write_cookie_file_impl \"$clbinary_name\""
    puts $outfile ""
    puts $outfile "# utilization reports"
    puts $outfile "report_utilization_impl $enable_util_report \"$kernels\" \"routed\" \"$ocl_inst_path\" \"$input_dir\" \"$output_dir\""
    puts $outfile ""

    if {$enable_pr_verify} {
      set hw_platform_dcp [expr { $uses_pr_shell_dcp ? $pr_shell_dcp : $bb_locked_dcp} ] 
      if {$hw_platform_dcp ne ""} {
        # to increase the portability, support relative path
        if { [string first $local_dir $hw_platform_dcp] != -1 } {
          set hw_platform_dcp "../../../$hw_platform_dcp"
        }

        puts $outfile "# verify pr with the hw_platform dcp"
        puts $outfile "pr_verify -in_memory -additional $hw_platform_dcp"
        puts $outfile ""
      }
    }

    # aws dcp support
    # ltx files are generated as part of write_bitstream, since for Faas, we stop at post route_design,
    # we need to run write_debug_probes commands explicitly to generate them
    # CR 1011484: copy *just* debug_nets.ltx and rename it to <binary>.ltx
    if { [string equal $link_output_format "dcp"] } {
      puts $outfile "# generate ltx files"
      puts $outfile "write_debug_probes -force -quiet -no_partial_ltxfile \[format \"%s/%s\" \".\" debug_nets.ltx\]"
      # puts $outfile "write_debug_probes -force -quiet -no_partial_ltxfile \[format \"%s/%s\" \".\" \[get_property TOP \[current_design\]\]\]"
    }

    if { [dict exists $failfast_config post_route_design] } {
      set failfast_args [dict get  $failfast_config post_route_design]
      if { [llength $failfast_args] == 0} {
        set failfast_args ""
      }
      # added on 4/9/2018 - to support macro expansion for reporting
      report_failfast_helper $config_info $hw_platform_info $failfast_args $outfile
    }

    close $outfile
  }

  # create a tcl hook for post post_route_phy_opt_design
  proc write_vpl_post_post_route_phys_opt_hook { config_info } {
    set scripts_dir          [dict get $config_info scripts_dir]
    set tclhook_prefix       [dict get $config_info tclhook_prefix] 

    set vpl_post_phys [open "$scripts_dir/${tclhook_prefix}_post_post_route_phys_opt.tcl" w]
    puts $vpl_post_phys "# This file was automatically generated by Vpl"
    close $vpl_post_phys
  }

  # create a tcl hook for post post_route_phy_opt_design
  proc write_vpl_post_write_bit_pdi_hook { config_info } {
    set scripts_dir          [dict get $config_info scripts_dir]
    set tclhook_prefix       [dict get $config_info tclhook_prefix] 
    set is_hw_export         [dict get $config_info is_hw_export] 
    set output_dir           [dict get $config_info output_dir]
    set fixed_xsa            [dict get $config_info fixed_xsa]

    # when this tcl hook runs, we know we are in prj/prj.runs/impl_1/, so we need to go 3 levels up
    set output_dir "../../../$output_dir"

    set vpl_post_phys [open "$scripts_dir/${tclhook_prefix}_post_write_bit_pdi.tcl" w]
    puts $vpl_post_phys "# This file was automatically generated by Vpl"
    if {$is_hw_export} {
      puts $vpl_post_phys "write_hw_platform -fixed -include_bit $output_dir/$fixed_xsa"
    }
    close $vpl_post_phys
  }

  # runs the report timing and frequency scaling either: 
  #    1. after route_design if post_route_phys_opt_design is not enabled
  # or 2. after post_route_phy_opt_design if enabled
  proc write_report_timing_and_scale_freq { hw_platform_info config_info clk_info is_physopt_enabled} {
    set ocl_inst_path        [dict get $hw_platform_info ocl_region]
    set is_unified           [dict get $hw_platform_info is_unified]
    set design_name          [dict get $config_info design_name]
    set output_dir           [dict get $config_info output_dir]
    set scripts_dir          [dict get $config_info scripts_dir]
    set clbinary_name        [dict get $config_info clbinary_name]
    set tclhook_prefix       [dict get $config_info tclhook_prefix] 

    # when this tcl hook runs, we know we are in prj/prj.runs/impl_1/, so we need to go 3 levels up
    set output_dir "../../../$output_dir"

    if { $is_physopt_enabled } {
      set tcl_hook "${tclhook_prefix}_post_post_route_phys_opt.tcl"
    } else {
      set tcl_hook "${tclhook_prefix}_post_route.tcl"
    }

    # insert a proc at the end of a tcl hook
    set post_hook [open "$scripts_dir/$tcl_hook" a+]
    puts $post_hook ""
    puts $post_hook "# run timing analysis and frequency scaling"
    puts $post_hook "if { !\[report_timing_and_scale_freq \"$ocl_inst_path\" \"$is_unified\" \"$design_name\" \"$output_dir\" \"$clk_info\" \"$clbinary_name\"\] } {"
    puts $post_hook "  return false"
    puts $post_hook "}"
    close $post_hook
  }

  proc report_utilization_impl {enable_util_report kernels run_step ocl_inst_path input_dir output_dir } {
    if { $enable_util_report } { 
      set kernel_util_string ""
      foreach kernel_inst [get_kernel_cells $ocl_inst_path] {
        if { ![string equal $kernel_inst ""] } {
          # puts "--- DEBUG: kernel instance is $kernel_inst"
          # report_property $kernel_inst
          # get the kernel name (for hls kernel, the orig_ref_name seems to be the kernel name) 
          set kernel [get_property ORIG_REF_NAME $kernel_inst]

          # xcl_design_i/expanded_region/u_ocl_region/opencldesign_i/mmult_cu1/inst
          set ki_split [split $kernel_inst "/"]
          # assume the second to the last element is the kernel instance name (i.e. "mmult_cu1")
          # this is not reliable, but couldn't figure out a better way
          set kernel_inst_base [lindex $ki_split end-1]

          set kernel_util_string "$kernel_util_string $kernel:$kernel_inst:$kernel_inst_base"
        }
      }

      if {$kernel_util_string ne ""} {
        # report_sdx_utilization is replace by report_accelerator_utilization
        # puts "INFO: \[OCL_UTIL\] report_accelerator_utilization -kernels \"$kernel_util_string\" -file \"kernel_util_${run_step}.rpt\" -name kernel_util_${run_step}"
        report_accelerator_utilization -kernels "$kernel_util_string" -file "$output_dir/kernel_util_${run_step}.rpt" -name kernel_util_${run_step} -json
        create_system_diagram_metadata $run_step $input_dir $output_dir
      }
    }
  }

  proc write_cookie_file_impl { clbinary_name} { 
    # write the "cookie file" for Dennis' messaging support
    set run_dir [pwd]
    set cookie_file ./.runmsg.txt
    set outfile [open $cookie_file w]
    puts $outfile "Compiling (bitstream) accelerator binary: $clbinary_name"
    puts $outfile "Log file: $run_dir/runme.log"
    close $outfile
  }

  proc report_timing_and_scale_freq {ocl_inst_path is_unified design_name output_dir clk_info clbinary_name {is_in_run true}} {
    set worst_negative_slack    [dict get $clk_info worst_negative_slack]
    set error_on_hold_violation [dict get $clk_info error_on_hold_violation]
    set skip_timing_and_scaling [dict get $clk_info skip_timing_and_scaling]
    set enable_auto_freq_scale  [dict get $clk_info enable_auto_freq_scale]
    set cwd [pwd]

    set new_clk_freq_file "$output_dir/_new_clk_freq" 
    # used for internal developer only
    if {$skip_timing_and_scaling} {
      # puts "INFO: \[OCL_UTIL\] skip_timing_and_scaling is true"
      write_orig_clk_freq $new_clk_freq_file $clk_info
      return true
    }

    # if this tcl proc is executed as part of implementation run, the cwd is vivdo/prj/prj.runs/impl_1
    #    the timing dcp and report files should be generated at the cwd
    # if this tcl proc is executed standalone (e.g. create_bitstreams_without_implementation), the cwd is vivado/
    #    this timing dcp and report files should be generated at vivado/output/
    set timing_output_dir [expr { $is_in_run ? $cwd : $output_dir} ] 
    
    set routed_timing_dcp $timing_output_dir/${design_name}_routed_timing.dcp
    # Check hold violation before trying frequency scaling per Steven's request
    set timingHoldPaths [get_timing_paths -hold -quiet]
    if { [llength $timingHoldPaths] > 0 && [get_property SLACK $timingHoldPaths] < 0} {
      # The command above will return the worst hold slack. If it's negative, we error out.
      if { ![file exists $routed_timing_dcp] } {
        write_checkpoint $routed_timing_dcp
      }
      report_timing_summary -hold -file $timing_output_dir/${design_name}_timing_summary_hold.rpt
      # when there is a hold violation, it can be caused by huge failures in setup timing
      # so setup timing report should always be generated as well
      report_timing_summary -slack_lesser_than $worst_negative_slack -file $timing_output_dir/${design_name}_timing_summary.rpt

      if { $error_on_hold_violation } {
        if { $is_in_run } { 
          error "design did not meet timing - hold violation"
        } else {
          error2file $output_dir "design did not meet timing - hold violation"
        }
      } else {
        puts "WARNING: Hold violation detected, it will be ignored due to user setting."
      }
    }

    set err_str "Design failed to meet timing"
    # set new_clk_freq_file "$output_dir/_new_clk_freq" 
    if {$enable_auto_freq_scale} {
      set is_timing_failure [expr [write_new_clk_freq $new_clk_freq_file $ocl_inst_path $clk_info err_str $clbinary_name] == "0"]
    } else {
      # for soc platforms
      set is_timing_failure [expr [check_timing_and_write_orig_clk_freq $new_clk_freq_file $design_name $clk_info err_str] == "0"] 
    }
    if { $is_timing_failure } {
      if { ![file exists $routed_timing_dcp] } {
        write_checkpoint $routed_timing_dcp
      }
      report_timing_summary -slack_lesser_than $worst_negative_slack -file ${design_name}_timing_summary.rpt

      if { $is_in_run } { 
        error "design did not meet timing - $err_str"
      } else {
        error2file $output_dir $err_str
      }
    }
    return true
  }

  proc apply_dont_partition { enable_dont_partition steps_log output_dir} {
    if { $enable_dont_partition } {
      add_to_steps_log $steps_log "internal step: read_xdc $output_dir/dont_partition.xdc" [fileName]:[lineNumber [info frame]]

      # create the dont partition xdc for kernels
      # 1. Creating a dont_partition.xdc file what will contain a dont_partition constraint for all kernels.
      # 2. Adding the dont_partition.xdc to the project prior to running implementation.
      
      set dontpartition [open "$output_dir/dont_partition.xdc" w]
      puts $dontpartition "set_property DONT_PARTITION TRUE \[get_cells -hier -filter {SDX_KERNEL==true}\]"
      close $dontpartition

      read_xdc $output_dir/dont_partition.xdc
    }
  }

  # check for failed timing paths before writing original clock frequencies
  # used by soc platform of the hw flow
  proc check_timing_and_write_orig_clk_freq {new_clk_freq_file design_name clk_info err_str} {
    set worst_negative_slack  [dict get $clk_info worst_negative_slack]
    upvar $err_str _err_str

    set routed_timing_dcp ${design_name}_routed_timing.dcp
    set timing_summary_rpt ${design_name}_timing_summary.rpt
    puts "INFO: \[OCL_UTIL\] clock frequency scaling is disabled for this flow, perform the normal timing check instead"
    puts "INFO: \[OCL_UTIL\] get_timing_paths -quiet -slack_lesser_than $worst_negative_slack"
    set timingFailedPaths [ get_timing_paths -quiet -slack_lesser_than $worst_negative_slack ]
    if { [llength $timingFailedPaths] > 0 } {
      set _err_str "Design failed to meet timing.\n"
      append _err_str "    Failed timing checks (paths):\n\t[ join $timingFailedPaths \n\t ]\n\n"
      append _err_str "    Please check the routed checkpoint ($routed_timing_dcp) and timing summary report ($timing_summary_rpt) for more information."

      return 0;
    }

    # write the original clock frequencies in _new_ocl_freq file
    write_orig_clk_freq $new_clk_freq_file $clk_info
    
    return 1
  }

  # write original clock frequencies without checking for failed timing paths.
  # see a proc "check_timing_and_write_orig_clk_freq" which checks for failed timing paths.
  # used for hw_emu flow or if a param compiler.skipTimingCheckAndFrequencyScaling is set to true.
  proc write_orig_clk_freq {new_clk_freq_file clk_info} {
    set kernel_clock_freqs    [dict get $clk_info kernel_clock_freqs]  
    set system_clock_freqs    [dict get $clk_info system_clock_freqs]  

    # write the original clock frequencies in _new_ocl_freq file
    set outfile [open $new_clk_freq_file w]
    dict for {kernel_clk dict_clock} $kernel_clock_freqs {
      set orig_clk_freq [dict get $dict_clock freq]
      set clk_id [dict get $dict_clock clk_id] 
      puts $outfile "kernel:$clk_id:$kernel_clk:$orig_clk_freq"
    }

    dict for {system_clk dict_clock} $system_clock_freqs {
      set orig_clk_freq [dict get $dict_clock freq]
      set clk_id [dict get $dict_clock clk_id] 
      # note for system clock, the clk_id is an empty string
      puts $outfile "system:$clk_id:$system_clk:$orig_clk_freq"
    }

    close $outfile
  }

  proc get_kernel_cells { ocl_inst_path } {
    # We only want to find kernels that are in the OCL region. Some platforms
    # now use kernels in the static portion of the design, which should
    # be ignored for this method. See CR-1016419.
    set kernel_instances {}
    # We use -quiet below because we don't want the warnings about nothing found.
    # Clients can issue a warning if they expect kernels but none are returned.
    if { $ocl_inst_path ne "" } {
      set kernel_instances [get_cells -quiet $ocl_inst_path/.* -regexp -hier -filter "SDX_KERNEL==true"] 
    } else {
      # No path supplied--revert to old behavior.
      set kernel_instances [get_cells -quiet -hier -filter "SDX_KERNEL==true"] 
    }
    return $kernel_instances
  }

  # ocl_util::get_kernel_counts

  proc get_kernel_counts { ocl_inst_path } {

    set hls_count 0
    set rtl_count 0

    foreach instance [get_kernel_cells $ocl_inst_path] {
      # assumes that the only two valid kernel types are 'hls' and 'rtl'
      if { [get_property SDX_KERNEL_TYPE $instance] eq "hls" } {
        incr hls_count
      } else {
        incr rtl_count
      }
    }
    return [dict create hls $hls_count rtl $rtl_count]
  }

  # ocl_util::check_kernel_count
  #
  #     Assumes that PL 0 is always hls kernel clock and PL 1 is always rtl kernel clock,
  #     regardless of platform.
  #
  # Parameters:
  #     d A dictionary of kernel counts indexed by keys 'hls' or 'rtl'
  #     clk_id A number where 0 is the id for hls kernel clock, 1 is rtl kernel clock
  #
  # Results:
  #     Returns 1 if at least one kernel of the given type is found
  #     Else returns 0

  proc check_kernel_count { d clk_id } {
      set kernel_type hls
      if { $clk_id == 1 } {
          set kernel_type rtl
      }
      if { [dict exists $d $kernel_type] } {
          if { [dict get $d $kernel_type] > 0 } {
              return 1
          }
      }
      return 0
  }

  # ocl_util::kernel_clock_purpose
  #
  #     Format human-readable string that explains the purpose for a given
  #     scalable kernel clock.
  #
  # Parameters:
  #     kernel_clk     A scalable kernel clock 'name' (pin path?)
  #     clk_id         Value 0 is the id for hls kernel clock, 1 is rtl kernel clock
  #     kernel_counts  Dict of kernel counts indexed by keys 'hls' or 'rtl'
  #
  # Results:
  #     A string, which may be empty

  proc kernel_clock_purpose { kernel_clk clk_id kernel_counts } {

    set result ""
    set kernel_type "" 
    if { $clk_id == 0 } {
      set kernel_type hls
    } elseif { $clk_id == 1 } {
      set kernel_type rtl
    } else {
      return $result
    }
    set count 0
    if { [dict exists $kernel_counts $kernel_type] } {
      set count [dict get $kernel_counts $kernel_type]
    }  
    set result "\n"
    append result "Scalable clock $kernel_clk (Id = $clk_id) is used for $kernel_type kernels. "
    append result "This design has $count $kernel_type kernel(s)."
    return $result
  }

  # ocl_util::write_new_clk_freq
  #
  #     Writes frequency data to file, used by runtime to set MMCM control registers.
  #     Output data is for scalable system clocks and kernel clocks.
  #
  # Parameters:
  #
  #     new_clk_freq_file Path to output file for scalable system and kernel clock results
  #     ocl_inst_path
  #     clk_info          Dictionary
  #     err_str
  #
  # Results:
  #     Returns 0 indicates frequency scaling failure; return 1 indicate success

  proc write_new_clk_freq {new_clk_freq_file ocl_inst_path clk_info err_str clbinary_name} {
    set kernel_clock_freqs    [dict get $clk_info kernel_clock_freqs]  
    set system_clock_freqs    [dict get $clk_info system_clock_freqs]  
    set worst_negative_slack  [dict get $clk_info worst_negative_slack]

    upvar $err_str _err_str
    # set startdir [pwd]

    puts "Starting auto-frequency scaling ..."
    # initialize kernel_pin_freqs
    foreach kernel_clk [dict keys $kernel_clock_freqs] {
      set kernel_pin_path "$ocl_inst_path/$kernel_clk"
      set dict_clock [dict get $kernel_clock_freqs $kernel_clk]
      set orig_clock_freq [dict get $dict_clock freq]
      set orig_clock_freq [format "%.1f" $orig_clock_freq]
      set kernel_pin_clock_map($kernel_pin_path) $kernel_clk

      # kernel_pin_freqs is a tcl array
      set kernel_pin_freqs($kernel_pin_path) $orig_clock_freq
      puts "kernel clock '$kernel_clk':"
      puts "   clock pin path     : $kernel_pin_path"
      puts "   original frequency : ${orig_clock_freq} MHz"
    }
    puts ""

    foreach system_clk [dict keys $system_clock_freqs] {
      set system_pin_path [lindex [get_pins -of_objects [get_clocks $system_clk]] 0]
      set dict_clock [dict get $system_clock_freqs $system_clk]
      set orig_clock_freq [dict get $dict_clock freq] 
      set orig_clock_freq [format "%.1f" $orig_clock_freq]
      set system_pin_clock_map($system_pin_path) $system_clk

      # system_pin_freqs is a tcl array
      set system_pin_freqs($system_pin_path) $orig_clock_freq
      puts "system clock '$system_clk':"
      puts "   clock pin path     : $system_pin_path"
      puts "   original frequency : ${orig_clock_freq} MHz"
    }
    puts ""

    # call steven li's auto frequency scaling tcl proc, kernel_pin_freqs and system_pin_freqs contains the scaled frequencies
    # note: get_achievable_kernel_freq not only tries to scale the scalable clocks, it also reports
    #       any unscalable clock (e.g. system clock) which doesn't meet timing (worse than wns)
    set failing_system_clocks ""
    # Used to message final achieved frequency for all scalable clocks.
    set achieved ""
    set purpose ""
    set ret [get_achievable_kernel_freq $worst_negative_slack kernel_pin_freqs system_pin_freqs failing_system_clocks]
    puts "Auto-frequency scaling completed"

    set kernel_counts [get_kernel_counts $ocl_inst_path]

    # returns 0 if any system clock slack < worst negative slack, in which case, the kernel clock frequencies are NOT scaled?
    if { $ret  == "0" } {
      set err_freq ""
      # unified platforms, clock names are not hard-coded
      # find the mimimum new_ocl_freq 
      set min_new_ocl_freq 0
      foreach kernel_pin [array names kernel_pin_freqs] {
        validate_new_clk_freq $ocl_util::Kernel $clk_info $kernel_pin kernel_pin_clock_map kernel_pin_freqs _err_str new_ocl_freq $clbinary_name $kernel_counts
        if { $min_new_ocl_freq == 0 } {
          set min_new_ocl_freq $new_ocl_freq 
        }
        # puts "min_new_ocl_freq is $min_new_ocl_freq; new_ocl_freq is $new_ocl_freq"
        if { $min_new_ocl_freq > $new_ocl_freq } {
          set min_new_ocl_freq $new_ocl_freq 
        }
      }
      set new_ocl_freq $min_new_ocl_freq

      # $new_ocl_freq could have decimal places, so round it down 
      set err_freq [round_down $new_ocl_freq]
      set _err_str "Design did not meet timing. One or more unscalable system clocks did not meet their required target frequency. Please try specifying a clock frequency lower than $err_freq MHz using the '--kernel_frequency' switch for the next compilation. For all system clocks, this design is using $worst_negative_slack nanoseconds as the threshold worst negative slack (WNS) value. List of system clocks with timing failure:"
      set report_clock_list ""
      foreach _sys_clk [dict keys $failing_system_clocks] {
        set _slack [dict get $failing_system_clocks $_sys_clk]
        append _err_str "\nsystem clock: $_sys_clk; slack: $_slack ns"
        append report_clock_list "\nsystem clock: $_sys_clk; slack: $_slack ns"
      }

      # AUTO-FREQ-SCALING-01
      if {[is_drcv]} { ::drcv::create_violation AUTO-FREQ-SCALING-01 -s $err_freq -s $worst_negative_slack -s $report_clock_list }
      return 0
    }

    # write the new clock frequencies in _new_ocl_freq file
    set output_dir [file dirname $new_clk_freq_file]
    set outfile [open $new_clk_freq_file w]


    # Handles scalable kernel clocks
    foreach kernel_pin [array names kernel_pin_freqs] {
      if { ![validate_new_clk_freq $ocl_util::Kernel $clk_info $kernel_pin kernel_pin_clock_map kernel_pin_freqs _err_str new_ocl_freq $clbinary_name $kernel_counts] } {
        close $outfile
        return 0 
      }
   
      set kernel_clk $kernel_pin_clock_map($kernel_pin)
      set dict_clock [dict get $kernel_clock_freqs $kernel_clk]
      set orig_clk_freq [dict get $dict_clock freq]
      set clk_id [dict get $dict_clock clk_id] 

      if { $new_ocl_freq < $orig_clk_freq } {
        warning2file $output_dir "WARNING: One or more timing paths failed timing targeting $orig_clk_freq MHz for kernel clock '$kernel_clk'. The frequency is being automatically changed to $new_ocl_freq MHz to enable proper functionality"
        # AUTO-FREQ-SCALING-04
        if {[is_drcv]} { ::drcv::create_violation AUTO-FREQ-SCALING-04 -dynamic_category [list [list xclbin $clbinary_name]] -REF [list type OTHER -name $kernel_clk] -s $orig_clk_freq -s $new_ocl_freq -s $clk_id }
      }

      # write the new ocl frequency to the file "_new_clk_freq" regardless the clock has been scaled or not
      # in the case where the clock is not scaled, the new frequency would be same as original frequency
      puts $outfile "kernel:$clk_id:$kernel_clk:$new_ocl_freq"
      append achieved "\nKernel: $kernel_clk = $new_ocl_freq MHz "
      append purpose [kernel_clock_purpose $kernel_clk $clk_id $kernel_counts]
    }

    # Handles scalable system clocks
    foreach system_pin [array names system_pin_freqs] {
      if { ![validate_new_clk_freq $ocl_util::System $clk_info $system_pin system_pin_clock_map system_pin_freqs _err_str new_clk_freq $clbinary_name $kernel_counts] } {
        close $outfile
        return 0 
      }
   
      set system_clk $system_pin_clock_map($system_pin)
      set dict_clock [dict get $system_clock_freqs $system_clk]
      set orig_clk_freq [dict get $dict_clock freq]
      set clk_id [dict get $dict_clock clk_id] 

      if { $new_clk_freq < $orig_clk_freq } {
        warning2file $output_dir "WARNING: One or more timing paths failed timing targeting $orig_clk_freq MHz for system clock '$system_clk'. The frequency is being automatically changed to $new_clk_freq MHz to enable proper functionality"
        # AUTO-FREQ-SCALING-07
        if {[is_drcv]} { ::drcv::create_violation AUTO-FREQ-SCALING-07 -REF [list type OTHER -name $system_clk] -s $orig_clk_freq -s $new_clk_freq }
      }

      # write the new ocl frequency to the file "_new_clk_freq" regardless the clock has been scaled or not
      # in the case where the clock is not scaled, the new frequency would be same as original frequency
      puts $outfile "system:$clk_id:$system_clk:$new_clk_freq"
      append achieved "\nSystem: $system_clk = $new_clk_freq MHz "
    }

    close $outfile
    append achieved $purpose
    # This is the right place to affirm the final achieved frequencies for the scalable clock domains.
    if {[is_drcv]} { ::drcv::create_affirmation PLATFORM-CLOCK-DOMAINS-01 -s $achieved }
    return 1;
  }

  # ::ocl_util::validate_new_clk_freq
  #
  # Parameters:
  #     clk_type       One of 'kernel' or 'system'
  #     clk_info       A dict populated using data from the HPFM
  #     clock_pin      A pin name
  #     pin_clock_map
  #     clk_pin_freqs
  #     err_str
  #     new_clk_freq   The proposed, computed value to validate
  #     clbinary_name
  #     kernel_counts  A dict that relates kernel type to count
  #
  # Results:
  #     Sets a scaled frequency value - return 0 when scaled frequency is below minimum,
  #     return 1 otherwise.

  proc validate_new_clk_freq { clk_type clk_info clock_pin pin_clock_map clk_pin_freqs err_str \
      new_clk_freq clbinary_name kernel_counts} {

    upvar $err_str _err_str
    upvar $new_clk_freq _new_clk_freq
    upvar $clk_pin_freqs _clk_pin_freqs
    upvar $pin_clock_map _pin_clock_map

    set max_frequency        [dict get $clk_info max_frequency]
    set min_frequency        [dict get $clk_info min_frequency]

    # clock_freqs can either be kernel_clock_freqs or system_clock_freqs depending on $clk_type 
    set clock_freqs [dict get $clk_info ${clk_type}_clock_freqs]  
    set clk $_pin_clock_map($clock_pin)
    set dict_clock [dict get $clock_freqs $clk]
    set orig_clk_freq [dict get $dict_clock freq]
    set orig_clk_freq [format "%.1f" $orig_clk_freq]
    set clk_id [dict get $dict_clock clk_id]
    set _new_clk_freq $_clk_pin_freqs($clock_pin)

    puts "$clk_type clock '$clk':"
    puts "   original frequency : ${orig_clk_freq} MHz"
    puts "   scaled frequency   : ${_new_clk_freq} MHz"
    if {[is_drcv]} { set clk_ref [::drcv::create_reference OTHER -name $clk] }

    # CR 964071: We should error out below 60Mhz. Nothing slower than this is supported
    # compiler.minFrequencyLimit
    if { $_new_clk_freq < $min_frequency } {
      set _err_str "auto frequency scaling failed because the auto scaled frequency '$_new_clk_freq MHz' is lower than the minimum frequency limit supported by the runtime ($min_frequency MHz)."
      if {[is_drcv]} {
        if {$clk_type eq $ocl_util::System} {
          # AUTO-FREQ-SCALING-05 is for system clock minimum
          ::drcv::create_violation AUTO-FREQ-SCALING-05 -REF $clk_ref -s $orig_clk_freq -s $_new_clk_freq -s $min_frequency
        } else {
          # AUTO-FREQ-SCALING-02 is for kernel clock minimum
          ::drcv::create_violation AUTO-FREQ-SCALING-02 -dynamic_category [list [list xclbin $clbinary_name]] -REF $clk_ref -s $orig_clk_freq -s $_new_clk_freq -s $min_frequency
        }
      }
      set _new_clk_freq $min_frequency
      return 0 
    }

    # runtime has a hard cap for maximum frequency of 500MHz, it the scaled frequency is larger 
    # than 500, we should cap it to 500.
    # compiler.maxFrequencyLimit
    if { $_new_clk_freq > $max_frequency } {
      puts "INFO: The maximum frequency supported by the runtime is $max_frequency MHz, which this design achieved. The compiler will not select a frequency value higher than the runtime maximum."
      if {[is_drcv]} {
        if {$clk_type eq $ocl_util::System} {
          # AUTO-FREQ-SCALING-06 is for system clock maximum
          ::drcv::create_affirmation AUTO-FREQ-SCALING-06 -s $max_frequency -REF $clk_ref -s $orig_clk_freq -s $_new_clk_freq -actual [list string $_new_clk_freq] -threshold [list string $max_frequency]
        } else {
          if { [check_kernel_count $kernel_counts $clk_id] } {
            # AUTO-FREQ-SCALING-03 is for kernel clock maximum
            ::drcv::create_affirmation AUTO-FREQ-SCALING-03 -s $max_frequency -dynamic_category [list [list xclbin $clbinary_name]] -REF $clk_ref -s $orig_clk_freq -s $_new_clk_freq -actual [list string $_new_clk_freq] -threshold [list string $max_frequency]
          }
        }
      }
      set _new_clk_freq $max_frequency
    }

    # cap the new frequency so that it is not higher than orignal frequency
    if { $_new_clk_freq > $orig_clk_freq } {
      puts "WARNING: The auto scaled frequency '$_new_clk_freq MHz' exceeds the original specified frequency. The compiler will select the original specified frequency of '$orig_clk_freq' MHz."
      if {[is_drcv]} {
        # AUTO-FREQ-SCALING-08
        ::drcv::create_violation AUTO-FREQ-SCALING-08 -dynamic_category [list [list xclbin $clbinary_name]] -REF $clk_ref -s $_new_clk_freq -s $orig_clk_freq
      }
      set _new_clk_freq $orig_clk_freq
    }

    return 1
  }

  proc get_achievable_kernel_freq {sysClkWnsTolerance kernelPinFreqArray sysPinFreqArray failingSysClksDict} {
    upvar $kernelPinFreqArray kernelPinFreqs
    upvar $sysPinFreqArray sysPinFreqs
    upvar $failingSysClksDict failingSysClks

    # initialize combined_pin_freqs
    foreach k_k [array names kernelPinFreqs] {
      set combined_pin_freqs($k_k) $kernelPinFreqs($k_k)
    }
    foreach s_k [array names sysPinFreqs] {
      set combined_pin_freqs($s_k) $sysPinFreqs($s_k)
    }

    #scale clocks
    set ret [get_achievable_kernel_freq_ $sysClkWnsTolerance combined_pin_freqs failingSysClks]
    if { $ret == "0" } {
      return $ret
    }

    #update pin freq arrays
    foreach k_k [array names kernelPinFreqs] {
      set kernelPinFreqs($k_k) $combined_pin_freqs($k_k)
    }
    foreach s_k [array names sysPinFreqs] {
      set sysPinFreqs($s_k) $combined_pin_freqs($s_k)
    }

    return $ret
  }

  # Compute the acheivable kernel frequency
  # Authur: Steven Li 
  # Input: sysClkWnsTolerance: the tolerance in which we consider the system clocks as meeting timing, typical value 0ns or -0.1ns. 
  #        kernelPinFreqArray - array containing the kernel clock pin names and their corresponding the returned scale freq
  #
  # Return: A list of achievable kernel frequencies in MHz unit with 1 decimal point
  #         For each kernel clock pin, compute the achievable kernel frequency, or unchange if the kernel clock pin is not found, or it's not connected to a clock
  #         The computed scaled frequencies are stored in the kernelPinFreqArray
  #         0 if any system clock slack < sysClkWnsTolerance
  #         1 if success

  proc get_achievable_kernel_freq_ {sysClkWnsTolerance kernelPinFreqArray failingSysClksDict} {
    upvar $kernelPinFreqArray kernelPinFreqs
    upvar $failingSysClksDict failingSysClks
    # puts "--- DEBUG: sysClkWnsTolerance is $sysClkWnsTolerance"
    # foreach kernel_pin [array names kernelPinFreqs] {
    #   set new_ocl_freq $kernelPinFreqs($kernel_pin)
    #   puts "--- DEBUG: $kernel_pin : $new_ocl_freq"
    # }

    set kernelClksToScale 0
    set success 1

    foreach kernelClkPin [array names kernelPinFreqs] {
      set pin [get_pins $kernelClkPin]
      if {$pin == ""} {
        # kernel clock pin is unconnected and optimized away
        puts "INFO: Pin $kernelClkPin not found"
        continue
      }

      set clk [get_clocks -of_objects $pin]
      if {$clk == ""} {
        # kernel clock pin is unconnected
        puts "INFO: Pin $pin has no clock"
        continue
      }
      puts "INFO: \[OCL_UTIL\] clock is '$clk' for pin '$pin'"

      # for dynamic platform (due to the dr bd boundary), it is a valid case
      # to NOT have a timing path for the secondary clock (which is used to
      # drive rtl kernel)
      set tps [get_timing_paths -group $clk]
      if {[llength $tps] == 0} {
        # kernel clock does not have timing paths
        puts "INFO: Clock $clk has no timing paths"
        continue
      }
      
      if {[info exists clkToKernelPins($clk)]} {
        lappend clkToKernelPins($clk) $kernelClkPin
      } else {
        set clkToKernelPins($clk) [list $kernelClkPin]
      }

      set kernelPinFreqs($kernelClkPin) 0
      incr kernelClksToScale 1
    }

    # puts "--- DEBUG: kernelClksToScale is $kernelClksToScale"
    # foreach _clk [array names clkToKernelPins] {
    #   set _pins $clkToKernelPins($_clk)
    #   puts "--- DEBUG: kernel clk '$_clk': $_pins"
    # }

    set tps [get_timing_paths -max_paths 1 -sort_by group]

    # tps is already sorted from worst clock to best clock
    # loop through each clock until slack >= sysClkWnsTolerance and the kernel freq is computed
    foreach tp $tps {
      set slk [get_property SLACK $tp]
      set grp [get_property GROUP $tp]
      # puts "--- DEBUG: Path=$tp\n\t Group=$grp Slack=$slk"
      #report_property $tp

      if {$grp == "**async_default**"} {
        continue
      }

      if {$slk < $sysClkWnsTolerance} {
        # puts "--- DEBUG: \$slk < \$sysClkWnsTolerance"
        if {[info exists clkToKernelPins($grp)]} {
          # puts "--- DEBUG: grp '$grp' exists in clkToKernelPins"
          set period [get_property PERIOD [get_clocks [get_property ENDPOINT_CLOCK $tp]]]
          set freq [expr int(10000.0 / ($period - $slk)) / 10.0]
          # puts "--- DEBUG: freq = $freq"

          foreach kernelPin $clkToKernelPins($grp) {
            # puts "--- DEBUG: set kernelPinFreqs($kernelPin) to $freq"
            set kernelPinFreqs($kernelPin) $freq
            incr kernelClksToScale -1
          }
        } else {
          # negative WNS for system clock, cannot scale frequency
          puts "WARNING: cannot scale kernel clocks: the failing system clock is $grp:$slk, the wns tolerance is $sysClkWnsTolerance"
          dict set failingSysClks $grp $slk
          # continue with other clocks until the scaled freq of all kernel clocks are computed
          set success 0
        }
      } else {
        # slack is better than $sysClkWnsTolerance
        # puts "--- DEBUG: \$slk > \$sysClkWnsTolerance"
        if {$kernelClksToScale == 0} {
          return $success
        } else {
          if {[info exists clkToKernelPins($grp)]} {
            # puts "--- DEBUG: grp '$grp' exists in clkToKernelPins"
            # Kernel slack is within the tolerance.  Treat it as 0 so as to compute the target frequency
            if {$slk < 0} {
              set slk 0
            }
            set period [get_property PERIOD [get_clocks [get_property ENDPOINT_CLOCK $tp]]]
            set freq [expr int(10000.0 / ($period - $slk)) / 10.0]
        
            # puts "freq: $freq"

            foreach kernelPin $clkToKernelPins($grp) {
              # puts "--- DEBUG: set kernelPinFreqs($kernelPin) to $freq"
              set kernelPinFreqs($kernelPin) $freq
              incr kernelClksToScale -1
            }
          }
        }
      }
    }

    # all the clocks in kernelPinFreqs should be scaled at this point
    if { $kernelClksToScale > 0 } {
      puts "WARNING: there are $kernelClksToScale clock(s) that couldn't be scaled, scaling algorithm needs to be checked"
      # set success 0
    }

    # Not all kernel clocks are found
    return $success
}

  # round down any number to an integer
  proc round_down {val} {
    set fl [expr {floor($val)}]
    set retval [format "%.0f" $fl]
    return $retval
  }; # end round_down  

  # convert frequency in MHz to period in ns
  proc convert_freq_to_period {freq} {
    return [expr {1000.000 / $freq}]
  }; # end convert_freq_to_period

  # convert period in ns to frequency in MHz
  proc convert_period_to_freq {period} {
    return [expr {1000 / $period}] 
  }; # end convert_period_to_freq

  # initialize clkwiz debug instance run
  proc initialize_clkwiz_debug {} {
    load librdi_iptasks.so
    set partinfo [get_property PART [current_project]]
    Init_Clkwiz [current_project] test1 $partinfo
  }; # end initialize_clkwiz_debug

  # un-initialize clkwiz debug instance run
  proc uninitialize_clkwiz_debug {} {
    UnInit_Clkwiz [current_project] test1
  }; # end uninitialize_clkwiz_debug

  # get property from clkwiz instance
  proc get_clkwiz_prop {prop} {
    set val [GetClkwizProperty [current_project] test1 $prop]
    return $val
  }; # end get_clkwiz_prop

  # set clkwiz instance properties
  proc set_clkwiz_prop {clock_freq_orig clock_freq} {
    SetClkwizProperty [current_project] test1 UseFinePS true 
    # GetClosestSolution <project_name> <instance_name> <requested output frequencies of clks separated by spaces> <requested phases of clocks separated by spaces> <requested duty cycles of clocks separated by spaces> <primary clock frequency> <secondary clock frequency> <number of output clocks> <minimum output jiter used> <non default phase or duty cycle> <primitive (MMCM or PLL)> <debug mode> <clkout XiPhy Enable> <clkout XiPhy Freq>
    GetClosestSolution [current_project] test1 $clock_freq 0 50 $clock_freq_orig 0 1 false false false false false false
  }; # end set_clkwiz_prop

  # create clock constraint(s) on the output pin of mmcm for implementation, overwriting a default generated clock
  proc write_user_impl_clock_constraint {inst dict_clock_freqs steps_log output_dir} {
    set uninit_wiz true
    set user_impl_clk_xdc "_user_impl_clk.xdc"
    set fo_xdc_file [open $output_dir/$user_impl_clk_xdc w]

    foreach clock_name [dict keys $dict_clock_freqs] {
      set dict_clock [dict get $dict_clock_freqs $clock_name]
      set is_user_set [dict get $dict_clock is_user_set]
      if { [string equal -nocase $is_user_set "true" ] } {
        set clock_freq [dict get $dict_clock freq]
        #set clock_freq_orig [dict get $dict_clock freq_orig]
        set outpin_mmcm [get_pins [get_property SOURCE_PINS [get_clocks -of_objects [get_pins $inst/$clock_name]]]]
        # CR 1018802: there might be more than one MMCM output pins that connect to the kernel clock pin, it leads to invalid 
        # clock_period value, e.g. "10.000 10.000", to prevent this kind of problem, add the following corrective treatment 
        if { [llength $outpin_mmcm] > 1 } {
          set outpin_mmcm [lindex $outpin_mmcm 0]
          puts "WARNING: there are more than one MMCM output pins that connect to kernel clock input pin '$inst/$clock_name', this is unexpected, using the first one '$outpin_mmcm' as the MMCM output pin"
        }

        set gclock [get_clocks -of_objects [get_pins $outpin_mmcm]]
        set gclock_name [get_property NAME $gclock]
        set inpin_mmcm [get_property SOURCE $gclock]
        set clock_period [get_property PERIOD [get_clocks -of_objects [get_pins $inpin_mmcm]]]  
        # make sure clock_period is all numeric
        if { ![string is double $clock_period] } {
          puts "CRITICAL WARNING: clock period '$clock_period' is not numeric, ignoring this clock"
          continue
        }

        set clock_freq_orig [round_down [convert_period_to_freq $clock_period]]
        if { $uninit_wiz } {
          initialize_clkwiz_debug
          set uninit_wiz false
        }
        set_clkwiz_prop $clock_freq_orig $clock_freq
        set clkout0_divide [round_down [get_clkwiz_prop ChosenDiv0]]
        set divclk_divide [round_down [get_clkwiz_prop ChosenD]]
        set divide_by [expr {$clkout0_divide * $divclk_divide}]
        set multiply_by [round_down [get_clkwiz_prop ChosenM]]
    
        puts $fo_xdc_file "\n# Kernel clock overridden by user"
        puts $fo_xdc_file "create_generated_clock -name $gclock_name -divide_by $divide_by -multiply_by $multiply_by -source $inpin_mmcm $outpin_mmcm"
      }
    }
    close $fo_xdc_file 
    # read_xdc applies the constraints immediately if a design is open
    # read_xdc behaves same as add_files if there is no open design
    if {$steps_log ne ""} {
      add_to_steps_log $steps_log "internal step: read_xdc $output_dir/$user_impl_clk_xdc" [fileName]:[lineNumber [info frame]]
    }
    read_xdc $output_dir/$user_impl_clk_xdc
    
    if { !$uninit_wiz } {
      uninitialize_clkwiz_debug 
    }
  }; # end write_user_impl_clock_constraint

  # create clock constraint(s) for synthesis, overwriting the default frequency from hw_platform
  proc write_user_synth_clock_constraint {xdc_file dict_clock_freqs} {
    set fo_xdc_file [open ./$xdc_file a]
    foreach clock_name [dict keys $dict_clock_freqs] {
      set dict_clock [dict get $dict_clock_freqs $clock_name]
      set is_user_set [dict get $dict_clock is_user_set]
      if { [string equal -nocase $is_user_set "true" ] } {
        set clock_freq [dict get $dict_clock freq]
        set clock_period [convert_freq_to_period $clock_freq]
        puts $fo_xdc_file "\n# Kernel clock overridden by user"
        puts $fo_xdc_file "create_clock -name USER_$clock_name -period $clock_period \[get_ports $clock_name\]"
      }
    }
    close $fo_xdc_file 
  }; # end write_user_synth_clock_constraint 

  # generate a resource demand report per kernel ip instance after OOC synth is done 
  proc generate_resource_report { output_dir steps_log } {
    set all_kernel_ips [get_ips -quiet -all -filter "SDX_KERNEL==true"]
    # puts "--- DEBUG: get_ips -quiet -all -filter \"SDX_KERNEL==true\": $all_kernel_ips"
    set size_all_ips [llength $all_kernel_ips]

    if { $size_all_ips > 0 } {
      set resource_usage_report [file join $output_dir "resource.json"]
      add_to_steps_log $steps_log "internal step: generating resource usage report '${resource_usage_report}'" [fileName]:[lineNumber [info frame]]
      set rdata_file [open $resource_usage_report "w"]
      puts $rdata_file "\{"
      puts $rdata_file "    \"Used Resources\": \["
      set index_ip 0

      foreach kernel_ip $all_kernel_ips {
        puts $rdata_file "        \{"
        puts $rdata_file "            \"ip_instance\": \"$kernel_ip\","

        set rdata [get_property dcp_resource_data $kernel_ip]
        # puts "--- DEBUG: get_property dcp_resource_data $kernel_ip: $rdata"
        puts $rdata_file "            \"resources\": \["
        set rdata_list [regexp -all -inline {\S+} $rdata]
        set size_rdata_list [llength $rdata_list]
        if { $size_rdata_list > 0 } {
          set index_rdata 0
          foreach rdata_item $rdata_list {
            incr index_rdata
            set is_odd [expr {($index_rdata % 2) != 0}]
            if { $is_odd } {
              puts $rdata_file "                \{"
              puts -nonewline $rdata_file "                    \"$rdata_item\": "
            } else {
              puts $rdata_file "\"$rdata_item\""
              if { $index_rdata == $size_rdata_list } {
                puts $rdata_file "                \}"
              } else {
                puts $rdata_file "                \},"
              }
            }
          }
        }
        puts $rdata_file "            \]"
        #puts "--- DEBUG: reporting IP properties of $kernel_ip"
        #report_property $kernel_ip

        incr index_ip
        if { $index_ip == $size_all_ips } {
          puts $rdata_file "        \}"
        } else {
          puts $rdata_file "        \},"
        }
      }

      puts $rdata_file "    \]"
      puts $rdata_file "\}"
      close $rdata_file
    }
  }; # end generate_resource_report 

}; # end namespace

