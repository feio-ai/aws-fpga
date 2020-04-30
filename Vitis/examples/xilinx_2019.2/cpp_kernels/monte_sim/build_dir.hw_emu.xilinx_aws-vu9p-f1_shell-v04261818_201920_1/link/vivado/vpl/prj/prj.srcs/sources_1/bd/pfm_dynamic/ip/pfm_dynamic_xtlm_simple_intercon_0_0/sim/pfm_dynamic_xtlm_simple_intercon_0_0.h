#ifndef IP_PFM_DYNAMIC_XTLM_SIMPLE_INTERCON_0_0_H_
#define IP_PFM_DYNAMIC_XTLM_SIMPLE_INTERCON_0_0_H_

// (c) Copyright 1995-2020 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.

#ifndef XTLM
#include "xtlm.h"
#endif

#ifndef SYSTEMC_INCLUDED
#include <systemc>
#endif

#if defined(_MSC_VER)
#define DllExport __declspec(dllexport)
#elif defined(__GNUC__)
#define DllExport __attribute__ ((visibility("default")))
#else
#define DllExport
#endif

#include "pfm_dynamic_xtlm_simple_intercon_0_0_sc.h"

class DllExport pfm_dynamic_xtlm_simple_intercon_0_0 : public pfm_dynamic_xtlm_simple_intercon_0_0_sc
{
public:

  pfm_dynamic_xtlm_simple_intercon_0_0(const sc_core::sc_module_name& nm);
  virtual ~pfm_dynamic_xtlm_simple_intercon_0_0();

  // module pin-to-pin RTL interface

  sc_core::sc_in< sc_dt::sc_bv<1> > s00_axi_awid;
  sc_core::sc_in< sc_dt::sc_bv<64> > s00_axi_awaddr;
  sc_core::sc_in< sc_dt::sc_bv<8> > s00_axi_awlen;
  sc_core::sc_in< sc_dt::sc_bv<3> > s00_axi_awsize;
  sc_core::sc_in< sc_dt::sc_bv<2> > s00_axi_awburst;
  sc_core::sc_in< bool > s00_axi_awlock;
  sc_core::sc_in< sc_dt::sc_bv<4> > s00_axi_awcache;
  sc_core::sc_in< sc_dt::sc_bv<3> > s00_axi_awprot;
  sc_core::sc_in< sc_dt::sc_bv<4> > s00_axi_awregion;
  sc_core::sc_in< sc_dt::sc_bv<4> > s00_axi_awqos;
  sc_core::sc_in< bool > s00_axi_awvalid;
  sc_core::sc_out< bool > s00_axi_awready;
  sc_core::sc_in< sc_dt::sc_bv<32> > s00_axi_wdata;
  sc_core::sc_in< sc_dt::sc_bv<4> > s00_axi_wstrb;
  sc_core::sc_in< bool > s00_axi_wlast;
  sc_core::sc_in< bool > s00_axi_wvalid;
  sc_core::sc_out< bool > s00_axi_wready;
  sc_core::sc_out< sc_dt::sc_bv<1> > s00_axi_bid;
  sc_core::sc_out< sc_dt::sc_bv<2> > s00_axi_bresp;
  sc_core::sc_out< bool > s00_axi_bvalid;
  sc_core::sc_in< bool > s00_axi_bready;
  sc_core::sc_in< sc_dt::sc_bv<1> > s00_axi_arid;
  sc_core::sc_in< sc_dt::sc_bv<64> > s00_axi_araddr;
  sc_core::sc_in< sc_dt::sc_bv<8> > s00_axi_arlen;
  sc_core::sc_in< sc_dt::sc_bv<3> > s00_axi_arsize;
  sc_core::sc_in< sc_dt::sc_bv<2> > s00_axi_arburst;
  sc_core::sc_in< bool > s00_axi_arlock;
  sc_core::sc_in< sc_dt::sc_bv<4> > s00_axi_arcache;
  sc_core::sc_in< sc_dt::sc_bv<3> > s00_axi_arprot;
  sc_core::sc_in< sc_dt::sc_bv<4> > s00_axi_arregion;
  sc_core::sc_in< sc_dt::sc_bv<4> > s00_axi_arqos;
  sc_core::sc_in< bool > s00_axi_arvalid;
  sc_core::sc_out< bool > s00_axi_arready;
  sc_core::sc_out< sc_dt::sc_bv<1> > s00_axi_rid;
  sc_core::sc_out< sc_dt::sc_bv<32> > s00_axi_rdata;
  sc_core::sc_out< sc_dt::sc_bv<2> > s00_axi_rresp;
  sc_core::sc_out< bool > s00_axi_rlast;
  sc_core::sc_out< bool > s00_axi_rvalid;
  sc_core::sc_in< bool > s00_axi_rready;
  sc_core::sc_in< bool > s00_axi_aclk;
  sc_core::sc_in< bool > s00_axi_aresetn;
  sc_core::sc_out< sc_dt::sc_bv<1> > m00_axi_awid;
  sc_core::sc_out< sc_dt::sc_bv<64> > m00_axi_awaddr;
  sc_core::sc_out< sc_dt::sc_bv<8> > m00_axi_awlen;
  sc_core::sc_out< sc_dt::sc_bv<3> > m00_axi_awsize;
  sc_core::sc_out< sc_dt::sc_bv<2> > m00_axi_awburst;
  sc_core::sc_out< bool > m00_axi_awlock;
  sc_core::sc_out< sc_dt::sc_bv<4> > m00_axi_awcache;
  sc_core::sc_out< sc_dt::sc_bv<3> > m00_axi_awprot;
  sc_core::sc_out< sc_dt::sc_bv<4> > m00_axi_awqos;
  sc_core::sc_out< sc_dt::sc_bv<1> > m00_axi_awuser;
  sc_core::sc_out< bool > m00_axi_awvalid;
  sc_core::sc_in< bool > m00_axi_awready;
  sc_core::sc_out< sc_dt::sc_bv<32> > m00_axi_wdata;
  sc_core::sc_out< sc_dt::sc_bv<4> > m00_axi_wstrb;
  sc_core::sc_out< bool > m00_axi_wlast;
  sc_core::sc_out< sc_dt::sc_bv<1> > m00_axi_wuser;
  sc_core::sc_out< bool > m00_axi_wvalid;
  sc_core::sc_in< bool > m00_axi_wready;
  sc_core::sc_in< sc_dt::sc_bv<1> > m00_axi_bid;
  sc_core::sc_in< sc_dt::sc_bv<2> > m00_axi_bresp;
  sc_core::sc_in< sc_dt::sc_bv<1> > m00_axi_buser;
  sc_core::sc_in< bool > m00_axi_bvalid;
  sc_core::sc_out< bool > m00_axi_bready;
  sc_core::sc_out< sc_dt::sc_bv<1> > m00_axi_arid;
  sc_core::sc_out< sc_dt::sc_bv<64> > m00_axi_araddr;
  sc_core::sc_out< sc_dt::sc_bv<8> > m00_axi_arlen;
  sc_core::sc_out< sc_dt::sc_bv<3> > m00_axi_arsize;
  sc_core::sc_out< sc_dt::sc_bv<2> > m00_axi_arburst;
  sc_core::sc_out< bool > m00_axi_arlock;
  sc_core::sc_out< sc_dt::sc_bv<4> > m00_axi_arcache;
  sc_core::sc_out< sc_dt::sc_bv<3> > m00_axi_arprot;
  sc_core::sc_out< sc_dt::sc_bv<4> > m00_axi_arqos;
  sc_core::sc_out< sc_dt::sc_bv<1> > m00_axi_aruser;
  sc_core::sc_out< bool > m00_axi_arvalid;
  sc_core::sc_in< bool > m00_axi_arready;
  sc_core::sc_in< sc_dt::sc_bv<1> > m00_axi_rid;
  sc_core::sc_in< sc_dt::sc_bv<32> > m00_axi_rdata;
  sc_core::sc_in< sc_dt::sc_bv<2> > m00_axi_rresp;
  sc_core::sc_in< bool > m00_axi_rlast;
  sc_core::sc_in< sc_dt::sc_bv<1> > m00_axi_ruser;
  sc_core::sc_in< bool > m00_axi_rvalid;
  sc_core::sc_out< bool > m00_axi_rready;
  sc_core::sc_in< bool > m00_axi_aclk;
  sc_core::sc_in< bool > m00_axi_aresetn;
  sc_core::sc_out< sc_dt::sc_bv<1> > m02_axi_awid;
  sc_core::sc_out< sc_dt::sc_bv<64> > m02_axi_awaddr;
  sc_core::sc_out< sc_dt::sc_bv<8> > m02_axi_awlen;
  sc_core::sc_out< sc_dt::sc_bv<3> > m02_axi_awsize;
  sc_core::sc_out< sc_dt::sc_bv<2> > m02_axi_awburst;
  sc_core::sc_out< bool > m02_axi_awlock;
  sc_core::sc_out< sc_dt::sc_bv<4> > m02_axi_awcache;
  sc_core::sc_out< sc_dt::sc_bv<3> > m02_axi_awprot;
  sc_core::sc_out< sc_dt::sc_bv<4> > m02_axi_awqos;
  sc_core::sc_out< sc_dt::sc_bv<1> > m02_axi_awuser;
  sc_core::sc_out< bool > m02_axi_awvalid;
  sc_core::sc_in< bool > m02_axi_awready;
  sc_core::sc_out< sc_dt::sc_bv<32> > m02_axi_wdata;
  sc_core::sc_out< sc_dt::sc_bv<4> > m02_axi_wstrb;
  sc_core::sc_out< bool > m02_axi_wlast;
  sc_core::sc_out< sc_dt::sc_bv<1> > m02_axi_wuser;
  sc_core::sc_out< bool > m02_axi_wvalid;
  sc_core::sc_in< bool > m02_axi_wready;
  sc_core::sc_in< sc_dt::sc_bv<1> > m02_axi_bid;
  sc_core::sc_in< sc_dt::sc_bv<2> > m02_axi_bresp;
  sc_core::sc_in< sc_dt::sc_bv<1> > m02_axi_buser;
  sc_core::sc_in< bool > m02_axi_bvalid;
  sc_core::sc_out< bool > m02_axi_bready;
  sc_core::sc_out< sc_dt::sc_bv<1> > m02_axi_arid;
  sc_core::sc_out< sc_dt::sc_bv<64> > m02_axi_araddr;
  sc_core::sc_out< sc_dt::sc_bv<8> > m02_axi_arlen;
  sc_core::sc_out< sc_dt::sc_bv<3> > m02_axi_arsize;
  sc_core::sc_out< sc_dt::sc_bv<2> > m02_axi_arburst;
  sc_core::sc_out< bool > m02_axi_arlock;
  sc_core::sc_out< sc_dt::sc_bv<4> > m02_axi_arcache;
  sc_core::sc_out< sc_dt::sc_bv<3> > m02_axi_arprot;
  sc_core::sc_out< sc_dt::sc_bv<4> > m02_axi_arqos;
  sc_core::sc_out< sc_dt::sc_bv<1> > m02_axi_aruser;
  sc_core::sc_out< bool > m02_axi_arvalid;
  sc_core::sc_in< bool > m02_axi_arready;
  sc_core::sc_in< sc_dt::sc_bv<1> > m02_axi_rid;
  sc_core::sc_in< sc_dt::sc_bv<32> > m02_axi_rdata;
  sc_core::sc_in< sc_dt::sc_bv<2> > m02_axi_rresp;
  sc_core::sc_in< bool > m02_axi_rlast;
  sc_core::sc_in< sc_dt::sc_bv<1> > m02_axi_ruser;
  sc_core::sc_in< bool > m02_axi_rvalid;
  sc_core::sc_out< bool > m02_axi_rready;
  sc_core::sc_in< bool > m02_axi_aclk;
  sc_core::sc_in< bool > m02_axi_aresetn;
  sc_core::sc_out< sc_dt::sc_bv<1> > m03_axi_awid;
  sc_core::sc_out< sc_dt::sc_bv<64> > m03_axi_awaddr;
  sc_core::sc_out< sc_dt::sc_bv<8> > m03_axi_awlen;
  sc_core::sc_out< sc_dt::sc_bv<3> > m03_axi_awsize;
  sc_core::sc_out< sc_dt::sc_bv<2> > m03_axi_awburst;
  sc_core::sc_out< bool > m03_axi_awlock;
  sc_core::sc_out< sc_dt::sc_bv<4> > m03_axi_awcache;
  sc_core::sc_out< sc_dt::sc_bv<3> > m03_axi_awprot;
  sc_core::sc_out< sc_dt::sc_bv<4> > m03_axi_awqos;
  sc_core::sc_out< sc_dt::sc_bv<1> > m03_axi_awuser;
  sc_core::sc_out< bool > m03_axi_awvalid;
  sc_core::sc_in< bool > m03_axi_awready;
  sc_core::sc_out< sc_dt::sc_bv<32> > m03_axi_wdata;
  sc_core::sc_out< sc_dt::sc_bv<4> > m03_axi_wstrb;
  sc_core::sc_out< bool > m03_axi_wlast;
  sc_core::sc_out< sc_dt::sc_bv<1> > m03_axi_wuser;
  sc_core::sc_out< bool > m03_axi_wvalid;
  sc_core::sc_in< bool > m03_axi_wready;
  sc_core::sc_in< sc_dt::sc_bv<1> > m03_axi_bid;
  sc_core::sc_in< sc_dt::sc_bv<2> > m03_axi_bresp;
  sc_core::sc_in< sc_dt::sc_bv<1> > m03_axi_buser;
  sc_core::sc_in< bool > m03_axi_bvalid;
  sc_core::sc_out< bool > m03_axi_bready;
  sc_core::sc_out< sc_dt::sc_bv<1> > m03_axi_arid;
  sc_core::sc_out< sc_dt::sc_bv<64> > m03_axi_araddr;
  sc_core::sc_out< sc_dt::sc_bv<8> > m03_axi_arlen;
  sc_core::sc_out< sc_dt::sc_bv<3> > m03_axi_arsize;
  sc_core::sc_out< sc_dt::sc_bv<2> > m03_axi_arburst;
  sc_core::sc_out< bool > m03_axi_arlock;
  sc_core::sc_out< sc_dt::sc_bv<4> > m03_axi_arcache;
  sc_core::sc_out< sc_dt::sc_bv<3> > m03_axi_arprot;
  sc_core::sc_out< sc_dt::sc_bv<4> > m03_axi_arqos;
  sc_core::sc_out< sc_dt::sc_bv<1> > m03_axi_aruser;
  sc_core::sc_out< bool > m03_axi_arvalid;
  sc_core::sc_in< bool > m03_axi_arready;
  sc_core::sc_in< sc_dt::sc_bv<1> > m03_axi_rid;
  sc_core::sc_in< sc_dt::sc_bv<32> > m03_axi_rdata;
  sc_core::sc_in< sc_dt::sc_bv<2> > m03_axi_rresp;
  sc_core::sc_in< bool > m03_axi_rlast;
  sc_core::sc_in< sc_dt::sc_bv<1> > m03_axi_ruser;
  sc_core::sc_in< bool > m03_axi_rvalid;
  sc_core::sc_out< bool > m03_axi_rready;
  sc_core::sc_in< bool > m03_axi_aclk;
  sc_core::sc_in< bool > m03_axi_aresetn;
  sc_core::sc_out< sc_dt::sc_bv<1> > m04_axi_awid;
  sc_core::sc_out< sc_dt::sc_bv<32> > m04_axi_awaddr;
  sc_core::sc_out< sc_dt::sc_bv<8> > m04_axi_awlen;
  sc_core::sc_out< sc_dt::sc_bv<3> > m04_axi_awsize;
  sc_core::sc_out< sc_dt::sc_bv<2> > m04_axi_awburst;
  sc_core::sc_out< bool > m04_axi_awlock;
  sc_core::sc_out< sc_dt::sc_bv<4> > m04_axi_awcache;
  sc_core::sc_out< sc_dt::sc_bv<3> > m04_axi_awprot;
  sc_core::sc_out< sc_dt::sc_bv<4> > m04_axi_awqos;
  sc_core::sc_out< sc_dt::sc_bv<1> > m04_axi_awuser;
  sc_core::sc_out< bool > m04_axi_awvalid;
  sc_core::sc_in< bool > m04_axi_awready;
  sc_core::sc_out< sc_dt::sc_bv<64> > m04_axi_wdata;
  sc_core::sc_out< sc_dt::sc_bv<8> > m04_axi_wstrb;
  sc_core::sc_out< bool > m04_axi_wlast;
  sc_core::sc_out< sc_dt::sc_bv<1> > m04_axi_wuser;
  sc_core::sc_out< bool > m04_axi_wvalid;
  sc_core::sc_in< bool > m04_axi_wready;
  sc_core::sc_in< sc_dt::sc_bv<1> > m04_axi_bid;
  sc_core::sc_in< sc_dt::sc_bv<2> > m04_axi_bresp;
  sc_core::sc_in< sc_dt::sc_bv<1> > m04_axi_buser;
  sc_core::sc_in< bool > m04_axi_bvalid;
  sc_core::sc_out< bool > m04_axi_bready;
  sc_core::sc_out< sc_dt::sc_bv<1> > m04_axi_arid;
  sc_core::sc_out< sc_dt::sc_bv<32> > m04_axi_araddr;
  sc_core::sc_out< sc_dt::sc_bv<8> > m04_axi_arlen;
  sc_core::sc_out< sc_dt::sc_bv<3> > m04_axi_arsize;
  sc_core::sc_out< sc_dt::sc_bv<2> > m04_axi_arburst;
  sc_core::sc_out< bool > m04_axi_arlock;
  sc_core::sc_out< sc_dt::sc_bv<4> > m04_axi_arcache;
  sc_core::sc_out< sc_dt::sc_bv<3> > m04_axi_arprot;
  sc_core::sc_out< sc_dt::sc_bv<4> > m04_axi_arqos;
  sc_core::sc_out< sc_dt::sc_bv<1> > m04_axi_aruser;
  sc_core::sc_out< bool > m04_axi_arvalid;
  sc_core::sc_in< bool > m04_axi_arready;
  sc_core::sc_in< sc_dt::sc_bv<1> > m04_axi_rid;
  sc_core::sc_in< sc_dt::sc_bv<64> > m04_axi_rdata;
  sc_core::sc_in< sc_dt::sc_bv<2> > m04_axi_rresp;
  sc_core::sc_in< bool > m04_axi_rlast;
  sc_core::sc_in< sc_dt::sc_bv<1> > m04_axi_ruser;
  sc_core::sc_in< bool > m04_axi_rvalid;
  sc_core::sc_out< bool > m04_axi_rready;
  sc_core::sc_in< bool > m04_axi_aclk;
  sc_core::sc_in< bool > m04_axi_aresetn;
  sc_core::sc_out< sc_dt::sc_bv<1> > m01_axi_awid;
  sc_core::sc_out< sc_dt::sc_bv<64> > m01_axi_awaddr;
  sc_core::sc_out< sc_dt::sc_bv<8> > m01_axi_awlen;
  sc_core::sc_out< sc_dt::sc_bv<3> > m01_axi_awsize;
  sc_core::sc_out< sc_dt::sc_bv<2> > m01_axi_awburst;
  sc_core::sc_out< bool > m01_axi_awlock;
  sc_core::sc_out< sc_dt::sc_bv<4> > m01_axi_awcache;
  sc_core::sc_out< sc_dt::sc_bv<3> > m01_axi_awprot;
  sc_core::sc_out< sc_dt::sc_bv<4> > m01_axi_awqos;
  sc_core::sc_out< sc_dt::sc_bv<1> > m01_axi_awuser;
  sc_core::sc_out< bool > m01_axi_awvalid;
  sc_core::sc_in< bool > m01_axi_awready;
  sc_core::sc_out< sc_dt::sc_bv<32> > m01_axi_wdata;
  sc_core::sc_out< sc_dt::sc_bv<4> > m01_axi_wstrb;
  sc_core::sc_out< bool > m01_axi_wlast;
  sc_core::sc_out< sc_dt::sc_bv<1> > m01_axi_wuser;
  sc_core::sc_out< bool > m01_axi_wvalid;
  sc_core::sc_in< bool > m01_axi_wready;
  sc_core::sc_in< sc_dt::sc_bv<1> > m01_axi_bid;
  sc_core::sc_in< sc_dt::sc_bv<2> > m01_axi_bresp;
  sc_core::sc_in< sc_dt::sc_bv<1> > m01_axi_buser;
  sc_core::sc_in< bool > m01_axi_bvalid;
  sc_core::sc_out< bool > m01_axi_bready;
  sc_core::sc_out< sc_dt::sc_bv<1> > m01_axi_arid;
  sc_core::sc_out< sc_dt::sc_bv<64> > m01_axi_araddr;
  sc_core::sc_out< sc_dt::sc_bv<8> > m01_axi_arlen;
  sc_core::sc_out< sc_dt::sc_bv<3> > m01_axi_arsize;
  sc_core::sc_out< sc_dt::sc_bv<2> > m01_axi_arburst;
  sc_core::sc_out< bool > m01_axi_arlock;
  sc_core::sc_out< sc_dt::sc_bv<4> > m01_axi_arcache;
  sc_core::sc_out< sc_dt::sc_bv<3> > m01_axi_arprot;
  sc_core::sc_out< sc_dt::sc_bv<4> > m01_axi_arqos;
  sc_core::sc_out< sc_dt::sc_bv<1> > m01_axi_aruser;
  sc_core::sc_out< bool > m01_axi_arvalid;
  sc_core::sc_in< bool > m01_axi_arready;
  sc_core::sc_in< sc_dt::sc_bv<1> > m01_axi_rid;
  sc_core::sc_in< sc_dt::sc_bv<32> > m01_axi_rdata;
  sc_core::sc_in< sc_dt::sc_bv<2> > m01_axi_rresp;
  sc_core::sc_in< bool > m01_axi_rlast;
  sc_core::sc_in< sc_dt::sc_bv<1> > m01_axi_ruser;
  sc_core::sc_in< bool > m01_axi_rvalid;
  sc_core::sc_out< bool > m01_axi_rready;
  sc_core::sc_in< bool > m01_axi_aclk;
  sc_core::sc_in< bool > m01_axi_aresetn;
  sc_core::sc_in< sc_dt::sc_bv<1> > s03_axi_awid;
  sc_core::sc_in< sc_dt::sc_bv<64> > s03_axi_awaddr;
  sc_core::sc_in< sc_dt::sc_bv<8> > s03_axi_awlen;
  sc_core::sc_in< sc_dt::sc_bv<3> > s03_axi_awsize;
  sc_core::sc_in< sc_dt::sc_bv<2> > s03_axi_awburst;
  sc_core::sc_in< bool > s03_axi_awlock;
  sc_core::sc_in< sc_dt::sc_bv<4> > s03_axi_awcache;
  sc_core::sc_in< sc_dt::sc_bv<3> > s03_axi_awprot;
  sc_core::sc_in< sc_dt::sc_bv<4> > s03_axi_awregion;
  sc_core::sc_in< sc_dt::sc_bv<4> > s03_axi_awqos;
  sc_core::sc_in< bool > s03_axi_awvalid;
  sc_core::sc_out< bool > s03_axi_awready;
  sc_core::sc_in< sc_dt::sc_bv<512> > s03_axi_wdata;
  sc_core::sc_in< sc_dt::sc_bv<64> > s03_axi_wstrb;
  sc_core::sc_in< bool > s03_axi_wlast;
  sc_core::sc_in< bool > s03_axi_wvalid;
  sc_core::sc_out< bool > s03_axi_wready;
  sc_core::sc_out< sc_dt::sc_bv<1> > s03_axi_bid;
  sc_core::sc_out< sc_dt::sc_bv<2> > s03_axi_bresp;
  sc_core::sc_out< bool > s03_axi_bvalid;
  sc_core::sc_in< bool > s03_axi_bready;
  sc_core::sc_in< sc_dt::sc_bv<1> > s03_axi_arid;
  sc_core::sc_in< sc_dt::sc_bv<64> > s03_axi_araddr;
  sc_core::sc_in< sc_dt::sc_bv<8> > s03_axi_arlen;
  sc_core::sc_in< sc_dt::sc_bv<3> > s03_axi_arsize;
  sc_core::sc_in< sc_dt::sc_bv<2> > s03_axi_arburst;
  sc_core::sc_in< bool > s03_axi_arlock;
  sc_core::sc_in< sc_dt::sc_bv<4> > s03_axi_arcache;
  sc_core::sc_in< sc_dt::sc_bv<3> > s03_axi_arprot;
  sc_core::sc_in< sc_dt::sc_bv<4> > s03_axi_arregion;
  sc_core::sc_in< sc_dt::sc_bv<4> > s03_axi_arqos;
  sc_core::sc_in< bool > s03_axi_arvalid;
  sc_core::sc_out< bool > s03_axi_arready;
  sc_core::sc_out< sc_dt::sc_bv<1> > s03_axi_rid;
  sc_core::sc_out< sc_dt::sc_bv<512> > s03_axi_rdata;
  sc_core::sc_out< sc_dt::sc_bv<2> > s03_axi_rresp;
  sc_core::sc_out< bool > s03_axi_rlast;
  sc_core::sc_out< bool > s03_axi_rvalid;
  sc_core::sc_in< bool > s03_axi_rready;
  sc_core::sc_in< bool > s03_axi_aclk;
  sc_core::sc_in< bool > s03_axi_aresetn;
  sc_core::sc_in< sc_dt::sc_bv<1> > s01_axi_awid;
  sc_core::sc_in< sc_dt::sc_bv<64> > s01_axi_awaddr;
  sc_core::sc_in< sc_dt::sc_bv<8> > s01_axi_awlen;
  sc_core::sc_in< sc_dt::sc_bv<3> > s01_axi_awsize;
  sc_core::sc_in< sc_dt::sc_bv<2> > s01_axi_awburst;
  sc_core::sc_in< bool > s01_axi_awlock;
  sc_core::sc_in< sc_dt::sc_bv<4> > s01_axi_awcache;
  sc_core::sc_in< sc_dt::sc_bv<3> > s01_axi_awprot;
  sc_core::sc_in< sc_dt::sc_bv<4> > s01_axi_awregion;
  sc_core::sc_in< sc_dt::sc_bv<4> > s01_axi_awqos;
  sc_core::sc_in< bool > s01_axi_awvalid;
  sc_core::sc_out< bool > s01_axi_awready;
  sc_core::sc_in< sc_dt::sc_bv<512> > s01_axi_wdata;
  sc_core::sc_in< sc_dt::sc_bv<64> > s01_axi_wstrb;
  sc_core::sc_in< bool > s01_axi_wlast;
  sc_core::sc_in< bool > s01_axi_wvalid;
  sc_core::sc_out< bool > s01_axi_wready;
  sc_core::sc_out< sc_dt::sc_bv<1> > s01_axi_bid;
  sc_core::sc_out< sc_dt::sc_bv<2> > s01_axi_bresp;
  sc_core::sc_out< bool > s01_axi_bvalid;
  sc_core::sc_in< bool > s01_axi_bready;
  sc_core::sc_in< sc_dt::sc_bv<1> > s01_axi_arid;
  sc_core::sc_in< sc_dt::sc_bv<64> > s01_axi_araddr;
  sc_core::sc_in< sc_dt::sc_bv<8> > s01_axi_arlen;
  sc_core::sc_in< sc_dt::sc_bv<3> > s01_axi_arsize;
  sc_core::sc_in< sc_dt::sc_bv<2> > s01_axi_arburst;
  sc_core::sc_in< bool > s01_axi_arlock;
  sc_core::sc_in< sc_dt::sc_bv<4> > s01_axi_arcache;
  sc_core::sc_in< sc_dt::sc_bv<3> > s01_axi_arprot;
  sc_core::sc_in< sc_dt::sc_bv<4> > s01_axi_arregion;
  sc_core::sc_in< sc_dt::sc_bv<4> > s01_axi_arqos;
  sc_core::sc_in< bool > s01_axi_arvalid;
  sc_core::sc_out< bool > s01_axi_arready;
  sc_core::sc_out< sc_dt::sc_bv<1> > s01_axi_rid;
  sc_core::sc_out< sc_dt::sc_bv<512> > s01_axi_rdata;
  sc_core::sc_out< sc_dt::sc_bv<2> > s01_axi_rresp;
  sc_core::sc_out< bool > s01_axi_rlast;
  sc_core::sc_out< bool > s01_axi_rvalid;
  sc_core::sc_in< bool > s01_axi_rready;
  sc_core::sc_in< bool > s01_axi_aclk;
  sc_core::sc_in< bool > s01_axi_aresetn;
  sc_core::sc_in< sc_dt::sc_bv<1> > s02_axi_awid;
  sc_core::sc_in< sc_dt::sc_bv<64> > s02_axi_awaddr;
  sc_core::sc_in< sc_dt::sc_bv<8> > s02_axi_awlen;
  sc_core::sc_in< sc_dt::sc_bv<3> > s02_axi_awsize;
  sc_core::sc_in< sc_dt::sc_bv<2> > s02_axi_awburst;
  sc_core::sc_in< bool > s02_axi_awlock;
  sc_core::sc_in< sc_dt::sc_bv<4> > s02_axi_awcache;
  sc_core::sc_in< sc_dt::sc_bv<3> > s02_axi_awprot;
  sc_core::sc_in< sc_dt::sc_bv<4> > s02_axi_awregion;
  sc_core::sc_in< sc_dt::sc_bv<4> > s02_axi_awqos;
  sc_core::sc_in< bool > s02_axi_awvalid;
  sc_core::sc_out< bool > s02_axi_awready;
  sc_core::sc_in< sc_dt::sc_bv<512> > s02_axi_wdata;
  sc_core::sc_in< sc_dt::sc_bv<64> > s02_axi_wstrb;
  sc_core::sc_in< bool > s02_axi_wlast;
  sc_core::sc_in< bool > s02_axi_wvalid;
  sc_core::sc_out< bool > s02_axi_wready;
  sc_core::sc_out< sc_dt::sc_bv<1> > s02_axi_bid;
  sc_core::sc_out< sc_dt::sc_bv<2> > s02_axi_bresp;
  sc_core::sc_out< bool > s02_axi_bvalid;
  sc_core::sc_in< bool > s02_axi_bready;
  sc_core::sc_in< sc_dt::sc_bv<1> > s02_axi_arid;
  sc_core::sc_in< sc_dt::sc_bv<64> > s02_axi_araddr;
  sc_core::sc_in< sc_dt::sc_bv<8> > s02_axi_arlen;
  sc_core::sc_in< sc_dt::sc_bv<3> > s02_axi_arsize;
  sc_core::sc_in< sc_dt::sc_bv<2> > s02_axi_arburst;
  sc_core::sc_in< bool > s02_axi_arlock;
  sc_core::sc_in< sc_dt::sc_bv<4> > s02_axi_arcache;
  sc_core::sc_in< sc_dt::sc_bv<3> > s02_axi_arprot;
  sc_core::sc_in< sc_dt::sc_bv<4> > s02_axi_arregion;
  sc_core::sc_in< sc_dt::sc_bv<4> > s02_axi_arqos;
  sc_core::sc_in< bool > s02_axi_arvalid;
  sc_core::sc_out< bool > s02_axi_arready;
  sc_core::sc_out< sc_dt::sc_bv<1> > s02_axi_rid;
  sc_core::sc_out< sc_dt::sc_bv<512> > s02_axi_rdata;
  sc_core::sc_out< sc_dt::sc_bv<2> > s02_axi_rresp;
  sc_core::sc_out< bool > s02_axi_rlast;
  sc_core::sc_out< bool > s02_axi_rvalid;
  sc_core::sc_in< bool > s02_axi_rready;
  sc_core::sc_in< bool > s02_axi_aclk;
  sc_core::sc_in< bool > s02_axi_aresetn;
  sc_core::sc_in< sc_dt::sc_bv<1> > s04_axi_awid;
  sc_core::sc_in< sc_dt::sc_bv<64> > s04_axi_awaddr;
  sc_core::sc_in< sc_dt::sc_bv<8> > s04_axi_awlen;
  sc_core::sc_in< sc_dt::sc_bv<3> > s04_axi_awsize;
  sc_core::sc_in< sc_dt::sc_bv<2> > s04_axi_awburst;
  sc_core::sc_in< bool > s04_axi_awlock;
  sc_core::sc_in< sc_dt::sc_bv<4> > s04_axi_awcache;
  sc_core::sc_in< sc_dt::sc_bv<3> > s04_axi_awprot;
  sc_core::sc_in< sc_dt::sc_bv<4> > s04_axi_awregion;
  sc_core::sc_in< sc_dt::sc_bv<4> > s04_axi_awqos;
  sc_core::sc_in< bool > s04_axi_awvalid;
  sc_core::sc_out< bool > s04_axi_awready;
  sc_core::sc_in< sc_dt::sc_bv<512> > s04_axi_wdata;
  sc_core::sc_in< sc_dt::sc_bv<64> > s04_axi_wstrb;
  sc_core::sc_in< bool > s04_axi_wlast;
  sc_core::sc_in< bool > s04_axi_wvalid;
  sc_core::sc_out< bool > s04_axi_wready;
  sc_core::sc_out< sc_dt::sc_bv<1> > s04_axi_bid;
  sc_core::sc_out< sc_dt::sc_bv<2> > s04_axi_bresp;
  sc_core::sc_out< bool > s04_axi_bvalid;
  sc_core::sc_in< bool > s04_axi_bready;
  sc_core::sc_in< sc_dt::sc_bv<1> > s04_axi_arid;
  sc_core::sc_in< sc_dt::sc_bv<64> > s04_axi_araddr;
  sc_core::sc_in< sc_dt::sc_bv<8> > s04_axi_arlen;
  sc_core::sc_in< sc_dt::sc_bv<3> > s04_axi_arsize;
  sc_core::sc_in< sc_dt::sc_bv<2> > s04_axi_arburst;
  sc_core::sc_in< bool > s04_axi_arlock;
  sc_core::sc_in< sc_dt::sc_bv<4> > s04_axi_arcache;
  sc_core::sc_in< sc_dt::sc_bv<3> > s04_axi_arprot;
  sc_core::sc_in< sc_dt::sc_bv<4> > s04_axi_arregion;
  sc_core::sc_in< sc_dt::sc_bv<4> > s04_axi_arqos;
  sc_core::sc_in< bool > s04_axi_arvalid;
  sc_core::sc_out< bool > s04_axi_arready;
  sc_core::sc_out< sc_dt::sc_bv<1> > s04_axi_rid;
  sc_core::sc_out< sc_dt::sc_bv<512> > s04_axi_rdata;
  sc_core::sc_out< sc_dt::sc_bv<2> > s04_axi_rresp;
  sc_core::sc_out< bool > s04_axi_rlast;
  sc_core::sc_out< bool > s04_axi_rvalid;
  sc_core::sc_in< bool > s04_axi_rready;
  sc_core::sc_in< bool > s04_axi_aclk;
  sc_core::sc_in< bool > s04_axi_aresetn;

protected:

  virtual void before_end_of_elaboration();

private:

  xtlm::xaximm_pin2xtlm_t<32,64,1,1,1,1,1,1>* mp_S00_AXI_transactor;
  xtlm::xaximm_pin2xtlm_t<512,64,1,1,1,1,1,1>* mp_S01_AXI_transactor;
  xtlm::xaximm_pin2xtlm_t<512,64,1,1,1,1,1,1>* mp_S02_AXI_transactor;
  xtlm::xaximm_pin2xtlm_t<512,64,1,1,1,1,1,1>* mp_S03_AXI_transactor;
  xtlm::xaximm_pin2xtlm_t<512,64,1,1,1,1,1,1>* mp_S04_AXI_transactor;
  xtlm::xaximm_xtlm2pin_t<32,64,1,1,1,1,1,1>* mp_M00_AXI_transactor;
  xtlm::xaximm_xtlm2pin_t<32,64,1,1,1,1,1,1>* mp_M01_AXI_transactor;
  xtlm::xaximm_xtlm2pin_t<32,64,1,1,1,1,1,1>* mp_M02_AXI_transactor;
  xtlm::xaximm_xtlm2pin_t<32,64,1,1,1,1,1,1>* mp_M03_AXI_transactor;
  xtlm::xaximm_xtlm2pin_t<64,32,1,1,1,1,1,1>* mp_M04_AXI_transactor;

};

#endif // IP_PFM_DYNAMIC_XTLM_SIMPLE_INTERCON_0_0_H_
