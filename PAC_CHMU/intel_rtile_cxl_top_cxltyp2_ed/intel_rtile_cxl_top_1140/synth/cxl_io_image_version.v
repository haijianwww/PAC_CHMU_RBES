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

module cxl_io_image_version (data_out);
    output [31:0] data_out;
    assign data_out[15:0] = 16'h4202; //CXL IO version
    assign data_out[31:16] = 16'h5403;
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "POizRfZBu2Za2e25gOrjvm1fIPLBk0eZmyFcDIFazcJl7PX67tT/saAlNoEXLHgw5mDQeEFh0JzMQ+qx/C0+PVE6a6spr5K6BpvxdLuS075hXOTsVE7Wc/lebFBxsNWYC7WKZkRFLi9LEIJIuDzdBuFqpnd6KNxaDlPfUh7jN8WMLzEL3yixxC+CcpZ1nL96FjsMR9I8wgkeME02AXMssvm/ZFxRfH2JRVTb/5Z7jzC2oCsljXthOTO4kTojVAXx9fiwS0K/4mgDwEPJPJo+NsWloF7ItifD3Xt0KQzDYiMi9lzqdLbzwqhSlsjRH1OMwG/4s3agktg7IifSF1bduSpwd4DV7ei2knO0fdpZaoH0OOU7IFUjTNdTSQFUZWEGx4N9NQH69noq9pep+WHrnEIXSaGT3Gd8zbHH+KsWjJTONzLiJLFbCxalB8nSBy1bloIl9shw7O3vUl/FsRbIzIPvxu4RCiptkcljUiINLNaKZxg1yabsjI3Y2/5a+ZXNFbuFfiz4CjV6AcsgGf0Gv/76zp8wHRXaiRSve3gRJMK0+C/KjHY9MqHHkN5E/Gi4hzWdjQMOBJUruV3eW60LYm+IGUTiQrJGY8Lr4BXjds84b4xCZ5qnr7b9HmZypUuY5ifWq7ppVvPBfJtovcZ8dF0mFWMR3l9yq/tbiwJFJ7gJs1Yo/wIJc3k1VbJzC/6/k44q7XLGN1EWhEbwtMNdMypeD8CYj4f7mhBKY2ZiKndpY7Z9Ss8d4ODEW+UTOy4+Y7lhMfeVcfm7iO+bbQ5tndck7UdKSaREudj38RbsgA9NqkX6ByWQhZSvjLLI+3s1YactwzfH0pdeO7oMinNwmdwSQ+jDRznJF85bI4zbNYhsYWGBAeycJ0J1lTU0Orz2XKHLo+fNGuLU3NwugAf6pAlKNH9mc31TMWzm05HPEoCd7wAjan9N9b0NRm8XGo8AmEX0XjDka5aUAwtfFBIiJ1rUdgYj41dxXHWYmANyqwf2B8XOEhD6zR+GMvT5Usrs"
`endif
