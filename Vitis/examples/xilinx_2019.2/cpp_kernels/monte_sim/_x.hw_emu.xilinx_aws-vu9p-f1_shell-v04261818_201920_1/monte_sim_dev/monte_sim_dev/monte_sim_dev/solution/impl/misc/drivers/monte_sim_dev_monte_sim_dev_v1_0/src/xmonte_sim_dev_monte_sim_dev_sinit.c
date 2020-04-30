// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xmonte_sim_dev_monte_sim_dev.h"

extern XMonte_sim_dev_monte_sim_dev_Config XMonte_sim_dev_monte_sim_dev_ConfigTable[];

XMonte_sim_dev_monte_sim_dev_Config *XMonte_sim_dev_monte_sim_dev_LookupConfig(u16 DeviceId) {
	XMonte_sim_dev_monte_sim_dev_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XMONTE_SIM_DEV_MONTE_SIM_DEV_NUM_INSTANCES; Index++) {
		if (XMonte_sim_dev_monte_sim_dev_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XMonte_sim_dev_monte_sim_dev_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XMonte_sim_dev_monte_sim_dev_Initialize(XMonte_sim_dev_monte_sim_dev *InstancePtr, u16 DeviceId) {
	XMonte_sim_dev_monte_sim_dev_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XMonte_sim_dev_monte_sim_dev_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XMonte_sim_dev_monte_sim_dev_CfgInitialize(InstancePtr, ConfigPtr);
}

#endif

