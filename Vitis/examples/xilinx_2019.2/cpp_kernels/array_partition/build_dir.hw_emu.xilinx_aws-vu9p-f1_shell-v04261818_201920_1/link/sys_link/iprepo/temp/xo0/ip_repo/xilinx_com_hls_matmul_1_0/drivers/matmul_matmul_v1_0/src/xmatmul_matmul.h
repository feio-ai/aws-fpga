// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef XMATMUL_MATMUL_H
#define XMATMUL_MATMUL_H

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
#include "xmatmul_matmul_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
#else
typedef struct {
    u16 DeviceId;
    u32 Control_BaseAddress;
} XMatmul_matmul_Config;
#endif

typedef struct {
    u32 Control_BaseAddress;
    u32 IsReady;
} XMatmul_matmul;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XMatmul_matmul_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XMatmul_matmul_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XMatmul_matmul_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XMatmul_matmul_ReadReg(BaseAddress, RegOffset) \
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
int XMatmul_matmul_Initialize(XMatmul_matmul *InstancePtr, u16 DeviceId);
XMatmul_matmul_Config* XMatmul_matmul_LookupConfig(u16 DeviceId);
int XMatmul_matmul_CfgInitialize(XMatmul_matmul *InstancePtr, XMatmul_matmul_Config *ConfigPtr);
#else
int XMatmul_matmul_Initialize(XMatmul_matmul *InstancePtr, const char* InstanceName);
int XMatmul_matmul_Release(XMatmul_matmul *InstancePtr);
#endif

void XMatmul_matmul_Start(XMatmul_matmul *InstancePtr);
u32 XMatmul_matmul_IsDone(XMatmul_matmul *InstancePtr);
u32 XMatmul_matmul_IsIdle(XMatmul_matmul *InstancePtr);
u32 XMatmul_matmul_IsReady(XMatmul_matmul *InstancePtr);
void XMatmul_matmul_EnableAutoRestart(XMatmul_matmul *InstancePtr);
void XMatmul_matmul_DisableAutoRestart(XMatmul_matmul *InstancePtr);

void XMatmul_matmul_Set_in1(XMatmul_matmul *InstancePtr, u64 Data);
u64 XMatmul_matmul_Get_in1(XMatmul_matmul *InstancePtr);
void XMatmul_matmul_Set_in2(XMatmul_matmul *InstancePtr, u64 Data);
u64 XMatmul_matmul_Get_in2(XMatmul_matmul *InstancePtr);
void XMatmul_matmul_Set_out_r(XMatmul_matmul *InstancePtr, u64 Data);
u64 XMatmul_matmul_Get_out_r(XMatmul_matmul *InstancePtr);
void XMatmul_matmul_Set_size(XMatmul_matmul *InstancePtr, u32 Data);
u32 XMatmul_matmul_Get_size(XMatmul_matmul *InstancePtr);

void XMatmul_matmul_InterruptGlobalEnable(XMatmul_matmul *InstancePtr);
void XMatmul_matmul_InterruptGlobalDisable(XMatmul_matmul *InstancePtr);
void XMatmul_matmul_InterruptEnable(XMatmul_matmul *InstancePtr, u32 Mask);
void XMatmul_matmul_InterruptDisable(XMatmul_matmul *InstancePtr, u32 Mask);
void XMatmul_matmul_InterruptClear(XMatmul_matmul *InstancePtr, u32 Mask);
u32 XMatmul_matmul_InterruptGetEnabled(XMatmul_matmul *InstancePtr);
u32 XMatmul_matmul_InterruptGetStatus(XMatmul_matmul *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
