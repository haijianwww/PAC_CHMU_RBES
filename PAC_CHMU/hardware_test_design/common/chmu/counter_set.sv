//=============================================================================
// Copyright (C) 2025 Eojin Na, Seoul National University,
// Scalable Computer Architecture Lab. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//=============================================================================
// Author       : Eojin Na
// Contact      : eojin.na@scale.snu.ac.kr
//=============================================================================


module counter_set #(
  parameter ADDR_SIZE      = 21,                      // DPA unit size = 4KB, address space = 8GB (33 - 12 = 21)
  parameter INDEX_SIZE     = 10,                      // # of sets (temp)
  parameter NUM_WAY        = 4,
  parameter TAG_SIZE       = ADDR_SIZE - INDEX_SIZE,
  parameter CNT_SIZE       = 12,        
  parameter HOT_TH         = 20                     // temp (TODO)
)(
  input  logic                 clk,
  input  logic                 rst_n,

  input  logic [ADDR_SIZE-1:0] input_addr,
  input  logic                 input_addr_valid,
  input  logic                 epoch,
  
  output logic [ADDR_SIZE-1:0] output_addr,
  output logic [CNT_SIZE-1:0]  output_cnt,
  output logic                 output_valid
);

  localparam NUM_SET = 1 << INDEX_SIZE; 
  
  genvar i;

  // latch signals
  logic                  valid, valid_d1, hot_valid;
  logic [ADDR_SIZE-1:0]  addr, addr_d1, hot_addr;
  logic [TAG_SIZE-1:0]   addr_tag; 
  logic [INDEX_SIZE-1:0] input_addr_index, addr_index, addr_index_d1, bram_addr;
  logic [CNT_SIZE-1:0]   hot_cnt;

  // way signals
  typedef struct packed {
    logic [TAG_SIZE-1:0]   tag;
    logic [CNT_SIZE-1:0]   cnt;
  } way_t;

  way_t                        way_wdata, hit_wdata, hit_wdata_d1, alloc_wdata;
  way_t [NUM_WAY-1:0]          way_output, way_rdata;
  
  logic  way_valid [NUM_SET][NUM_WAY-1:0];

  logic [NUM_WAY-1:0]          way_wren, way_match, way_free;
  logic                        hit_any, alloc_any, hit_any_d1, alloc_any_d1, collision;

  logic [$clog2(NUM_WAY)-1:0]  hit_way_enc, alloc_way_enc, hit_way_enc_d1, alloc_way_enc_d1;

  /*************** Latching input signals ***************/ 
  assign input_addr_index = input_addr[INDEX_SIZE-1:0];
  assign addr_index    = addr[INDEX_SIZE-1:0];
  assign addr_index_d1 = addr_d1[INDEX_SIZE-1:0];
  assign addr_tag      = addr[ADDR_SIZE-1 -: TAG_SIZE];

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      valid  <= 1'b0;
      addr   <= {ADDR_SIZE{1'b0}};
    end
    else if (epoch) begin
      valid  <= 1'b0;
      addr   <= {ADDR_SIZE{1'b0}};
    end
    else if (input_addr_valid) begin
      valid  <= input_addr_valid;
      addr   <= input_addr;
    end
    else begin
      valid <= 1'b0;
    end
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      valid_d1          <= 1'b0;
      addr_d1           <= {ADDR_SIZE{1'b0}};
      hit_way_enc_d1    <= '0;
      alloc_way_enc_d1  <= '0;
      hit_any_d1        <= '0;
      alloc_any_d1      <= '0;
      hit_wdata_d1      <= '0;
    end
    else if (epoch) begin
      valid_d1          <= 1'b0;
      addr_d1           <= {ADDR_SIZE{1'b0}};
      hit_way_enc_d1    <= '0;
      alloc_way_enc_d1  <= '0;
      hit_any_d1        <= '0;
      alloc_any_d1      <= '0;
      hit_wdata_d1      <= '0;
    end
    else begin
      valid_d1          <= valid;
      addr_d1           <= addr;
      hit_way_enc_d1    <= hit_way_enc;
      alloc_way_enc_d1  <= alloc_way_enc;
      hit_any_d1        <= hit_any;
      alloc_any_d1      <= alloc_any;
      hit_wdata_d1      <= hit_wdata;
    end
  end
  
  /*************** Cycle 1: read counter table ***************/ 
  always_comb begin
    for (int w = 0; w < NUM_WAY; w++) begin
      if (valid) begin
        way_rdata[w] = way_output[w];
      end
      else begin
        way_rdata[w] = '{default: '0};
      end
    end
  end

  /*************** Cycle 1: counting logic ***************/

  always_comb begin
    for (int w = 0; w < NUM_WAY; w++) begin
      way_match[w] = way_valid[addr_index][w] && (way_rdata[w].tag == addr_tag) && valid;
      way_free[w] = ~way_valid[addr_index][w] && valid;
    end
  end
  
  assign hit_any = |way_match ;
  assign alloc_any = (~hit_any) && (|way_free);
  assign collision = valid && !hit_any && !alloc_any;
  
  // priority encoder for hit ** hardcoded for NUM_WAY = 4 **
  assign hit_way_enc[0] = way_match[1] | way_match[3];
  assign hit_way_enc[1] = way_match[2] | way_match[3];

  // priority encoder for allocate
  always_comb begin 
    casez (way_free)
      4'b???1: alloc_way_enc = 2'd0;
      4'b??10: alloc_way_enc = 2'd1;
      4'b?100: alloc_way_enc = 2'd2;
      4'b1000: alloc_way_enc = 2'd3;
      default: alloc_way_enc = 2'd0;
    endcase
  end

  // pre-computed write data
  /*
  always_comb begin
    hit_wdata = way_rdata[hit_way_enc];
    if (hit_wdata.cnt != {CNT_SIZE{1'b1}}) begin
      hit_wdata.cnt = way_rdata[hit_way_enc].cnt + 'd1;
    end
  end
  */
  always_comb begin
    hit_wdata.tag = addr_tag;
    hit_wdata.cnt = way_rdata[hit_way_enc].cnt + 'd1;
  end

  always_comb begin
    alloc_wdata.tag = addr_tag;
    alloc_wdata.cnt = 'd1;
  end

  // update counter
  generate
    for (i = 0; i < NUM_WAY; i++) begin
      assign way_wren[i] = valid ? (alloc_any ? (i == alloc_way_enc) : hit_any ? (i == hit_way_enc) : 1'b0) : 1'b0;
    end
  endgenerate
  
  //assign way_wdata = valid ? (alloc_any ? alloc_wdata : hit_any ? hit_wdata : '{default:'0}) : '{default:'0};
  assign way_wdata = hit_any ? hit_wdata : alloc_wdata;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      hot_valid <= 1'b0;
      hot_addr  <= '0;
      hot_cnt   <= '0;
    end 
    else if (epoch) begin
      hot_valid <= 1'b0;
      hot_addr  <= '0;
      hot_cnt   <= '0;
    end
    else if (valid) begin
      hot_valid <= 1'b0;
      if (hit_any) begin
        if (hit_wdata.cnt >= HOT_TH[CNT_SIZE-1:0]) begin
          hot_valid <= 1'b1;
          hot_addr  <= addr;
          hot_cnt   <= hit_wdata.cnt;
        end else begin
          hot_valid <= 1'b0;
          hot_addr  <= '0;
          hot_cnt   <= '0;
        end
      end 
    end 
    else begin
      hot_valid <= 1'b0;
    end
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      for (int s = 0; s < NUM_SET; s++) begin
        for (int w = 0; w < NUM_WAY; w++) begin
          way_valid[s][w] <= 1'b0;
        end
      end
    end 
    else if (epoch) begin
      for (int s = 0; s < NUM_SET; s++) begin
        for (int w = 0; w < NUM_WAY; w++) begin
          way_valid[s][w] <= 1'b0;
        end
      end
    end
    else if (valid_d1) begin
      // hit
      if (hit_any_d1) begin
        if (hit_wdata_d1.cnt >= HOT_TH[CNT_SIZE-1:0]) begin
          way_valid[addr_index_d1][hit_way_enc_d1] <= 1'b0;
        end else begin
          way_valid[addr_index_d1][hit_way_enc_d1] <= 1'b1;
        end
      end 
      // allocate
      else if (alloc_any_d1) begin
        way_valid[addr_index_d1][alloc_way_enc_d1] <= 1'b1;
      end 
    end 
  end

  assign output_valid = hot_valid;
  assign output_addr  = hot_addr;
  assign output_cnt   = hot_cnt;

  assign bram_addr = valid ? addr_index : input_addr_index;

  /*************** When cycle 2, bram write occur ***************/

  /*************** Module, IP Instance ***************/
  generate
    for (i = 0; i < NUM_WAY; i++) begin : BRAM_inst
      port_1_ram bram_0 (
        .data      (way_wdata),
        .q         (way_output[i]),      
        .address   (bram_addr),      
        .wren      (way_wren[i]), 
        .clock     (clk)
      );
    end
  endgenerate
endmodule
