// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
/***************************** Include Files *********************************/
#include "xmonte_sim_monte_sim.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XMonte_sim_monte_sim_CfgInitialize(XMonte_sim_monte_sim *InstancePtr, XMonte_sim_monte_sim_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XMonte_sim_monte_sim_Start(XMonte_sim_monte_sim *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMonte_sim_monte_sim_ReadReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_AP_CTRL) & 0x80;
    XMonte_sim_monte_sim_WriteReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XMonte_sim_monte_sim_IsDone(XMonte_sim_monte_sim *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMonte_sim_monte_sim_ReadReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XMonte_sim_monte_sim_IsIdle(XMonte_sim_monte_sim *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMonte_sim_monte_sim_ReadReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XMonte_sim_monte_sim_IsReady(XMonte_sim_monte_sim *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMonte_sim_monte_sim_ReadReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XMonte_sim_monte_sim_EnableAutoRestart(XMonte_sim_monte_sim *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMonte_sim_monte_sim_WriteReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XMonte_sim_monte_sim_DisableAutoRestart(XMonte_sim_monte_sim *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMonte_sim_monte_sim_WriteReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_AP_CTRL, 0);
}

void XMonte_sim_monte_sim_Set_in1_V(XMonte_sim_monte_sim *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMonte_sim_monte_sim_WriteReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_IN1_V_DATA, (u32)(Data));
    XMonte_sim_monte_sim_WriteReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_IN1_V_DATA + 4, (u32)(Data >> 32));
}

u64 XMonte_sim_monte_sim_Get_in1_V(XMonte_sim_monte_sim *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMonte_sim_monte_sim_ReadReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_IN1_V_DATA);
    Data += (u64)XMonte_sim_monte_sim_ReadReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_IN1_V_DATA + 4) << 32;
    return Data;
}

void XMonte_sim_monte_sim_Set_in2_V(XMonte_sim_monte_sim *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMonte_sim_monte_sim_WriteReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_IN2_V_DATA, (u32)(Data));
    XMonte_sim_monte_sim_WriteReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_IN2_V_DATA + 4, (u32)(Data >> 32));
}

u64 XMonte_sim_monte_sim_Get_in2_V(XMonte_sim_monte_sim *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMonte_sim_monte_sim_ReadReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_IN2_V_DATA);
    Data += (u64)XMonte_sim_monte_sim_ReadReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_IN2_V_DATA + 4) << 32;
    return Data;
}

void XMonte_sim_monte_sim_Set_out_r_V(XMonte_sim_monte_sim *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMonte_sim_monte_sim_WriteReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_OUT_R_V_DATA, (u32)(Data));
    XMonte_sim_monte_sim_WriteReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_OUT_R_V_DATA + 4, (u32)(Data >> 32));
}

u64 XMonte_sim_monte_sim_Get_out_r_V(XMonte_sim_monte_sim *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMonte_sim_monte_sim_ReadReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_OUT_R_V_DATA);
    Data += (u64)XMonte_sim_monte_sim_ReadReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_OUT_R_V_DATA + 4) << 32;
    return Data;
}

void XMonte_sim_monte_sim_Set_size(XMonte_sim_monte_sim *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMonte_sim_monte_sim_WriteReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_SIZE_DATA, Data);
}

u32 XMonte_sim_monte_sim_Get_size(XMonte_sim_monte_sim *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMonte_sim_monte_sim_ReadReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_SIZE_DATA);
    return Data;
}

void XMonte_sim_monte_sim_InterruptGlobalEnable(XMonte_sim_monte_sim *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMonte_sim_monte_sim_WriteReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_GIE, 1);
}

void XMonte_sim_monte_sim_InterruptGlobalDisable(XMonte_sim_monte_sim *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMonte_sim_monte_sim_WriteReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_GIE, 0);
}

void XMonte_sim_monte_sim_InterruptEnable(XMonte_sim_monte_sim *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XMonte_sim_monte_sim_ReadReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_IER);
    XMonte_sim_monte_sim_WriteReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_IER, Register | Mask);
}

void XMonte_sim_monte_sim_InterruptDisable(XMonte_sim_monte_sim *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XMonte_sim_monte_sim_ReadReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_IER);
    XMonte_sim_monte_sim_WriteReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_IER, Register & (~Mask));
}

void XMonte_sim_monte_sim_InterruptClear(XMonte_sim_monte_sim *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMonte_sim_monte_sim_WriteReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_ISR, Mask);
}

u32 XMonte_sim_monte_sim_InterruptGetEnabled(XMonte_sim_monte_sim *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XMonte_sim_monte_sim_ReadReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_IER);
}

u32 XMonte_sim_monte_sim_InterruptGetStatus(XMonte_sim_monte_sim *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XMonte_sim_monte_sim_ReadReg(InstancePtr->Control_BaseAddress, XMONTE_SIM_MONTE_SIM_CONTROL_ADDR_ISR);
}

