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
  parameter HOT_TH         = 20                     
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
  logic [ADDR_SIZE-1:0]  addr, addr_d1, addr_d2, hot_addr;
  logic [TAG_SIZE-1:0]   addr_tag, addr_tag_d1; 
  logic [INDEX_SIZE-1:0] input_addr_index, addr_index, addr_index_d1, addr_index_d2;
  logic [CNT_SIZE-1:0]   hot_cnt;

  // way signals
  typedef struct packed {
    logic [TAG_SIZE-1:0]   tag;
    logic [CNT_SIZE-1:0]   cnt;
  } way_t;

  way_t                        way_wdata, way_wdata_d1, hit_wdata, hit_wdata_d1, alloc_wdata;
  way_t [NUM_WAY-1:0]          way_output, way_rdata, way_rdata_d1;
  
  logic way_valid [NUM_SET][NUM_WAY-1:0];

  logic [NUM_WAY-1:0]          way_wren, way_match, way_free;
  logic                        is_forward, hit_any, alloc_any, hit_any_d1, alloc_any_d1, hit_any_d2, alloc_any_d2, collision, collision_d1, collision_d2;


  logic [$clog2(NUM_WAY)-1:0]  hit_way_enc, alloc_way_enc, evict_way_enc, hit_way_enc_d1, alloc_way_enc_d1, evict_way_enc_d1, hit_way_enc_d2, alloc_way_enc_d2, evict_way_enc_d2, bram_hit_way_enc;

  // pseudo-LRU signals
  logic [NUM_WAY-2:0] plru_bits [NUM_SET-1:0];
  logic [NUM_WAY-2:0] plru_update;
  logic [$clog2(NUM_WAY)-1:0] accessed_way;
  logic invalidate_previous_value;

  
  /*************** Latching input signals ***************/ 
  assign input_addr_index = input_addr[INDEX_SIZE-1:0];
  assign addr_index    = addr[INDEX_SIZE-1:0];
  assign addr_index_d1 = addr_d1[INDEX_SIZE-1:0];
  assign addr_index_d2 = addr_d2[INDEX_SIZE-1:0];
  assign addr_tag      = addr[ADDR_SIZE-1 -: TAG_SIZE];
  assign addr_tag_d1   = addr_d1[ADDR_SIZE-1 -: TAG_SIZE];

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
      addr_d2           <= {ADDR_SIZE{1'b0}};
      hit_way_enc_d1    <= '0;
      hit_way_enc_d2    <= '0;
      alloc_way_enc_d1  <= '0;
      alloc_way_enc_d2  <= '0;
      evict_way_enc_d1  <= '0;
      evict_way_enc_d2  <= '0;
      hit_any_d1        <= '0;
      hit_any_d2        <= '0;
      alloc_any_d1      <= '0;
      alloc_any_d2      <= '0;
      collision_d1      <= '0;
      collision_d2      <= '0;
      hit_wdata_d1      <= '0;
      for (int w = 0; w < NUM_WAY; w++) begin
        way_rdata_d1[w] <= '0;
      end
      way_wdata_d1      <= '0;
    end
    else if (epoch) begin
      valid_d1          <= 1'b0;
      addr_d1           <= {ADDR_SIZE{1'b0}};
      addr_d2           <= {ADDR_SIZE{1'b0}};
      hit_way_enc_d1    <= '0;
      hit_way_enc_d2    <= '0;
      alloc_way_enc_d1  <= '0;
      alloc_way_enc_d2  <= '0;
      evict_way_enc_d1  <= '0;
      evict_way_enc_d2  <= '0;
      hit_any_d1        <= '0;
      hit_any_d2        <= '0;
      alloc_any_d1      <= '0;
      alloc_any_d2      <= '0;
      collision_d1      <= '0;
      collision_d2      <= '0;
      hit_wdata_d1      <= '0;
      for (int w = 0; w < NUM_WAY; w++) begin
        way_rdata_d1[w] <= '0;
      end
      way_wdata_d1      <= '0;
    end
    else begin
      valid_d1          <= valid;
      addr_d1           <= addr;
      addr_d2           <= addr_d1;
      hit_way_enc_d1    <= hit_way_enc;
      hit_way_enc_d2    <= hit_way_enc_d1;
      alloc_way_enc_d1  <= alloc_way_enc;
      alloc_way_enc_d2  <= alloc_way_enc_d1;
      evict_way_enc_d1  <= evict_way_enc;
      evict_way_enc_d2  <= evict_way_enc_d1;
      hit_any_d1        <= hit_any;
      hit_any_d2        <= hit_any_d1;
      alloc_any_d1      <= alloc_any;
      alloc_any_d2      <= alloc_any_d1;
      collision_d1      <= collision;
      collision_d2      <= collision_d1;
      hit_wdata_d1      <= hit_wdata;
      for (int w = 0; w < NUM_WAY; w++) begin
        way_rdata_d1[w] <= way_rdata[w];
      end
      way_wdata_d1      <= way_wdata;
    end
  end
  
  /*************** Cycle 1: Read counter table & determine hit, allocation, collision ***************/ 
  
  assign is_forward = (hit_any_d2 || alloc_any_d2 || collision_d2) && (addr == addr_d2);
  assign invalidate_previous_value = collision_d2 & (addr_index == addr_index_d2);

  always_comb begin
    for (int w = 0; w < NUM_WAY; w++) begin
      if (valid) begin
        if (is_forward) begin
          way_rdata[w] = way_wdata_d1;
        end
        else begin
          way_rdata[w] = way_output[w];
        end
      end
      else begin
        way_rdata[w] = '{default: '0};
      end
    end
  end

  always_comb begin
    for (int w = 0; w < NUM_WAY; w++) begin
      way_match[w] = way_valid[addr_index][w] && (way_rdata[w].tag == addr_tag) && valid && ~(invalidate_previous_value && (w == evict_way_enc_d2));
      way_free[w] = ~way_valid[addr_index][w] && valid;
    end
  end

  assign hit_any = is_forward | (|way_match) ;
  assign alloc_any = (~hit_any) && (|way_free);
  assign collision = valid && !hit_any && !alloc_any;
  
  // priority encoder for hit ** TODO: hardcoded for NUM_WAY = 4 **
  assign bram_hit_way_enc[0] = way_match[1] | way_match[3];
  assign bram_hit_way_enc[1] = way_match[2] | way_match[3];

  assign hit_way_enc = ~is_forward ? bram_hit_way_enc : hit_any_d2 ? hit_way_enc_d2 : alloc_any_d2 ? alloc_way_enc_d2 : evict_way_enc_d1;

  // priority encoder for allocate ** TODO: hardcoded for NUM_WAY = 4 **
  always_comb begin 
    casez (way_free)
      4'b???1: alloc_way_enc = 2'd0;
      4'b??10: alloc_way_enc = 2'd1;
      4'b?100: alloc_way_enc = 2'd2;
      4'b1000: alloc_way_enc = 2'd3;
      default: alloc_way_enc = 2'd0;
    endcase
  end

  // pseudo-LRU logic ** TODO: hardcoded for NUM_WAY = 4 **
  assign evict_way_enc[0] = plru_bits[addr_index][2] ? plru_bits[addr_index][0] : plru_bits[addr_index][1];
  assign evict_way_enc[1] = plru_bits[addr_index][2];

  /*************** Cycle 2: Compute write data and write enable to BRAM, valid bit update, PLRU bits update ***************/ 
  always_comb begin
    hit_wdata.tag = addr_tag_d1;
    hit_wdata.cnt = way_rdata_d1[hit_way_enc_d1].cnt + 'd1;
    alloc_wdata.tag = addr_tag_d1;
    alloc_wdata.cnt = 'd1;
  end

  // pseudo-LRU logic
  assign accessed_way = hit_any_d1 ? hit_way_enc_d1 : alloc_any_d1 ? alloc_way_enc_d1 : evict_way_enc_d1;

  always_comb begin
    if (valid_d1) begin
      case (accessed_way) // ** TODO: hardcoded for NUM_WAY = 4 **
        2'b00: plru_update = {1'b1, 1'b1, plru_bits[addr_index_d1][0]};
        2'b01: plru_update = {1'b1, 1'b0, plru_bits[addr_index_d1][0]};
        2'b10: plru_update = {1'b0, plru_bits[addr_index_d1][1], 1'b1};
        2'b11: plru_update = {1'b0, plru_bits[addr_index_d1][1], 1'b0};
      endcase
    end
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      for (int s = 0; s < NUM_SET; s++) begin
        plru_bits[s] <= 3'b111;
      end
    end
    else if (epoch) begin
      for (int s = 0; s < NUM_SET; s++) begin
        plru_bits[s] <= 3'b111;
      end
    end
    else if (valid_d1) begin
      plru_bits[addr_index_d1] <= plru_update;
    end
  end

  // ready counter write (update at cycle 3)
  generate
    for (i = 0; i < NUM_WAY; i++) begin
      assign way_wren[i] = valid_d1 ? (alloc_any_d1 ? (i == alloc_way_enc_d1) : hit_any_d1 ? (i == hit_way_enc_d1) : (i == evict_way_enc_d1)) : 1'b0;
    end
  endgenerate
  
  assign way_wdata = hit_any_d1 ? hit_wdata : alloc_wdata; // evict wdata is same with alloc wdata.

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
    else if (valid_d1) begin
      hot_valid <= 1'b0;
      if (hit_any_d1) begin
        if (way_rdata_d1[hit_way_enc_d1].cnt >= HOT_TH[CNT_SIZE-1:0] - 1) begin
          hot_valid <= 1'b1;
          hot_addr  <= addr;
          hot_cnt   <= hit_wdata.cnt;
        end 
        else begin
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
        if (way_rdata_d1[hit_way_enc_d1].cnt >= HOT_TH[CNT_SIZE-1:0] - 1) begin
          way_valid[addr_index_d1][hit_way_enc_d1] <= 1'b0;
        end else 
        begin
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

  /*************** Cycle 3: BRAM write & next read cycle 1 ***************/ 

  /*************** Module, IP Instance ***************/
  generate
    for (i = 0; i < NUM_WAY; i++) begin : BRAM_inst
      port_2_ram bram_0 (
        .data       (way_wdata),
        .q          (way_output[i]),
        .wraddress  (addr_index),
        .rdaddress  (input_addr_index),
        .wren       (way_wren[i]),
        .clock      (clk)
      );  
    end
  endgenerate
endmodule