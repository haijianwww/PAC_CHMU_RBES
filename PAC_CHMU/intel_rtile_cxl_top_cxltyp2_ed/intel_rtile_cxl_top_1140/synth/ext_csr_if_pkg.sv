// (C) 2001-2024 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// Copyright 2023 Intel Corporation.
//
// THIS SOFTWARE MAY CONTAIN PREPRODUCTION CODE AND IS PROVIDED BY THE
// COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
///////////////////////////////////////////////////////////////////////

package ext_csr_if_pkg;

// copied over from tmp_cafu_csr0_cfg_pkg.sv
typedef struct packed {
    logic  [0:0] pm_init_comp_capable;  // RO
    logic  [0:0] viral_capable;  // RO
    logic  [0:0] mld;  // RO
    logic  [0:0] reserved0;  // RSVD
    logic  [0:0] cxl_reset_mem_clr_capable;  // RO
    logic  [2:0] cxl_reset_timeout;  // RO
    logic  [0:0] cxl_reset_capable;  // RO
    logic  [0:0] cache_wb_and_inv_capable;  // RO
    logic  [1:0] hdm_count;  // RO
    logic  [0:0] mem_hwInit_mode;  // RO
    logic  [0:0] mem_capable;  // RO
    logic  [0:0] io_capable;  // RO
    logic  [0:0] cache_capable;  // RO
    logic [15:0] dvsec_id;  // RO
} CXLIP_DVSEC_FBCAP_HDR2_t;

// copied over from tmp_cafu_csr0_cfg_pkg.sv
typedef struct packed {
    logic  [0:0] power_mgt_init_complete;  // RO/V
    logic [11:0] reserved0;  // RSVD
    logic  [0:0] cxl_reset_error;  // RO/V
    logic  [0:0] cxl_reset_complete;  // RO/V
    logic  [0:0] cache_invalid;  // RO/V
    logic [11:0] reserved1;  // RSVD
    logic  [0:0] cxl_reset_mem_clr_enable;  // RW
    logic  [0:0] initiate_cxl_reset;  // RW/1S/V
    logic  [0:0] initiate_cache_wb_and_inv;  // RW/1S/V
    logic  [0:0] disable_caching;  // RW
} CXLIP_DVSEC_FBCTRL2_STATUS2_t;

// copied over from tmp_cafu_csr0_cfg_pkg.sv
typedef struct packed {
    logic  [0:0] reserved0;  // RSVD
    logic  [0:0] viral_status;  // RW/1C/V/P
    logic [14:0] reserved1;  // RSVD
    logic  [0:0] viral_enable;  // RW/L
    logic  [1:0] reserved2;  // RSVD
    logic  [0:0] cache_clean_eviction;  // RW/L
    logic  [2:0] cache_sf_granularity;  // RW/L
    logic  [4:0] cache_sf_coverage;  // RW/L
    logic  [0:0] mem_enable;  // RW/L
    logic  [0:0] io_enable;  // RO
    logic  [0:0] cache_enable;  // RW/L
} CXLIP_DVSEC_FBCTRL_STATUS_t;

// copied over from tmp_cafu_csr0_cfg_pkg.sv
typedef struct packed {
    logic  [0:0] power_mgt_init_complete;  // RO/V
    logic  [0:0] cxl_reset_error;  // RO/V
    logic  [0:0] cxl_reset_complete;  // RO/V
    logic  [0:0] cache_invalid;  // RO/V
    logic  [0:0] initiate_cxl_reset;  // RW/1S/V
    logic  [0:0] initiate_cache_wb_and_inv;  // RW/1S/V
} CXLIP_new_DVSEC_FBCTRL2_STATUS2_t;

typedef struct packed {
  CXLIP_DVSEC_FBCAP_HDR2_t       dvsec_fbcap_hdr2;       // 32 bits wide
  CXLIP_DVSEC_FBCTRL2_STATUS2_t  dvsec_fbctrl2_status2;  // 32 bits wide
  CXLIP_DVSEC_FBCTRL_STATUS_t    dvsec_fbctrl_status;    // 32 bits wide
} cafu2ip_csr0_cfg_if_t;

// Module connect script has issue with "= $bits(cafu2ip_csr0_cfg_if_t)"
localparam CAFU2IP_CSR0_CFG_IF_WIDTH = 96;

localparam TMP_NEW_DVSEC_FBCTRL2_STATUS2_T_BW = $bits( CXLIP_new_DVSEC_FBCTRL2_STATUS2_t );

typedef struct packed {
   logic [51:6]    DevAddr;
   logic [32:0]    SBECnt;
   logic [32:0]    DBECnt;
   logic [32:0]    PoisonRtnCnt;
   logic           NewSBE;
   logic           NewDBE;
   logic           NewPoisonRtn;
   logic           NewPartialWr;
} mc_err_cnt_t;

//-------------------------
//----- CXL Device Type
//      Used by DOE CDAT FSM
// @@copy for common_afu_pkg@@start
typedef enum logic [1:0] {
    INV_TYPE_DEV        = 2'b00,        // (mem_capable, cache_capable)
    TYPE_1_DEV          = 2'b01,
    TYPE_3_DEV          = 2'b10,
    TYPE_2_DEV          = 2'b11
} CxlDeviceType_e;
// @@copy for common_afu_pkg@@end

//-------------------------
//----- DOE CDAT POR values.
//      Type 1 POR Values
//      Included structures DSMAS, DSLBIS and DSIS
// @@copy for common_afu_pkg@@start
localparam TYPE1_CDAT_0 = 32'h00000030;        // CDAT Length
localparam TYPE1_CDAT_1 = 32'h0000AA01;        // CDAT Checksum and Rev.
// @@copy for common_afu_pkg@@end

//      Type 2 POR Values
//      Included structures DSMAS, DSLBIS, DSIS and DSEMTS
// @@copy for common_afu_pkg@@start
localparam TYPE2_CDAT_0 = 32'h00000060;        // CDAT Length
localparam TYPE2_CDAT_1 = 32'h00004101;        // CDAT Checksum and Rev.
// @@copy for common_afu_pkg@@end


endpackage: ext_csr_if_pkg
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "EknmHwQp1Im7e42VTEW4oP2YlkjZ4q1qxNf0pFfjUqCitHkH39CYcFkwSiDngDquknlwOs0cV09OWg1Vqr9AJzKHl9u3jmr1ART1KkS8wXukVlgHSVfd16n8/T9v5gAWwkVERtgG7ZXREFE2Ma4KnGT/aFGmA6j1B8XDnuCKFAsk/YDTkJMsrKEHO5zzdNk6r7SaThxY+E0ejgfrwMULALf2OnQu+lk4HNYpq3cSGSQ3oa4H4U5TzSHs0IgqStqrrSLt6CEznqeavuEKM+YqGYvepHl4q+hJYBpWw0cSQriHINaVlLG9thAkSvCzZ1LpTNvYE9CNij26aS77iguU0S2WLPcZ3npg4VS/8L1cc8l7A5iJzN1NJgYbrkR54Lif2eRcutqjic6WkC86m1leNtZIR+J3pWCMnMfy4H+mxSmzfcBXcx961c6o+aOS3FT7/QRWBbOGoV4/9ATOFzFUi21u4F8TwRGW9FDqEX2mckoXXxWpTWOqRPSjshVpo6IhTYX5HnLbxO4UHD1OB+ZxDihYGW3j0MIvBCn0ifd1DtoYhRfq/IieYKKJWNTTYtrrW2YUMYIxUGXOP9k1buia4JOYZEcHgFbYW+DBRAtXIUDzdWfhVNYwME2AO3oYDf097cnPWJW/fdiLHXGkZLzJ4G+D3s71J/jBoQ5F+Xv320PZQ+yrX5YCgNPeYy1//0UTXH1N9o729jeVOtra8GNg8NA1iVZdCzhz0UxLuMgAuQjdLeiUO9agU51YMR5T798id/2PRf/nQZUFi5G+No67w01K3mOm8UkjYnoFMZ360O5yFEzCiEBCNNw7dO0AUuXmJHP0xApW7LoAty1fU6sgJmL7TW1BRh73jNhuNx+h0R3w+YBmTsGoRi5KdFXOj82E91AUVlUWj3VKsH1p0Ohd8BYjgGOMasudkgJhrMkY+euyaKMZSLOLWyi5naSy1KVgsmLjZxDzapb6iurS17C64oR0JzRG3ufcxsyX+OWjdYRCt1sqovxqD7fyCqVgTYJI"
`endif