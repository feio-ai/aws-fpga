package require json
namespace eval hw_emu_common_util {
  
  #this proc searches key in adict array and returns the value. If key doesnt exist, returns default value
  proc dict_get_default {adict key default} {
    if { [dict exists $adict $key] } {
      return [dict get $adict $key]
    }
    return $default
  }
  #end of dict_get_default

  proc gen_vimage_inputs { config_info callBootGen kernelDebug } {
    set scDebugLevel [dict get $config_info sc_debug_level]
    if { $callBootGen } {
      if { [dict exists $config_info "default_vimage_scripts"] } {
        set default_vimage_scripts    [dict get $config_info "default_vimage_scripts" ] 
        set product_dir [dict get $config_info "product_dir" ] 
        set platform_dir [dict get $config_info "platform_dir" ] 
        set platform_name [dict get $config_info "platform_name" ] 
        set config_name [dict get $config_info "config_name" ] 
        set os_name [dict get $config_info "os_name" ] 
        set cpu_type [dict get $config_info "cpu_type" ] 
  
        lappend ::auto_path $default_vimage_scripts
        package require vimage::env
        vimage::env::set_install_root $product_dir
        package require vimage::sdcard
        package require vimage::emu
        ::vimage::sdcard::setVerbose 1
        ::vimage::sdcard::setCreateBootBin 0
        ::vimage::sdcard::initializeSdCardImageWriter $platform_dir $platform_name $config_name {} $os_name $cpu_type {}
        ::vimage::emu::exportSimulationFilesOcl _vimage {} {} {} hw_emu
        ::vimage::emu::exportExtraSimulationFiles _vimage
        set sdx_emu_args ""
        if { [file exists "_vimage/emulation/qemu_qspi.bin"] } {
          append sdx_emu_args " -image "
          append sdx_emu_args " _vimage/emulation/qemu_qspi.bin "
        }

        set launch_emulator_file "launch_hw_emu.sh"
        set out  [open $launch_emulator_file w]

        puts $out "#!/bin/bash -f"
        puts $out "export XTLM_LOG_STATE=$scDebugLevel"
        puts $out "touch launch_emu.log"
        puts $out "if \[\[ $* == *-emuData* \]\]; then"
        puts $out "  echo \" emuData is passed from the XRT. Making use of those args in launching the emulation\" >> launch_emu.log"
        puts $out "  echo \" launching Co-simulation of Qemu and XSIM using launch_emulator: Args are $*\" >> launch_emu.log"
        puts $out "  launch_emulator -device-family Versal -pl-sim-dir . $* | tee hw_emulator.log"
        puts $out "else "
        puts $out "  echo \" Using the regular flow which uses boot.pdi\" >> launch_emu.log "
        puts $out "  echo \" launching Co-simulation of Qemu and XSIM using launch_emulator: Args are $*\" >> launch_emu.log "
        puts $out "  launch_emulator -device-family Versal -pl-sim-dir . -image  _vimage/emulation/qemu_qspi.bin $* | tee hw_emulator.log"
        puts $out "fi"
        close $out        
      } 
    } else {
      set launch_emulator_file "launch_hw_emu.sh"
      set out  [open $launch_emulator_file w]
      puts $out "#!/bin/bash -f"
      puts $out "export XTLM_LOG_STATE=$scDebugLevel"
      puts $out "echo \" running simulate.sh $*\""
      puts $out "./simulate.sh $*"
      close $out
    }
  }
 
  #following proc caches addressing before deleting the bd_objects. update_addressing proc uses same this information to addressing again.
  proc get_addressing { } {
    set addrSegs [dict create]
    set kernel_segs [get_bd_addr_segs -of_objects [get_bd_addr_spaces /S_AXI]]
    foreach kernel_seg $kernel_segs { 
      set slave_seg [get_bd_addr_segs -of_objects $kernel_seg]
      if { ![dict exists $addrSegs $slave_seg] } {
        dict set addrSegs $slave_seg [list [get_property offset $kernel_seg] [get_property range $kernel_seg]]
      }
    }
    return $addrSegs
  } 
  #end of get_addressing

  #following proc re-creates addressing from saved addrSegs.
  proc update_addressing {addrSegs controlInterface intfOffset} {
    set index1 0
    foreach slave_seg [dict keys $addrSegs] {
      lassign [dict get $addrSegs $slave_seg] offset range
      set finaloffset [format 0x%x [expr {$offset + $intfOffset}]]
      puts "create_bd_addr_seg -range $range -offset $finaloffset [get_bd_addr_spaces $controlInterface] $slave_seg SEG_OCL_REGION_0_reg$index1"
      create_bd_addr_seg -range $range -offset $finaloffset [get_bd_addr_spaces $controlInterface] $slave_seg SEG_OCL_REGION_0_reg$index1
      incr index1
    } 
  }
  #end of update_addressing

  #this proc creates new simulation script by replacing xsimk binary call directly.
  proc writeNewSimulateScript { replaceXSimCall bdName } {
    set oldFilename "simulate.sh"
    set newFileName "simulate_sysemulation.sh"
    set in  [open $oldFilename r]
    set out [open $newFileName w]
    while {[gets $in line] != -1} {
      if { $replaceXSimCall } {
        regsub -all "xsim.*simulate.log" $line "./xsim.dir/${bdName}_wrapper_behav/axsim" line
      }
      puts $out $line
    }
    file attributes  simulate_sysemulation.sh -permissions rwxrwxrwx
    file rename -force  simulate_sysemulation.sh simulate.sh
    close $in
    close $out
  }
  #end of writeNewSimulateScript

  #this proc creates new openclDesign.tcl file.
  proc writeNewOpenClScript {debugLevel bdName simRuntime} {
    set oldFilename "${bdName}_wrapper.tcl"
    set in  [open $oldFilename w]
    puts $in "log_wave -r *"
    puts $in "if { \[info exists ::env(VITIS_WAVEFORM) \] } {"
    puts $in "  if {\[file exists \$::env(VITIS_WAVEFORM)\] == 1} {"
    puts $in "    open_wave_config \$::env(VITIS_WAVEFORM)"
    puts $in "  }" 
    puts $in "}"
    
    puts $in "if { \[file exists preprocess_profile.tcl\] } {"
    puts $in "  source -notrace preprocess_profile.tcl"
    puts $in "}"
    
    puts $in "puts \"We are running Simulator for infinite time. Added some default signals in the waveform. You can pause simulation and add signals and then resume the simulaion again.\""
    puts $in "puts \"\""
    puts $in "puts \"Stopping at breakpoint in simulator also stops the host code execution\""
    puts $in "puts \"\""
    puts $in "if { \[info exists ::env(VITIS_LAUNCH_WAVEFORM_GUI) \] } {"
    puts $in "  run 1ns"
    puts $in "} else {"
    puts $in "  run $simRuntime"
    puts $in "}"
    if { [string compare -nocase $debugLevel "BATCH"] == 0 } {
      puts $in "quit"
    }

    puts $in "if { \[file exists profile.tcl\] } {"
    puts $in "  source -notrace profile.tcl"
    puts $in "}"

    puts $in "if { \[info exists ::env(VITIS_LAUNCH_WAVEFORM_BATCH) \] } {"
    puts $in "quit"
    puts $in "}"

    close $in
  }
  #end of writeNewOpenClScript

  #this proc is called from HPIKernelCompilerSystemFpga.cxx. This proc executes following operations
  #1 set the parameters 
  #2 generate simulation scripts
  #3 create new simulation scripts from original by modifying ExecStep 
  #4 execure compile and elaborate.
  # proc generate_simulation_scripts_and_compile {  debugLevel simulator clibs topBd kernelDebug } 
  proc generate_simulation_scripts_and_compile {  config_info } {
    set debugLevel   [dict get $config_info debug_level] 
    set scDebugLevel [dict get $config_info sc_debug_level] 
    set simulator    [dict get $config_info simulator] 
    set clibs        [dict get $config_info clibs] 
    set topBdName    [dict get $config_info top_bd_name] 
    set kernelDebug  [dict get $config_info kernel_debug] 
    set topBd        [dict get $config_info top_bd] 
    set drBd         [dict get $config_info dr_bd]
    set simRuntime   [dict get $config_info simulation_runtime] 
	
    # note this tcl proc is used by both non-unified platform and unified platform
    # for unified platform, the vivado project has been renamed to "prj" to be consistent with hw flow
    # emu_project_name entry is only available for unified platform
    # set project_name [dict get $config_info synth_proj_name] 
    if { [dict exists $config_info emu_proj_name] } {
      set project_name [dict get $config_info emu_proj_name] 
    } else {
      set project_name [dict get $config_info synth_proj_name] 
    }

    set bdDesign ""
    if { $topBdName ne "" } {
      set bdDesign [get_bd_designs $topBdName] 
    } else {
      set bdDesign [lindex [get_bd_designs] end] 
    }

    if {$bdDesign eq ""} {
      puts "ERROR: there is no open BD design"
    }

    #reset_target {simulation} [get_files [get_property FILE_NAME $bdDesign]]
    #
    #CR-1016564. Work-around to reset-project
    #reset_project
    set_property generate_synth_checkpoint false [get_files  [get_property FILE_NAME $bdDesign]]
    #generate_target {simulation} [get_files  [get_property FILE_NAME $bdDesign]]
    set_property -name {xsim.simulate.runtime} -value $simRuntime -objects [current_fileset -simset]
    set topBdName [get_property NAME $bdDesign]
    set activeFileset [current_fileset -simset] 
    set topModule [get_property top $activeFileset ]
    set callBootGen false

    if {$topModule eq ""} {
      puts "--- DEBUG: changing the top model to ${topBdName}_wrapper"
      set_property top ${topBdName}_wrapper [get_filesets $activeFileset]
    } else {
      puts "--- DEBUG: top is already set to $topModule"
    }

    #open DR BD design to check for noc IP
    if { $topBd != $drBd && $topBd ne "" } {
      open_bd_design -auto_upgrade [get_files $drBd]
    }
    #TODO following is a HACK to check the versal platform
    set axi_noc_ip [get_bd_cells * -filter {VLNV=~xilinx.com:ip:axi_noc:*} -quiet]
    
    if {$axi_noc_ip != ""} {
      set callBootGen true
      set topBdName ${topBdName}_wrapper_sim
      set_property top ${topBdName}_wrapper [get_filesets sim_1]
      set_property top_lib xil_defaultlib [get_filesets sim_1]
      update_compile_order -fileset sim_1
      update_compile_order
    }

    #Restore the top BD
    if { $topBd != $drBd && $topBd ne "" } {
      open_bd_design -auto_upgrade [get_files $topBd]
    }

    set origSimulator "xsim"
    set replaceXSimCall false
    set debugMode false
    if { [string compare -nocase $simulator "questa"] == 0 } {
      set origSimulator "questa"
      set_property target_simulator Questa [current_project]
      if { $clibs ne "" } {
        set_property compxlib.questa_compiled_library_dir $clibs [current_project]
      }
      set_property -name {questa.simulate.runtime} -value $simRuntime -objects [current_fileset -simset]
      set_property -name {QUESTA.SIMULATE.LOG_ALL_SIGNALS} -value {false} -objects [current_fileset -simset]
      launch_simulation -scripts_only
      cd $project_name/$project_name.sim/$activeFileset/behav/questa
      exec ./compile.sh
      exec ./elaborate.sh
      cd ../../../../../
      file copy -force $project_name/$project_name.sim/$activeFileset/behav/ $project_name/$project_name.sim/$activeFileset/behav_waveform
      set_property -name {QUESTA.SIMULATE.VSIM.MORE_OPTIONS} -value "" -objects [current_fileset -simset]
      set_property -name {QUESTA.SIMULATE.LOG_ALL_SIGNALS} -value {false} -objects [current_fileset -simset]
    } else {
      set_property target_simulator XSim [current_project]
      set_property -name {xsim.simulate.runtime} -value $simRuntime -objects [current_fileset -simset]
  
      # Keep the user specified debug modes as is
      if { [string compare -nocase $debugLevel "BATCH"] == 0 } {
        set debugMode true
        set_property -name {XSIM.ELABORATE.DEBUG_LEVEL} -value {typical} -objects [current_fileset -simset]
        set_property -name {xsim.simulate.xsim.more_options} -value "-nolog --onfinish quit \$*" -objects [current_fileset -simset]
      } elseif { [string compare -nocase $debugLevel "GUI"] == 0 } {
        set debugMode true
        set_property -name {XSIM.ELABORATE.DEBUG_LEVEL} -value {typical} -objects [current_fileset -simset]
        set_property -name {xsim.simulate.xsim.more_options} -value " -gui \$*" -objects [current_fileset -simset]
      } else {
        
        set protobufInclude "$::env(XILINX_VIVADO)/data/simmodels/xsim/2019.2/lnx64/6.2.0/ext/protobuf/include"
        set protobufLibrary "$::env(XILINX_VIVADO)/data/simmodels/xsim/2019.2/lnx64/6.2.0/ext/protobuf/"
        
        set_property -name {XSIM.COMPILE.XSC.MORE_OPTIONS}  -value "--gcc_compile_options \"-I$protobufInclude\" " -objects [current_fileset -simset]
        set_property -name {XSIM.ELABORATE.XSC.MORE_OPTIONS}  -value "--gcc_link_options \"-L$protobufLibrary -lprotobuf\" " -objects [current_fileset -simset]
        set_property -name {XSIM.ELABORATE.XELAB.MORE_OPTIONS} -value " --include $protobufInclude -ignore_assertions " -objects [current_fileset -simset]
        
        # Handle the default flow and the interactive debug flow 
        if { [string compare -nocase $kernelDebug "false"] == 0 } {
           set_property -name {XSIM.ELABORATE.DEBUG_LEVEL} -value {off} -objects [current_fileset -simset]
           set_property -name {XSIM.ELABORATE.XELAB.MORE_OPTIONS} -value "-standalone --include $protobufInclude -ignore_assertions " -objects [current_fileset -simset]
           set replaceXSimCall true
        } else {
          set_property -name {xsim.simulate.xsim.more_options} -value "\$*" -objects [current_fileset -simset]

          if { [string compare -nocase $scDebugLevel "WAVEFORM"] == 0 || [string compare -nocase $scDebugLevel "WAVEFORM_AND_LOG"] == 0 } {
           set_property -name {XSIM.ELABORATE.XELAB.MORE_OPTIONS} -value " --debug sc " -objects [current_fileset -simset]
          }

          launch_simulation -scripts_only
          cd $project_name/$project_name.sim/$activeFileset/behav/xsim
          gen_vimage_inputs $config_info $callBootGen $kernelDebug
          writeNewOpenClScript $debugLevel $topBdName $simRuntime
          puts "INFO: \[HW_EMU_COMMON_UTIL\] compile.sh started"
          exec ./compile.sh
          puts "INFO: \[HW_EMU_COMMON_UTIL\] compile.sh ended"
          puts "INFO: \[HW_EMU_COMMON_UTIL\] elaborate.sh started"
          exec ./elaborate.sh
          puts "INFO: \[HW_EMU_COMMON_UTIL\] elaborate.sh ended"

          cd ../../../../../
          file copy -force $project_name/$project_name.sim/$activeFileset/behav/ $project_name/$project_name.sim/$activeFileset/behav_waveform
          set replaceXSimCall true
          set_property -name {XSIM.ELABORATE.XELAB.MORE_OPTIONS} -value " -standalone -xdci --include $protobufInclude -ignore_assertions " -objects [current_fileset -simset]
        }
      }
    }
    launch_simulation -scripts_only
    if { ![file exists $project_name/$project_name.sim/$activeFileset/behav_gdb] } {
      # -force doesn't work for directory overwrite
      file rename -force $project_name/$project_name.sim/$activeFileset/behav/ $project_name/$project_name.sim/$activeFileset/behav_gdb
    }

    cd $project_name/$project_name.sim/$activeFileset/behav_gdb/$origSimulator
    if { $debugMode } {
      writeNewOpenClScript $debugLevel $topBdName $simRuntime
    }
    
    gen_vimage_inputs $config_info $callBootGen $kernelDebug
    puts "INFO: \[HW_EMU_COMMON_UTIL\] compile.sh started for waveform"
    exec ./compile.sh
    puts "INFO: \[HW_EMU_COMMON_UTIL\] compile.sh ended for waveform"
    writeNewSimulateScript $replaceXSimCall $topBdName
    puts "INFO: \[HW_EMU_COMMON_UTIL\] elaborate.sh started for waveform"
    exec ./elaborate.sh
    puts "INFO: \[HW_EMU_COMMON_UTIL\] elaborate.sh ended for waveform"
    cd ../../../../../
  }
  #end of generate_simulation_scripts_and_compile

  # vimage emulation support for unified platform ZCU102
  # proc generate_simulation_scripts_and_compile_unip { emulation_mode } 
  proc generate_simulation_scripts_and_compile_unip { config_info } {
    set emulation_mode  [dict get $config_info emulation_mode] 
    set project_name    [dict get $config_info emu_proj_name] 
    set simulator       [dict get $config_info simulator] 
    set clibs           [dict get $config_info clibs] 
    #set simRuntime      [dict get $config_info simulation_runtime] 
    
    global tcl_platform

    puts "--- DEBUG: generate_simluation_scripts_and_compile_unip"
    set_param ips.enableSVCosim 1
    set_param project.allowSharedLibraryType 1
    set_param project.copyShLibsToCurrRunDir 1

    set top_bd_design [lindex [get_bd_designs] end]
    generate_target {simulation} [get_files [get_property FILE_NAME $top_bd_design]]
    set bdName [get_property NAME $top_bd_design]]
    set activeFileset [current_fileset -simset] 
    set topModule [get_property top $activeFileset ]
    if {$topModule eq ""} {
      puts "--- DEBUG: changing the top model to ${bdName}_wrapper"
      set_property top ${bdName}_wrapper [get_filesets $activeFileset]
    } else {
      puts "--- DEBUG: top is already set to $topModule"
    }
    if { [string equal -nocase $tcl_platform(platform) "windows"] } {
      set_property {xsim.elaborate.debug_level} %1 [current_fileset -simset]
    } else {
      set_property {xsim.elaborate.debug_level} \$1 [current_fileset -simset]
    }
    set cur_val [get_property xsim.simulate.xsim.more_options [current_fileset -simset]]
    if { [string equal -nocase $tcl_platform(platform) "windows"] } {
      set_property {xsim.simulate.xsim.more_options} "$cur_val %*" [current_fileset -simset]
    } else {
      set_property {xsim.simulate.xsim.more_options} "$cur_val \$*" [current_fileset -simset]
    }
    reset_target {simulation} [get_files [get_property FILE_NAME $top_bd_design]]
   
    set simulatorSelected "xsim"
    if { [string compare -nocase $simulator "questa"] == 0 } {
      set simulatorSelected "questa"
      set_property target_simulator Questa [current_project]
      if { $clibs ne "" } {
        set_property compxlib.questa_compiled_library_dir $clibs [current_project]
      }
      set_property -name {questa.simulate.runtime} -value {all} -objects [current_fileset -simset]
      set_property -name {QUESTA.SIMULATE.LOG_ALL_SIGNALS} -value {false} -objects [current_fileset -simset]
    } 

    launch_simulation -scripts_only
    
    cd $project_name/$project_name.sim/$activeFileset/behav/$simulatorSelected
    if { [string equal -nocase $tcl_platform(platform) "windows"] } {
      puts "--- DEBUG: running compile_bat" 
      exec ./compile.bat
      puts "--- DEBUG: running elaborate_bat $emulation_mode"
      exec ./elaborate.bat $emulation_mode
    } else {
      puts "--- DEBUG: running compile_sh"
      exec ./compile.sh
      puts "--- DEBUG: running elaborate_sh $emulation_mode"
      exec ./elaborate.sh $emulation_mode
    }
    cd ../../../../../
    #file copy -force $project_name/$project_name.sim/$activeFileset/behav $output_dir
  }
  #END of generate_simulation_scripts_and_compile_unip 

  proc jsonFileToDict { fileName } {
    set paramDict [dict create]
    set fp [open $fileName r]
    set file_data [read $fp]

    set paramDict [ json::json2dict $file_data]
    return $paramDict
  }
}

