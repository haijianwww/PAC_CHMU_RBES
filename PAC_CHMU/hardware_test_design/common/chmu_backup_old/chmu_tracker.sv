module chmu_tracker #(
  parameter ADDR_SIZE      = 21,
  parameter INDEX_SIZE     = 10,
  parameter NUM_WAY        = 4,
  parameter TAG_SIZE       = ADDR_SIZE - INDEX_SIZE,
  parameter CNT_SIZE       = 12,
  parameter HOT_TH         = 100,
  parameter LIST_SIZE      = 32,
  parameter SAMPLING_RATE  = 1
)(
  input  logic                          clk,
  input  logic                          rst_n,

  input  logic [ADDR_SIZE-1:0]          input_addr,
  input  logic                          input_addr_valid,
  output logic                          output_addr_ready,

  input  logic                          query_en,
  output logic                          query_ready,

  output logic                          mig_addr_cnt_en,
  output logic [ADDR_SIZE+CNT_SIZE-1:0] mig_addr_cnt,
  input  logic                          mig_addr_cnt_ready
);

  // wiring between stages
  logic [ADDR_SIZE-1:0]  sampling_output_addr;
  logic                  sampling_output_addr_valid;

  logic [ADDR_SIZE-1:0]  counter_hot_addr;
  logic [CNT_SIZE-1:0]   counter_hot_cnt;
  logic                  counter_hot_valid;

  logic [1:0]                  state, next_state;
  localparam STATE_IDLE  				= 2'd0;
  localparam STATE_REQ_1  			= 2'd1;
  localparam STATE_REQ_2        = 2'd2;
  localparam STATE_EPOCH        = 2'd3;

  // state transition
  always_comb begin
    next_state = STATE_IDLE;
    case(state)
      STATE_IDLE: begin
        if (query_en) begin
          next_state = STATE_EPOCH;
        end
        else if (input_addr_valid) begin
          next_state = STATE_REQ_1;
        end
      end
      STATE_REQ_1: begin
        if (query_en) begin
          next_state = STATE_EPOCH;
        end
        else begin
          next_state = STATE_REQ_2;
        end
      end
      STATE_REQ_2: begin 
        if (query_en) begin
          next_state = STATE_EPOCH;
        end
        else if (input_addr_valid) begin
          next_state = STATE_REQ_1;
        end        
      end   
      STATE_EPOCH: begin 
        if (query_en) begin
          next_state = STATE_EPOCH;
        end
        else if (input_addr_valid) begin
          next_state = STATE_REQ_1;
        end
      end
      default:;
    endcase 
  end

  assign output_addr_ready = (state == STATE_IDLE) | (state == STATE_REQ_2);

  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= 2'b0;
    end
    else begin
      state <= next_state;
    end
  end

  sampling_module #(
    .ADDR_SIZE     (ADDR_SIZE),
    .SAMPLING_RATE (SAMPLING_RATE)
  ) 
  u_sampling_module (
    .clk               (clk),
    .rst_n             (rst_n),

    .input_addr        (input_addr),
    .input_addr_valid  (input_addr_valid),
    .epoch             (query_en),
    
    .output_addr       (sampling_output_addr),
    .output_addr_valid (sampling_output_addr_valid)
  );

  counter_set #(
    .ADDR_SIZE (ADDR_SIZE),
    .INDEX_SIZE(INDEX_SIZE),
    .NUM_WAY   (NUM_WAY),
    .TAG_SIZE  (TAG_SIZE),
    .CNT_SIZE  (CNT_SIZE),
    .HOT_TH    (HOT_TH)
  )
  u_counter_set (
    .clk               (clk),
    .rst_n             (rst_n),

    .input_addr        (sampling_output_addr),
    .input_addr_valid  (sampling_output_addr_valid),
    .epoch             (query_en),

    .output_addr       (counter_hot_addr),
    .output_cnt        (counter_hot_cnt),
    .output_valid      (counter_hot_valid)
  );

  hotlist #(
    .ADDR_SIZE (ADDR_SIZE),
    .CNT_SIZE  (CNT_SIZE),
    .LIST_SIZE (LIST_SIZE)
  ) 
  u_hotlist (
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .input_addr             (counter_hot_addr), 
    .input_cnt              (counter_hot_cnt),
    .input_valid            (counter_hot_valid),
    
    .query_en               (query_en),
    .query_ready            (query_ready),

    .mig_addr_cnt_en        (mig_addr_cnt_en),
    .mig_addr_cnt           (mig_addr_cnt),
    .mig_addr_cnt_ready     (mig_addr_cnt_ready)
  );

endmodule