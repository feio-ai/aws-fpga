// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xmatmul_partition_matmul_partition.h"

extern XMatmul_partition_matmul_partition_Config XMatmul_partition_matmul_partition_ConfigTable[];

XMatmul_partition_matmul_partition_Config *XMatmul_partition_matmul_partition_LookupConfig(u16 DeviceId) {
	XMatmul_partition_matmul_partition_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XMATMUL_PARTITION_MATMUL_PARTITION_NUM_INSTANCES; Index++) {
		if (XMatmul_partition_matmul_partition_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XMatmul_partition_matmul_partition_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XMatmul_partition_matmul_partition_Initialize(XMatmul_partition_matmul_partition *InstancePtr, u16 DeviceId) {
	XMatmul_partition_matmul_partition_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XMatmul_partition_matmul_partition_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XMatmul_partition_matmul_partition_CfgInitialize(InstancePtr, ConfigPtr);
}

#endif

