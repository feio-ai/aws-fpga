// Amazon FPGA Hardware Development Kit
//
// Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License"). You may not use
// this file except in compliance with the License. A copy of the License is
// located at
//
//    http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
// implied. See the License for the specific language governing permissions and
// limitations under the License.

`define SPATIAL_SCALAR_WIDTH 64

module cl_dram_dma #(parameter NUM_DDR=4)

(
   `include "cl_ports.vh"

);

// /*
    initial begin
        $dumpfile("Top.vcd");
        $dumpvars(0, Top_inst);
        // $dumpvars(1, SH_DDR);
        $dumpvars(1, cl_dram_dma);
        // $dumpvars;
    end
// */

`include "cl_common_defines.vh"      // CL Defines for all examples
`include "cl_id_defines.vh"          // Defines for ID0 and ID1 (PCI ID's)
`include "cl_dram_dma_defines.vh"

// TIE OFF ALL UNUSED INTERFACES
// Including all the unused interface to tie off
// This list is put in the top of the fie to remind
// developers to remve the specific interfaces
// that the CL will use

`include "unused_sh_bar1_template.inc"

// Define the addition pipeline stag
// needed to close timing for the various
// place where ATG (Automatic Test Generator)
// is defined

   localparam NUM_CFG_STGS_CL_DDR_ATG = 8;
   localparam NUM_CFG_STGS_SH_DDR_ATG = 4;
   localparam NUM_CFG_STGS_PCIE_ATG = 4;

// To reduce RTL simulation time, only 8KiB of
// each external DRAM is scrubbed in simulations

`ifdef SIM
   localparam DDR_SCRB_MAX_ADDR = 64'h1FFF;
`else
   localparam DDR_SCRB_MAX_ADDR = 64'h3FFFFFFFF; //16GB
`endif
   localparam DDR_SCRB_BURST_LEN_MINUS1 = 15;

`ifdef NO_CL_TST_SCRUBBER
   localparam NO_SCRB_INST = 1;
`else
   localparam NO_SCRB_INST = 0;
`endif

//----------------------------
// Internal signals
//----------------------------
axi_bus_t lcl_cl_sh_ddra();
axi_bus_t lcl_cl_sh_ddrb();
axi_bus_t lcl_cl_sh_ddrd();
axi_bus_t axi_bus_tied();

axi_bus_t sh_cl_dma_pcis_bus();
axi_bus_t sh_cl_dma_pcis_q();

axi_bus_t cl_axi_mstr_bus();

axi_bus_t cl_sh_pcim_bus();
axi_bus_t cl_sh_ddr_bus();

axi_bus_t sda_cl_bus();
axi_bus_t sh_ocl_bus();

cfg_bus_t pcim_tst_cfg_bus();
cfg_bus_t ddra_tst_cfg_bus();
cfg_bus_t ddrb_tst_cfg_bus();
cfg_bus_t ddrc_tst_cfg_bus();
cfg_bus_t ddrd_tst_cfg_bus();
cfg_bus_t axi_mstr_cfg_bus();
cfg_bus_t int_tst_cfg_bus();

scrb_bus_t ddra_scrb_bus();
scrb_bus_t ddrb_scrb_bus();
scrb_bus_t ddrc_scrb_bus();
scrb_bus_t ddrd_scrb_bus();


logic clk;
(* dont_touch = "true" *) logic pipe_rst_n;
logic pre_sync_rst_n;
(* dont_touch = "true" *) logic sync_rst_n;
logic sh_cl_flr_assert_q;

logic [3:0] all_ddr_scrb_done;
logic [3:0] all_ddr_is_ready;
logic [2:0] lcl_sh_cl_ddr_is_ready;

logic dbg_scrb_en;
logic [2:0] dbg_scrb_mem_sel;

//----------------------------
// End Internal signals
//----------------------------

// Unused 'full' signals
assign cl_sh_dma_rd_full  = 1'b0;
assign cl_sh_dma_wr_full  = 1'b0;

// Unused *burst signals
assign cl_sh_ddr_arburst[1:0] = 2'h0;
assign cl_sh_ddr_awburst[1:0] = 2'h0;


assign clk = clk_main_a0;

//reset synchronizer
lib_pipe #(.WIDTH(1), .STAGES(4)) PIPE_RST_N (.clk(clk), .rst_n(1'b1), .in_bus(rst_main_n), .out_bus(pipe_rst_n));

always_ff @(negedge pipe_rst_n or posedge clk)
   if (!pipe_rst_n)
   begin
      pre_sync_rst_n <= 0;
      sync_rst_n <= 0;
   end
   else
   begin
      pre_sync_rst_n <= 1;
      sync_rst_n <= pre_sync_rst_n;
   end

//FLR response
always_ff @(negedge sync_rst_n or posedge clk)
   if (!sync_rst_n)
   begin
      sh_cl_flr_assert_q <= 0;
      cl_sh_flr_done <= 0;
   end
   else
   begin
      sh_cl_flr_assert_q <= sh_cl_flr_assert;
      cl_sh_flr_done <= sh_cl_flr_assert_q && !cl_sh_flr_done;
   end

///////////////////////////////////////////////////////////////////////
///////////////// Scrubber enable and status //////////////////////////
///////////////////////////////////////////////////////////////////////

// Bit 31: Debug enable (for cl_sh_id0 and cl_sh_id1)
// Bit 30:28: Debug Scrb memory select

// Bit 3 : DDRC Scrub enable
// Bit 2 : DDRD Scrub enable
// Bit 1 : DDRB Scrub enable
// Bit 0 : DDRA Scrub enable
logic [31:0] sh_cl_ctl0_q;
always_ff @(posedge clk or negedge sync_rst_n)
  if (!sync_rst_n)
    sh_cl_ctl0_q <= 32'd0;
  else
    sh_cl_ctl0_q <= sh_cl_ctl0;

assign ddra_scrb_bus.enable = sh_cl_ctl0_q[0];
assign ddrb_scrb_bus.enable = sh_cl_ctl0_q[1];
assign ddrd_scrb_bus.enable = sh_cl_ctl0_q[2];
assign ddrc_scrb_bus.enable = sh_cl_ctl0_q[3];


assign dbg_scrb_en = sh_cl_ctl0_q[31];
assign dbg_scrb_mem_sel[2:0] = sh_cl_ctl0_q[30:28];

// The functionality for these signals is TBD so they can can be tied-off.
assign cl_sh_status0 = 32'h0;
assign cl_sh_status1 = 32'h0;

always_ff @(posedge clk)
    cl_sh_id0 <= dbg_scrb_en ? (dbg_scrb_mem_sel == 3'd3 ? ddrc_scrb_bus.addr[31:0] :
                                dbg_scrb_mem_sel == 3'd2 ? ddrd_scrb_bus.addr[31:0] :
                                dbg_scrb_mem_sel == 3'd1 ? ddrb_scrb_bus.addr[31:0] : ddra_scrb_bus.addr[31:0]) :
                                `CL_SH_ID0;
always_ff @(posedge clk)
    cl_sh_id1 <= dbg_scrb_en ? (dbg_scrb_mem_sel == 3'd3 ? ddrc_scrb_bus.addr[63:32] :
                                dbg_scrb_mem_sel == 3'd2 ? ddrd_scrb_bus.addr[63:32] :
                                dbg_scrb_mem_sel == 3'd1 ? ddrb_scrb_bus.addr[63:32] : ddra_scrb_bus.addr[63:32]) :
                                `CL_SH_ID1;

logic sh_cl_ddr_is_ready_q;
always_ff @(posedge clk or negedge sync_rst_n)
  if (!sync_rst_n)
  begin
    sh_cl_ddr_is_ready_q <= 1'b0;
  end
  else
  begin
    sh_cl_ddr_is_ready_q <= sh_cl_ddr_is_ready;
  end

assign all_ddr_is_ready = {lcl_sh_cl_ddr_is_ready[2], sh_cl_ddr_is_ready_q, lcl_sh_cl_ddr_is_ready[1:0]};

assign all_ddr_scrb_done = {ddrc_scrb_bus.done, ddrd_scrb_bus.done, ddrb_scrb_bus.done, ddra_scrb_bus.done};


///////////////////////////////////////////////////////////////////////
///////////////// Scrubber enable and status //////////////////////////
///////////////////////////////////////////////////////////////////////

//------------------------------------
// Instantiate Top
//------------------------------------

logic [`SPATIAL_SCALAR_WIDTH-1:0] SCALAR_argIn__0;
logic [`SPATIAL_SCALAR_WIDTH-1:0] SCALAR_argIn__1;
logic [`SPATIAL_SCALAR_WIDTH-1:0] SCALAR_argIn__2;
logic [`SPATIAL_SCALAR_WIDTH-1:0] SCALAR_argIn__3;
logic [`SPATIAL_SCALAR_WIDTH-1:0] SCALAR_argIn__4;
logic [`SPATIAL_SCALAR_WIDTH-1:0] SCALAR_argIn__5;
logic [`SPATIAL_SCALAR_WIDTH-1:0] SCALAR_argIn__6;
logic [`SPATIAL_SCALAR_WIDTH-1:0] SCALAR_argIn__7;
logic [`SPATIAL_SCALAR_WIDTH-1:0] SCALAR_argIn__8;
logic [`SPATIAL_SCALAR_WIDTH-1:0] SCALAR_argIn__9;
logic [`SPATIAL_SCALAR_WIDTH-1:0] SCALAR_argIn__10;
logic [`SPATIAL_SCALAR_WIDTH-1:0] SCALAR_argOut__0;
logic [31:0] SCALAR_en;    // CMD bit from host
logic [31:0] SCALAR_reset; // CMD bit from host
logic [31:0] SCALAR_done;  // Status bit from host

logic [15:0]   Top_Out_io_M_AXI_0_AWID;
// logic [31:0]  Top_Out_io_M_AXI_0_AWUSER;
logic [31:0]  Top_Out_io_M_AXI_0_AWADDR;
logic [7:0]   Top_Out_io_M_AXI_0_AWLEN;
logic [2:0]   Top_Out_io_M_AXI_0_AWSIZE;
// logic [1:0]   Top_Out_io_M_AXI_0_AWBURST;
// logic         Top_Out_io_M_AXI_0_AWLOCK;
// logic [3:0]   Top_Out_io_M_AXI_0_AWCACHE;
// logic [2:0]   Top_Out_io_M_AXI_0_AWPROT;
// logic [3:0]   Top_Out_io_M_AXI_0_AWQOS;
logic         Top_Out_io_M_AXI_0_AWVALID;
logic         Top_In_io_M_AXI_0_AWREADY;
logic [15:0]   Top_Out_io_M_AXI_0_ARID;
// logic [31:0]  Top_Out_io_M_AXI_0_ARUSER;
logic [31:0]  Top_Out_io_M_AXI_0_ARADDR;
logic [7:0]   Top_Out_io_M_AXI_0_ARLEN;
logic [2:0]   Top_Out_io_M_AXI_0_ARSIZE;
// logic [1:0]   Top_Out_io_M_AXI_0_ARBURST;
// logic         Top_Out_io_M_AXI_0_ARLOCK;
// logic [3:0]   Top_Out_io_M_AXI_0_ARCACHE;
// logic [2:0]   Top_Out_io_M_AXI_0_ARPROT;
// logic [3:0]   Top_Out_io_M_AXI_0_ARQOS;
logic         Top_Out_io_M_AXI_0_ARVALID;
logic         Top_In_io_M_AXI_0_ARREADY;
logic [511:0] Top_Out_io_M_AXI_0_WDATA;
logic [63:0]  Top_Out_io_M_AXI_0_WSTRB;
logic         Top_Out_io_M_AXI_0_WLAST;
logic         Top_Out_io_M_AXI_0_WVALID;
logic         Top_In_io_M_AXI_0_WREADY;
logic [15:0]   Top_In_io_M_AXI_0_RID;
// logic [31:0]  Top_In_io_M_AXI_0_RUSER;
logic [511:0] Top_In_io_M_AXI_0_RDATA;
logic [1:0]   Top_In_io_M_AXI_0_RRESP;
logic         Top_In_io_M_AXI_0_RLAST;
logic         Top_In_io_M_AXI_0_RVALID;
logic         Top_Out_io_M_AXI_0_RREADY;
logic [15:0]   Top_In_io_M_AXI_0_BID;
// logic [31:0]  Top_In_io_M_AXI_0_BUSER;
logic [1:0]   Top_In_io_M_AXI_0_BRESP;
logic         Top_In_io_M_AXI_0_BVALID;
logic         Top_Out_io_M_AXI_0_BREADY;

logic [15:0]   Top_Out_io_M_AXI_0_AWID_q;
// logic [31:0]  Top_Out_io_M_AXI_0_AWUSER;
logic [31:0]  Top_Out_io_M_AXI_0_AWADDR_q;
logic [7:0]   Top_Out_io_M_AXI_0_AWLEN_q;
logic [2:0]   Top_Out_io_M_AXI_0_AWSIZE_q;
// logic [1:0]   Top_Out_io_M_AXI_0_AWBURST;
// logic         Top_Out_io_M_AXI_0_AWLOCK;
// logic [3:0]   Top_Out_io_M_AXI_0_AWCACHE;
// logic [2:0]   Top_Out_io_M_AXI_0_AWPROT;
// logic [3:0]   Top_Out_io_M_AXI_0_AWQOS;
logic         Top_Out_io_M_AXI_0_AWVALID_q;
logic         Top_In_io_M_AXI_0_AWREADY_q;
logic [15:0]   Top_Out_io_M_AXI_0_ARID_q;
// logic [31:0]  Top_Out_io_M_AXI_0_ARUSER;
logic [31:0]  Top_Out_io_M_AXI_0_ARADDR_q;
logic [7:0]   Top_Out_io_M_AXI_0_ARLEN_q;
logic [2:0]   Top_Out_io_M_AXI_0_ARSIZE_q;
// logic [1:0]   Top_Out_io_M_AXI_0_ARBURST;
// logic         Top_Out_io_M_AXI_0_ARLOCK;
// logic [3:0]   Top_Out_io_M_AXI_0_ARCACHE;
// logic [2:0]   Top_Out_io_M_AXI_0_ARPROT;
// logic [3:0]   Top_Out_io_M_AXI_0_ARQOS;
logic         Top_Out_io_M_AXI_0_ARVALID_q;
logic         Top_In_io_M_AXI_0_ARREADY_q;
logic [511:0] Top_Out_io_M_AXI_0_WDATA_q;
logic [63:0]  Top_Out_io_M_AXI_0_WSTRB_q;
logic         Top_Out_io_M_AXI_0_WLAST_q;
logic         Top_Out_io_M_AXI_0_WVALID_q;
logic         Top_In_io_M_AXI_0_WREADY_q;
logic [15:0]   Top_In_io_M_AXI_0_RID_q;
// logic [31:0]  Top_In_io_M_AXI_0_RUSER;
logic [511:0] Top_In_io_M_AXI_0_RDATA_q;
logic [1:0]   Top_In_io_M_AXI_0_RRESP_q;
logic         Top_In_io_M_AXI_0_RLAST_q;
logic         Top_In_io_M_AXI_0_RVALID_q;
logic         Top_Out_io_M_AXI_0_RREADY_q;
logic [15:0]   Top_In_io_M_AXI_0_BID_q;
// logic [31:0]  Top_In_io_M_AXI_0_BUSER;
logic [1:0]   Top_In_io_M_AXI_0_BRESP_q;
logic         Top_In_io_M_AXI_0_BVALID_q;
logic         Top_Out_io_M_AXI_0_BREADY_q;

// [4channels]
//logic [15:0]   Top_Out_io_M_AXI_1_AWID;
//// logic [31:0]  Top_Out_io_M_AXI_1_AWUSER;
//logic [31:0]  Top_Out_io_M_AXI_1_AWADDR;
//logic [7:0]   Top_Out_io_M_AXI_1_AWLEN;
//logic [2:0]   Top_Out_io_M_AXI_1_AWSIZE;
//// logic [1:0]   Top_Out_io_M_AXI_1_AWBURST;
//// logic         Top_Out_io_M_AXI_1_AWLOCK;
//// logic [3:0]   Top_Out_io_M_AXI_1_AWCACHE;
//// logic [2:0]   Top_Out_io_M_AXI_1_AWPROT;
//// logic [3:0]   Top_Out_io_M_AXI_1_AWQOS;
//logic         Top_Out_io_M_AXI_1_AWVALID;
//logic         Top_In_io_M_AXI_1_AWREADY;
//logic [15:0]   Top_Out_io_M_AXI_1_ARID;
//// logic [31:0]  Top_Out_io_M_AXI_1_ARUSER;
//logic [31:0]  Top_Out_io_M_AXI_1_ARADDR;
//logic [7:0]   Top_Out_io_M_AXI_1_ARLEN;
//logic [2:0]   Top_Out_io_M_AXI_1_ARSIZE;
//// logic [1:0]   Top_Out_io_M_AXI_1_ARBURST;
//// logic         Top_Out_io_M_AXI_1_ARLOCK;
//// logic [3:0]   Top_Out_io_M_AXI_1_ARCACHE;
//// logic [2:0]   Top_Out_io_M_AXI_1_ARPROT;
//// logic [3:0]   Top_Out_io_M_AXI_1_ARQOS;
//logic         Top_Out_io_M_AXI_1_ARVALID;
//logic         Top_In_io_M_AXI_1_ARREADY;
//logic [511:0] Top_Out_io_M_AXI_1_WDATA;
//logic [63:0]  Top_Out_io_M_AXI_1_WSTRB;
//logic         Top_Out_io_M_AXI_1_WLAST;
//logic         Top_Out_io_M_AXI_1_WVALID;
//logic         Top_In_io_M_AXI_1_WREADY;
//logic [15:0]   Top_In_io_M_AXI_1_RID;
//// logic [31:0]  Top_In_io_M_AXI_1_RUSER;
//logic [511:0] Top_In_io_M_AXI_1_RDATA;
//logic [1:0]   Top_In_io_M_AXI_1_RRESP;
//logic         Top_In_io_M_AXI_1_RLAST;
//logic         Top_In_io_M_AXI_1_RVALID;
//logic         Top_Out_io_M_AXI_1_RREADY;
//logic [15:0]   Top_In_io_M_AXI_1_BID;
//// logic [31:0]  Top_In_io_M_AXI_1_BUSER;
//logic [1:0]   Top_In_io_M_AXI_1_BRESP;
//logic         Top_In_io_M_AXI_1_BVALID;
//logic         Top_Out_io_M_AXI_1_BREADY;
//
//logic [15:0]   Top_Out_io_M_AXI_2_AWID;
//// logic [31:0]  Top_Out_io_M_AXI_2_AWUSER;
//logic [31:0]  Top_Out_io_M_AXI_2_AWADDR;
//logic [7:0]   Top_Out_io_M_AXI_2_AWLEN;
//logic [2:0]   Top_Out_io_M_AXI_2_AWSIZE;
//// logic [1:0]   Top_Out_io_M_AXI_2_AWBURST;
//// logic         Top_Out_io_M_AXI_2_AWLOCK;
//// logic [3:0]   Top_Out_io_M_AXI_2_AWCACHE;
//// logic [2:0]   Top_Out_io_M_AXI_2_AWPROT;
//// logic [3:0]   Top_Out_io_M_AXI_2_AWQOS;
//logic         Top_Out_io_M_AXI_2_AWVALID;
//logic         Top_In_io_M_AXI_2_AWREADY;
//logic [15:0]   Top_Out_io_M_AXI_2_ARID;
//// logic [31:0]  Top_Out_io_M_AXI_2_ARUSER;
//logic [31:0]  Top_Out_io_M_AXI_2_ARADDR;
//logic [7:0]   Top_Out_io_M_AXI_2_ARLEN;
//logic [2:0]   Top_Out_io_M_AXI_2_ARSIZE;
//// logic [1:0]   Top_Out_io_M_AXI_2_ARBURST;
//// logic         Top_Out_io_M_AXI_2_ARLOCK;
//// logic [3:0]   Top_Out_io_M_AXI_2_ARCACHE;
//// logic [2:0]   Top_Out_io_M_AXI_2_ARPROT;
//// logic [3:0]   Top_Out_io_M_AXI_2_ARQOS;
//logic         Top_Out_io_M_AXI_2_ARVALID;
//logic         Top_In_io_M_AXI_2_ARREADY;
//logic [511:0] Top_Out_io_M_AXI_2_WDATA;
//logic [63:0]  Top_Out_io_M_AXI_2_WSTRB;
//logic         Top_Out_io_M_AXI_2_WLAST;
//logic         Top_Out_io_M_AXI_2_WVALID;
//logic         Top_In_io_M_AXI_2_WREADY;
//logic [15:0]   Top_In_io_M_AXI_2_RID;
//// logic [31:0]  Top_In_io_M_AXI_2_RUSER;
//logic [511:0] Top_In_io_M_AXI_2_RDATA;
//logic [1:0]   Top_In_io_M_AXI_2_RRESP;
//logic         Top_In_io_M_AXI_2_RLAST;
//logic         Top_In_io_M_AXI_2_RVALID;
//logic         Top_Out_io_M_AXI_2_RREADY;
//logic [15:0]   Top_In_io_M_AXI_2_BID;
//// logic [31:0]  Top_In_io_M_AXI_2_BUSER;
//logic [1:0]   Top_In_io_M_AXI_2_BRESP;
//logic         Top_In_io_M_AXI_2_BVALID;
//logic         Top_Out_io_M_AXI_2_BREADY;
//
//logic [15:0]   Top_Out_io_M_AXI_3_AWID;
//// logic [31:0]  Top_Out_io_M_AXI_3_AWUSER;
//logic [31:0]  Top_Out_io_M_AXI_3_AWADDR;
//logic [7:0]   Top_Out_io_M_AXI_3_AWLEN;
//logic [2:0]   Top_Out_io_M_AXI_3_AWSIZE;
//// logic [1:0]   Top_Out_io_M_AXI_3_AWBURST;
//// logic         Top_Out_io_M_AXI_3_AWLOCK;
//// logic [3:0]   Top_Out_io_M_AXI_3_AWCACHE;
//// logic [2:0]   Top_Out_io_M_AXI_3_AWPROT;
//// logic [3:0]   Top_Out_io_M_AXI_3_AWQOS;
//logic         Top_Out_io_M_AXI_3_AWVALID;
//logic         Top_In_io_M_AXI_3_AWREADY;
//logic [15:0]   Top_Out_io_M_AXI_3_ARID;
//// logic [31:0]  Top_Out_io_M_AXI_3_ARUSER;
//logic [31:0]  Top_Out_io_M_AXI_3_ARADDR;
//logic [7:0]   Top_Out_io_M_AXI_3_ARLEN;
//logic [2:0]   Top_Out_io_M_AXI_3_ARSIZE;
//// logic [1:0]   Top_Out_io_M_AXI_3_ARBURST;
//// logic         Top_Out_io_M_AXI_3_ARLOCK;
//// logic [3:0]   Top_Out_io_M_AXI_3_ARCACHE;
//// logic [2:0]   Top_Out_io_M_AXI_3_ARPROT;
//// logic [3:0]   Top_Out_io_M_AXI_3_ARQOS;
//logic         Top_Out_io_M_AXI_3_ARVALID;
//logic         Top_In_io_M_AXI_3_ARREADY;
//logic [511:0] Top_Out_io_M_AXI_3_WDATA;
//logic [63:0]  Top_Out_io_M_AXI_3_WSTRB;
//logic         Top_Out_io_M_AXI_3_WLAST;
//logic         Top_Out_io_M_AXI_3_WVALID;
//logic         Top_In_io_M_AXI_3_WREADY;
//logic [15:0]   Top_In_io_M_AXI_3_RID;
//// logic [31:0]  Top_In_io_M_AXI_3_RUSER;
//logic [511:0] Top_In_io_M_AXI_3_RDATA;
//logic [1:0]   Top_In_io_M_AXI_3_RRESP;
//logic         Top_In_io_M_AXI_3_RLAST;
//logic         Top_In_io_M_AXI_3_RVALID;
//logic         Top_Out_io_M_AXI_3_RREADY;
//logic [15:0]   Top_In_io_M_AXI_3_BID;
//// logic [31:0]  Top_In_io_M_AXI_3_BUSER;
//logic [1:0]   Top_In_io_M_AXI_3_BRESP;
//logic         Top_In_io_M_AXI_3_BVALID;
//logic         Top_Out_io_M_AXI_3_BREADY;

Top Top_inst (
  .clock(clk),
  .reset(SCALAR_reset[0]),
  .io_enable(SCALAR_en),
  .io_done(SCALAR_done),

  // Scalars
  .io_scalarIns_0(SCALAR_argIn__0),
  .io_scalarIns_1(SCALAR_argIn__1),
  .io_scalarIns_2(SCALAR_argIn__2),
  .io_scalarIns_3(SCALAR_argIn__3),
  .io_scalarIns_4(SCALAR_argIn__4),
  .io_scalarIns_5(SCALAR_argIn__5),
  .io_scalarIns_6(SCALAR_argIn__6),
  .io_scalarIns_7(SCALAR_argIn__7),
  .io_scalarIns_8(SCALAR_argIn__8),
  .io_scalarIns_9(SCALAR_argIn__9),
  .io_scalarIns_10(SCALAR_argIn__10),
  .io_scalarOuts_0(SCALAR_argOut__0),

  // AXI-4 for DRAM
  .io_M_AXI_0_AWID    (Top_Out_io_M_AXI_0_AWID_q),     // output [15:0]
  // .io_M_AXI_0_AWUSER  (Top_Out_io_M_AXI_0_AWUSER),   // output [31:0]
  .io_M_AXI_0_AWADDR  (Top_Out_io_M_AXI_0_AWADDR_q),   // output [31:0]
  .io_M_AXI_0_AWLEN   (Top_Out_io_M_AXI_0_AWLEN_q),    // output [7:0]
  .io_M_AXI_0_AWSIZE  (Top_Out_io_M_AXI_0_AWSIZE_q),   // output [2:0]
  // .io_M_AXI_0_AWBURST (Top_Out_io_M_AXI_0_AWBURST),  // output [1:0]
  // .io_M_AXI_0_AWLOCK  (Top_Out_io_M_AXI_0_AWLOCK),   // output
  // .io_M_AXI_0_AWCACHE (Top_Out_io_M_AXI_0_AWCACHE),  // output [3:0]
  // .io_M_AXI_0_AWPROT  (Top_Out_io_M_AXI_0_AWPROT),   // output [2:0]
  // .io_M_AXI_0_AWQOS   (Top_Out_io_M_AXI_0_AWQOS),    // output [3:0]
  .io_M_AXI_0_AWVALID (Top_Out_io_M_AXI_0_AWVALID_q),  // output
  .io_M_AXI_0_AWREADY (Top_In_io_M_AXI_0_AWREADY_q),   // input
  .io_M_AXI_0_ARID    (Top_Out_io_M_AXI_0_ARID_q),     // output [15:0]
  // .io_M_AXI_0_ARUSER  (Top_Out_io_M_AXI_0_ARUSER),   // output [31:0]
  .io_M_AXI_0_ARADDR  (Top_Out_io_M_AXI_0_ARADDR_q),   // output [31:0]
  .io_M_AXI_0_ARLEN   (Top_Out_io_M_AXI_0_ARLEN_q),    // output [7:0]
  .io_M_AXI_0_ARSIZE  (Top_Out_io_M_AXI_0_ARSIZE_q),   // output [2:0]
  // .io_M_AXI_0_ARBURST (Top_Out_io_M_AXI_0_ARBURST),  // output [1:0]
  // .io_M_AXI_0_ARLOCK  (Top_Out_io_M_AXI_0_ARLOCK),   // output
  // .io_M_AXI_0_ARCACHE (Top_Out_io_M_AXI_0_ARCACHE),  // output [3:0]
  // .io_M_AXI_0_ARPROT  (Top_Out_io_M_AXI_0_ARPROT),   // output [2:0]
  // .io_M_AXI_0_ARQOS   (Top_Out_io_M_AXI_0_ARQOS),    // output [3:0]
  .io_M_AXI_0_ARVALID (Top_Out_io_M_AXI_0_ARVALID_q),  // output
  .io_M_AXI_0_ARREADY (Top_In_io_M_AXI_0_ARREADY_q),   // input
  .io_M_AXI_0_WDATA   (Top_Out_io_M_AXI_0_WDATA_q),    // output [511:0]
  .io_M_AXI_0_WSTRB   (Top_Out_io_M_AXI_0_WSTRB_q),    // output [63:0]
  .io_M_AXI_0_WLAST   (Top_Out_io_M_AXI_0_WLAST_q),    // output
  .io_M_AXI_0_WVALID  (Top_Out_io_M_AXI_0_WVALID_q),   // output
  .io_M_AXI_0_WREADY  (Top_In_io_M_AXI_0_WREADY_q),    // input
  .io_M_AXI_0_RID     (Top_In_io_M_AXI_0_RID_q),       // input  [15:0]
  // .io_M_AXI_0_RUSER   (Top_In_io_M_AXI_0_RUSER),     // input  [31:0]
  .io_M_AXI_0_RDATA   (Top_In_io_M_AXI_0_RDATA_q),     // input  [511:0]
  .io_M_AXI_0_RRESP   (Top_In_io_M_AXI_0_RRESP_q),     // input  [1:0]
  .io_M_AXI_0_RLAST   (Top_In_io_M_AXI_0_RLAST_q),     // input
  .io_M_AXI_0_RVALID  (Top_In_io_M_AXI_0_RVALID_q),    // input
  .io_M_AXI_0_RREADY  (Top_Out_io_M_AXI_0_RREADY_q),   // output
  .io_M_AXI_0_BID     (Top_In_io_M_AXI_0_BID_q),       // input  [15:0]
  // .io_M_AXI_0_BUSER   (Top_In_io_M_AXI_0_BUSER),     // input  [31:0]
  .io_M_AXI_0_BRESP   (Top_In_io_M_AXI_0_BRESP_q),     // input  [1:0]
  .io_M_AXI_0_BVALID  (Top_In_io_M_AXI_0_BVALID_q),    // input
  .io_M_AXI_0_BREADY  (Top_Out_io_M_AXI_0_BREADY_q)    // output

//  [4channels]
//  .io_M_AXI_1_AWID    (Top_Out_io_M_AXI_1_AWID),     // output [15:0]
//  // .io_M_AXI_1_AWUSER  (Top_Out_io_M_AXI_1_AWUSER),   // output [31:0]
//  .io_M_AXI_1_AWADDR  (Top_Out_io_M_AXI_1_AWADDR),   // output [31:0]
//  .io_M_AXI_1_AWLEN   (Top_Out_io_M_AXI_1_AWLEN),    // output [7:0]
//  .io_M_AXI_1_AWSIZE  (Top_Out_io_M_AXI_1_AWSIZE),   // output [2:0]
//  // .io_M_AXI_1_AWBURST (Top_Out_io_M_AXI_1_AWBURST),  // output [1:0]
//  // .io_M_AXI_1_AWLOCK  (Top_Out_io_M_AXI_1_AWLOCK),   // output
//  // .io_M_AXI_1_AWCACHE (Top_Out_io_M_AXI_1_AWCACHE),  // output [3:0]
//  // .io_M_AXI_1_AWPROT  (Top_Out_io_M_AXI_1_AWPROT),   // output [2:0]
//  // .io_M_AXI_1_AWQOS   (Top_Out_io_M_AXI_1_AWQOS),    // output [3:0]
//  .io_M_AXI_1_AWVALID (Top_Out_io_M_AXI_1_AWVALID),  // output
//  .io_M_AXI_1_AWREADY (Top_In_io_M_AXI_1_AWREADY),   // input
//  .io_M_AXI_1_ARID    (Top_Out_io_M_AXI_1_ARID),     // output [15:0]
//  // .io_M_AXI_1_ARUSER  (Top_Out_io_M_AXI_1_ARUSER),   // output [31:0]
//  .io_M_AXI_1_ARADDR  (Top_Out_io_M_AXI_1_ARADDR),   // output [31:0]
//  .io_M_AXI_1_ARLEN   (Top_Out_io_M_AXI_1_ARLEN),    // output [7:0]
//  .io_M_AXI_1_ARSIZE  (Top_Out_io_M_AXI_1_ARSIZE),   // output [2:0]
//  // .io_M_AXI_1_ARBURST (Top_Out_io_M_AXI_1_ARBURST),  // output [1:0]
//  // .io_M_AXI_1_ARLOCK  (Top_Out_io_M_AXI_1_ARLOCK),   // output
//  // .io_M_AXI_1_ARCACHE (Top_Out_io_M_AXI_1_ARCACHE),  // output [3:0]
//  // .io_M_AXI_1_ARPROT  (Top_Out_io_M_AXI_1_ARPROT),   // output [2:0]
//  // .io_M_AXI_1_ARQOS   (Top_Out_io_M_AXI_1_ARQOS),    // output [3:0]
//  .io_M_AXI_1_ARVALID (Top_Out_io_M_AXI_1_ARVALID),  // output
//  .io_M_AXI_1_ARREADY (Top_In_io_M_AXI_1_ARREADY),   // input
//  .io_M_AXI_1_WDATA   (Top_Out_io_M_AXI_1_WDATA),    // output [511:0]
//  .io_M_AXI_1_WSTRB   (Top_Out_io_M_AXI_1_WSTRB),    // output [63:0]
//  .io_M_AXI_1_WLAST   (Top_Out_io_M_AXI_1_WLAST),    // output
//  .io_M_AXI_1_WVALID  (Top_Out_io_M_AXI_1_WVALID),   // output
//  .io_M_AXI_1_WREADY  (Top_In_io_M_AXI_1_WREADY),    // input
//  .io_M_AXI_1_RID     (Top_In_io_M_AXI_1_RID),       // input  [15:0]
//  // .io_M_AXI_1_RUSER   (Top_In_io_M_AXI_1_RUSER),     // input  [31:0]
//  .io_M_AXI_1_RDATA   (Top_In_io_M_AXI_1_RDATA),     // input  [511:0]
//  .io_M_AXI_1_RRESP   (Top_In_io_M_AXI_1_RRESP),     // input  [1:0]
//  .io_M_AXI_1_RLAST   (Top_In_io_M_AXI_1_RLAST),     // input
//  .io_M_AXI_1_RVALID  (Top_In_io_M_AXI_1_RVALID),    // input
//  .io_M_AXI_1_RREADY  (Top_Out_io_M_AXI_1_RREADY),   // output
//  .io_M_AXI_1_BID     (Top_In_io_M_AXI_1_BID),       // input  [15:0]
//  // .io_M_AXI_1_BUSER   (Top_In_io_M_AXI_1_BUSER),     // input  [31:0]
//  .io_M_AXI_1_BRESP   (Top_In_io_M_AXI_1_BRESP),     // input  [1:0]
//  .io_M_AXI_1_BVALID  (Top_In_io_M_AXI_1_BVALID),    // input
//  .io_M_AXI_1_BREADY  (Top_Out_io_M_AXI_1_BREADY),    // output
//
//  .io_M_AXI_2_AWID    (Top_Out_io_M_AXI_2_AWID),     // output [15:0]
//  // .io_M_AXI_2_AWUSER  (Top_Out_io_M_AXI_2_AWUSER),   // output [31:0]
//  .io_M_AXI_2_AWADDR  (Top_Out_io_M_AXI_2_AWADDR),   // output [31:0]
//  .io_M_AXI_2_AWLEN   (Top_Out_io_M_AXI_2_AWLEN),    // output [7:0]
//  .io_M_AXI_2_AWSIZE  (Top_Out_io_M_AXI_2_AWSIZE),   // output [2:0]
//  // .io_M_AXI_2_AWBURST (Top_Out_io_M_AXI_2_AWBURST),  // output [1:0]
//  // .io_M_AXI_2_AWLOCK  (Top_Out_io_M_AXI_2_AWLOCK),   // output
//  // .io_M_AXI_2_AWCACHE (Top_Out_io_M_AXI_2_AWCACHE),  // output [3:0]
//  // .io_M_AXI_2_AWPROT  (Top_Out_io_M_AXI_2_AWPROT),   // output [2:0]
//  // .io_M_AXI_2_AWQOS   (Top_Out_io_M_AXI_2_AWQOS),    // output [3:0]
//  .io_M_AXI_2_AWVALID (Top_Out_io_M_AXI_2_AWVALID),  // output
//  .io_M_AXI_2_AWREADY (Top_In_io_M_AXI_2_AWREADY),   // input
//  .io_M_AXI_2_ARID    (Top_Out_io_M_AXI_2_ARID),     // output [15:0]
//  // .io_M_AXI_2_ARUSER  (Top_Out_io_M_AXI_2_ARUSER),   // output [31:0]
//  .io_M_AXI_2_ARADDR  (Top_Out_io_M_AXI_2_ARADDR),   // output [31:0]
//  .io_M_AXI_2_ARLEN   (Top_Out_io_M_AXI_2_ARLEN),    // output [7:0]
//  .io_M_AXI_2_ARSIZE  (Top_Out_io_M_AXI_2_ARSIZE),   // output [2:0]
//  // .io_M_AXI_2_ARBURST (Top_Out_io_M_AXI_2_ARBURST),  // output [1:0]
//  // .io_M_AXI_2_ARLOCK  (Top_Out_io_M_AXI_2_ARLOCK),   // output
//  // .io_M_AXI_2_ARCACHE (Top_Out_io_M_AXI_2_ARCACHE),  // output [3:0]
//  // .io_M_AXI_2_ARPROT  (Top_Out_io_M_AXI_2_ARPROT),   // output [2:0]
//  // .io_M_AXI_2_ARQOS   (Top_Out_io_M_AXI_2_ARQOS),    // output [3:0]
//  .io_M_AXI_2_ARVALID (Top_Out_io_M_AXI_2_ARVALID),  // output
//  .io_M_AXI_2_ARREADY (Top_In_io_M_AXI_2_ARREADY),   // input
//  .io_M_AXI_2_WDATA   (Top_Out_io_M_AXI_2_WDATA),    // output [511:0]
//  .io_M_AXI_2_WSTRB   (Top_Out_io_M_AXI_2_WSTRB),    // output [63:0]
//  .io_M_AXI_2_WLAST   (Top_Out_io_M_AXI_2_WLAST),    // output
//  .io_M_AXI_2_WVALID  (Top_Out_io_M_AXI_2_WVALID),   // output
//  .io_M_AXI_2_WREADY  (Top_In_io_M_AXI_2_WREADY),    // input
//  .io_M_AXI_2_RID     (Top_In_io_M_AXI_2_RID),       // input  [15:0]
//  // .io_M_AXI_2_RUSER   (Top_In_io_M_AXI_2_RUSER),     // input  [31:0]
//  .io_M_AXI_2_RDATA   (Top_In_io_M_AXI_2_RDATA),     // input  [511:0]
//  .io_M_AXI_2_RRESP   (Top_In_io_M_AXI_2_RRESP),     // input  [1:0]
//  .io_M_AXI_2_RLAST   (Top_In_io_M_AXI_2_RLAST),     // input
//  .io_M_AXI_2_RVALID  (Top_In_io_M_AXI_2_RVALID),    // input
//  .io_M_AXI_2_RREADY  (Top_Out_io_M_AXI_2_RREADY),   // output
//  .io_M_AXI_2_BID     (Top_In_io_M_AXI_2_BID),       // input  [15:0]
//  // .io_M_AXI_2_BUSER   (Top_In_io_M_AXI_2_BUSER),     // input  [31:0]
//  .io_M_AXI_2_BRESP   (Top_In_io_M_AXI_2_BRESP),     // input  [1:0]
//  .io_M_AXI_2_BVALID  (Top_In_io_M_AXI_2_BVALID),    // input
//  .io_M_AXI_2_BREADY  (Top_Out_io_M_AXI_2_BREADY),    // output
//
//  .io_M_AXI_3_AWID    (Top_Out_io_M_AXI_3_AWID),     // output [15:0]
//  // .io_M_AXI_3_AWUSER  (Top_Out_io_M_AXI_3_AWUSER),   // output [31:0]
//  .io_M_AXI_3_AWADDR  (Top_Out_io_M_AXI_3_AWADDR),   // output [31:0]
//  .io_M_AXI_3_AWLEN   (Top_Out_io_M_AXI_3_AWLEN),    // output [7:0]
//  .io_M_AXI_3_AWSIZE  (Top_Out_io_M_AXI_3_AWSIZE),   // output [2:0]
//  // .io_M_AXI_3_AWBURST (Top_Out_io_M_AXI_3_AWBURST),  // output [1:0]
//  // .io_M_AXI_3_AWLOCK  (Top_Out_io_M_AXI_3_AWLOCK),   // output
//  // .io_M_AXI_3_AWCACHE (Top_Out_io_M_AXI_3_AWCACHE),  // output [3:0]
//  // .io_M_AXI_3_AWPROT  (Top_Out_io_M_AXI_3_AWPROT),   // output [2:0]
//  // .io_M_AXI_3_AWQOS   (Top_Out_io_M_AXI_3_AWQOS),    // output [3:0]
//  .io_M_AXI_3_AWVALID (Top_Out_io_M_AXI_3_AWVALID),  // output
//  .io_M_AXI_3_AWREADY (Top_In_io_M_AXI_3_AWREADY),   // input
//  .io_M_AXI_3_ARID    (Top_Out_io_M_AXI_3_ARID),     // output [15:0]
//  // .io_M_AXI_3_ARUSER  (Top_Out_io_M_AXI_3_ARUSER),   // output [31:0]
//  .io_M_AXI_3_ARADDR  (Top_Out_io_M_AXI_3_ARADDR),   // output [31:0]
//  .io_M_AXI_3_ARLEN   (Top_Out_io_M_AXI_3_ARLEN),    // output [7:0]
//  .io_M_AXI_3_ARSIZE  (Top_Out_io_M_AXI_3_ARSIZE),   // output [2:0]
//  // .io_M_AXI_3_ARBURST (Top_Out_io_M_AXI_3_ARBURST),  // output [1:0]
//  // .io_M_AXI_3_ARLOCK  (Top_Out_io_M_AXI_3_ARLOCK),   // output
//  // .io_M_AXI_3_ARCACHE (Top_Out_io_M_AXI_3_ARCACHE),  // output [3:0]
//  // .io_M_AXI_3_ARPROT  (Top_Out_io_M_AXI_3_ARPROT),   // output [2:0]
//  // .io_M_AXI_3_ARQOS   (Top_Out_io_M_AXI_3_ARQOS),    // output [3:0]
//  .io_M_AXI_3_ARVALID (Top_Out_io_M_AXI_3_ARVALID),  // output
//  .io_M_AXI_3_ARREADY (Top_In_io_M_AXI_3_ARREADY),   // input
//  .io_M_AXI_3_WDATA   (Top_Out_io_M_AXI_3_WDATA),    // output [511:0]
//  .io_M_AXI_3_WSTRB   (Top_Out_io_M_AXI_3_WSTRB),    // output [63:0]
//  .io_M_AXI_3_WLAST   (Top_Out_io_M_AXI_3_WLAST),    // output
//  .io_M_AXI_3_WVALID  (Top_Out_io_M_AXI_3_WVALID),   // output
//  .io_M_AXI_3_WREADY  (Top_In_io_M_AXI_3_WREADY),    // input
//  .io_M_AXI_3_RID     (Top_In_io_M_AXI_3_RID),       // input  [15:0]
//  // .io_M_AXI_3_RUSER   (Top_In_io_M_AXI_3_RUSER),     // input  [31:0]
//  .io_M_AXI_3_RDATA   (Top_In_io_M_AXI_3_RDATA),     // input  [511:0]
//  .io_M_AXI_3_RRESP   (Top_In_io_M_AXI_3_RRESP),     // input  [1:0]
//  .io_M_AXI_3_RLAST   (Top_In_io_M_AXI_3_RLAST),     // input
//  .io_M_AXI_3_RVALID  (Top_In_io_M_AXI_3_RVALID),    // input
//  .io_M_AXI_3_RREADY  (Top_Out_io_M_AXI_3_RREADY),   // output
//  .io_M_AXI_3_BID     (Top_In_io_M_AXI_3_BID),       // input  [15:0]
//  // .io_M_AXI_3_BUSER   (Top_In_io_M_AXI_3_BUSER),     // input  [31:0]
//  .io_M_AXI_3_BRESP   (Top_In_io_M_AXI_3_BRESP),     // input  [1:0]
//  .io_M_AXI_3_BVALID  (Top_In_io_M_AXI_3_BVALID),    // input
//  .io_M_AXI_3_BREADY  (Top_Out_io_M_AXI_3_BREADY)    // output
);


(* dont_touch = "true" *) logic dma_pcis_slv_sync_rst_n;
axi_register_slice SPATIAL_FRINGE_REGISTER_SLICE (
    .aclk           (clk),
    .aresetn        (dma_pcis_slv_sync_rst_n), // ??
                                                                                                                              
    .m_axi_awid     (Top_Out_io_M_AXI_0_AWID),   
    .m_axi_awaddr   (Top_Out_io_M_AXI_0_AWADDR), 
    .m_axi_awlen    (Top_Out_io_M_AXI_0_AWLEN),  
    .m_axi_awsize   (Top_Out_io_M_AXI_0_AWSIZE),
    .m_axi_awvalid  (Top_Out_io_M_AXI_0_AWVALID),
    .m_axi_awready  (Top_In_io_M_AXI_0_AWREADY),
    .m_axi_wdata    (Top_Out_io_M_AXI_0_WDATA),  
    .m_axi_wstrb    (Top_Out_io_M_AXI_0_WSTRB),  
    .m_axi_wlast    (Top_Out_io_M_AXI_0_WLAST),  
    .m_axi_wvalid   (Top_Out_io_M_AXI_0_WVALID), 
    .m_axi_wready   (Top_In_io_M_AXI_0_WREADY), 
    .m_axi_bid      (Top_In_io_M_AXI_0_BID),    
    .m_axi_bresp    (Top_In_io_M_AXI_0_BRESP),  
    .m_axi_bvalid   (Top_In_io_M_AXI_0_BVALID), 
    .m_axi_bready   (Top_Out_io_M_AXI_0_BREADY), 
    .m_axi_arid     (Top_Out_io_M_AXI_0_ARID),   
    .m_axi_araddr   (Top_Out_io_M_AXI_0_ARADDR), 
    .m_axi_arlen    (Top_Out_io_M_AXI_0_ARLEN),  
    .m_axi_arsize   (Top_Out_io_M_AXI_0_ARSIZE),
    .m_axi_arvalid  (Top_Out_io_M_AXI_0_ARVALID),
    .m_axi_arready  (Top_In_io_M_AXI_0_ARREADY),
    .m_axi_rid      (Top_In_io_M_AXI_0_RID),    
    .m_axi_rdata    (Top_In_io_M_AXI_0_RDATA),  
    .m_axi_rresp    (Top_In_io_M_AXI_0_RRESP),  
    .m_axi_rlast    (Top_In_io_M_AXI_0_RLAST),  
    .m_axi_rvalid   (Top_In_io_M_AXI_0_RVALID), 
    .m_axi_rready   (Top_Out_io_M_AXI_0_RREADY),
    
    .s_axi_awid     (Top_Out_io_M_AXI_0_AWID_q),   
    .s_axi_awaddr   (Top_Out_io_M_AXI_0_AWADDR_q), 
    .s_axi_awlen    (Top_Out_io_M_AXI_0_AWLEN_q),  
    .s_axi_awsize   (Top_Out_io_M_AXI_0_AWSIZE_q),
    .s_axi_awvalid  (Top_Out_io_M_AXI_0_AWVALID_q),
    .s_axi_awready  (Top_In_io_M_AXI_0_AWREADY_q),
    .s_axi_wdata    (Top_Out_io_M_AXI_0_WDATA_q),  
    .s_axi_wstrb    (Top_Out_io_M_AXI_0_WSTRB_q),  
    .s_axi_wlast    (Top_Out_io_M_AXI_0_WLAST_q),  
    .s_axi_wvalid   (Top_Out_io_M_AXI_0_WVALID_q), 
    .s_axi_wready   (Top_In_io_M_AXI_0_WREADY_q), 
    .s_axi_bid      (Top_In_io_M_AXI_0_BID_q),    
    .s_axi_bresp    (Top_In_io_M_AXI_0_BRESP_q),  
    .s_axi_bvalid   (Top_In_io_M_AXI_0_BVALID_q), 
    .s_axi_bready   (Top_Out_io_M_AXI_0_BREADY_q), 
    .s_axi_arid     (Top_Out_io_M_AXI_0_ARID_q),   
    .s_axi_araddr   (Top_Out_io_M_AXI_0_ARADDR_q), 
    .s_axi_arlen    (Top_Out_io_M_AXI_0_ARLEN_q),  
    .s_axi_arsize   (Top_Out_io_M_AXI_0_ARSIZE_q),
    .s_axi_arvalid  (Top_Out_io_M_AXI_0_ARVALID_q),
    .s_axi_arready  (Top_In_io_M_AXI_0_ARREADY_q),
    .s_axi_rid      (Top_In_io_M_AXI_0_RID_q),    
    .s_axi_rdata    (Top_In_io_M_AXI_0_RDATA_q),  
    .s_axi_rresp    (Top_In_io_M_AXI_0_RRESP_q),  
    .s_axi_rlast    (Top_In_io_M_AXI_0_RLAST_q),  
    .s_axi_rvalid   (Top_In_io_M_AXI_0_RVALID_q), 
    .s_axi_rready   (Top_Out_io_M_AXI_0_RREADY_q)
);


logic ddr_commands_from_design;
// TODO: Maybe add another q
always @ (*) begin
  if (~ddr_commands_from_design) begin
    Top_In_io_M_AXI_0_AWREADY  <= 0;
    Top_In_io_M_AXI_0_ARREADY  <= 0;
    Top_In_io_M_AXI_0_WREADY   <= 0;
    Top_In_io_M_AXI_0_RID      <= 0;
    // Top_In_io_M_AXI_0_RUSER    <= 0;
    Top_In_io_M_AXI_0_RDATA    <= 0;
    Top_In_io_M_AXI_0_RRESP    <= 0;
    Top_In_io_M_AXI_0_RLAST    <= 0;
    Top_In_io_M_AXI_0_RVALID   <= 0;
    Top_In_io_M_AXI_0_BID      <= 0;
    // Top_In_io_M_AXI_0_BUSER    <= 0;
    Top_In_io_M_AXI_0_BRESP    <= 0;
    Top_In_io_M_AXI_0_BVALID   <= 0;
//    [4channels]
//    Top_In_io_M_AXI_1_AWREADY  <= 0;
//    Top_In_io_M_AXI_1_ARREADY  <= 0;
//    Top_In_io_M_AXI_1_WREADY   <= 0;
//    Top_In_io_M_AXI_1_RID      <= 0;
//    // Top_In_io_M_AXI_1_RUSER    <= 0;
//    Top_In_io_M_AXI_1_RDATA    <= 0;
//    Top_In_io_M_AXI_1_RRESP    <= 0;
//    Top_In_io_M_AXI_1_RLAST    <= 0;
//    Top_In_io_M_AXI_1_RVALID   <= 0;
//    Top_In_io_M_AXI_1_BID      <= 0;
//    // Top_In_io_M_AXI_1_BUSER    <= 0;
//    Top_In_io_M_AXI_1_BRESP    <= 0;
//    Top_In_io_M_AXI_1_BVALID   <= 0;
//
//
//    Top_In_io_M_AXI_2_AWREADY  <= 0;
//    Top_In_io_M_AXI_2_ARREADY  <= 0;
//    Top_In_io_M_AXI_2_WREADY   <= 0;
//    Top_In_io_M_AXI_2_RID      <= 0;
//    // Top_In_io_M_AXI_2_RUSER    <= 0;
//    Top_In_io_M_AXI_2_RDATA    <= 0;
//    Top_In_io_M_AXI_2_RRESP    <= 0;
//    Top_In_io_M_AXI_2_RLAST    <= 0;
//    Top_In_io_M_AXI_2_RVALID   <= 0;
//    Top_In_io_M_AXI_2_BID      <= 0;
//    // Top_In_io_M_AXI_2_BUSER    <= 0;
//    Top_In_io_M_AXI_2_BRESP    <= 0;
//    Top_In_io_M_AXI_2_BVALID   <= 0;
//
//    Top_In_io_M_AXI_3_AWREADY  <= 0;
//    Top_In_io_M_AXI_3_ARREADY  <= 0;
//    Top_In_io_M_AXI_3_WREADY   <= 0;
//    Top_In_io_M_AXI_3_RID      <= 0;
//    // Top_In_io_M_AXI_3_RUSER    <= 0;
//    Top_In_io_M_AXI_3_RDATA    <= 0;
//    Top_In_io_M_AXI_3_RRESP    <= 0;
//    Top_In_io_M_AXI_3_RLAST    <= 0;
//    Top_In_io_M_AXI_3_RVALID   <= 0;
//    Top_In_io_M_AXI_3_BID      <= 0;
//    // Top_In_io_M_AXI_3_BUSER    <= 0;
//    Top_In_io_M_AXI_3_BRESP    <= 0;
//    Top_In_io_M_AXI_3_BVALID   <= 0;

  end else begin
    Top_In_io_M_AXI_0_AWREADY  <= lcl_cl_sh_ddra.awready;
    Top_In_io_M_AXI_0_ARREADY  <= lcl_cl_sh_ddra.arready;
    Top_In_io_M_AXI_0_WREADY   <= lcl_cl_sh_ddra.wready;
    Top_In_io_M_AXI_0_RID      <= lcl_cl_sh_ddra.rid;
    // Top_In_io_M_AXI_0_RUSER    <= lcl_cl_sh_ddra.ruser;
    Top_In_io_M_AXI_0_RDATA    <= lcl_cl_sh_ddra.rdata;
    Top_In_io_M_AXI_0_RRESP    <= lcl_cl_sh_ddra.rresp;
    Top_In_io_M_AXI_0_RLAST    <= lcl_cl_sh_ddra.rlast;
    Top_In_io_M_AXI_0_RVALID   <= lcl_cl_sh_ddra.rvalid;
    Top_In_io_M_AXI_0_BID      <= lcl_cl_sh_ddra.bid;
    // Top_In_io_M_AXI_0_BUSER    <= lcl_cl_sh_ddra.buser;
    Top_In_io_M_AXI_0_BRESP    <= lcl_cl_sh_ddra.bresp;
    Top_In_io_M_AXI_0_BVALID   <= lcl_cl_sh_ddra.bvalid;
//    [4channels]
//    Top_In_io_M_AXI_1_AWREADY  <= lcl_cl_sh_ddrb.awready;
//    Top_In_io_M_AXI_1_ARREADY  <= lcl_cl_sh_ddrb.arready;
//    Top_In_io_M_AXI_1_WREADY   <= lcl_cl_sh_ddrb.wready;
//    Top_In_io_M_AXI_1_RID      <= lcl_cl_sh_ddrb.rid;
//    // Top_In_io_M_AXI_1_RUSER    <= lcl_cl_sh_ddrb.ruser;
//    Top_In_io_M_AXI_1_RDATA    <= lcl_cl_sh_ddrb.rdata;
//    Top_In_io_M_AXI_1_RRESP    <= lcl_cl_sh_ddrb.rresp;
//    Top_In_io_M_AXI_1_RLAST    <= lcl_cl_sh_ddrb.rlast;
//    Top_In_io_M_AXI_1_RVALID   <= lcl_cl_sh_ddrb.rvalid;
//    Top_In_io_M_AXI_1_BID      <= lcl_cl_sh_ddrb.bid;
//    // Top_In_io_M_AXI_1_BUSER    <= lcl_cl_sh_ddrb.buser;
//    Top_In_io_M_AXI_1_BRESP    <= lcl_cl_sh_ddrb.bresp;
//    Top_In_io_M_AXI_1_BVALID   <= lcl_cl_sh_ddrb.bvalid;
//
//    Top_In_io_M_AXI_2_AWREADY  <= sh_cl_ddr_awready;
//    Top_In_io_M_AXI_2_ARREADY  <= sh_cl_ddr_arready;
//    Top_In_io_M_AXI_2_WREADY   <= sh_cl_ddr_wready;
//    Top_In_io_M_AXI_2_RID      <= sh_cl_ddr_rid;
//    // Top_In_io_M_AXI_2_RUSER    <= sh_cl_ddr_ruser;
//    Top_In_io_M_AXI_2_RDATA    <= sh_cl_ddr_rdata;
//    Top_In_io_M_AXI_2_RRESP    <= sh_cl_ddr_rresp;
//    Top_In_io_M_AXI_2_RLAST    <= sh_cl_ddr_rlast;
//    Top_In_io_M_AXI_2_RVALID   <= sh_cl_ddr_rvalid;
//    Top_In_io_M_AXI_2_BID      <= sh_cl_ddr_bid;
//    // Top_In_io_M_AXI_2_BUSER    <= sh_cl_ddr_buser;
//    Top_In_io_M_AXI_2_BRESP    <= sh_cl_ddr_bresp;
//    Top_In_io_M_AXI_2_BVALID   <= sh_cl_ddr_bvalid;
//
//    Top_In_io_M_AXI_3_AWREADY  <= lcl_cl_sh_ddrd.awready;
//    Top_In_io_M_AXI_3_ARREADY  <= lcl_cl_sh_ddrd.arready;
//    Top_In_io_M_AXI_3_WREADY   <= lcl_cl_sh_ddrd.wready;
//    Top_In_io_M_AXI_3_RID      <= lcl_cl_sh_ddrd.rid;
//    // Top_In_io_M_AXI_3_RUSER    <= lcl_cl_sh_ddrd.ruser;
//    Top_In_io_M_AXI_3_RDATA    <= lcl_cl_sh_ddrd.rdata;
//    Top_In_io_M_AXI_3_RRESP    <= lcl_cl_sh_ddrd.rresp;
//    Top_In_io_M_AXI_3_RLAST    <= lcl_cl_sh_ddrd.rlast;
//    Top_In_io_M_AXI_3_RVALID   <= lcl_cl_sh_ddrd.rvalid;
//    Top_In_io_M_AXI_3_BID      <= lcl_cl_sh_ddrd.bid;
//    // Top_In_io_M_AXI_3_BUSER    <= lcl_cl_sh_ddrd.buser;
//    Top_In_io_M_AXI_3_BRESP    <= lcl_cl_sh_ddrd.bresp;
//    Top_In_io_M_AXI_3_BVALID   <= lcl_cl_sh_ddrd.bvalid;
  end
end

always_ff @(posedge clk) begin
  if (Top_Out_io_M_AXI_0_AWVALID && Top_In_io_M_AXI_0_AWREADY) begin
    $display("[%t] [Ch0] Store with ID %d of length %d to   0x%x", $realtime, Top_Out_io_M_AXI_0_AWID, Top_Out_io_M_AXI_0_AWLEN, Top_Out_io_M_AXI_0_AWADDR);
  end
  if (Top_Out_io_M_AXI_0_ARVALID && Top_In_io_M_AXI_0_ARREADY) begin
    $display("[%t] [Ch 0] Load  with ID %d of length %d from 0x%x", $realtime, Top_Out_io_M_AXI_0_ARID, Top_Out_io_M_AXI_0_ARLEN, Top_Out_io_M_AXI_0_ARADDR);
  end
// [4channels]
//  if (Top_Out_io_M_AXI_1_AWVALID && Top_In_io_M_AXI_1_AWREADY) begin
//    $display("[%t] [Ch 1] Store with ID %d of length %d to   0x%x", $realtime, Top_Out_io_M_AXI_1_AWID, Top_Out_io_M_AXI_1_AWLEN, Top_Out_io_M_AXI_1_AWADDR);
//  end
//  if (Top_Out_io_M_AXI_1_ARVALID && Top_In_io_M_AXI_1_ARREADY) begin
//    $display("[%t] [Ch 1] Load  with ID %d of length %d from 0x%x", $realtime, Top_Out_io_M_AXI_1_ARID, Top_Out_io_M_AXI_1_ARLEN, Top_Out_io_M_AXI_1_ARADDR);
//  end
//  if (Top_Out_io_M_AXI_2_AWVALID && Top_In_io_M_AXI_2_AWREADY) begin
//    $display("[%t] [Ch 2] Store with ID %d of length %d to   0x%x", $realtime, Top_Out_io_M_AXI_2_AWID, Top_Out_io_M_AXI_2_AWLEN, Top_Out_io_M_AXI_2_AWADDR);
//  end
//  if (Top_Out_io_M_AXI_2_ARVALID && Top_In_io_M_AXI_2_ARREADY) begin
//    $display("[%t] [Ch 2] Load  with ID %d of length %d from 0x%x", $realtime, Top_Out_io_M_AXI_2_ARID, Top_Out_io_M_AXI_2_ARLEN, Top_Out_io_M_AXI_2_ARADDR);
//  end
//  if (Top_Out_io_M_AXI_3_AWVALID && Top_In_io_M_AXI_3_AWREADY) begin
//    $display("[%t] [Ch 3] Store with ID %d of length %d to   0x%x", $realtime, Top_Out_io_M_AXI_3_AWID, Top_Out_io_M_AXI_3_AWLEN, Top_Out_io_M_AXI_3_AWADDR);
//  end
//  if (Top_Out_io_M_AXI_3_ARVALID && Top_In_io_M_AXI_3_ARREADY) begin
//    $display("[%t] [Ch 3] Load  with ID %d of length %d from 0x%x", $realtime, Top_Out_io_M_AXI_3_ARID, Top_Out_io_M_AXI_3_ARLEN, Top_Out_io_M_AXI_3_ARADDR);
//  end
end

// State machine to set a bit high during duration of design execution
logic [2:0] design_state; // S0 = initializing DDR, S1 = running, S2 = done
always_ff @(posedge clk or negedge sync_rst_n) begin
  if (!sync_rst_n | SCALAR_reset[0])
    design_state <= 0;
  else begin
    if (design_state === 0) begin
      if (SCALAR_en[0]) begin
        design_state <= 1;
      end else begin
        design_state <= 0;
      end
    end else if (design_state === 1) begin
      if (SCALAR_done[0]) begin
        design_state <= 2;
      end else begin
        design_state <= 1;
      end
    end else begin
      design_state <= 2;
    end
  end
end
assign ddr_commands_from_design = (design_state === 1);


// Perf Counter
// TODO: Can do this with less area (have 1 counter and print when state changes)
logic [31:0] performance_counter;
logic [31:0] performance_counter_0;
logic [31:0] performance_counter_1;
logic [31:0] performance_counter_2;
always_ff @(posedge clk or negedge sync_rst_n) begin
  if (!sync_rst_n | SCALAR_reset[0]) begin
    performance_counter <= 0;
    performance_counter_0 <= 0;
    performance_counter_1 <= 0;
    performance_counter_2 <= 0;
  end else begin
    performance_counter <= performance_counter + 1;
    if (design_state === 0) begin
      performance_counter_0 <= performance_counter_0 + 1;
    end else if (design_state === 1) begin
      performance_counter_1 <= performance_counter_1 + 1;
    end else if (design_state === 2) begin
      performance_counter_2 <= performance_counter_2 + 1;
    end
  end
end
always_ff @(posedge SCALAR_done[0]) begin
  $display("App done, # cycles total = %d", performance_counter);
  $display("          # cycles init  = %d", performance_counter_0);
  $display("          # cycles run   = %d", performance_counter_1);
  $display("          # cycles done  = %d", performance_counter_2);
end

// // Status prints
// always_ff @(posedge clk) begin
//   if (performance_counter % 100 == 0) begin
//     $display("[%t] %d cycles", $realtime, performance_counter);
//   end
// end

//------------------------------------
// END Instantiate Top
//------------------------------------

///////////////////////////////////////////////////////////////////////
///////////////// DMA PCIS SLAVE module ///////////////////////////////
///////////////////////////////////////////////////////////////////////

assign sh_cl_dma_pcis_bus.awvalid = sh_cl_dma_pcis_awvalid;
assign sh_cl_dma_pcis_bus.awaddr = sh_cl_dma_pcis_awaddr;
assign sh_cl_dma_pcis_bus.awid[5:0] = sh_cl_dma_pcis_awid;
assign sh_cl_dma_pcis_bus.awlen = sh_cl_dma_pcis_awlen;
assign sh_cl_dma_pcis_bus.awsize = sh_cl_dma_pcis_awsize;
assign cl_sh_dma_pcis_awready = sh_cl_dma_pcis_bus.awready;
assign sh_cl_dma_pcis_bus.wvalid = sh_cl_dma_pcis_wvalid;
assign sh_cl_dma_pcis_bus.wdata = sh_cl_dma_pcis_wdata;
assign sh_cl_dma_pcis_bus.wstrb = sh_cl_dma_pcis_wstrb;
assign sh_cl_dma_pcis_bus.wlast = sh_cl_dma_pcis_wlast;
assign cl_sh_dma_pcis_wready = sh_cl_dma_pcis_bus.wready;
assign cl_sh_dma_pcis_bvalid = sh_cl_dma_pcis_bus.bvalid;
assign cl_sh_dma_pcis_bresp = sh_cl_dma_pcis_bus.bresp;
assign sh_cl_dma_pcis_bus.bready = sh_cl_dma_pcis_bready;
assign cl_sh_dma_pcis_bid = sh_cl_dma_pcis_bus.bid[5:0];
assign sh_cl_dma_pcis_bus.arvalid = sh_cl_dma_pcis_arvalid;
assign sh_cl_dma_pcis_bus.araddr = sh_cl_dma_pcis_araddr;
assign sh_cl_dma_pcis_bus.arid[5:0] = sh_cl_dma_pcis_arid;
assign sh_cl_dma_pcis_bus.arlen = sh_cl_dma_pcis_arlen;
assign sh_cl_dma_pcis_bus.arsize = sh_cl_dma_pcis_arsize;
assign cl_sh_dma_pcis_arready = sh_cl_dma_pcis_bus.arready;
assign cl_sh_dma_pcis_rvalid = sh_cl_dma_pcis_bus.rvalid;
assign cl_sh_dma_pcis_rid = sh_cl_dma_pcis_bus.rid[5:0];
assign cl_sh_dma_pcis_rlast = sh_cl_dma_pcis_bus.rlast;
assign cl_sh_dma_pcis_rresp = sh_cl_dma_pcis_bus.rresp;
assign cl_sh_dma_pcis_rdata = sh_cl_dma_pcis_bus.rdata;
assign sh_cl_dma_pcis_bus.rready = sh_cl_dma_pcis_rready;

// DDR-C channel
// [4channels]
//assign cl_sh_ddr_awid = ddr_commands_from_design ? Top_Out_io_M_AXI_2_AWID : cl_sh_ddr_bus.awid;
//assign cl_sh_ddr_awaddr = ddr_commands_from_design ? Top_Out_io_M_AXI_2_AWADDR : cl_sh_ddr_bus.awaddr;
//assign cl_sh_ddr_awlen = ddr_commands_from_design ? Top_Out_io_M_AXI_2_AWLEN : cl_sh_ddr_bus.awlen;
//assign cl_sh_ddr_awsize = ddr_commands_from_design ? Top_Out_io_M_AXI_2_AWSIZE : cl_sh_ddr_bus.awsize;
//assign cl_sh_ddr_awvalid =  ddr_commands_from_design ? Top_Out_io_M_AXI_2_AWVALID : cl_sh_ddr_bus.awvalid;
//assign cl_sh_ddr_bus.awready = sh_cl_ddr_awready;
//assign cl_sh_ddr_wid =  16'b0;
//assign cl_sh_ddr_wdata = ddr_commands_from_design ? Top_Out_io_M_AXI_2_WDATA : cl_sh_ddr_bus.wdata;
//assign cl_sh_ddr_wstrb = ddr_commands_from_design ? Top_Out_io_M_AXI_2_WSTRB : cl_sh_ddr_bus.wstrb;
//assign cl_sh_ddr_wlast = ddr_commands_from_design ? Top_Out_io_M_AXI_2_WLAST : cl_sh_ddr_bus.wlast;
//assign cl_sh_ddr_wvalid = ddr_commands_from_design ? Top_Out_io_M_AXI_2_WVALID : cl_sh_ddr_bus.wvalid;
//assign cl_sh_ddr_bus.wready = sh_cl_ddr_wready;
//assign cl_sh_ddr_bus.bid = sh_cl_ddr_bid;
//assign cl_sh_ddr_bus.bresp = sh_cl_ddr_bresp;
//assign cl_sh_ddr_bus.bvalid = sh_cl_ddr_bvalid;
//assign cl_sh_ddr_bready = ddr_commands_from_design ? Top_Out_io_M_AXI_2_BREADY : cl_sh_ddr_bus.bready;
//assign cl_sh_ddr_arid = ddr_commands_from_design ? Top_Out_io_M_AXI_2_ARID : cl_sh_ddr_bus.arid;
//assign cl_sh_ddr_araddr = ddr_commands_from_design ? Top_Out_io_M_AXI_2_ARADDR : cl_sh_ddr_bus.araddr;
//assign cl_sh_ddr_arlen = ddr_commands_from_design ? Top_Out_io_M_AXI_2_ARLEN : cl_sh_ddr_bus.arlen;
//assign cl_sh_ddr_arsize = ddr_commands_from_design ? Top_Out_io_M_AXI_2_ARSIZE : cl_sh_ddr_bus.arsize;
//assign cl_sh_ddr_arvalid = ddr_commands_from_design ? Top_Out_io_M_AXI_2_ARVALID : cl_sh_ddr_bus.arvalid;
//assign cl_sh_ddr_bus.arready = sh_cl_ddr_arready;
//assign cl_sh_ddr_bus.rid = sh_cl_ddr_rid;
//assign cl_sh_ddr_bus.rresp = sh_cl_ddr_rresp;
//assign cl_sh_ddr_bus.rvalid = sh_cl_ddr_rvalid;
//assign cl_sh_ddr_bus.rdata = sh_cl_ddr_rdata;
//assign cl_sh_ddr_bus.rlast = sh_cl_ddr_rlast;
//assign cl_sh_ddr_rready = ddr_commands_from_design ? Top_Out_io_M_AXI_2_RREADY : cl_sh_ddr_bus.rready;
assign cl_sh_ddr_awid     = cl_sh_ddr_bus.awid;
assign cl_sh_ddr_awaddr   = cl_sh_ddr_bus.awaddr;
assign cl_sh_ddr_awlen    = cl_sh_ddr_bus.awlen;
assign cl_sh_ddr_awsize   = cl_sh_ddr_bus.awsize;
assign cl_sh_ddr_awvalid  = cl_sh_ddr_bus.awvalid;
assign cl_sh_ddr_bus.awready = sh_cl_ddr_awready;
assign cl_sh_ddr_wid      =  16'b0;
assign cl_sh_ddr_wdata    = cl_sh_ddr_bus.wdata;
assign cl_sh_ddr_wstrb    = cl_sh_ddr_bus.wstrb;
assign cl_sh_ddr_wlast    = cl_sh_ddr_bus.wlast;
assign cl_sh_ddr_wvalid   = cl_sh_ddr_bus.wvalid;
assign cl_sh_ddr_bus.wready = sh_cl_ddr_wready;
assign cl_sh_ddr_bus.bid = sh_cl_ddr_bid;
assign cl_sh_ddr_bus.bresp = sh_cl_ddr_bresp;
assign cl_sh_ddr_bus.bvalid = sh_cl_ddr_bvalid;
assign cl_sh_ddr_bready   = cl_sh_ddr_bus.bready;
assign cl_sh_ddr_arid     = cl_sh_ddr_bus.arid;
assign cl_sh_ddr_araddr   = cl_sh_ddr_bus.araddr;
assign cl_sh_ddr_arlen    = cl_sh_ddr_bus.arlen;
assign cl_sh_ddr_arsize   = cl_sh_ddr_bus.arsize;
assign cl_sh_ddr_arvalid  = cl_sh_ddr_bus.arvalid;
assign cl_sh_ddr_bus.arready = sh_cl_ddr_arready;
assign cl_sh_ddr_bus.rid = sh_cl_ddr_rid;
assign cl_sh_ddr_bus.rresp = sh_cl_ddr_rresp;
assign cl_sh_ddr_bus.rvalid = sh_cl_ddr_rvalid;
assign cl_sh_ddr_bus.rdata = sh_cl_ddr_rdata;
assign cl_sh_ddr_bus.rlast = sh_cl_ddr_rlast;
assign cl_sh_ddr_rready = cl_sh_ddr_bus.rready;



lib_pipe #(.WIDTH(1), .STAGES(4)) DMA_PCIS_SLV_SLC_RST_N (.clk(clk), .rst_n(1'b1), .in_bus(sync_rst_n), .out_bus(dma_pcis_slv_sync_rst_n));
cl_dma_pcis_slv #(.SCRB_BURST_LEN_MINUS1(DDR_SCRB_BURST_LEN_MINUS1),
                    .SCRB_MAX_ADDR(DDR_SCRB_MAX_ADDR),
                    .NO_SCRB_INST(NO_SCRB_INST)) CL_DMA_PCIS_SLV (
    .aclk(clk),
    .aresetn(dma_pcis_slv_sync_rst_n),

    .ddra_tst_cfg_bus(ddra_tst_cfg_bus),
    .ddrb_tst_cfg_bus(ddrb_tst_cfg_bus),
    .ddrc_tst_cfg_bus(ddrc_tst_cfg_bus),
    .ddrd_tst_cfg_bus(ddrd_tst_cfg_bus),

    .ddra_scrb_bus(ddra_scrb_bus),
    .ddrb_scrb_bus(ddrb_scrb_bus),
    .ddrc_scrb_bus(ddrc_scrb_bus),
    .ddrd_scrb_bus(ddrd_scrb_bus),

    .sh_cl_dma_pcis_bus(sh_cl_dma_pcis_bus),
    .cl_axi_mstr_bus(cl_axi_mstr_bus),

    .lcl_cl_sh_ddra(lcl_cl_sh_ddra),
    .lcl_cl_sh_ddrb(lcl_cl_sh_ddrb),
    .lcl_cl_sh_ddrd(lcl_cl_sh_ddrd),

    .sh_cl_dma_pcis_q(sh_cl_dma_pcis_q),

    .cl_sh_ddr_bus     (cl_sh_ddr_bus)
  );

///////////////////////////////////////////////////////////////////////
///////////////// DMA PCIS SLAVE module ///////////////////////////////
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
///////////////// Secondary AXI Master module /////////////////////////
///////////////////////////////////////////////////////////////////////
cl_dram_dma_axi_mstr  CL_DRAM_DMA_AXI_MSTR (
    .aclk(clk),
    .aresetn(dma_pcis_slv_sync_rst_n),
    .cl_axi_mstr_bus(cl_axi_mstr_bus),
    .axi_mstr_cfg_bus(axi_mstr_cfg_bus)
  );

///////////////////////////////////////////////////////////////////////
///////////////// Secondary AXI Master module /////////////////////////
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
///////////////// PCIM MSTR module ////////////////////////////////////
///////////////////////////////////////////////////////////////////////

assign cl_sh_pcim_awid = cl_sh_pcim_bus.awid;
assign cl_sh_pcim_awaddr = cl_sh_pcim_bus.awaddr;
assign cl_sh_pcim_awlen = cl_sh_pcim_bus.awlen;
assign cl_sh_pcim_awvalid = cl_sh_pcim_bus.awvalid;
assign cl_sh_pcim_awsize = cl_sh_pcim_bus.awsize;
assign cl_sh_pcim_bus.awready = sh_cl_pcim_awready;
assign cl_sh_pcim_wdata = cl_sh_pcim_bus.wdata;
assign cl_sh_pcim_wstrb = cl_sh_pcim_bus.wstrb;
assign cl_sh_pcim_wlast = cl_sh_pcim_bus.wlast;
assign cl_sh_pcim_wvalid = cl_sh_pcim_bus.wvalid;
assign cl_sh_pcim_bus.wready = sh_cl_pcim_wready;
assign cl_sh_pcim_bus.bid = sh_cl_pcim_bid;
assign cl_sh_pcim_bus.bresp = sh_cl_pcim_bresp;
assign cl_sh_pcim_bus.bvalid = sh_cl_pcim_bvalid;
assign cl_sh_pcim_bready = cl_sh_pcim_bus.bready;
assign cl_sh_pcim_arid = cl_sh_pcim_bus.arid;
assign cl_sh_pcim_araddr = cl_sh_pcim_bus.araddr;
assign cl_sh_pcim_arlen = cl_sh_pcim_bus.arlen;
assign cl_sh_pcim_arvalid = cl_sh_pcim_bus.arvalid;
assign cl_sh_pcim_bus.arready = sh_cl_pcim_arready;
assign cl_sh_pcim_arsize = cl_sh_pcim_bus.arsize;
assign cl_sh_pcim_bus.rid = sh_cl_pcim_rid;
assign cl_sh_pcim_bus.rresp = sh_cl_pcim_rresp;
assign cl_sh_pcim_bus.rvalid = sh_cl_pcim_rvalid;
assign cl_sh_pcim_bus.rdata = sh_cl_pcim_rdata;
assign cl_sh_pcim_bus.rlast = sh_cl_pcim_rlast;
assign cl_sh_pcim_rready = cl_sh_pcim_bus.rready;

// note: cl_sh_pcim_aruser/awuser are ignored by the shell
// and the axi4 size is set fixed for 64-bytes
//  cl_sh_pcim_arsize/awsize = 3'b6;

(* dont_touch = "true" *) logic pcim_mstr_sync_rst_n;
lib_pipe #(.WIDTH(1), .STAGES(4)) PCIM_MSTR_SLC_RST_N (.clk(clk), .rst_n(1'b1), .in_bus(sync_rst_n), .out_bus(pcim_mstr_sync_rst_n));
cl_pcim_mstr CL_PCIM_MSTR (

     .aclk(clk),
     .aresetn(pcim_mstr_sync_rst_n),

     .cfg_bus(pcim_tst_cfg_bus),

     .cl_sh_pcim_bus     (cl_sh_pcim_bus)
);

///////////////////////////////////////////////////////////////////////
///////////////// OCL SLAVE module ////////////////////////////////////
///////////////////////////////////////////////////////////////////////

assign sh_ocl_bus.awvalid = sh_ocl_awvalid;
assign sh_ocl_bus.awaddr[31:0] = sh_ocl_awaddr;
assign ocl_sh_awready = sh_ocl_bus.awready;
assign sh_ocl_bus.wvalid = sh_ocl_wvalid;
assign sh_ocl_bus.wdata[31:0] = sh_ocl_wdata;
assign sh_ocl_bus.wstrb[3:0] = sh_ocl_wstrb;
assign ocl_sh_wready = sh_ocl_bus.wready;
assign ocl_sh_bvalid = sh_ocl_bus.bvalid;
assign ocl_sh_bresp = sh_ocl_bus.bresp;
assign sh_ocl_bus.bready = sh_ocl_bready;
assign sh_ocl_bus.arvalid = sh_ocl_arvalid;
assign sh_ocl_bus.araddr[31:0] = sh_ocl_araddr;
assign ocl_sh_arready = sh_ocl_bus.arready;
assign ocl_sh_rvalid = sh_ocl_bus.rvalid;
assign ocl_sh_rresp = sh_ocl_bus.rresp;
assign ocl_sh_rdata = sh_ocl_bus.rdata[31:0];
assign sh_ocl_bus.rready = sh_ocl_rready;

(* dont_touch = "true" *) logic ocl_slv_sync_rst_n;
lib_pipe #(.WIDTH(1), .STAGES(4)) OCL_SLV_SLC_RST_N (.clk(clk), .rst_n(1'b1), .in_bus(sync_rst_n), .out_bus(ocl_slv_sync_rst_n));
cl_ocl_slv CL_OCL_SLV (

   .clk(clk),
   //.sync_rst_n( !(!ocl_slv_sync_rst_n | SCALAR_reset[0]) ),
   .sync_rst_n(ocl_slv_sync_rst_n),

   .sh_cl_flr_assert_q(sh_cl_flr_assert_q),

   .sh_ocl_bus  (sh_ocl_bus),

   .pcim_tst_cfg_bus(pcim_tst_cfg_bus),
   .ddra_tst_cfg_bus(ddra_tst_cfg_bus),
   .ddrb_tst_cfg_bus(ddrb_tst_cfg_bus),
   .ddrc_tst_cfg_bus(ddrc_tst_cfg_bus),
   .ddrd_tst_cfg_bus(ddrd_tst_cfg_bus),
   .axi_mstr_cfg_bus(axi_mstr_cfg_bus),
   .int_tst_cfg_bus(int_tst_cfg_bus),

   .SCALAR_argIn__0(SCALAR_argIn__0),
   .SCALAR_argIn__1(SCALAR_argIn__1),
   .SCALAR_argIn__2(SCALAR_argIn__2),
   .SCALAR_argIn__3(SCALAR_argIn__3),
   .SCALAR_argIn__4(SCALAR_argIn__4),
   .SCALAR_argIn__5(SCALAR_argIn__5),
   .SCALAR_argIn__6(SCALAR_argIn__6),
   .SCALAR_argIn__7(SCALAR_argIn__7),
   .SCALAR_argIn__8(SCALAR_argIn__8),
   .SCALAR_argIn__9(SCALAR_argIn__9),
   .SCALAR_argIn__10(SCALAR_argIn__10),
   .SCALAR_argOut__0(SCALAR_argOut__0),
   .SCALAR_en(SCALAR_en),
   .SCALAR_reset(SCALAR_reset),
   .SCALAR_done(SCALAR_done),
   // .all_ddr_is_ready(all_ddr_is_ready),
   .performance_counter_1(performance_counter_1)

);

///////////////////////////////////////////////////////////////////////
///////////////// OCL SLAVE module ////////////////////////////////////
///////////////////////////////////////////////////////////////////////

//-----------------------------------------
// DDR controller instantiation
//-----------------------------------------
logic [7:0] sh_ddr_stat_addr_q[2:0];
logic[2:0] sh_ddr_stat_wr_q;
logic[2:0] sh_ddr_stat_rd_q;
logic[31:0] sh_ddr_stat_wdata_q[2:0];
logic[2:0] ddr_sh_stat_ack_q;
logic[31:0] ddr_sh_stat_rdata_q[2:0];
logic[7:0] ddr_sh_stat_int_q[2:0];


lib_pipe #(.WIDTH(1+1+8+32), .STAGES(NUM_CFG_STGS_CL_DDR_ATG)) PIPE_DDR_STAT0 (.clk(clk), .rst_n(sync_rst_n),
                                               .in_bus({sh_ddr_stat_wr0, sh_ddr_stat_rd0, sh_ddr_stat_addr0, sh_ddr_stat_wdata0}),
                                               .out_bus({sh_ddr_stat_wr_q[0], sh_ddr_stat_rd_q[0], sh_ddr_stat_addr_q[0], sh_ddr_stat_wdata_q[0]})
                                               );


lib_pipe #(.WIDTH(1+8+32), .STAGES(NUM_CFG_STGS_CL_DDR_ATG)) PIPE_DDR_STAT_ACK0 (.clk(clk), .rst_n(sync_rst_n),
                                               .in_bus({ddr_sh_stat_ack_q[0], ddr_sh_stat_int_q[0], ddr_sh_stat_rdata_q[0]}),
                                               .out_bus({ddr_sh_stat_ack0, ddr_sh_stat_int0, ddr_sh_stat_rdata0})
                                               );


lib_pipe #(.WIDTH(1+1+8+32), .STAGES(NUM_CFG_STGS_CL_DDR_ATG)) PIPE_DDR_STAT1 (.clk(clk), .rst_n(sync_rst_n),
                                               .in_bus({sh_ddr_stat_wr1, sh_ddr_stat_rd1, sh_ddr_stat_addr1, sh_ddr_stat_wdata1}),
                                               .out_bus({sh_ddr_stat_wr_q[1], sh_ddr_stat_rd_q[1], sh_ddr_stat_addr_q[1], sh_ddr_stat_wdata_q[1]})
                                               );


lib_pipe #(.WIDTH(1+8+32), .STAGES(NUM_CFG_STGS_CL_DDR_ATG)) PIPE_DDR_STAT_ACK1 (.clk(clk), .rst_n(sync_rst_n),
                                               .in_bus({ddr_sh_stat_ack_q[1], ddr_sh_stat_int_q[1], ddr_sh_stat_rdata_q[1]}),
                                               .out_bus({ddr_sh_stat_ack1, ddr_sh_stat_int1, ddr_sh_stat_rdata1})
                                               );

lib_pipe #(.WIDTH(1+1+8+32), .STAGES(NUM_CFG_STGS_CL_DDR_ATG)) PIPE_DDR_STAT2 (.clk(clk), .rst_n(sync_rst_n),
                                               .in_bus({sh_ddr_stat_wr2, sh_ddr_stat_rd2, sh_ddr_stat_addr2, sh_ddr_stat_wdata2}),
                                               .out_bus({sh_ddr_stat_wr_q[2], sh_ddr_stat_rd_q[2], sh_ddr_stat_addr_q[2], sh_ddr_stat_wdata_q[2]})
                                               );


lib_pipe #(.WIDTH(1+8+32), .STAGES(NUM_CFG_STGS_CL_DDR_ATG)) PIPE_DDR_STAT_ACK2 (.clk(clk), .rst_n(sync_rst_n),
                                               .in_bus({ddr_sh_stat_ack_q[2], ddr_sh_stat_int_q[2], ddr_sh_stat_rdata_q[2]}),
                                               .out_bus({ddr_sh_stat_ack2, ddr_sh_stat_int2, ddr_sh_stat_rdata2})
                                               );

//convert to 2D
logic[15:0] cl_sh_ddr_awid_2d[2:0];
logic[63:0] cl_sh_ddr_awaddr_2d[2:0];
logic[7:0] cl_sh_ddr_awlen_2d[2:0];
logic[2:0] cl_sh_ddr_awsize_2d[2:0];
logic[1:0] cl_sh_ddr_awburst_2d[2:0];
logic cl_sh_ddr_awvalid_2d [2:0];
logic[2:0] sh_cl_ddr_awready_2d;

logic[15:0] cl_sh_ddr_wid_2d[2:0];
logic[511:0] cl_sh_ddr_wdata_2d[2:0];
logic[63:0] cl_sh_ddr_wstrb_2d[2:0];
logic[2:0] cl_sh_ddr_wlast_2d;
logic[2:0] cl_sh_ddr_wvalid_2d;
logic[2:0] sh_cl_ddr_wready_2d;

logic[15:0] sh_cl_ddr_bid_2d[2:0];
logic[1:0] sh_cl_ddr_bresp_2d[2:0];
logic[2:0] sh_cl_ddr_bvalid_2d;
logic[2:0] cl_sh_ddr_bready_2d;

logic[15:0] cl_sh_ddr_arid_2d[2:0];
logic[63:0] cl_sh_ddr_araddr_2d[2:0];
logic[7:0] cl_sh_ddr_arlen_2d[2:0];
logic[2:0] cl_sh_ddr_arsize_2d[2:0];
logic[1:0] cl_sh_ddr_arburst_2d[2:0];
logic[2:0] cl_sh_ddr_arvalid_2d;
logic[2:0] sh_cl_ddr_arready_2d;

logic[15:0] sh_cl_ddr_rid_2d[2:0];
logic[511:0] sh_cl_ddr_rdata_2d[2:0];
logic[1:0] sh_cl_ddr_rresp_2d[2:0];
logic[2:0] sh_cl_ddr_rlast_2d;
logic[2:0] sh_cl_ddr_rvalid_2d;
logic[2:0] cl_sh_ddr_rready_2d;

// [4channels]
//assign cl_sh_ddr_awid_2d = '{ddr_commands_from_design ? Top_Out_io_M_AXI_3_AWID : lcl_cl_sh_ddrd.awid, ddr_commands_from_design ? Top_Out_io_M_AXI_1_AWID : lcl_cl_sh_ddrb.awid, ddr_commands_from_design ? Top_Out_io_M_AXI_0_AWID : lcl_cl_sh_ddra.awid};
//assign cl_sh_ddr_awaddr_2d = '{ddr_commands_from_design ? Top_Out_io_M_AXI_3_AWADDR : lcl_cl_sh_ddrd.awaddr, ddr_commands_from_design ? Top_Out_io_M_AXI_1_AWADDR : lcl_cl_sh_ddrb.awaddr, ddr_commands_from_design ? Top_Out_io_M_AXI_0_AWADDR : lcl_cl_sh_ddra.awaddr};
//assign cl_sh_ddr_awlen_2d = '{ddr_commands_from_design ? Top_Out_io_M_AXI_3_AWLEN : lcl_cl_sh_ddrd.awlen, ddr_commands_from_design ? Top_Out_io_M_AXI_1_AWLEN : lcl_cl_sh_ddrb.awlen, ddr_commands_from_design ? Top_Out_io_M_AXI_0_AWLEN : lcl_cl_sh_ddra.awlen};
//assign cl_sh_ddr_awsize_2d = '{ddr_commands_from_design ? Top_Out_io_M_AXI_3_AWSIZE :  lcl_cl_sh_ddrd.awsize, ddr_commands_from_design ? Top_Out_io_M_AXI_1_AWSIZE : lcl_cl_sh_ddrb.awsize, ddr_commands_from_design ? Top_Out_io_M_AXI_0_AWSIZE : lcl_cl_sh_ddra.awsize};
//assign cl_sh_ddr_awvalid_2d = '{ddr_commands_from_design ? Top_Out_io_M_AXI_3_AWVALID :  lcl_cl_sh_ddrd.awvalid, ddr_commands_from_design ? Top_Out_io_M_AXI_1_AWVALID : lcl_cl_sh_ddrb.awvalid, ddr_commands_from_design ? Top_Out_io_M_AXI_0_AWVALID : lcl_cl_sh_ddra.awvalid};
assign cl_sh_ddr_awid_2d =    '{lcl_cl_sh_ddrd.awid,    lcl_cl_sh_ddrb.awid,    ddr_commands_from_design ? Top_Out_io_M_AXI_0_AWID : lcl_cl_sh_ddra.awid};
assign cl_sh_ddr_awaddr_2d =  '{lcl_cl_sh_ddrd.awaddr,  lcl_cl_sh_ddrb.awaddr,  ddr_commands_from_design ? Top_Out_io_M_AXI_0_AWADDR : lcl_cl_sh_ddra.awaddr};
assign cl_sh_ddr_awlen_2d =   '{lcl_cl_sh_ddrd.awlen,   lcl_cl_sh_ddrb.awlen,   ddr_commands_from_design ? Top_Out_io_M_AXI_0_AWLEN : lcl_cl_sh_ddra.awlen};
assign cl_sh_ddr_awsize_2d =  '{lcl_cl_sh_ddrd.awsize,  lcl_cl_sh_ddrb.awsize,  ddr_commands_from_design ? Top_Out_io_M_AXI_0_AWSIZE : lcl_cl_sh_ddra.awsize};
assign cl_sh_ddr_awvalid_2d = '{lcl_cl_sh_ddrd.awvalid, lcl_cl_sh_ddrb.awvalid, ddr_commands_from_design ? Top_Out_io_M_AXI_0_AWVALID : lcl_cl_sh_ddra.awvalid};

assign cl_sh_ddr_awburst_2d = {2'b01, 2'b01, 2'b01};
assign {lcl_cl_sh_ddrd.awready, lcl_cl_sh_ddrb.awready, lcl_cl_sh_ddra.awready} = sh_cl_ddr_awready_2d;

// [4channels]
//assign cl_sh_ddr_wid_2d = '{ddr_commands_from_design ? 0 : lcl_cl_sh_ddrd.wid, ddr_commands_from_design ? 0 : lcl_cl_sh_ddrb.wid, ddr_commands_from_design ? 0 : lcl_cl_sh_ddra.wid};
//assign cl_sh_ddr_wdata_2d = '{ddr_commands_from_design ? Top_Out_io_M_AXI_3_WDATA : lcl_cl_sh_ddrd.wdata, ddr_commands_from_design ? Top_Out_io_M_AXI_1_WDATA : lcl_cl_sh_ddrb.wdata, ddr_commands_from_design ? Top_Out_io_M_AXI_0_WDATA : lcl_cl_sh_ddra.wdata};
//assign cl_sh_ddr_wstrb_2d = '{ddr_commands_from_design ? Top_Out_io_M_AXI_3_WSTRB : lcl_cl_sh_ddrd.wstrb, ddr_commands_from_design ? Top_Out_io_M_AXI_1_WSTRB :  lcl_cl_sh_ddrb.wstrb, ddr_commands_from_design ? Top_Out_io_M_AXI_0_WSTRB : lcl_cl_sh_ddra.wstrb};
//assign cl_sh_ddr_wlast_2d = {ddr_commands_from_design ? Top_Out_io_M_AXI_3_WLAST :  lcl_cl_sh_ddrd.wlast, ddr_commands_from_design ? Top_Out_io_M_AXI_1_WLAST : lcl_cl_sh_ddrb.wlast, ddr_commands_from_design ? Top_Out_io_M_AXI_0_WLAST : lcl_cl_sh_ddra.wlast};
//assign cl_sh_ddr_wvalid_2d = {ddr_commands_from_design ? Top_Out_io_M_AXI_3_WVALID :  lcl_cl_sh_ddrd.wvalid, ddr_commands_from_design ? Top_Out_io_M_AXI_1_WVALID : lcl_cl_sh_ddrb.wvalid, ddr_commands_from_design ? Top_Out_io_M_AXI_0_WVALID : lcl_cl_sh_ddra.wvalid};
assign cl_sh_ddr_wid_2d =   '{lcl_cl_sh_ddrd.wid,     lcl_cl_sh_ddrb.wid, ddr_commands_from_design ? 0 : lcl_cl_sh_ddra.wid};
assign cl_sh_ddr_wdata_2d = '{lcl_cl_sh_ddrd.wdata,   lcl_cl_sh_ddrb.wdata, ddr_commands_from_design ? Top_Out_io_M_AXI_0_WDATA : lcl_cl_sh_ddra.wdata};
assign cl_sh_ddr_wstrb_2d = '{lcl_cl_sh_ddrd.wstrb,   lcl_cl_sh_ddrb.wstrb, ddr_commands_from_design ? Top_Out_io_M_AXI_0_WSTRB : lcl_cl_sh_ddra.wstrb};
assign cl_sh_ddr_wlast_2d =  {lcl_cl_sh_ddrd.wlast,   lcl_cl_sh_ddrb.wlast, ddr_commands_from_design ? Top_Out_io_M_AXI_0_WLAST : lcl_cl_sh_ddra.wlast};
assign cl_sh_ddr_wvalid_2d = {lcl_cl_sh_ddrd.wvalid,  lcl_cl_sh_ddrb.wvalid, ddr_commands_from_design ? Top_Out_io_M_AXI_0_WVALID : lcl_cl_sh_ddra.wvalid};

assign {lcl_cl_sh_ddrd.wready, lcl_cl_sh_ddrb.wready, lcl_cl_sh_ddra.wready} = sh_cl_ddr_wready_2d;

assign {lcl_cl_sh_ddrd.bid, lcl_cl_sh_ddrb.bid, lcl_cl_sh_ddra.bid} = {sh_cl_ddr_bid_2d[2], sh_cl_ddr_bid_2d[1], sh_cl_ddr_bid_2d[0]};
assign {lcl_cl_sh_ddrd.bresp, lcl_cl_sh_ddrb.bresp, lcl_cl_sh_ddra.bresp} = {sh_cl_ddr_bresp_2d[2], sh_cl_ddr_bresp_2d[1], sh_cl_ddr_bresp_2d[0]};
assign {lcl_cl_sh_ddrd.bvalid, lcl_cl_sh_ddrb.bvalid, lcl_cl_sh_ddra.bvalid} = sh_cl_ddr_bvalid_2d;

// [4channels]
//assign cl_sh_ddr_bready_2d = {ddr_commands_from_design ? Top_Out_io_M_AXI_3_BREADY : lcl_cl_sh_ddrd.bready, ddr_commands_from_design ? Top_Out_io_M_AXI_1_BREADY : lcl_cl_sh_ddrb.bready, ddr_commands_from_design ? Top_Out_io_M_AXI_0_BREADY : lcl_cl_sh_ddra.bready};
assign cl_sh_ddr_bready_2d = {lcl_cl_sh_ddrd.bready, lcl_cl_sh_ddrb.bready, ddr_commands_from_design ? Top_Out_io_M_AXI_0_BREADY : lcl_cl_sh_ddra.bready};

// [4channels]
//assign cl_sh_ddr_arid_2d = '{ddr_commands_from_design ? Top_Out_io_M_AXI_3_ARID : lcl_cl_sh_ddrd.arid, ddr_commands_from_design ? Top_Out_io_M_AXI_1_ARID : lcl_cl_sh_ddrb.arid, ddr_commands_from_design ? Top_Out_io_M_AXI_0_ARID : lcl_cl_sh_ddra.arid};
//assign cl_sh_ddr_araddr_2d = '{ddr_commands_from_design ? Top_Out_io_M_AXI_3_ARADDR : lcl_cl_sh_ddrd.araddr, ddr_commands_from_design ? Top_Out_io_M_AXI_1_ARADDR : lcl_cl_sh_ddrb.araddr, ddr_commands_from_design ? Top_Out_io_M_AXI_0_ARADDR : lcl_cl_sh_ddra.araddr};
//assign cl_sh_ddr_arlen_2d = '{ddr_commands_from_design ? Top_Out_io_M_AXI_3_ARLEN : lcl_cl_sh_ddrd.arlen, ddr_commands_from_design ? Top_Out_io_M_AXI_1_ARLEN : lcl_cl_sh_ddrb.arlen, ddr_commands_from_design ? Top_Out_io_M_AXI_0_ARLEN : lcl_cl_sh_ddra.arlen};
//assign cl_sh_ddr_arsize_2d = '{ddr_commands_from_design ? Top_Out_io_M_AXI_3_ARSIZE : lcl_cl_sh_ddrd.arsize, ddr_commands_from_design ? Top_Out_io_M_AXI_1_ARSIZE : lcl_cl_sh_ddrb.arsize, ddr_commands_from_design ? Top_Out_io_M_AXI_0_ARSIZE : lcl_cl_sh_ddra.arsize};
//assign cl_sh_ddr_arvalid_2d = {ddr_commands_from_design ? Top_Out_io_M_AXI_3_ARVALID : lcl_cl_sh_ddrd.arvalid, ddr_commands_from_design ? Top_Out_io_M_AXI_1_ARVALID : lcl_cl_sh_ddrb.arvalid, ddr_commands_from_design ? Top_Out_io_M_AXI_0_ARVALID : lcl_cl_sh_ddra.arvalid};
assign cl_sh_ddr_arid_2d =    '{lcl_cl_sh_ddrd.arid,    lcl_cl_sh_ddrb.arid,    ddr_commands_from_design ? Top_Out_io_M_AXI_0_ARID : lcl_cl_sh_ddra.arid};
assign cl_sh_ddr_araddr_2d =  '{lcl_cl_sh_ddrd.araddr,  lcl_cl_sh_ddrb.araddr,  ddr_commands_from_design ? Top_Out_io_M_AXI_0_ARADDR : lcl_cl_sh_ddra.araddr};
assign cl_sh_ddr_arlen_2d =   '{lcl_cl_sh_ddrd.arlen,   lcl_cl_sh_ddrb.arlen,   ddr_commands_from_design ? Top_Out_io_M_AXI_0_ARLEN : lcl_cl_sh_ddra.arlen};
assign cl_sh_ddr_arsize_2d =  '{lcl_cl_sh_ddrd.arsize,  lcl_cl_sh_ddrb.arsize,  ddr_commands_from_design ? Top_Out_io_M_AXI_0_ARSIZE : lcl_cl_sh_ddra.arsize};
assign cl_sh_ddr_arvalid_2d =  {lcl_cl_sh_ddrd.arvalid, lcl_cl_sh_ddrb.arvalid, ddr_commands_from_design ? Top_Out_io_M_AXI_0_ARVALID : lcl_cl_sh_ddra.arvalid};
assign cl_sh_ddr_arburst_2d = {2'b01, 2'b01, 2'b01};
assign {lcl_cl_sh_ddrd.arready, lcl_cl_sh_ddrb.arready, lcl_cl_sh_ddra.arready} = sh_cl_ddr_arready_2d;

assign {lcl_cl_sh_ddrd.rid, lcl_cl_sh_ddrb.rid, lcl_cl_sh_ddra.rid} = {sh_cl_ddr_rid_2d[2], sh_cl_ddr_rid_2d[1], sh_cl_ddr_rid_2d[0]};
assign {lcl_cl_sh_ddrd.rresp, lcl_cl_sh_ddrb.rresp, lcl_cl_sh_ddra.rresp} = {sh_cl_ddr_rresp_2d[2], sh_cl_ddr_rresp_2d[1], sh_cl_ddr_rresp_2d[0]};
assign {lcl_cl_sh_ddrd.rdata, lcl_cl_sh_ddrb.rdata, lcl_cl_sh_ddra.rdata} = {sh_cl_ddr_rdata_2d[2], sh_cl_ddr_rdata_2d[1], sh_cl_ddr_rdata_2d[0]};
assign {lcl_cl_sh_ddrd.rlast, lcl_cl_sh_ddrb.rlast, lcl_cl_sh_ddra.rlast} = sh_cl_ddr_rlast_2d;
assign {lcl_cl_sh_ddrd.rvalid, lcl_cl_sh_ddrb.rvalid, lcl_cl_sh_ddra.rvalid} = sh_cl_ddr_rvalid_2d;

// [4channels]
//assign cl_sh_ddr_rready_2d = {ddr_commands_from_design ? Top_Out_io_M_AXI_3_RREADY : lcl_cl_sh_ddrd.rready, ddr_commands_from_design ? Top_Out_io_M_AXI_1_RREADY : lcl_cl_sh_ddrb.rready, ddr_commands_from_design ? Top_Out_io_M_AXI_0_RREADY : lcl_cl_sh_ddra.rready};
assign cl_sh_ddr_rready_2d = {lcl_cl_sh_ddrd.rready, lcl_cl_sh_ddrb.rready, ddr_commands_from_design ? Top_Out_io_M_AXI_0_RREADY : lcl_cl_sh_ddra.rready};

(* dont_touch = "true" *) logic sh_ddr_sync_rst_n;
lib_pipe #(.WIDTH(1), .STAGES(4)) SH_DDR_SLC_RST_N (.clk(clk), .rst_n(1'b1), .in_bus(sync_rst_n), .out_bus(sh_ddr_sync_rst_n));
sh_ddr #(
         .DDR_A_PRESENT(1),
         .DDR_B_PRESENT(0),
         .DDR_D_PRESENT(0)
   ) SH_DDR
   (
   .clk(clk),
   .rst_n(sh_ddr_sync_rst_n),

   .stat_clk(clk),
   .stat_rst_n(sh_ddr_sync_rst_n),


   .CLK_300M_DIMM0_DP(CLK_300M_DIMM0_DP),
   .CLK_300M_DIMM0_DN(CLK_300M_DIMM0_DN),
   .M_A_ACT_N(M_A_ACT_N),
   .M_A_MA(M_A_MA),
   .M_A_BA(M_A_BA),
   .M_A_BG(M_A_BG),
   .M_A_CKE(M_A_CKE),
   .M_A_ODT(M_A_ODT),
   .M_A_CS_N(M_A_CS_N),
   .M_A_CLK_DN(M_A_CLK_DN),
   .M_A_CLK_DP(M_A_CLK_DP),
   .M_A_PAR(M_A_PAR),
   .M_A_DQ(M_A_DQ),
   .M_A_ECC(M_A_ECC),
   .M_A_DQS_DP(M_A_DQS_DP),
   .M_A_DQS_DN(M_A_DQS_DN),
   .cl_RST_DIMM_A_N(cl_RST_DIMM_A_N),


   .CLK_300M_DIMM1_DP(CLK_300M_DIMM1_DP),
   .CLK_300M_DIMM1_DN(CLK_300M_DIMM1_DN),
   .M_B_ACT_N(M_B_ACT_N),
   .M_B_MA(M_B_MA),
   .M_B_BA(M_B_BA),
   .M_B_BG(M_B_BG),
   .M_B_CKE(M_B_CKE),
   .M_B_ODT(M_B_ODT),
   .M_B_CS_N(M_B_CS_N),
   .M_B_CLK_DN(M_B_CLK_DN),
   .M_B_CLK_DP(M_B_CLK_DP),
   .M_B_PAR(M_B_PAR),
   .M_B_DQ(M_B_DQ),
   .M_B_ECC(M_B_ECC),
   .M_B_DQS_DP(M_B_DQS_DP),
   .M_B_DQS_DN(M_B_DQS_DN),
   .cl_RST_DIMM_B_N(cl_RST_DIMM_B_N),

   .CLK_300M_DIMM3_DP(CLK_300M_DIMM3_DP),
   .CLK_300M_DIMM3_DN(CLK_300M_DIMM3_DN),
   .M_D_ACT_N(M_D_ACT_N),
   .M_D_MA(M_D_MA),
   .M_D_BA(M_D_BA),
   .M_D_BG(M_D_BG),
   .M_D_CKE(M_D_CKE),
   .M_D_ODT(M_D_ODT),
   .M_D_CS_N(M_D_CS_N),
   .M_D_CLK_DN(M_D_CLK_DN),
   .M_D_CLK_DP(M_D_CLK_DP),
   .M_D_PAR(M_D_PAR),
   .M_D_DQ(M_D_DQ),
   .M_D_ECC(M_D_ECC),
   .M_D_DQS_DP(M_D_DQS_DP),
   .M_D_DQS_DN(M_D_DQS_DN),
   .cl_RST_DIMM_D_N(cl_RST_DIMM_D_N),

   //------------------------------------------------------
   // DDR-4 Interface from CL (AXI-4)
   //------------------------------------------------------
   .cl_sh_ddr_awid(cl_sh_ddr_awid_2d),
   .cl_sh_ddr_awaddr(cl_sh_ddr_awaddr_2d),
   .cl_sh_ddr_awlen(cl_sh_ddr_awlen_2d),
   .cl_sh_ddr_awsize(cl_sh_ddr_awsize_2d),
   .cl_sh_ddr_awvalid(cl_sh_ddr_awvalid_2d),
   .cl_sh_ddr_awburst(cl_sh_ddr_awburst_2d),
   .sh_cl_ddr_awready(sh_cl_ddr_awready_2d),

   .cl_sh_ddr_wid(cl_sh_ddr_wid_2d),
   .cl_sh_ddr_wdata(cl_sh_ddr_wdata_2d),
   .cl_sh_ddr_wstrb(cl_sh_ddr_wstrb_2d),
   .cl_sh_ddr_wlast(cl_sh_ddr_wlast_2d),
   .cl_sh_ddr_wvalid(cl_sh_ddr_wvalid_2d),
   .sh_cl_ddr_wready(sh_cl_ddr_wready_2d),

   .sh_cl_ddr_bid(sh_cl_ddr_bid_2d),
   .sh_cl_ddr_bresp(sh_cl_ddr_bresp_2d),
   .sh_cl_ddr_bvalid(sh_cl_ddr_bvalid_2d),
   .cl_sh_ddr_bready(cl_sh_ddr_bready_2d),

   .cl_sh_ddr_arid(cl_sh_ddr_arid_2d),
   .cl_sh_ddr_araddr(cl_sh_ddr_araddr_2d),
   .cl_sh_ddr_arlen(cl_sh_ddr_arlen_2d),
   .cl_sh_ddr_arsize(cl_sh_ddr_arsize_2d),
   .cl_sh_ddr_arvalid(cl_sh_ddr_arvalid_2d),
   .cl_sh_ddr_arburst(cl_sh_ddr_arburst_2d),
   .sh_cl_ddr_arready(sh_cl_ddr_arready_2d),

   .sh_cl_ddr_rid(sh_cl_ddr_rid_2d),
   .sh_cl_ddr_rdata(sh_cl_ddr_rdata_2d),
   .sh_cl_ddr_rresp(sh_cl_ddr_rresp_2d),
   .sh_cl_ddr_rlast(sh_cl_ddr_rlast_2d),
   .sh_cl_ddr_rvalid(sh_cl_ddr_rvalid_2d),
   .cl_sh_ddr_rready(cl_sh_ddr_rready_2d),

   .sh_cl_ddr_is_ready(lcl_sh_cl_ddr_is_ready),

   .sh_ddr_stat_addr0  (sh_ddr_stat_addr_q[0]) ,
   .sh_ddr_stat_wr0    (sh_ddr_stat_wr_q[0]     ) ,
   .sh_ddr_stat_rd0    (sh_ddr_stat_rd_q[0]     ) ,
   .sh_ddr_stat_wdata0 (sh_ddr_stat_wdata_q[0]  ) ,
   .ddr_sh_stat_ack0   (ddr_sh_stat_ack_q[0]    ) ,
   .ddr_sh_stat_rdata0 (ddr_sh_stat_rdata_q[0]  ),
   .ddr_sh_stat_int0   (ddr_sh_stat_int_q[0]    ),

   .sh_ddr_stat_addr1  (sh_ddr_stat_addr_q[1]) ,
   .sh_ddr_stat_wr1    (sh_ddr_stat_wr_q[1]     ) ,
   .sh_ddr_stat_rd1    (sh_ddr_stat_rd_q[1]     ) ,
   .sh_ddr_stat_wdata1 (sh_ddr_stat_wdata_q[1]  ) ,
   .ddr_sh_stat_ack1   (ddr_sh_stat_ack_q[1]    ) ,
   .ddr_sh_stat_rdata1 (ddr_sh_stat_rdata_q[1]  ),
   .ddr_sh_stat_int1   (ddr_sh_stat_int_q[1]    ),

   .sh_ddr_stat_addr2  (sh_ddr_stat_addr_q[2]) ,
   .sh_ddr_stat_wr2    (sh_ddr_stat_wr_q[2]     ) ,
   .sh_ddr_stat_rd2    (sh_ddr_stat_rd_q[2]     ) ,
   .sh_ddr_stat_wdata2 (sh_ddr_stat_wdata_q[2]  ) ,
   .ddr_sh_stat_ack2   (ddr_sh_stat_ack_q[2]    ) ,
   .ddr_sh_stat_rdata2 (ddr_sh_stat_rdata_q[2]  ),
   .ddr_sh_stat_int2   (ddr_sh_stat_int_q[2]    )
   );

//-----------------------------------------
// DDR controller instantiation
//-----------------------------------------

/* Debugging
always_ff @(posedge clk or negedge sync_rst_n)
  begin
    $display("-------------------------------------------");
    $display("[%t]   [AXI-4 R]  : lcl_cl_sh_ddra.araddr   = %x", $realtime, cl_sh_ddr_araddr_2d[0]);
    $display("[%t]   [AXI-4 R]  : lcl_cl_sh_ddra.arvalid  = %x", $realtime, cl_sh_ddr_arvalid_2d[0]);
    $display("[%t]   [AXI-4 R]  : lcl_cl_sh_ddra.arready  = %x", $realtime, lcl_cl_sh_ddra.arready);
    $display("[%t]   [AXI-4 R]  :               `--> AND1 = %x", $realtime, cl_sh_ddr_arvalid_2d[0] & lcl_cl_sh_ddra.arready);
    $display("[%t]   [AXI-4 R]  : lcl_cl_sh_ddra.arid     = %x", $realtime, cl_sh_ddr_arid_2d[0]);
    $display("[%t]   [AXI-4 R]  : sh_cl_ddr_rdata_2d[0]   = %x", $realtime, sh_cl_ddr_rdata_2d[0]);
    $display("[%t]   [AXI-4 R]  : lcl_cl_sh_ddra.rvalid   = %x", $realtime, lcl_cl_sh_ddra.rvalid);
    $display("[%t]   [AXI-4 R]  : lcl_cl_sh_ddra.rready   = %x", $realtime, cl_sh_ddr_rready_2d[0]);
    $display("[%t]   [AXI-4 R]  :               `--> AND2 = %x", $realtime, lcl_cl_sh_ddra.rvalid & cl_sh_ddr_rready_2d[0]);
    $display("[%t]   [AXI-4 R]  : sh_cl_ddr_rresp_2d[0]   = %x", $realtime, sh_cl_ddr_rresp_2d[0]);
    $display("[%t]   [AXI-4 R]  : lcl_cl_sh_ddra.rid      = %x", $realtime, lcl_cl_sh_ddra.rid);

    $display("[%t]   [AXI-4 W]  : lcl_cl_sh_ddra.awaddr   = %x", $realtime, cl_sh_ddr_awaddr_2d[0]);
    $display("[%t]   [AXI-4 W]  : lcl_cl_sh_ddra.awvalid  = %x", $realtime, cl_sh_ddr_awvalid_2d[0]);
    $display("[%t]   [AXI-4 W]  : lcl_cl_sh_ddra.awready  = %x", $realtime, lcl_cl_sh_ddra.awready);
    $display("[%t]   [AXI-4 W]  :               `--> AND3 = %x", $realtime, cl_sh_ddr_awvalid_2d[0] & lcl_cl_sh_ddra.awready);
    $display("[%t]   [AXI-4 W]  : lcl_cl_sh_ddra.awid     = %x", $realtime, cl_sh_ddr_awid_2d[0]);
    $display("[%t]   [AXI-4 W]  : lcl_cl_sh_ddra.wdata    = %x", $realtime, cl_sh_ddr_wdata_2d[0]);
    $display("[%t]   [AXI-4 W]  : lcl_cl_sh_ddra.wvalid   = %x", $realtime, cl_sh_ddr_wvalid_2d[0]);
    $display("[%t]   [AXI-4 W]  : lcl_cl_sh_ddra.wready   = %x", $realtime, lcl_cl_sh_ddra.wready);
    $display("[%t]   [AXI-4 W]  :               `--> AND4 = %x", $realtime, cl_sh_ddr_wvalid_2d[0] & lcl_cl_sh_ddra.wready);
    $display("[%t]   [AXI-4 W]  : sh_cl_ddr_bresp_2d[0]   = %x", $realtime, sh_cl_ddr_bresp_2d[0]);
    $display("[%t]   [AXI-4 W]  : lcl_cl_sh_ddra.bvalid   = %x", $realtime, lcl_cl_sh_ddra.bvalid);
    $display("[%t]   [AXI-4 W]  : lcl_cl_sh_ddra.bready   = %x", $realtime, cl_sh_ddr_bready_2d[0]);
    $display("[%t]   [AXI-4 W]  :               `--> AND5 = %x", $realtime, lcl_cl_sh_ddra.bvalid & cl_sh_ddr_bready_2d[0]);
    $display("[%t]   [AXI-4 W]  : lcl_cl_sh_ddra.bid      = %x", $realtime, lcl_cl_sh_ddra.bid);
  end

always_ff @(posedge clk or negedge sync_rst_n)
  begin
    if (cl_sh_ddr_arvalid_2d[0] && lcl_cl_sh_ddra.arready) begin
      $display("[%t]   [AXI-4 R]  : Addr A   = %x", $realtime, cl_sh_ddr_araddr_2d[0]);
    end
    if (cl_sh_ddr_arvalid_2d[1] && lcl_cl_sh_ddrb.arready) begin
      $display("[%t]   [AXI-4 R]  : Addr B   = %x", $realtime, cl_sh_ddr_araddr_2d[1]);
    end
    if (cl_sh_ddr_arvalid_2d[2] && lcl_cl_sh_ddrd.arready) begin
      $display("[%t]   [AXI-4 R]  : Addr D   = %x", $realtime, cl_sh_ddr_araddr_2d[2]);
    end

    if (cl_sh_ddr_rready_2d[0] && lcl_cl_sh_ddra.rvalid) begin
      $display("[%t]   [AXI-4 R]  : Data A   = %x", $realtime, sh_cl_ddr_rdata_2d[0]);
    end
    if (cl_sh_ddr_rready_2d[1] && lcl_cl_sh_ddrb.rvalid) begin
      $display("[%t]   [AXI-4 R]  : Data B   = %x", $realtime, sh_cl_ddr_rdata_2d[1]);
    end
    if (cl_sh_ddr_rready_2d[2] && lcl_cl_sh_ddrd.rvalid) begin
      $display("[%t]   [AXI-4 R]  : Data D   = %x", $realtime, sh_cl_ddr_rdata_2d[2]);
    end
  end
*/


//-----------------------------------------
// Interrrupt example
//-----------------------------------------

(* dont_touch = "true" *) logic int_slv_sync_rst_n;
lib_pipe #(.WIDTH(1), .STAGES(4)) INT_SLV_SLC_RST_N (.clk(clk), .rst_n(1'b1), .in_bus(sync_rst_n), .out_bus(int_slv_sync_rst_n));
cl_int_slv CL_INT_TST
(
  .clk                 (clk),
  .rst_n               (int_slv_sync_rst_n),

  .cfg_bus             (int_tst_cfg_bus),

  .cl_sh_apppf_irq_req (cl_sh_apppf_irq_req),
  .sh_cl_apppf_irq_ack (sh_cl_apppf_irq_ack)

);

//-----------------------------------------
// Interrrupt example
//-----------------------------------------

//-----------------------------------------
// SDA SLAVE module
//-----------------------------------------


assign sda_cl_bus.awvalid = sda_cl_awvalid;
assign sda_cl_bus.awaddr[31:0] = sda_cl_awaddr;
assign cl_sda_awready = sda_cl_bus.awready;
assign sda_cl_bus.wvalid = sda_cl_wvalid;
assign sda_cl_bus.wdata[31:0] = sda_cl_wdata;
assign sda_cl_bus.wstrb[3:0] = sda_cl_wstrb;
assign cl_sda_wready = sda_cl_bus.wready;
assign cl_sda_bvalid = sda_cl_bus.bvalid;
assign cl_sda_bresp = sda_cl_bus.bresp;
assign sda_cl_bus.bready = sda_cl_bready;
assign sda_cl_bus.arvalid = sda_cl_arvalid;
assign sda_cl_bus.araddr[31:0] = sda_cl_araddr;
assign cl_sda_arready = sda_cl_bus.arready;
assign cl_sda_rvalid = sda_cl_bus.rvalid;
assign cl_sda_rresp = sda_cl_bus.rresp;
assign cl_sda_rdata = sda_cl_bus.rdata[31:0];
assign sda_cl_bus.rready = sda_cl_rready;

(* dont_touch = "true" *) logic sda_slv_sync_rst_n;
lib_pipe #(.WIDTH(1), .STAGES(4)) SDA_SLV_SLC_RST_N (.clk(clk), .rst_n(1'b1), .in_bus(sync_rst_n), .out_bus(sda_slv_sync_rst_n));
cl_sda_slv CL_SDA_SLV (

  .aclk(clk),
  .aresetn(sda_slv_sync_rst_n),

  .sda_cl_bus(sda_cl_bus)
);

//-----------------------------------------
// SDA SLAVE module
//-----------------------------------------


//-----------------------------------------
// Virtual JTAG ILA Debug core example
//-----------------------------------------


`ifndef DISABLE_VJTAG_DEBUG

   cl_ila #(.DDR_A_PRESENT(`DDR_A_PRESENT) ) CL_ILA   (

   .aclk(clk),
   .drck(drck),
   .shift(shift),
      .tdi(tdi),
   .update(update),
   .sel(sel),
   .tdo(tdo),
   .tms(tms),
   .tck(tck),
   .runtest(runtest),
   .reset(reset),
   .capture(capture),
   .bscanid_en(bscanid_en),
   .sh_cl_dma_pcis_q(sh_cl_dma_pcis_q),
`ifndef DDR_A_ABSENT   
   .lcl_cl_sh_ddra(lcl_cl_sh_ddra)
`else
   .lcl_cl_sh_ddra(axi_bus_tied) //
`endif
);

cl_vio CL_VIO (

   .clk_extra_a1(clk_extra_a1)

);


`endif //  `ifndef DISABLE_VJTAG_DEBUG

//-----------------------------------------
// Virtual JATG ILA Debug core example 
//-----------------------------------------
// tie off for ILA port when probing block not present
   assign axi_bus_tied.awvalid = 1'b0 ;
   assign axi_bus_tied.awaddr = 64'b0 ;
   assign axi_bus_tied.awready = 1'b0 ;
   assign axi_bus_tied.wvalid = 1'b0 ;
   assign axi_bus_tied.wstrb = 64'b0 ;
   assign axi_bus_tied.wlast = 1'b0 ;
   assign axi_bus_tied.wready = 1'b0 ;
   assign axi_bus_tied.wdata = 512'b0 ;
   assign axi_bus_tied.arready = 1'b0 ;
   assign axi_bus_tied.rdata = 512'b0 ;
   assign axi_bus_tied.araddr = 64'b0 ;
   assign axi_bus_tied.arvalid = 1'b0 ;
   assign axi_bus_tied.awid = 16'b0 ;
   assign axi_bus_tied.arid = 16'b0 ;
   assign axi_bus_tied.awlen = 8'b0 ;
   assign axi_bus_tied.rlast = 1'b0 ;
   assign axi_bus_tied.rresp = 2'b0 ;
   assign axi_bus_tied.rid = 16'b0 ;
   assign axi_bus_tied.rvalid = 1'b0 ;
   assign axi_bus_tied.arlen = 8'b0 ;
   assign axi_bus_tied.bresp = 2'b0 ;
   assign axi_bus_tied.rready = 1'b0 ;
   assign axi_bus_tied.bvalid = 1'b0 ;
   assign axi_bus_tied.bid = 16'b0 ;
   assign axi_bus_tied.bready = 1'b0 ;


// Temporal workaround until these signals removed from the shell

     assign cl_sh_pcim_awuser = 18'h0;
     assign cl_sh_pcim_aruser = 18'h0;

endmodule
