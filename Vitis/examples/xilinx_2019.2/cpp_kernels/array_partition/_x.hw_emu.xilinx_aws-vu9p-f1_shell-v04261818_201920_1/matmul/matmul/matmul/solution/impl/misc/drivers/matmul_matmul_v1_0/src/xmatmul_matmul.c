// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
/***************************** Include Files *********************************/
#include "xmatmul_matmul.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XMatmul_matmul_CfgInitialize(XMatmul_matmul *InstancePtr, XMatmul_matmul_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XMatmul_matmul_Start(XMatmul_matmul *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMatmul_matmul_ReadReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_AP_CTRL) & 0x80;
    XMatmul_matmul_WriteReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XMatmul_matmul_IsDone(XMatmul_matmul *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMatmul_matmul_ReadReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XMatmul_matmul_IsIdle(XMatmul_matmul *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMatmul_matmul_ReadReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XMatmul_matmul_IsReady(XMatmul_matmul *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMatmul_matmul_ReadReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XMatmul_matmul_EnableAutoRestart(XMatmul_matmul *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMatmul_matmul_WriteReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XMatmul_matmul_DisableAutoRestart(XMatmul_matmul *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMatmul_matmul_WriteReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_AP_CTRL, 0);
}

void XMatmul_matmul_Set_in1(XMatmul_matmul *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMatmul_matmul_WriteReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_IN1_DATA, (u32)(Data));
    XMatmul_matmul_WriteReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_IN1_DATA + 4, (u32)(Data >> 32));
}

u64 XMatmul_matmul_Get_in1(XMatmul_matmul *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMatmul_matmul_ReadReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_IN1_DATA);
    Data += (u64)XMatmul_matmul_ReadReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_IN1_DATA + 4) << 32;
    return Data;
}

void XMatmul_matmul_Set_in2(XMatmul_matmul *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMatmul_matmul_WriteReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_IN2_DATA, (u32)(Data));
    XMatmul_matmul_WriteReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_IN2_DATA + 4, (u32)(Data >> 32));
}

u64 XMatmul_matmul_Get_in2(XMatmul_matmul *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMatmul_matmul_ReadReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_IN2_DATA);
    Data += (u64)XMatmul_matmul_ReadReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_IN2_DATA + 4) << 32;
    return Data;
}

void XMatmul_matmul_Set_out_r(XMatmul_matmul *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMatmul_matmul_WriteReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_OUT_R_DATA, (u32)(Data));
    XMatmul_matmul_WriteReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_OUT_R_DATA + 4, (u32)(Data >> 32));
}

u64 XMatmul_matmul_Get_out_r(XMatmul_matmul *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMatmul_matmul_ReadReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_OUT_R_DATA);
    Data += (u64)XMatmul_matmul_ReadReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_OUT_R_DATA + 4) << 32;
    return Data;
}

void XMatmul_matmul_Set_size(XMatmul_matmul *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMatmul_matmul_WriteReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_SIZE_DATA, Data);
}

u32 XMatmul_matmul_Get_size(XMatmul_matmul *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMatmul_matmul_ReadReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_SIZE_DATA);
    return Data;
}

void XMatmul_matmul_InterruptGlobalEnable(XMatmul_matmul *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMatmul_matmul_WriteReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_GIE, 1);
}

void XMatmul_matmul_InterruptGlobalDisable(XMatmul_matmul *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMatmul_matmul_WriteReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_GIE, 0);
}

void XMatmul_matmul_InterruptEnable(XMatmul_matmul *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XMatmul_matmul_ReadReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_IER);
    XMatmul_matmul_WriteReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_IER, Register | Mask);
}

void XMatmul_matmul_InterruptDisable(XMatmul_matmul *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XMatmul_matmul_ReadReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_IER);
    XMatmul_matmul_WriteReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_IER, Register & (~Mask));
}

void XMatmul_matmul_InterruptClear(XMatmul_matmul *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMatmul_matmul_WriteReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_ISR, Mask);
}

u32 XMatmul_matmul_InterruptGetEnabled(XMatmul_matmul *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XMatmul_matmul_ReadReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_IER);
}

u32 XMatmul_matmul_InterruptGetStatus(XMatmul_matmul *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XMatmul_matmul_ReadReg(InstancePtr->Control_BaseAddress, XMATMUL_MATMUL_CONTROL_ADDR_ISR);
}

