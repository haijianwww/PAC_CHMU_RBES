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


// ***************************************************************************
//                               INTEL CONFIDENTIAL
//
//        Copyright (C) 2008-2011 Intel Corporation All Rights Reserved.
//
// The source code contained or described herein and all  documents related to
// the  source  code  ("Material")  are  owned  by  Intel  Corporation  or its
// suppliers  or  licensors.    Title  to  the  Material  remains  with  Intel
// Corporation or  its suppliers  and licensors.  The Material  contains trade
// secrets  and  proprietary  and  confidential  information  of  Intel or its
// suppliers and licensors.  The Material is protected  by worldwide copyright
// and trade secret laws and treaty provisions. No part of the Material may be
// used,   copied,   reproduced,   modified,   published,   uploaded,  posted,
// transmitted,  distributed,  or  disclosed  in any way without Intel's prior
// express written permission.
//
// No license under any patent,  copyright, trade secret or other intellectual
// property  right  is  granted  to  or  conferred  upon  you by disclosure or
// delivery  of  the  Materials, either expressly, by implication, inducement,
// estoppel or otherwise.  Any license under such intellectual property rights
// must be express and approved by Intel in writing.
//
// Engineer:            Yoanna Baumgartner, Mark Wolski
// Create Date:         Fri Jul 29 14:45:50 PDT 2011
// Module Name:         gram_sdp.v
// Project:             TBF/LVF 
// Description:
//
// ***************************************************************************
// gram_sdp.v: Generic simple dual port RAM with one write port and one read port
// qigang.wang@intel.com Copyright Intel 2008
// edited by pratik marolia on 3/15/2010
// edited by yoanna baumgartner on 1/23/2019
// Created 2008Oct16
// referenced Arthur's VHDL version
//
// Generic dual port RAM. This module helps to keep your HDL code architecture
// independent. 
//
// 
// This module makes use of synthesis tool's automatic RAM recognition feature.
// It can infer distributed as well as block RAM. The type of inferred RAM
// depends on GRAM_STYLE and mode. 
// RAM. There are three supported values for GRAM_STYLE.
// GRAM_AUTO : Let the tool to decide 
// GRAM_BLCK : Use block RAM
// GRAM_DIST : Use distributed RAM
// 
// Diagram of GRAM:
//
//           +---+      +------------+     +------+
//   raddr --|1/3|______|            |     | 2/3  |
//           |>  |      |            |-----|      |-- dout
//           +---+      |            |     |>     |
//        din __________|   RAM      |     +------+
//      waddr __________|            |
//        we  __________|            |
//        clk __________|\           |
//                      |/           |
//                      +------------+
//
// You can override parameters to customize RAM.
//

import gbl_pkg::*;

  module gram_sdp (clk,     // input   clock
                   we,      // input   write enable
                   waddr,   // input   write address with configurable width
                   din,     // input   write data with configurable width
                   raddr,   // input   read address with configurable width
                   dout     // output  write data with configurable width
                  );      

  parameter BUS_SIZE_ADDR = 4;                  // number of bits of address bus
  parameter BUS_SIZE_DATA = 32;                 // number of bits of data bus
  parameter GRAM_MODE =     2'd3;               // GRAM read mode
  parameter GRAM_STYLE =    gbl_pkg::GRAM_AUTO; // GRAM_AUTO, GRAM_BLCK, GRAM_DIST

  //localparam RAM_BLOCK_TYPE = GRAM_STYLE==gbl_pkg::GRAM_BLCK
  //                          ? "M20K"
  //                          : GRAM_STYLE==gbl_pkg::GRAM_DIST
  //                            ? "MLAB"
  //                            : "AUTO";


input                           clk;
input                           we;
input   [BUS_SIZE_ADDR-1:0]     waddr;
input   [BUS_SIZE_DATA-1:0]     din;
input   [BUS_SIZE_ADDR-1:0]     raddr;
output  [BUS_SIZE_DATA-1:0]     dout;

//Add directive to don't care the behavior of read/write same address
//This allows Quartus to choose an MLAB for smaller RAMs in S10
//This may not be required in FalconMesa!
(*ramstyle= GRAM_STYLE*) reg [BUS_SIZE_DATA-1:0] ram [(2**BUS_SIZE_ADDR)-1:0];

//reg [BUS_SIZE_DATA-1:0] dout /* synthesis keep */;     // keep wires for signaltap, hurts timing
//reg [BUS_SIZE_DATA-1:0] ram_dout /* synthesis keep */;

reg [BUS_SIZE_DATA-1:0] dout /* preserve_syn_only */;
reg [BUS_SIZE_DATA-1:0] ram_dout /* preserve_syn_only*/;

/*synthesis translate_off */
reg                     driveX;         // simultaneous access detected. Drive X on output
/*synthesis translate_on */

// mw: Start timescale test
/*synthesis translate_off */
initial
begin
//  $display("mw: printing the timescale upon entry into gram_sdp.");
//  $printtimescale(); // mw: added to observe timescale upon entry into gram_sdp
  $display("mw: printing the array parameters for RAM detection in gram_sdp.");
  $display("mw: from gram_sdp, inside hierarchy %m with array params: %4d x %4d and GRAM_MODE=%2d",BUS_SIZE_ADDR,BUS_SIZE_DATA,GRAM_MODE);
end
/*synthesis translate_on */
// mw: End timescale test


    case (GRAM_MODE)
      0: begin : GEN_ASYN_READ                    // asynchronous read
      //-----------------------------------------------------------------------
          always @(posedge clk)
          begin
            if (we)
              ram[waddr]<=din; // synchronous write the RAM
          end
  
           always @(*) dout = ram[raddr];
         end
      1: begin : GEN_SYN_READ                     // synchronous read (rd, data valid next cyc)
      //-----------------------------------------------------------------------
          always @(posedge clk)
           begin  
                  if (we)
                    ram[waddr]<=din; // synchronous write the RAM
  
                                                  /* synthesis translate_off */
                  if(driveX)
                          dout <= 'hx;
                  else                            /* synthesis translate_on */
                          dout <= ram[raddr];
           end
                                                  /*synthesis translate_off */
           always @(*)
           begin
                  driveX = 0;
                                                  
                  if(raddr==waddr && we)
                          driveX  = 1;
                  else    driveX  = 0;            
     
           end                                    /*synthesis translate_on */
           
         end
      2: begin : GEN_FALSE_SYN_READ               // False synchronous read, buffer output
      //-----------------------------------------------------------------------
         always @(*)
           begin
                  ram_dout = ram[raddr];
                                                  /*synthesis translate_off */
                  if(raddr==waddr && we)
                  ram_dout = 'hx;                 /*synthesis translate_on */
           end
           always @(posedge clk)
           begin
                  if (we)
                    ram[waddr]<=din; // synchronous write the RAM
  
                  dout <= ram_dout;
           end
         end
      3: begin : GEN_SYN_READ_BUF_OUTPUT          // synchronous read, buffer output (rd, data valid 2nd cycle after)
      //-----------------------------------------------------------------------
         always @(posedge clk)
              begin
                    if (we)
                      ram[waddr]<=din; // synchronous write the RAM
  
                     ram_dout<= ram[raddr];
                     dout    <= ram_dout;
                                                     /*synthesis translate_off */
                     if(driveX)
                          dout    <= 'hx;
                     if(raddr==waddr && we)
                             driveX <= 1;
                     else    driveX <= 0;            /*synthesis translate_on */
              end
         end
    endcase

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "eloP3HEWt+enNNR7uc4ZTy5FU1xUYBn9WNS12KqlnsTBIMWBESXJBRpVdZLTAS8G0/vsoJnb7t3JYyutNuldWRrqwaekmaGeVNTpl3SIFkx0NbeTyHC7E3kqBqc537Sk2s+0dTZ1eDw04O7qOPMrllEmQzQg2xgkm63YUK/Gbl9klfpBSWCzcV2V9F80IA5lV7cXNOJWZv+YXqSIcDVUtgYG5sDO2ilFMeYB64ke1BKNUWR5C9hQCJYi+pRXpagHqnDLoreAZR0GwriTnVPXg1rFSTCxxFn7dUnnvEG6PPM6XuN+Z3s4cvmBTINiW3I6TwlLRI1QQCYdnIu2d7uKqRvS3upbNGM5c0ibkD3UZlRE46QHVS9VzEKAvS4Pg6AWJOA0/rT9TIVjTuMfZC6g6txLRmOfOCxa4aisOjk8NHdmwHgMAiwnZT5wms/ejiIbs97p8Mzt3gaqo8qGcyI+LkBfWdT32uXjtnmk0Entdd+RvUjMY792M/KFaiwz+WHQREkRgypLsg5oS2DX4WVlgJoK38oPvyasnqL9rHJhCW5P7wb/5uXXIiwXosyhpJM2CRYUhvII3iL3CFOpRVWg6fHO2uPt0SWnLz3mtSblGvwbX6i7ONDkyIL/OI4UgvWN0hsSh3GPiB9MbT9aoCBFYmnQETtPU/V35J1YnjnVmO3DZbuTmaeqgkt6zT2Bvi0uOuP7jypKB5y2PgIZUddXTxnNJj+bEuzyRs7l5B7cH3g20xCo/+wcTwA8Ph4xyNMiFJFv2G8k3jdI8Bm8LMhNLcgrB2iRFkoknh0ES4eOka4Qz7OVRfbXTVJIgWyVXeM5P0WRbrk11Cr7xuKEL6KdQ8xFZ8HQuHxzhwuVPymCqWQUezSq2jUkhpG1kTsMfD6QuOEKaQ2oiueVEyobbYv+mdCfTHGpnYk8zqpQJXD/lxyXyauBm2/ci4cELoxqN6oODMaNrJmPCEDJ85mxIvgFGYgER1nbX2uRUFI5OX24Fge+3O/QHZarUFpCBQVlIvpv"
`endif