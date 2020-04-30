set moduleName monte_sim_dev
set isTopModule 1
set isTaskLevelControl 1
set isCombinational 0
set isDatapathOnly 0
set isFreeRunPipelineModule 0
set isPipelined 0
set pipeline_type none
set FunctionProtocol ap_ctrl_hs
set isOneStateSeq 0
set ProfileFlag 1
set StallSigGenFlag 1
set isEnableWaveformDebug 1
set C_modelName {monte_sim_dev}
set C_modelType { void 0 }
set C_modelArgList {
	{ gmem int 32 regular {axi_master 2}  }
	{ in1_V int 64 regular {axi_slave 0}  }
	{ in2_V int 64 regular {axi_slave 0}  }
	{ out_r_V int 64 regular {axi_slave 0}  }
	{ size int 32 regular {axi_slave 0}  }
}
set C_modelArgMapList {[ 
	{ "Name" : "gmem", "interface" : "axi_master", "bitwidth" : 32, "direction" : "READWRITE", "bitSlice":[{"low":0,"up":31,"cElement": [{"cName": "in1.V","cData": "int32","bit_use": { "low": 0,"up": 31},"offset": { "type": "dynamic","port_name": "in1_V","bundle": "control"},"direction": "READONLY","cArray": [{"low" : 0,"up" : 0,"step" : 1}]},{"cName": "in2.V","cData": "int32","bit_use": { "low": 0,"up": 31},"offset": { "type": "dynamic","port_name": "in2_V","bundle": "control"},"direction": "READONLY","cArray": [{"low" : 0,"up" : 0,"step" : 1}]},{"cName": "out_r.V","cData": "int32","bit_use": { "low": 0,"up": 31},"offset": { "type": "dynamic","port_name": "out_r_V","bundle": "control"},"direction": "WRITEONLY","cArray": [{"low" : 0,"up" : 0,"step" : 1}]}]}]} , 
 	{ "Name" : "in1_V", "interface" : "axi_slave", "bundle":"control","type":"ap_none","bitwidth" : 64, "direction" : "READONLY", "offset" : {"in":16}, "offset_end" : {"in":27}} , 
 	{ "Name" : "in2_V", "interface" : "axi_slave", "bundle":"control","type":"ap_none","bitwidth" : 64, "direction" : "READONLY", "offset" : {"in":28}, "offset_end" : {"in":39}} , 
 	{ "Name" : "out_r_V", "interface" : "axi_slave", "bundle":"control","type":"ap_none","bitwidth" : 64, "direction" : "READONLY", "offset" : {"in":40}, "offset_end" : {"in":51}} , 
 	{ "Name" : "size", "interface" : "axi_slave", "bundle":"control","type":"ap_none","bitwidth" : 32, "direction" : "READONLY", "bitSlice":[{"low":0,"up":31,"cElement": [{"cName": "size","cData": "int","bit_use": { "low": 0,"up": 31},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}], "offset" : {"in":52}, "offset_end" : {"in":59}} ]}
# RTL Port declarations: 
set portNum 73
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst_n sc_in sc_logic 1 reset -1 active_low_sync } 
	{ event_done sc_out sc_logic 1 signal -1 } 
	{ m_axi_gmem_AWVALID sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmem_AWREADY sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmem_AWADDR sc_out sc_lv 64 signal 0 } 
	{ m_axi_gmem_AWID sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmem_AWLEN sc_out sc_lv 8 signal 0 } 
	{ m_axi_gmem_AWSIZE sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmem_AWBURST sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmem_AWLOCK sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmem_AWCACHE sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmem_AWPROT sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmem_AWQOS sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmem_AWREGION sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmem_AWUSER sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmem_WVALID sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmem_WREADY sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmem_WDATA sc_out sc_lv 32 signal 0 } 
	{ m_axi_gmem_WSTRB sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmem_WLAST sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmem_WID sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmem_WUSER sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmem_ARVALID sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmem_ARREADY sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmem_ARADDR sc_out sc_lv 64 signal 0 } 
	{ m_axi_gmem_ARID sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmem_ARLEN sc_out sc_lv 8 signal 0 } 
	{ m_axi_gmem_ARSIZE sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmem_ARBURST sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmem_ARLOCK sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmem_ARCACHE sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmem_ARPROT sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmem_ARQOS sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmem_ARREGION sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmem_ARUSER sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmem_RVALID sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmem_RREADY sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmem_RDATA sc_in sc_lv 32 signal 0 } 
	{ m_axi_gmem_RLAST sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmem_RID sc_in sc_lv 1 signal 0 } 
	{ m_axi_gmem_RUSER sc_in sc_lv 1 signal 0 } 
	{ m_axi_gmem_RRESP sc_in sc_lv 2 signal 0 } 
	{ m_axi_gmem_BVALID sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmem_BREADY sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmem_BRESP sc_in sc_lv 2 signal 0 } 
	{ m_axi_gmem_BID sc_in sc_lv 1 signal 0 } 
	{ m_axi_gmem_BUSER sc_in sc_lv 1 signal 0 } 
	{ s_axi_control_AWVALID sc_in sc_logic 1 signal -1 } 
	{ s_axi_control_AWREADY sc_out sc_logic 1 signal -1 } 
	{ s_axi_control_AWADDR sc_in sc_lv 6 signal -1 } 
	{ s_axi_control_WVALID sc_in sc_logic 1 signal -1 } 
	{ s_axi_control_WREADY sc_out sc_logic 1 signal -1 } 
	{ s_axi_control_WDATA sc_in sc_lv 32 signal -1 } 
	{ s_axi_control_WSTRB sc_in sc_lv 4 signal -1 } 
	{ s_axi_control_ARVALID sc_in sc_logic 1 signal -1 } 
	{ s_axi_control_ARREADY sc_out sc_logic 1 signal -1 } 
	{ s_axi_control_ARADDR sc_in sc_lv 6 signal -1 } 
	{ s_axi_control_RVALID sc_out sc_logic 1 signal -1 } 
	{ s_axi_control_RREADY sc_in sc_logic 1 signal -1 } 
	{ s_axi_control_RDATA sc_out sc_lv 32 signal -1 } 
	{ s_axi_control_RRESP sc_out sc_lv 2 signal -1 } 
	{ s_axi_control_BVALID sc_out sc_logic 1 signal -1 } 
	{ s_axi_control_BREADY sc_in sc_logic 1 signal -1 } 
	{ s_axi_control_BRESP sc_out sc_lv 2 signal -1 } 
	{ interrupt sc_out sc_logic 1 signal -1 } 
	{ event_start sc_out sc_logic 1 signal -1 } 
	{ stall_start_ext sc_out sc_logic 1 signal -1 } 
	{ stall_done_ext sc_out sc_logic 1 signal -1 } 
	{ stall_start_str sc_out sc_logic 1 signal -1 } 
	{ stall_done_str sc_out sc_logic 1 signal -1 } 
	{ stall_start_int sc_out sc_logic 1 signal -1 } 
	{ stall_done_int sc_out sc_logic 1 signal -1 } 
}
set NewPortList {[ 
	{ "name": "s_axi_control_AWADDR", "direction": "in", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "control", "role": "AWADDR" },"address":[{"name":"monte_sim_dev","role":"start","value":"0","valid_bit":"0"},{"name":"monte_sim_dev","role":"continue","value":"0","valid_bit":"4"},{"name":"monte_sim_dev","role":"auto_start","value":"0","valid_bit":"7"},{"name":"in1_V","role":"data","value":"16"},{"name":"in2_V","role":"data","value":"28"},{"name":"out_r_V","role":"data","value":"40"},{"name":"size","role":"data","value":"52"}] },
	{ "name": "s_axi_control_AWVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "AWVALID" } },
	{ "name": "s_axi_control_AWREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "AWREADY" } },
	{ "name": "s_axi_control_WVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "WVALID" } },
	{ "name": "s_axi_control_WREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "WREADY" } },
	{ "name": "s_axi_control_WDATA", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "control", "role": "WDATA" } },
	{ "name": "s_axi_control_WSTRB", "direction": "in", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "control", "role": "WSTRB" } },
	{ "name": "s_axi_control_ARADDR", "direction": "in", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "control", "role": "ARADDR" },"address":[{"name":"monte_sim_dev","role":"start","value":"0","valid_bit":"0"},{"name":"monte_sim_dev","role":"done","value":"0","valid_bit":"1"},{"name":"monte_sim_dev","role":"idle","value":"0","valid_bit":"2"},{"name":"monte_sim_dev","role":"ready","value":"0","valid_bit":"3"},{"name":"monte_sim_dev","role":"auto_start","value":"0","valid_bit":"7"}] },
	{ "name": "s_axi_control_ARVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "ARVALID" } },
	{ "name": "s_axi_control_ARREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "ARREADY" } },
	{ "name": "s_axi_control_RVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "RVALID" } },
	{ "name": "s_axi_control_RREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "RREADY" } },
	{ "name": "s_axi_control_RDATA", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "control", "role": "RDATA" } },
	{ "name": "s_axi_control_RRESP", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "control", "role": "RRESP" } },
	{ "name": "s_axi_control_BVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "BVALID" } },
	{ "name": "s_axi_control_BREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "BREADY" } },
	{ "name": "s_axi_control_BRESP", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "control", "role": "BRESP" } },
	{ "name": "interrupt", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "interrupt" } }, 
 	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst_n", "role": "default" }} , 
 	{ "name": "event_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "event_done", "role": "default" }} , 
 	{ "name": "m_axi_gmem_AWVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "AWVALID" }} , 
 	{ "name": "m_axi_gmem_AWREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "AWREADY" }} , 
 	{ "name": "m_axi_gmem_AWADDR", "direction": "out", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "gmem", "role": "AWADDR" }} , 
 	{ "name": "m_axi_gmem_AWID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "AWID" }} , 
 	{ "name": "m_axi_gmem_AWLEN", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "gmem", "role": "AWLEN" }} , 
 	{ "name": "m_axi_gmem_AWSIZE", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmem", "role": "AWSIZE" }} , 
 	{ "name": "m_axi_gmem_AWBURST", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmem", "role": "AWBURST" }} , 
 	{ "name": "m_axi_gmem_AWLOCK", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmem", "role": "AWLOCK" }} , 
 	{ "name": "m_axi_gmem_AWCACHE", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmem", "role": "AWCACHE" }} , 
 	{ "name": "m_axi_gmem_AWPROT", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmem", "role": "AWPROT" }} , 
 	{ "name": "m_axi_gmem_AWQOS", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmem", "role": "AWQOS" }} , 
 	{ "name": "m_axi_gmem_AWREGION", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmem", "role": "AWREGION" }} , 
 	{ "name": "m_axi_gmem_AWUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "AWUSER" }} , 
 	{ "name": "m_axi_gmem_WVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "WVALID" }} , 
 	{ "name": "m_axi_gmem_WREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "WREADY" }} , 
 	{ "name": "m_axi_gmem_WDATA", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "gmem", "role": "WDATA" }} , 
 	{ "name": "m_axi_gmem_WSTRB", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmem", "role": "WSTRB" }} , 
 	{ "name": "m_axi_gmem_WLAST", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "WLAST" }} , 
 	{ "name": "m_axi_gmem_WID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "WID" }} , 
 	{ "name": "m_axi_gmem_WUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "WUSER" }} , 
 	{ "name": "m_axi_gmem_ARVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "ARVALID" }} , 
 	{ "name": "m_axi_gmem_ARREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "ARREADY" }} , 
 	{ "name": "m_axi_gmem_ARADDR", "direction": "out", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "gmem", "role": "ARADDR" }} , 
 	{ "name": "m_axi_gmem_ARID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "ARID" }} , 
 	{ "name": "m_axi_gmem_ARLEN", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "gmem", "role": "ARLEN" }} , 
 	{ "name": "m_axi_gmem_ARSIZE", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmem", "role": "ARSIZE" }} , 
 	{ "name": "m_axi_gmem_ARBURST", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmem", "role": "ARBURST" }} , 
 	{ "name": "m_axi_gmem_ARLOCK", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmem", "role": "ARLOCK" }} , 
 	{ "name": "m_axi_gmem_ARCACHE", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmem", "role": "ARCACHE" }} , 
 	{ "name": "m_axi_gmem_ARPROT", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmem", "role": "ARPROT" }} , 
 	{ "name": "m_axi_gmem_ARQOS", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmem", "role": "ARQOS" }} , 
 	{ "name": "m_axi_gmem_ARREGION", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmem", "role": "ARREGION" }} , 
 	{ "name": "m_axi_gmem_ARUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "ARUSER" }} , 
 	{ "name": "m_axi_gmem_RVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "RVALID" }} , 
 	{ "name": "m_axi_gmem_RREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "RREADY" }} , 
 	{ "name": "m_axi_gmem_RDATA", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "gmem", "role": "RDATA" }} , 
 	{ "name": "m_axi_gmem_RLAST", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "RLAST" }} , 
 	{ "name": "m_axi_gmem_RID", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "RID" }} , 
 	{ "name": "m_axi_gmem_RUSER", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "RUSER" }} , 
 	{ "name": "m_axi_gmem_RRESP", "direction": "in", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmem", "role": "RRESP" }} , 
 	{ "name": "m_axi_gmem_BVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "BVALID" }} , 
 	{ "name": "m_axi_gmem_BREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "BREADY" }} , 
 	{ "name": "m_axi_gmem_BRESP", "direction": "in", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmem", "role": "BRESP" }} , 
 	{ "name": "m_axi_gmem_BID", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "BID" }} , 
 	{ "name": "m_axi_gmem_BUSER", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem", "role": "BUSER" }} , 
 	{ "name": "event_start", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "event_start", "role": "default" }} , 
 	{ "name": "stall_start_ext", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "stall_start_ext", "role": "default" }} , 
 	{ "name": "stall_done_ext", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "stall_done_ext", "role": "default" }} , 
 	{ "name": "stall_start_str", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "stall_start_str", "role": "default" }} , 
 	{ "name": "stall_done_str", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "stall_done_str", "role": "default" }} , 
 	{ "name": "stall_start_int", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "stall_start_int", "role": "default" }} , 
 	{ "name": "stall_done_int", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "stall_done_int", "role": "default" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1", "2", "3", "4", "5", "6", "29", "52", "75", "98", "121", "144", "167", "168", "169", "170", "171", "172", "173", "174", "175", "176"],
		"CDFG" : "monte_sim_dev",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "13369", "EstimateLatencyMax" : "13369",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "gmem", "Type" : "MAXI", "Direction" : "IO",
				"BlockSignal" : [
					{"Name" : "gmem_blk_n_AR", "Type" : "RtlSignal"},
					{"Name" : "gmem_blk_n_R", "Type" : "RtlSignal"},
					{"Name" : "gmem_blk_n_AW", "Type" : "RtlSignal"},
					{"Name" : "gmem_blk_n_W", "Type" : "RtlSignal"},
					{"Name" : "gmem_blk_n_B", "Type" : "RtlSignal"}]},
			{"Name" : "in1_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "in2_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "out_r_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "size", "Type" : "None", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_inverse_lut_table_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "6", "SubInstance" : "grp_pow_32_16_s_fu_411", "Port" : "log_apfixed_reduce_log_inverse_lut_table_array_V"},
					{"ID" : "29", "SubInstance" : "grp_pow_32_16_s_fu_438", "Port" : "log_apfixed_reduce_log_inverse_lut_table_array_V"},
					{"ID" : "52", "SubInstance" : "grp_pow_32_16_s_fu_465", "Port" : "log_apfixed_reduce_log_inverse_lut_table_array_V"},
					{"ID" : "75", "SubInstance" : "grp_pow_32_16_s_fu_492", "Port" : "log_apfixed_reduce_log_inverse_lut_table_array_V"},
					{"ID" : "98", "SubInstance" : "grp_pow_32_16_s_fu_519", "Port" : "log_apfixed_reduce_log_inverse_lut_table_array_V"},
					{"ID" : "121", "SubInstance" : "grp_pow_32_16_s_fu_546", "Port" : "log_apfixed_reduce_log_inverse_lut_table_array_V"},
					{"ID" : "144", "SubInstance" : "grp_pow_32_16_s_fu_573", "Port" : "log_apfixed_reduce_log_inverse_lut_table_array_V"}]},
			{"Name" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "6", "SubInstance" : "grp_pow_32_16_s_fu_411", "Port" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V"},
					{"ID" : "29", "SubInstance" : "grp_pow_32_16_s_fu_438", "Port" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V"},
					{"ID" : "52", "SubInstance" : "grp_pow_32_16_s_fu_465", "Port" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V"},
					{"ID" : "75", "SubInstance" : "grp_pow_32_16_s_fu_492", "Port" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V"},
					{"ID" : "98", "SubInstance" : "grp_pow_32_16_s_fu_519", "Port" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V"},
					{"ID" : "121", "SubInstance" : "grp_pow_32_16_s_fu_546", "Port" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V"},
					{"ID" : "144", "SubInstance" : "grp_pow_32_16_s_fu_573", "Port" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "6", "SubInstance" : "grp_pow_32_16_s_fu_411", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V"},
					{"ID" : "29", "SubInstance" : "grp_pow_32_16_s_fu_438", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V"},
					{"ID" : "52", "SubInstance" : "grp_pow_32_16_s_fu_465", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V"},
					{"ID" : "75", "SubInstance" : "grp_pow_32_16_s_fu_492", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V"},
					{"ID" : "98", "SubInstance" : "grp_pow_32_16_s_fu_519", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V"},
					{"ID" : "121", "SubInstance" : "grp_pow_32_16_s_fu_546", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V"},
					{"ID" : "144", "SubInstance" : "grp_pow_32_16_s_fu_573", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "6", "SubInstance" : "grp_pow_32_16_s_fu_411", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V"},
					{"ID" : "29", "SubInstance" : "grp_pow_32_16_s_fu_438", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V"},
					{"ID" : "52", "SubInstance" : "grp_pow_32_16_s_fu_465", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V"},
					{"ID" : "75", "SubInstance" : "grp_pow_32_16_s_fu_492", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V"},
					{"ID" : "98", "SubInstance" : "grp_pow_32_16_s_fu_519", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V"},
					{"ID" : "121", "SubInstance" : "grp_pow_32_16_s_fu_546", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V"},
					{"ID" : "144", "SubInstance" : "grp_pow_32_16_s_fu_573", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "6", "SubInstance" : "grp_pow_32_16_s_fu_411", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V"},
					{"ID" : "29", "SubInstance" : "grp_pow_32_16_s_fu_438", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V"},
					{"ID" : "52", "SubInstance" : "grp_pow_32_16_s_fu_465", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V"},
					{"ID" : "75", "SubInstance" : "grp_pow_32_16_s_fu_492", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V"},
					{"ID" : "98", "SubInstance" : "grp_pow_32_16_s_fu_519", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V"},
					{"ID" : "121", "SubInstance" : "grp_pow_32_16_s_fu_546", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V"},
					{"ID" : "144", "SubInstance" : "grp_pow_32_16_s_fu_573", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "6", "SubInstance" : "grp_pow_32_16_s_fu_411", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V"},
					{"ID" : "29", "SubInstance" : "grp_pow_32_16_s_fu_438", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V"},
					{"ID" : "52", "SubInstance" : "grp_pow_32_16_s_fu_465", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V"},
					{"ID" : "75", "SubInstance" : "grp_pow_32_16_s_fu_492", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V"},
					{"ID" : "98", "SubInstance" : "grp_pow_32_16_s_fu_519", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V"},
					{"ID" : "121", "SubInstance" : "grp_pow_32_16_s_fu_546", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V"},
					{"ID" : "144", "SubInstance" : "grp_pow_32_16_s_fu_573", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V"}]},
			{"Name" : "f_x_msb_4_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "6", "SubInstance" : "grp_pow_32_16_s_fu_411", "Port" : "f_x_msb_4_table_V"},
					{"ID" : "29", "SubInstance" : "grp_pow_32_16_s_fu_438", "Port" : "f_x_msb_4_table_V"},
					{"ID" : "52", "SubInstance" : "grp_pow_32_16_s_fu_465", "Port" : "f_x_msb_4_table_V"},
					{"ID" : "75", "SubInstance" : "grp_pow_32_16_s_fu_492", "Port" : "f_x_msb_4_table_V"},
					{"ID" : "98", "SubInstance" : "grp_pow_32_16_s_fu_519", "Port" : "f_x_msb_4_table_V"},
					{"ID" : "121", "SubInstance" : "grp_pow_32_16_s_fu_546", "Port" : "f_x_msb_4_table_V"},
					{"ID" : "144", "SubInstance" : "grp_pow_32_16_s_fu_573", "Port" : "f_x_msb_4_table_V"}]},
			{"Name" : "f_x_msb_3_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "6", "SubInstance" : "grp_pow_32_16_s_fu_411", "Port" : "f_x_msb_3_table_V"},
					{"ID" : "29", "SubInstance" : "grp_pow_32_16_s_fu_438", "Port" : "f_x_msb_3_table_V"},
					{"ID" : "52", "SubInstance" : "grp_pow_32_16_s_fu_465", "Port" : "f_x_msb_3_table_V"},
					{"ID" : "75", "SubInstance" : "grp_pow_32_16_s_fu_492", "Port" : "f_x_msb_3_table_V"},
					{"ID" : "98", "SubInstance" : "grp_pow_32_16_s_fu_519", "Port" : "f_x_msb_3_table_V"},
					{"ID" : "121", "SubInstance" : "grp_pow_32_16_s_fu_546", "Port" : "f_x_msb_3_table_V"},
					{"ID" : "144", "SubInstance" : "grp_pow_32_16_s_fu_573", "Port" : "f_x_msb_3_table_V"}]},
			{"Name" : "f_x_msb_2_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "6", "SubInstance" : "grp_pow_32_16_s_fu_411", "Port" : "f_x_msb_2_table_V"},
					{"ID" : "29", "SubInstance" : "grp_pow_32_16_s_fu_438", "Port" : "f_x_msb_2_table_V"},
					{"ID" : "52", "SubInstance" : "grp_pow_32_16_s_fu_465", "Port" : "f_x_msb_2_table_V"},
					{"ID" : "75", "SubInstance" : "grp_pow_32_16_s_fu_492", "Port" : "f_x_msb_2_table_V"},
					{"ID" : "98", "SubInstance" : "grp_pow_32_16_s_fu_519", "Port" : "f_x_msb_2_table_V"},
					{"ID" : "121", "SubInstance" : "grp_pow_32_16_s_fu_546", "Port" : "f_x_msb_2_table_V"},
					{"ID" : "144", "SubInstance" : "grp_pow_32_16_s_fu_573", "Port" : "f_x_msb_2_table_V"}]},
			{"Name" : "exp_x_msb_1_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "6", "SubInstance" : "grp_pow_32_16_s_fu_411", "Port" : "exp_x_msb_1_table_V"},
					{"ID" : "29", "SubInstance" : "grp_pow_32_16_s_fu_438", "Port" : "exp_x_msb_1_table_V"},
					{"ID" : "52", "SubInstance" : "grp_pow_32_16_s_fu_465", "Port" : "exp_x_msb_1_table_V"},
					{"ID" : "75", "SubInstance" : "grp_pow_32_16_s_fu_492", "Port" : "exp_x_msb_1_table_V"},
					{"ID" : "98", "SubInstance" : "grp_pow_32_16_s_fu_519", "Port" : "exp_x_msb_1_table_V"},
					{"ID" : "121", "SubInstance" : "grp_pow_32_16_s_fu_546", "Port" : "exp_x_msb_1_table_V"},
					{"ID" : "144", "SubInstance" : "grp_pow_32_16_s_fu_573", "Port" : "exp_x_msb_1_table_V"}]}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.monte_sim_dev_control_s_axi_U", "Parent" : "0"},
	{"ID" : "2", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.monte_sim_dev_gmem_m_axi_U", "Parent" : "0"},
	{"ID" : "3", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.v1_buffer_V_U", "Parent" : "0"},
	{"ID" : "4", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.v2_buffer_V_U", "Parent" : "0"},
	{"ID" : "5", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.vout_buffer_V_U", "Parent" : "0"},
	{"ID" : "6", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411", "Parent" : "0", "Child" : ["7", "20", "28"],
		"CDFG" : "pow_32_16_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "54", "EstimateLatencyMin" : "54", "EstimateLatencyMax" : "54",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "y_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_inverse_lut_table_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "7", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_inverse_lut_table_array_V"}]},
			{"Name" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "7", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "7", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "7", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "7", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "7", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V"}]},
			{"Name" : "f_x_msb_4_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "20", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_4_table_V"}]},
			{"Name" : "f_x_msb_3_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "20", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_3_table_V"}]},
			{"Name" : "f_x_msb_2_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "20", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_2_table_V"}]},
			{"Name" : "exp_x_msb_1_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "20", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "exp_x_msb_1_table_V"}]}]},
	{"ID" : "7", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_log_67_17_s_fu_144", "Parent" : "6", "Child" : ["8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19"],
		"CDFG" : "log_67_17_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "31", "EstimateLatencyMin" : "31", "EstimateLatencyMax" : "31",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_inverse_lut_table_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V", "Type" : "Memory", "Direction" : "I"}]},
	{"ID" : "8", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_inverse_lut_table_array_V_U", "Parent" : "7"},
	{"ID" : "9", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_log_67_17_s_fu_144.log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V_U", "Parent" : "7"},
	{"ID" : "10", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V_U", "Parent" : "7"},
	{"ID" : "11", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V_U", "Parent" : "7"},
	{"ID" : "12", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V_U", "Parent" : "7"},
	{"ID" : "13", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V_U", "Parent" : "7"},
	{"ID" : "14", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_log_67_17_s_fu_144.monte_sim_dev_mul_81ns_6ns_87_5_1_U1", "Parent" : "7"},
	{"ID" : "15", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_log_67_17_s_fu_144.monte_sim_dev_mul_68ns_4ns_72_5_1_U2", "Parent" : "7"},
	{"ID" : "16", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_log_67_17_s_fu_144.monte_sim_dev_mul_60ns_6ns_66_4_1_U3", "Parent" : "7"},
	{"ID" : "17", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_log_67_17_s_fu_144.monte_sim_dev_mul_55ns_6ns_61_4_1_U4", "Parent" : "7"},
	{"ID" : "18", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_log_67_17_s_fu_144.monte_sim_dev_mul_50ns_6ns_56_4_1_U5", "Parent" : "7"},
	{"ID" : "19", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_log_67_17_s_fu_144.monte_sim_dev_mul_7s_68ns_73_5_1_U6", "Parent" : "7"},
	{"ID" : "20", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_exp_core_32_16_50_s_fu_161", "Parent" : "6", "Child" : ["21", "22", "23", "24", "25", "26", "27"],
		"CDFG" : "exp_core_32_16_50_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "15", "EstimateLatencyMin" : "15", "EstimateLatencyMax" : "15",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "f_x_msb_4_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "f_x_msb_3_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "f_x_msb_2_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "exp_x_msb_1_table_V", "Type" : "Memory", "Direction" : "I"}]},
	{"ID" : "21", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_exp_core_32_16_50_s_fu_161.f_x_msb_4_table_V_U", "Parent" : "20"},
	{"ID" : "22", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_exp_core_32_16_50_s_fu_161.f_x_msb_3_table_V_U", "Parent" : "20"},
	{"ID" : "23", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_exp_core_32_16_50_s_fu_161.f_x_msb_2_table_V_U", "Parent" : "20"},
	{"ID" : "24", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_exp_core_32_16_50_s_fu_161.exp_x_msb_1_table_V_U", "Parent" : "20"},
	{"ID" : "25", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_36ns_44ns_80_4_1_U20", "Parent" : "20"},
	{"ID" : "26", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_48ns_50ns_98_4_1_U21", "Parent" : "20"},
	{"ID" : "27", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_50ns_50ns_100_4_1_U22", "Parent" : "20"},
	{"ID" : "28", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_411.monte_sim_dev_mul_56s_19ns_74_4_1_U31", "Parent" : "6"},
	{"ID" : "29", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438", "Parent" : "0", "Child" : ["30", "43", "51"],
		"CDFG" : "pow_32_16_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "54", "EstimateLatencyMin" : "54", "EstimateLatencyMax" : "54",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "y_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_inverse_lut_table_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "30", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_inverse_lut_table_array_V"}]},
			{"Name" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "30", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "30", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "30", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "30", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "30", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V"}]},
			{"Name" : "f_x_msb_4_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "43", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_4_table_V"}]},
			{"Name" : "f_x_msb_3_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "43", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_3_table_V"}]},
			{"Name" : "f_x_msb_2_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "43", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_2_table_V"}]},
			{"Name" : "exp_x_msb_1_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "43", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "exp_x_msb_1_table_V"}]}]},
	{"ID" : "30", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_log_67_17_s_fu_144", "Parent" : "29", "Child" : ["31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42"],
		"CDFG" : "log_67_17_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "31", "EstimateLatencyMin" : "31", "EstimateLatencyMax" : "31",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_inverse_lut_table_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V", "Type" : "Memory", "Direction" : "I"}]},
	{"ID" : "31", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_inverse_lut_table_array_V_U", "Parent" : "30"},
	{"ID" : "32", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_log_67_17_s_fu_144.log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V_U", "Parent" : "30"},
	{"ID" : "33", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V_U", "Parent" : "30"},
	{"ID" : "34", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V_U", "Parent" : "30"},
	{"ID" : "35", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V_U", "Parent" : "30"},
	{"ID" : "36", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V_U", "Parent" : "30"},
	{"ID" : "37", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_log_67_17_s_fu_144.monte_sim_dev_mul_81ns_6ns_87_5_1_U1", "Parent" : "30"},
	{"ID" : "38", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_log_67_17_s_fu_144.monte_sim_dev_mul_68ns_4ns_72_5_1_U2", "Parent" : "30"},
	{"ID" : "39", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_log_67_17_s_fu_144.monte_sim_dev_mul_60ns_6ns_66_4_1_U3", "Parent" : "30"},
	{"ID" : "40", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_log_67_17_s_fu_144.monte_sim_dev_mul_55ns_6ns_61_4_1_U4", "Parent" : "30"},
	{"ID" : "41", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_log_67_17_s_fu_144.monte_sim_dev_mul_50ns_6ns_56_4_1_U5", "Parent" : "30"},
	{"ID" : "42", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_log_67_17_s_fu_144.monte_sim_dev_mul_7s_68ns_73_5_1_U6", "Parent" : "30"},
	{"ID" : "43", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_exp_core_32_16_50_s_fu_161", "Parent" : "29", "Child" : ["44", "45", "46", "47", "48", "49", "50"],
		"CDFG" : "exp_core_32_16_50_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "15", "EstimateLatencyMin" : "15", "EstimateLatencyMax" : "15",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "f_x_msb_4_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "f_x_msb_3_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "f_x_msb_2_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "exp_x_msb_1_table_V", "Type" : "Memory", "Direction" : "I"}]},
	{"ID" : "44", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_exp_core_32_16_50_s_fu_161.f_x_msb_4_table_V_U", "Parent" : "43"},
	{"ID" : "45", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_exp_core_32_16_50_s_fu_161.f_x_msb_3_table_V_U", "Parent" : "43"},
	{"ID" : "46", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_exp_core_32_16_50_s_fu_161.f_x_msb_2_table_V_U", "Parent" : "43"},
	{"ID" : "47", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_exp_core_32_16_50_s_fu_161.exp_x_msb_1_table_V_U", "Parent" : "43"},
	{"ID" : "48", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_36ns_44ns_80_4_1_U20", "Parent" : "43"},
	{"ID" : "49", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_48ns_50ns_98_4_1_U21", "Parent" : "43"},
	{"ID" : "50", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_50ns_50ns_100_4_1_U22", "Parent" : "43"},
	{"ID" : "51", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_438.monte_sim_dev_mul_56s_19ns_74_4_1_U31", "Parent" : "29"},
	{"ID" : "52", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465", "Parent" : "0", "Child" : ["53", "66", "74"],
		"CDFG" : "pow_32_16_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "54", "EstimateLatencyMin" : "54", "EstimateLatencyMax" : "54",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "y_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_inverse_lut_table_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "53", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_inverse_lut_table_array_V"}]},
			{"Name" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "53", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "53", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "53", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "53", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "53", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V"}]},
			{"Name" : "f_x_msb_4_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "66", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_4_table_V"}]},
			{"Name" : "f_x_msb_3_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "66", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_3_table_V"}]},
			{"Name" : "f_x_msb_2_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "66", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_2_table_V"}]},
			{"Name" : "exp_x_msb_1_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "66", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "exp_x_msb_1_table_V"}]}]},
	{"ID" : "53", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_log_67_17_s_fu_144", "Parent" : "52", "Child" : ["54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65"],
		"CDFG" : "log_67_17_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "31", "EstimateLatencyMin" : "31", "EstimateLatencyMax" : "31",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_inverse_lut_table_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V", "Type" : "Memory", "Direction" : "I"}]},
	{"ID" : "54", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_inverse_lut_table_array_V_U", "Parent" : "53"},
	{"ID" : "55", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_log_67_17_s_fu_144.log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V_U", "Parent" : "53"},
	{"ID" : "56", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V_U", "Parent" : "53"},
	{"ID" : "57", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V_U", "Parent" : "53"},
	{"ID" : "58", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V_U", "Parent" : "53"},
	{"ID" : "59", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V_U", "Parent" : "53"},
	{"ID" : "60", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_log_67_17_s_fu_144.monte_sim_dev_mul_81ns_6ns_87_5_1_U1", "Parent" : "53"},
	{"ID" : "61", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_log_67_17_s_fu_144.monte_sim_dev_mul_68ns_4ns_72_5_1_U2", "Parent" : "53"},
	{"ID" : "62", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_log_67_17_s_fu_144.monte_sim_dev_mul_60ns_6ns_66_4_1_U3", "Parent" : "53"},
	{"ID" : "63", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_log_67_17_s_fu_144.monte_sim_dev_mul_55ns_6ns_61_4_1_U4", "Parent" : "53"},
	{"ID" : "64", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_log_67_17_s_fu_144.monte_sim_dev_mul_50ns_6ns_56_4_1_U5", "Parent" : "53"},
	{"ID" : "65", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_log_67_17_s_fu_144.monte_sim_dev_mul_7s_68ns_73_5_1_U6", "Parent" : "53"},
	{"ID" : "66", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_exp_core_32_16_50_s_fu_161", "Parent" : "52", "Child" : ["67", "68", "69", "70", "71", "72", "73"],
		"CDFG" : "exp_core_32_16_50_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "15", "EstimateLatencyMin" : "15", "EstimateLatencyMax" : "15",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "f_x_msb_4_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "f_x_msb_3_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "f_x_msb_2_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "exp_x_msb_1_table_V", "Type" : "Memory", "Direction" : "I"}]},
	{"ID" : "67", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_exp_core_32_16_50_s_fu_161.f_x_msb_4_table_V_U", "Parent" : "66"},
	{"ID" : "68", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_exp_core_32_16_50_s_fu_161.f_x_msb_3_table_V_U", "Parent" : "66"},
	{"ID" : "69", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_exp_core_32_16_50_s_fu_161.f_x_msb_2_table_V_U", "Parent" : "66"},
	{"ID" : "70", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_exp_core_32_16_50_s_fu_161.exp_x_msb_1_table_V_U", "Parent" : "66"},
	{"ID" : "71", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_36ns_44ns_80_4_1_U20", "Parent" : "66"},
	{"ID" : "72", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_48ns_50ns_98_4_1_U21", "Parent" : "66"},
	{"ID" : "73", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_50ns_50ns_100_4_1_U22", "Parent" : "66"},
	{"ID" : "74", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_465.monte_sim_dev_mul_56s_19ns_74_4_1_U31", "Parent" : "52"},
	{"ID" : "75", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492", "Parent" : "0", "Child" : ["76", "89", "97"],
		"CDFG" : "pow_32_16_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "54", "EstimateLatencyMin" : "54", "EstimateLatencyMax" : "54",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "y_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_inverse_lut_table_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "76", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_inverse_lut_table_array_V"}]},
			{"Name" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "76", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "76", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "76", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "76", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "76", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V"}]},
			{"Name" : "f_x_msb_4_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "89", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_4_table_V"}]},
			{"Name" : "f_x_msb_3_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "89", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_3_table_V"}]},
			{"Name" : "f_x_msb_2_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "89", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_2_table_V"}]},
			{"Name" : "exp_x_msb_1_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "89", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "exp_x_msb_1_table_V"}]}]},
	{"ID" : "76", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_log_67_17_s_fu_144", "Parent" : "75", "Child" : ["77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88"],
		"CDFG" : "log_67_17_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "31", "EstimateLatencyMin" : "31", "EstimateLatencyMax" : "31",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_inverse_lut_table_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V", "Type" : "Memory", "Direction" : "I"}]},
	{"ID" : "77", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_inverse_lut_table_array_V_U", "Parent" : "76"},
	{"ID" : "78", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_log_67_17_s_fu_144.log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V_U", "Parent" : "76"},
	{"ID" : "79", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V_U", "Parent" : "76"},
	{"ID" : "80", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V_U", "Parent" : "76"},
	{"ID" : "81", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V_U", "Parent" : "76"},
	{"ID" : "82", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V_U", "Parent" : "76"},
	{"ID" : "83", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_log_67_17_s_fu_144.monte_sim_dev_mul_81ns_6ns_87_5_1_U1", "Parent" : "76"},
	{"ID" : "84", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_log_67_17_s_fu_144.monte_sim_dev_mul_68ns_4ns_72_5_1_U2", "Parent" : "76"},
	{"ID" : "85", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_log_67_17_s_fu_144.monte_sim_dev_mul_60ns_6ns_66_4_1_U3", "Parent" : "76"},
	{"ID" : "86", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_log_67_17_s_fu_144.monte_sim_dev_mul_55ns_6ns_61_4_1_U4", "Parent" : "76"},
	{"ID" : "87", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_log_67_17_s_fu_144.monte_sim_dev_mul_50ns_6ns_56_4_1_U5", "Parent" : "76"},
	{"ID" : "88", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_log_67_17_s_fu_144.monte_sim_dev_mul_7s_68ns_73_5_1_U6", "Parent" : "76"},
	{"ID" : "89", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_exp_core_32_16_50_s_fu_161", "Parent" : "75", "Child" : ["90", "91", "92", "93", "94", "95", "96"],
		"CDFG" : "exp_core_32_16_50_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "15", "EstimateLatencyMin" : "15", "EstimateLatencyMax" : "15",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "f_x_msb_4_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "f_x_msb_3_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "f_x_msb_2_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "exp_x_msb_1_table_V", "Type" : "Memory", "Direction" : "I"}]},
	{"ID" : "90", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_exp_core_32_16_50_s_fu_161.f_x_msb_4_table_V_U", "Parent" : "89"},
	{"ID" : "91", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_exp_core_32_16_50_s_fu_161.f_x_msb_3_table_V_U", "Parent" : "89"},
	{"ID" : "92", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_exp_core_32_16_50_s_fu_161.f_x_msb_2_table_V_U", "Parent" : "89"},
	{"ID" : "93", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_exp_core_32_16_50_s_fu_161.exp_x_msb_1_table_V_U", "Parent" : "89"},
	{"ID" : "94", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_36ns_44ns_80_4_1_U20", "Parent" : "89"},
	{"ID" : "95", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_48ns_50ns_98_4_1_U21", "Parent" : "89"},
	{"ID" : "96", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_50ns_50ns_100_4_1_U22", "Parent" : "89"},
	{"ID" : "97", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_492.monte_sim_dev_mul_56s_19ns_74_4_1_U31", "Parent" : "75"},
	{"ID" : "98", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519", "Parent" : "0", "Child" : ["99", "112", "120"],
		"CDFG" : "pow_32_16_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "54", "EstimateLatencyMin" : "54", "EstimateLatencyMax" : "54",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "y_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_inverse_lut_table_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "99", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_inverse_lut_table_array_V"}]},
			{"Name" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "99", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "99", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "99", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "99", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "99", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V"}]},
			{"Name" : "f_x_msb_4_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "112", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_4_table_V"}]},
			{"Name" : "f_x_msb_3_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "112", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_3_table_V"}]},
			{"Name" : "f_x_msb_2_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "112", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_2_table_V"}]},
			{"Name" : "exp_x_msb_1_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "112", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "exp_x_msb_1_table_V"}]}]},
	{"ID" : "99", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_log_67_17_s_fu_144", "Parent" : "98", "Child" : ["100", "101", "102", "103", "104", "105", "106", "107", "108", "109", "110", "111"],
		"CDFG" : "log_67_17_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "31", "EstimateLatencyMin" : "31", "EstimateLatencyMax" : "31",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_inverse_lut_table_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V", "Type" : "Memory", "Direction" : "I"}]},
	{"ID" : "100", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_inverse_lut_table_array_V_U", "Parent" : "99"},
	{"ID" : "101", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_log_67_17_s_fu_144.log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V_U", "Parent" : "99"},
	{"ID" : "102", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V_U", "Parent" : "99"},
	{"ID" : "103", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V_U", "Parent" : "99"},
	{"ID" : "104", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V_U", "Parent" : "99"},
	{"ID" : "105", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V_U", "Parent" : "99"},
	{"ID" : "106", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_log_67_17_s_fu_144.monte_sim_dev_mul_81ns_6ns_87_5_1_U1", "Parent" : "99"},
	{"ID" : "107", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_log_67_17_s_fu_144.monte_sim_dev_mul_68ns_4ns_72_5_1_U2", "Parent" : "99"},
	{"ID" : "108", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_log_67_17_s_fu_144.monte_sim_dev_mul_60ns_6ns_66_4_1_U3", "Parent" : "99"},
	{"ID" : "109", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_log_67_17_s_fu_144.monte_sim_dev_mul_55ns_6ns_61_4_1_U4", "Parent" : "99"},
	{"ID" : "110", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_log_67_17_s_fu_144.monte_sim_dev_mul_50ns_6ns_56_4_1_U5", "Parent" : "99"},
	{"ID" : "111", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_log_67_17_s_fu_144.monte_sim_dev_mul_7s_68ns_73_5_1_U6", "Parent" : "99"},
	{"ID" : "112", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_exp_core_32_16_50_s_fu_161", "Parent" : "98", "Child" : ["113", "114", "115", "116", "117", "118", "119"],
		"CDFG" : "exp_core_32_16_50_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "15", "EstimateLatencyMin" : "15", "EstimateLatencyMax" : "15",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "f_x_msb_4_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "f_x_msb_3_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "f_x_msb_2_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "exp_x_msb_1_table_V", "Type" : "Memory", "Direction" : "I"}]},
	{"ID" : "113", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_exp_core_32_16_50_s_fu_161.f_x_msb_4_table_V_U", "Parent" : "112"},
	{"ID" : "114", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_exp_core_32_16_50_s_fu_161.f_x_msb_3_table_V_U", "Parent" : "112"},
	{"ID" : "115", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_exp_core_32_16_50_s_fu_161.f_x_msb_2_table_V_U", "Parent" : "112"},
	{"ID" : "116", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_exp_core_32_16_50_s_fu_161.exp_x_msb_1_table_V_U", "Parent" : "112"},
	{"ID" : "117", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_36ns_44ns_80_4_1_U20", "Parent" : "112"},
	{"ID" : "118", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_48ns_50ns_98_4_1_U21", "Parent" : "112"},
	{"ID" : "119", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_50ns_50ns_100_4_1_U22", "Parent" : "112"},
	{"ID" : "120", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_519.monte_sim_dev_mul_56s_19ns_74_4_1_U31", "Parent" : "98"},
	{"ID" : "121", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546", "Parent" : "0", "Child" : ["122", "135", "143"],
		"CDFG" : "pow_32_16_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "54", "EstimateLatencyMin" : "54", "EstimateLatencyMax" : "54",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "y_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_inverse_lut_table_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "122", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_inverse_lut_table_array_V"}]},
			{"Name" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "122", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "122", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "122", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "122", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "122", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V"}]},
			{"Name" : "f_x_msb_4_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "135", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_4_table_V"}]},
			{"Name" : "f_x_msb_3_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "135", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_3_table_V"}]},
			{"Name" : "f_x_msb_2_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "135", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_2_table_V"}]},
			{"Name" : "exp_x_msb_1_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "135", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "exp_x_msb_1_table_V"}]}]},
	{"ID" : "122", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_log_67_17_s_fu_144", "Parent" : "121", "Child" : ["123", "124", "125", "126", "127", "128", "129", "130", "131", "132", "133", "134"],
		"CDFG" : "log_67_17_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "31", "EstimateLatencyMin" : "31", "EstimateLatencyMax" : "31",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_inverse_lut_table_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V", "Type" : "Memory", "Direction" : "I"}]},
	{"ID" : "123", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_inverse_lut_table_array_V_U", "Parent" : "122"},
	{"ID" : "124", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_log_67_17_s_fu_144.log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V_U", "Parent" : "122"},
	{"ID" : "125", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V_U", "Parent" : "122"},
	{"ID" : "126", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V_U", "Parent" : "122"},
	{"ID" : "127", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V_U", "Parent" : "122"},
	{"ID" : "128", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V_U", "Parent" : "122"},
	{"ID" : "129", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_log_67_17_s_fu_144.monte_sim_dev_mul_81ns_6ns_87_5_1_U1", "Parent" : "122"},
	{"ID" : "130", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_log_67_17_s_fu_144.monte_sim_dev_mul_68ns_4ns_72_5_1_U2", "Parent" : "122"},
	{"ID" : "131", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_log_67_17_s_fu_144.monte_sim_dev_mul_60ns_6ns_66_4_1_U3", "Parent" : "122"},
	{"ID" : "132", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_log_67_17_s_fu_144.monte_sim_dev_mul_55ns_6ns_61_4_1_U4", "Parent" : "122"},
	{"ID" : "133", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_log_67_17_s_fu_144.monte_sim_dev_mul_50ns_6ns_56_4_1_U5", "Parent" : "122"},
	{"ID" : "134", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_log_67_17_s_fu_144.monte_sim_dev_mul_7s_68ns_73_5_1_U6", "Parent" : "122"},
	{"ID" : "135", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_exp_core_32_16_50_s_fu_161", "Parent" : "121", "Child" : ["136", "137", "138", "139", "140", "141", "142"],
		"CDFG" : "exp_core_32_16_50_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "15", "EstimateLatencyMin" : "15", "EstimateLatencyMax" : "15",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "f_x_msb_4_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "f_x_msb_3_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "f_x_msb_2_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "exp_x_msb_1_table_V", "Type" : "Memory", "Direction" : "I"}]},
	{"ID" : "136", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_exp_core_32_16_50_s_fu_161.f_x_msb_4_table_V_U", "Parent" : "135"},
	{"ID" : "137", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_exp_core_32_16_50_s_fu_161.f_x_msb_3_table_V_U", "Parent" : "135"},
	{"ID" : "138", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_exp_core_32_16_50_s_fu_161.f_x_msb_2_table_V_U", "Parent" : "135"},
	{"ID" : "139", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_exp_core_32_16_50_s_fu_161.exp_x_msb_1_table_V_U", "Parent" : "135"},
	{"ID" : "140", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_36ns_44ns_80_4_1_U20", "Parent" : "135"},
	{"ID" : "141", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_48ns_50ns_98_4_1_U21", "Parent" : "135"},
	{"ID" : "142", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_50ns_50ns_100_4_1_U22", "Parent" : "135"},
	{"ID" : "143", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_546.monte_sim_dev_mul_56s_19ns_74_4_1_U31", "Parent" : "121"},
	{"ID" : "144", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573", "Parent" : "0", "Child" : ["145", "158", "166"],
		"CDFG" : "pow_32_16_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "54", "EstimateLatencyMin" : "54", "EstimateLatencyMax" : "54",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "y_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_inverse_lut_table_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "145", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_inverse_lut_table_array_V"}]},
			{"Name" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "145", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "145", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "145", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "145", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V"}]},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "145", "SubInstance" : "grp_log_67_17_s_fu_144", "Port" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V"}]},
			{"Name" : "f_x_msb_4_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "158", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_4_table_V"}]},
			{"Name" : "f_x_msb_3_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "158", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_3_table_V"}]},
			{"Name" : "f_x_msb_2_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "158", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "f_x_msb_2_table_V"}]},
			{"Name" : "exp_x_msb_1_table_V", "Type" : "Memory", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "158", "SubInstance" : "grp_exp_core_32_16_50_s_fu_161", "Port" : "exp_x_msb_1_table_V"}]}]},
	{"ID" : "145", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_log_67_17_s_fu_144", "Parent" : "144", "Child" : ["146", "147", "148", "149", "150", "151", "152", "153", "154", "155", "156", "157"],
		"CDFG" : "log_67_17_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "31", "EstimateLatencyMin" : "31", "EstimateLatencyMax" : "31",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_inverse_lut_table_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V", "Type" : "Memory", "Direction" : "I"}]},
	{"ID" : "146", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_inverse_lut_table_array_V_U", "Parent" : "145"},
	{"ID" : "147", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_log_67_17_s_fu_144.log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V_U", "Parent" : "145"},
	{"ID" : "148", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V_U", "Parent" : "145"},
	{"ID" : "149", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V_U", "Parent" : "145"},
	{"ID" : "150", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V_U", "Parent" : "145"},
	{"ID" : "151", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_log_67_17_s_fu_144.log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V_U", "Parent" : "145"},
	{"ID" : "152", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_log_67_17_s_fu_144.monte_sim_dev_mul_81ns_6ns_87_5_1_U1", "Parent" : "145"},
	{"ID" : "153", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_log_67_17_s_fu_144.monte_sim_dev_mul_68ns_4ns_72_5_1_U2", "Parent" : "145"},
	{"ID" : "154", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_log_67_17_s_fu_144.monte_sim_dev_mul_60ns_6ns_66_4_1_U3", "Parent" : "145"},
	{"ID" : "155", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_log_67_17_s_fu_144.monte_sim_dev_mul_55ns_6ns_61_4_1_U4", "Parent" : "145"},
	{"ID" : "156", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_log_67_17_s_fu_144.monte_sim_dev_mul_50ns_6ns_56_4_1_U5", "Parent" : "145"},
	{"ID" : "157", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_log_67_17_s_fu_144.monte_sim_dev_mul_7s_68ns_73_5_1_U6", "Parent" : "145"},
	{"ID" : "158", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_exp_core_32_16_50_s_fu_161", "Parent" : "144", "Child" : ["159", "160", "161", "162", "163", "164", "165"],
		"CDFG" : "exp_core_32_16_50_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "15", "EstimateLatencyMin" : "15", "EstimateLatencyMax" : "15",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"},
			{"Name" : "f_x_msb_4_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "f_x_msb_3_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "f_x_msb_2_table_V", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "exp_x_msb_1_table_V", "Type" : "Memory", "Direction" : "I"}]},
	{"ID" : "159", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_exp_core_32_16_50_s_fu_161.f_x_msb_4_table_V_U", "Parent" : "158"},
	{"ID" : "160", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_exp_core_32_16_50_s_fu_161.f_x_msb_3_table_V_U", "Parent" : "158"},
	{"ID" : "161", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_exp_core_32_16_50_s_fu_161.f_x_msb_2_table_V_U", "Parent" : "158"},
	{"ID" : "162", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_exp_core_32_16_50_s_fu_161.exp_x_msb_1_table_V_U", "Parent" : "158"},
	{"ID" : "163", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_36ns_44ns_80_4_1_U20", "Parent" : "158"},
	{"ID" : "164", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_48ns_50ns_98_4_1_U21", "Parent" : "158"},
	{"ID" : "165", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.grp_exp_core_32_16_50_s_fu_161.monte_sim_dev_mul_50ns_50ns_100_4_1_U22", "Parent" : "158"},
	{"ID" : "166", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_pow_32_16_s_fu_573.monte_sim_dev_mul_56s_19ns_74_4_1_U31", "Parent" : "144"},
	{"ID" : "167", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_600", "Parent" : "0",
		"CDFG" : "sqrt_fixed_32_16_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "0", "ap_start" : "0", "ap_ready" : "0", "ap_done" : "0", "ap_continue" : "0", "ap_idle" : "0",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "12", "EstimateLatencyMin" : "12", "EstimateLatencyMax" : "12",
		"Combinational" : "0",
		"Datapath" : "1",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x_V", "Type" : "None", "Direction" : "I"}]},
	{"ID" : "168", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.monte_sim_dev_mul_32s_32s_64_4_1_U36", "Parent" : "0"},
	{"ID" : "169", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.monte_sim_dev_mul_24ns_64s_64_5_1_U37", "Parent" : "0"},
	{"ID" : "170", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.monte_sim_dev_mul_32s_32s_48_4_1_U38", "Parent" : "0"},
	{"ID" : "171", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.monte_sim_dev_mul_32s_15ns_47_4_1_U39", "Parent" : "0"},
	{"ID" : "172", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.monte_sim_dev_mul_32s_16ns_48_4_1_U40", "Parent" : "0"},
	{"ID" : "173", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.monte_sim_dev_mul_32s_11ns_43_4_1_U41", "Parent" : "0"},
	{"ID" : "174", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.monte_sim_dev_mul_32s_8ns_40_4_1_U42", "Parent" : "0"},
	{"ID" : "175", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.monte_sim_dev_mul_32s_5ns_37_4_1_U43", "Parent" : "0"},
	{"ID" : "176", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.monte_sim_dev_mul_32s_32s_48_4_1_U44", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	monte_sim_dev {
		gmem {Type IO LastRead 26 FirstWrite 27}
		in1_V {Type I LastRead 0 FirstWrite -1}
		in2_V {Type I LastRead 0 FirstWrite -1}
		out_r_V {Type I LastRead 0 FirstWrite -1}
		size {Type I LastRead 0 FirstWrite -1}
		log_apfixed_reduce_log_inverse_lut_table_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_4_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_3_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_2_table_V {Type I LastRead -1 FirstWrite -1}
		exp_x_msb_1_table_V {Type I LastRead -1 FirstWrite -1}}
	pow_32_16_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		y_V {Type I LastRead 0 FirstWrite -1}
		log_apfixed_reduce_log_inverse_lut_table_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_4_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_3_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_2_table_V {Type I LastRead -1 FirstWrite -1}
		exp_x_msb_1_table_V {Type I LastRead -1 FirstWrite -1}}
	log_67_17_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		log_apfixed_reduce_log_inverse_lut_table_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V {Type I LastRead -1 FirstWrite -1}}
	exp_core_32_16_50_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		f_x_msb_4_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_3_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_2_table_V {Type I LastRead -1 FirstWrite -1}
		exp_x_msb_1_table_V {Type I LastRead -1 FirstWrite -1}}
	pow_32_16_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		y_V {Type I LastRead 0 FirstWrite -1}
		log_apfixed_reduce_log_inverse_lut_table_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_4_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_3_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_2_table_V {Type I LastRead -1 FirstWrite -1}
		exp_x_msb_1_table_V {Type I LastRead -1 FirstWrite -1}}
	log_67_17_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		log_apfixed_reduce_log_inverse_lut_table_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V {Type I LastRead -1 FirstWrite -1}}
	exp_core_32_16_50_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		f_x_msb_4_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_3_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_2_table_V {Type I LastRead -1 FirstWrite -1}
		exp_x_msb_1_table_V {Type I LastRead -1 FirstWrite -1}}
	pow_32_16_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		y_V {Type I LastRead 0 FirstWrite -1}
		log_apfixed_reduce_log_inverse_lut_table_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_4_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_3_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_2_table_V {Type I LastRead -1 FirstWrite -1}
		exp_x_msb_1_table_V {Type I LastRead -1 FirstWrite -1}}
	log_67_17_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		log_apfixed_reduce_log_inverse_lut_table_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V {Type I LastRead -1 FirstWrite -1}}
	exp_core_32_16_50_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		f_x_msb_4_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_3_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_2_table_V {Type I LastRead -1 FirstWrite -1}
		exp_x_msb_1_table_V {Type I LastRead -1 FirstWrite -1}}
	pow_32_16_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		y_V {Type I LastRead 0 FirstWrite -1}
		log_apfixed_reduce_log_inverse_lut_table_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_4_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_3_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_2_table_V {Type I LastRead -1 FirstWrite -1}
		exp_x_msb_1_table_V {Type I LastRead -1 FirstWrite -1}}
	log_67_17_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		log_apfixed_reduce_log_inverse_lut_table_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V {Type I LastRead -1 FirstWrite -1}}
	exp_core_32_16_50_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		f_x_msb_4_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_3_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_2_table_V {Type I LastRead -1 FirstWrite -1}
		exp_x_msb_1_table_V {Type I LastRead -1 FirstWrite -1}}
	pow_32_16_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		y_V {Type I LastRead 0 FirstWrite -1}
		log_apfixed_reduce_log_inverse_lut_table_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_4_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_3_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_2_table_V {Type I LastRead -1 FirstWrite -1}
		exp_x_msb_1_table_V {Type I LastRead -1 FirstWrite -1}}
	log_67_17_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		log_apfixed_reduce_log_inverse_lut_table_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V {Type I LastRead -1 FirstWrite -1}}
	exp_core_32_16_50_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		f_x_msb_4_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_3_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_2_table_V {Type I LastRead -1 FirstWrite -1}
		exp_x_msb_1_table_V {Type I LastRead -1 FirstWrite -1}}
	pow_32_16_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		y_V {Type I LastRead 0 FirstWrite -1}
		log_apfixed_reduce_log_inverse_lut_table_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_4_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_3_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_2_table_V {Type I LastRead -1 FirstWrite -1}
		exp_x_msb_1_table_V {Type I LastRead -1 FirstWrite -1}}
	log_67_17_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		log_apfixed_reduce_log_inverse_lut_table_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V {Type I LastRead -1 FirstWrite -1}}
	exp_core_32_16_50_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		f_x_msb_4_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_3_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_2_table_V {Type I LastRead -1 FirstWrite -1}
		exp_x_msb_1_table_V {Type I LastRead -1 FirstWrite -1}}
	pow_32_16_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		y_V {Type I LastRead 0 FirstWrite -1}
		log_apfixed_reduce_log_inverse_lut_table_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_4_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_3_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_2_table_V {Type I LastRead -1 FirstWrite -1}
		exp_x_msb_1_table_V {Type I LastRead -1 FirstWrite -1}}
	log_67_17_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		log_apfixed_reduce_log_inverse_lut_table_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_7_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_12_6_64_array_V {Type I LastRead -1 FirstWrite -1}
		log_apfixed_reduce_log_lut_table_ap_fixed_17_6_64_array_V {Type I LastRead -1 FirstWrite -1}}
	exp_core_32_16_50_s {
		x_V {Type I LastRead 0 FirstWrite -1}
		f_x_msb_4_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_3_table_V {Type I LastRead -1 FirstWrite -1}
		f_x_msb_2_table_V {Type I LastRead -1 FirstWrite -1}
		exp_x_msb_1_table_V {Type I LastRead -1 FirstWrite -1}}
	sqrt_fixed_32_16_s {
		x_V {Type I LastRead 0 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "13369", "Max" : "13369"}
	, {"Name" : "Interval", "Min" : "13370", "Max" : "13370"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
	{"Pipeline" : "1", "EnableSignal" : "ap_enable_pp1"}
	{"Pipeline" : "2", "EnableSignal" : "ap_enable_pp2"}
	{"Pipeline" : "3", "EnableSignal" : "ap_enable_pp3"}
]}

set Spec2ImplPortList { 
	gmem { m_axi {  { m_axi_gmem_AWVALID VALID 1 1 }  { m_axi_gmem_AWREADY READY 0 1 }  { m_axi_gmem_AWADDR ADDR 1 64 }  { m_axi_gmem_AWID ID 1 1 }  { m_axi_gmem_AWLEN LEN 1 8 }  { m_axi_gmem_AWSIZE SIZE 1 3 }  { m_axi_gmem_AWBURST BURST 1 2 }  { m_axi_gmem_AWLOCK LOCK 1 2 }  { m_axi_gmem_AWCACHE CACHE 1 4 }  { m_axi_gmem_AWPROT PROT 1 3 }  { m_axi_gmem_AWQOS QOS 1 4 }  { m_axi_gmem_AWREGION REGION 1 4 }  { m_axi_gmem_AWUSER USER 1 1 }  { m_axi_gmem_WVALID VALID 1 1 }  { m_axi_gmem_WREADY READY 0 1 }  { m_axi_gmem_WDATA DATA 1 32 }  { m_axi_gmem_WSTRB STRB 1 4 }  { m_axi_gmem_WLAST LAST 1 1 }  { m_axi_gmem_WID ID 1 1 }  { m_axi_gmem_WUSER USER 1 1 }  { m_axi_gmem_ARVALID VALID 1 1 }  { m_axi_gmem_ARREADY READY 0 1 }  { m_axi_gmem_ARADDR ADDR 1 64 }  { m_axi_gmem_ARID ID 1 1 }  { m_axi_gmem_ARLEN LEN 1 8 }  { m_axi_gmem_ARSIZE SIZE 1 3 }  { m_axi_gmem_ARBURST BURST 1 2 }  { m_axi_gmem_ARLOCK LOCK 1 2 }  { m_axi_gmem_ARCACHE CACHE 1 4 }  { m_axi_gmem_ARPROT PROT 1 3 }  { m_axi_gmem_ARQOS QOS 1 4 }  { m_axi_gmem_ARREGION REGION 1 4 }  { m_axi_gmem_ARUSER USER 1 1 }  { m_axi_gmem_RVALID VALID 0 1 }  { m_axi_gmem_RREADY READY 1 1 }  { m_axi_gmem_RDATA DATA 0 32 }  { m_axi_gmem_RLAST LAST 0 1 }  { m_axi_gmem_RID ID 0 1 }  { m_axi_gmem_RUSER USER 0 1 }  { m_axi_gmem_RRESP RESP 0 2 }  { m_axi_gmem_BVALID VALID 0 1 }  { m_axi_gmem_BREADY READY 1 1 }  { m_axi_gmem_BRESP RESP 0 2 }  { m_axi_gmem_BID ID 0 1 }  { m_axi_gmem_BUSER USER 0 1 } } }
}

set busDeadlockParameterList { 
	{ gmem { NUM_READ_OUTSTANDING 16 NUM_WRITE_OUTSTANDING 16 MAX_READ_BURST_LENGTH 16 MAX_WRITE_BURST_LENGTH 16 } } \
}

# RTL port scheduling information:
set fifoSchedulingInfoList { 
}

# RTL bus port read request latency information:
set busReadReqLatencyList { 
	{ gmem 1 }
}

# RTL bus port write response latency information:
set busWriteResLatencyList { 
	{ gmem 1 }
}

# RTL array port load latency information:
set memoryLoadLatencyList { 
}
