// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xmonte_sim_monte_sim.h"

extern XMonte_sim_monte_sim_Config XMonte_sim_monte_sim_ConfigTable[];

XMonte_sim_monte_sim_Config *XMonte_sim_monte_sim_LookupConfig(u16 DeviceId) {
	XMonte_sim_monte_sim_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XMONTE_SIM_MONTE_SIM_NUM_INSTANCES; Index++) {
		if (XMonte_sim_monte_sim_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XMonte_sim_monte_sim_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XMonte_sim_monte_sim_Initialize(XMonte_sim_monte_sim *InstancePtr, u16 DeviceId) {
	XMonte_sim_monte_sim_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XMonte_sim_monte_sim_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XMonte_sim_monte_sim_CfgInitialize(InstancePtr, ConfigPtr);
}

#endif

