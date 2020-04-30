// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef XMONTE_SIM_DEV_MONTE_SIM_DEV_H
#define XMONTE_SIM_DEV_MONTE_SIM_DEV_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
#else
#include <stdint.h>
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stddef.h>
#endif
#include "xmonte_sim_dev_monte_sim_dev_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
#else
typedef struct {
    u16 DeviceId;
    u32 Control_BaseAddress;
} XMonte_sim_dev_monte_sim_dev_Config;
#endif

typedef struct {
    u32 Control_BaseAddress;
    u32 IsReady;
} XMonte_sim_dev_monte_sim_dev;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XMonte_sim_dev_monte_sim_dev_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XMonte_sim_dev_monte_sim_dev_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XMonte_sim_dev_monte_sim_dev_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XMonte_sim_dev_monte_sim_dev_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset))

#define Xil_AssertVoid(expr)    assert(expr)
#define Xil_AssertNonvoid(expr) assert(expr)

#define XST_SUCCESS             0
#define XST_DEVICE_NOT_FOUND    2
#define XST_OPEN_DEVICE_FAILED  3
#define XIL_COMPONENT_IS_READY  1
#endif

/************************** Function Prototypes *****************************/
#ifndef __linux__
int XMonte_sim_dev_monte_sim_dev_Initialize(XMonte_sim_dev_monte_sim_dev *InstancePtr, u16 DeviceId);
XMonte_sim_dev_monte_sim_dev_Config* XMonte_sim_dev_monte_sim_dev_LookupConfig(u16 DeviceId);
int XMonte_sim_dev_monte_sim_dev_CfgInitialize(XMonte_sim_dev_monte_sim_dev *InstancePtr, XMonte_sim_dev_monte_sim_dev_Config *ConfigPtr);
#else
int XMonte_sim_dev_monte_sim_dev_Initialize(XMonte_sim_dev_monte_sim_dev *InstancePtr, const char* InstanceName);
int XMonte_sim_dev_monte_sim_dev_Release(XMonte_sim_dev_monte_sim_dev *InstancePtr);
#endif

void XMonte_sim_dev_monte_sim_dev_Start(XMonte_sim_dev_monte_sim_dev *InstancePtr);
u32 XMonte_sim_dev_monte_sim_dev_IsDone(XMonte_sim_dev_monte_sim_dev *InstancePtr);
u32 XMonte_sim_dev_monte_sim_dev_IsIdle(XMonte_sim_dev_monte_sim_dev *InstancePtr);
u32 XMonte_sim_dev_monte_sim_dev_IsReady(XMonte_sim_dev_monte_sim_dev *InstancePtr);
void XMonte_sim_dev_monte_sim_dev_EnableAutoRestart(XMonte_sim_dev_monte_sim_dev *InstancePtr);
void XMonte_sim_dev_monte_sim_dev_DisableAutoRestart(XMonte_sim_dev_monte_sim_dev *InstancePtr);

void XMonte_sim_dev_monte_sim_dev_Set_in1_V(XMonte_sim_dev_monte_sim_dev *InstancePtr, u64 Data);
u64 XMonte_sim_dev_monte_sim_dev_Get_in1_V(XMonte_sim_dev_monte_sim_dev *InstancePtr);
void XMonte_sim_dev_monte_sim_dev_Set_in2_V(XMonte_sim_dev_monte_sim_dev *InstancePtr, u64 Data);
u64 XMonte_sim_dev_monte_sim_dev_Get_in2_V(XMonte_sim_dev_monte_sim_dev *InstancePtr);
void XMonte_sim_dev_monte_sim_dev_Set_out_r_V(XMonte_sim_dev_monte_sim_dev *InstancePtr, u64 Data);
u64 XMonte_sim_dev_monte_sim_dev_Get_out_r_V(XMonte_sim_dev_monte_sim_dev *InstancePtr);
void XMonte_sim_dev_monte_sim_dev_Set_size(XMonte_sim_dev_monte_sim_dev *InstancePtr, u32 Data);
u32 XMonte_sim_dev_monte_sim_dev_Get_size(XMonte_sim_dev_monte_sim_dev *InstancePtr);

void XMonte_sim_dev_monte_sim_dev_InterruptGlobalEnable(XMonte_sim_dev_monte_sim_dev *InstancePtr);
void XMonte_sim_dev_monte_sim_dev_InterruptGlobalDisable(XMonte_sim_dev_monte_sim_dev *InstancePtr);
void XMonte_sim_dev_monte_sim_dev_InterruptEnable(XMonte_sim_dev_monte_sim_dev *InstancePtr, u32 Mask);
void XMonte_sim_dev_monte_sim_dev_InterruptDisable(XMonte_sim_dev_monte_sim_dev *InstancePtr, u32 Mask);
void XMonte_sim_dev_monte_sim_dev_InterruptClear(XMonte_sim_dev_monte_sim_dev *InstancePtr, u32 Mask);
u32 XMonte_sim_dev_monte_sim_dev_InterruptGetEnabled(XMonte_sim_dev_monte_sim_dev *InstancePtr);
u32 XMonte_sim_dev_monte_sim_dev_InterruptGetStatus(XMonte_sim_dev_monte_sim_dev *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
