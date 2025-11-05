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
// Module Name:         gram_sdp_be.v
// Project:             TBF/LVF 
// Description:
//
// ***************************************************************************
// gram_sdp_be.v: Generic simple dual port RAM with one write port and one read port
// qigang.wang@intel.com Copyright Intel 2008
// edited by pratik marolia on 3/15/2010
// edited by yoanna baumgartner on 1/23/2018
// Created 2008Oct16
// referenced Arthur's VHDL version
//
// Generic dual port RAM. This module helps to keep your HDL code architecture
// independent. 
//
// This module makes use of synthesis tool's automatic RAM recognition feature.
// It can infer distributed as well as block RAM. The type of inferred RAM
// depends on GRAM_STYLE and mode. 
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
//        be  __________|            |
//        clk __________|\           |
//                      |/           |
//                      +------------+
//
// You can override parameters to customize RAM.
//

import gbl_pkg::*;

  module gram_sdp_be (clk,    // input   clock
                      we,     // input   write enable
                      be,     // input   write ByteEnables
                      waddr,  // input   write address with configurable width
                      din,    // input   write data with configurable width
                      raddr,  // input   read address with configurable width
                      dout    // output  write data with configurable width
                     );

  parameter BUS_SIZE_ADDR = 4;                  // number of bits of address bus
  parameter BUS_SIZE_DATA = 32;                 // number of bits of data bus.  Must be multiple of 8.
  parameter GRAM_MODE =     2'd3;               // GRAM read mode defaults to Buffered read, 2 cycle delay.
  parameter BUS_SIZE_BE =   BUS_SIZE_DATA/8;    // Number of ByteEnables. Use default.
  parameter GRAM_STYLE =    gbl_pkg::GRAM_AUTO; // GRAM_AUTO, GRAM_BLCK, GRAM_DIST
  //localparam RAM_BLOCK_TYPE = GRAM_STYLE==gbl_pkg::GRAM_BLCK
  //                          ? "M20K"
  //                          :GRAM_STYLE==gbl_pkg::GRAM_DIST
  //                           ? "MLAB"
  //                           : "AUTO";


input                           clk;
input                           we;
input   [BUS_SIZE_BE-1:0]       be;
input   [BUS_SIZE_ADDR-1:0]     waddr;
input   [BUS_SIZE_DATA-1:0]     din;
input   [BUS_SIZE_ADDR-1:0]     raddr;
output  [BUS_SIZE_DATA-1:0]     dout;

//Add directive to don't care the behavior of read/write same address
(*ramstyle=GRAM_STYLE*) reg [BUS_SIZE_BE-1:0][7:0] ram [(2**BUS_SIZE_ADDR)-1:0];  //ram divided into bytes.

reg [BUS_SIZE_ADDR-1:0] raddr_Q;
reg [BUS_SIZE_DATA-1:0] dout;
reg [BUS_SIZE_DATA-1:0] ram_dout;
/*synthesis translate_off */
reg                     driveX;         // simultaneous access detected. Drive X on output
/*synthesis translate_on */

// mw: Start timescale test
/*synthesis translate_off */
initial
begin
//$display("mw: printing the timescale upon entry into gram_sdp.");
//$printtimescale(); // mw: added to observe timescale upon entry into gram_sdp
  $display("mw: printing the array parameters for RAM detection in gram_sdp_be.");
  $display("mw: from gram_sdp_be, inside hierarchy %m with array params: %4d x %4d",BUS_SIZE_ADDR,BUS_SIZE_DATA);
end
/*synthesis translate_on */
// mw: End timescale test

 case (GRAM_MODE)
 
      1: begin : GEN_SYN_READ                     // synchronous read (rd, data valid next cyc)
      //-----------------------------------------------------------------------
        always @(posedge clk)
            begin
            if (we)
                for (int i=0; i<BUS_SIZE_DATA/8; i++) 
                begin
                // ram[waddr][BUS_SIZE_DATA-1:0]<=din[BUS_SIZE_DATA-1:0]; // synchronous write the RAM
                if (be[i])                
                    ram[waddr][i]  <= din[7+(8*i)-:8]; 
             end
                                    /* synthesis translate_off */
            if (driveX)
                dout <= 'hx;
            else                    /* synthesis translate_on */
                dout<= ram[raddr];       //unbuffered ram output.
        end
           
                                    /*synthesis translate_off */
         always_comb
           begin
                  driveX = 0;
                                                  
                  if(raddr==waddr && we)
                          driveX  = 1;
                  else    driveX  = 0;            
     
           end                         
                                    /*synthesis translate_on */
      end


      3: begin : GEN_SYN_READ_BUF_OUTPUT          // synchronous read, buffer output (rd, data valid 2nd cycle after)
      //-----------------------------------------------------------------------
        always @(posedge clk)
            begin
            if (we)
                for (int i=0; i<BUS_SIZE_DATA/8; i++) 
                begin
                // ram[waddr][BUS_SIZE_DATA-1:0]<=din[BUS_SIZE_DATA-1:0]; // synchronous write the RAM
                if (be[i])                
                    ram[waddr][i]  <= din[7+(8*i)-:8]; 
             end

            ram_dout    <= ram[raddr]; 
                                        /*synthesis translate_off */
            if(driveX)
                dout    <= 'hx;
            else                        /* synthesis translate_on */
                dout    <= ram_dout;    //buffer ram output 

                                        /* synthesis translate_off */
            if(raddr==waddr && we)
                driveX <= 1;
            else driveX <= 0;            /*synthesis translate_on */
        end
      end
 endcase
 
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "eloP3HEWt+enNNR7uc4ZTy5FU1xUYBn9WNS12KqlnsTBIMWBESXJBRpVdZLTAS8G0/vsoJnb7t3JYyutNuldWRrqwaekmaGeVNTpl3SIFkx0NbeTyHC7E3kqBqc537Sk2s+0dTZ1eDw04O7qOPMrllEmQzQg2xgkm63YUK/Gbl9klfpBSWCzcV2V9F80IA5lV7cXNOJWZv+YXqSIcDVUtgYG5sDO2ilFMeYB64ke1BJw/SiMUKGEjzzMIuuCblFeZJT/XDVDeeH4HHTTWoTppcj0aKPE+Z6FLEu/zey0maEFVFM09nxeXgrA0yr9lnfUqeCeRitViHWQmddp0KszefRQXw0L2rBYW/eXeGQTeAQGlKRP0vRuF41CSxSSeJC+3GJHgza71ZJQTQhG412EWA4kbDyzTgiNZtqO9PiLyjA952PNlLWBIDJ058I2B62Pbl3mAczwp6uZWeQXuBkWHSFLtmTMyhp9Cfe0R3yGn7C5AHihdLTlrUNRwjQS0DY70ZkuoMudTWliC4ElmAdx/q3BgrzQ6LjJcIZog5F1zcUEiO4rv8Vrf2FxkAtNTAzeRlD4WQTlRJYSFnYG+ID4bYb5Sqks6iid1Fz7bKxgHRgJ8KUDSaiomjRf0hh0QCiCoBkO1qXouurkgGgmYxo1pPd1v1IxzN2o4CFxStTErmqP+hCf9O/IDnqyJhmdUMiY0FnMiaOmdiXDb06nhy/zaCl2OO6dW86HgN/miy7apNKr2WMFqSkuncoly0Z1q5JEN5EnI3Skr+wfxxawefccEUm0vw7dJMFPRR9bvp+B1gr9rAANiAP9oNthf/Jm6NjGwzAqTq4/iG84HM61aI4N6w+A3jNyNaMVRNJvel2YIe4hjM+mzvIB3lycfFfRULosohkjOsjIklUDE5+u2O2nUn+M7IqlNabK79kZwXbxkyyzUXoRNGvurhVxtcyXCmGCjXLwHf0+IFZ7t2svnmZwjxcBEGyGIrZlkw7d74ewqOdLc2/E3PSZ1D9DxTIZw8dw"
`endif