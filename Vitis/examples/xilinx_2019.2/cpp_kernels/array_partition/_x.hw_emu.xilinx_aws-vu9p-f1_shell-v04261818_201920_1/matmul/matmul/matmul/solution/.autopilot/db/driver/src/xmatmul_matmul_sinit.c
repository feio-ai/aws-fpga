// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xmatmul_matmul.h"

extern XMatmul_matmul_Config XMatmul_matmul_ConfigTable[];

XMatmul_matmul_Config *XMatmul_matmul_LookupConfig(u16 DeviceId) {
	XMatmul_matmul_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XMATMUL_MATMUL_NUM_INSTANCES; Index++) {
		if (XMatmul_matmul_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XMatmul_matmul_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XMatmul_matmul_Initialize(XMatmul_matmul *InstancePtr, u16 DeviceId) {
	XMatmul_matmul_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XMatmul_matmul_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XMatmul_matmul_CfgInitialize(InstancePtr, ConfigPtr);
}

#endif

