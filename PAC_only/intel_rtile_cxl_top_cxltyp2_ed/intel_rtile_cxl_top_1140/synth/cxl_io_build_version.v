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


// Copyright 2022 Intel Corporation.
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

module cxl_io_build_version (data_out);
    output [31:0] data_out;
    assign data_out[31] = 1'h1; //1 - debug, 0 - release
    assign data_out[30:0] = 30'h00000000;
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "POizRfZBu2Za2e25gOrjvm1fIPLBk0eZmyFcDIFazcJl7PX67tT/saAlNoEXLHgw5mDQeEFh0JzMQ+qx/C0+PVE6a6spr5K6BpvxdLuS075hXOTsVE7Wc/lebFBxsNWYC7WKZkRFLi9LEIJIuDzdBuFqpnd6KNxaDlPfUh7jN8WMLzEL3yixxC+CcpZ1nL96FjsMR9I8wgkeME02AXMssvm/ZFxRfH2JRVTb/5Z7jzBIWUmMxFTmx+QWkPDlFaKteR3V2oDCgW0Bly7QYsdyGwfSH7D4xCFQdKOlRN3h7shtsUl0/HHoTmU0pmBvVy6Lm0F5BNFpWZcLnWWJNEqw48RtkDakx9o0bQsa2+eEG1hR8sJS6PB69Pk3v5XNHZc+lCDKdaxPEt6+to/1WjUKqxxPDTxysizTHNJnj9ivjSQwKaf3mc65nMOjcw/+Z9vkslt2esQcu3GihaxxOJRmeByokQ0ijSwxIDvmiIucjzBPh4+OQyShkvgTiE/0t02TExW6BSAQvg36jQc4SSvlCNnpOXzX+DfuBjiyCKJ3yLQl6c3K8VDCOImNounkkcsYhXRKesbrNyChG2zeeXBsdc0ueFm9bRKX8yp3aQ8cHJuDPoElcAzHaQyHMhbjwvs0inzDVOx8MBMK/9SHC0cN0v7cgRu6/8bg5vgM9hLVN+/TQ3ws0H6FDHtNeMPgiYkssZwFLBE2Sz27/94sfjP1yvb0atvSbKM8lsK86Tpeyns5aLtJT2Aik6HCms9ZseG2HQ55tGrhR8U1Ipx6mcfotc7O3jESCsPJz30oNuGnn5TTf7tfpRj+zt9f0zd8fg4NEXdcU0Pe/qbKddFTDjl7r9SgzaEN8IE6cg1kOWfggEydWWqn/MXeOCxkuUqJGHRsuUGLS/nnTqRbKxwI+YMmVedLeh7shn2Y+5pRvstWMwfqXMKK1C2x1PI75vxeSxffoMPhWNFtiTtQAAqBw1IDDZagCfPzbaU8TNFgrqeJvMbqS31eFAlWlXebDJSSXeWb"
`endif