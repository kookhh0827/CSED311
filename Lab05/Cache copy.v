`include "CLOG2.v"

module Cache #(parameter LINE_SIZE = 16,
               parameter NUM_SETS = 1
               parameter NUM_WAYS = 16) (
    input reset,
    input clk,

    input [31:0] addr,
    input mem_read,
    input mem_write,
    input [31:0] din,

    output is_ready,
    output is_output_valid,
    output [31:0] dout,
    output is_hit);
  
  integer i;

  // Wire declarations
  wire is_data_mem_ready;
  wire bo = addr[3:2];
  wire idx = addr[CLOG2(NUM_WAYS)+3:4];
  wire tag = addr[31:CLOG2(NUM_WAYS)+4];
  wire line_addr = (addr >> CLOG2(LINE_SIZE)) << CLOG2(LINE_SIZE);

  wire is_output_valid;
  wire [LINE_SIZE * 8 - 1:0] memory_dout;

  // Reg declarations
  // You might need registers to keep the status.
  reg valid_bank [NUM_WAYS-1:0];
  reg dirty_bank [NUM_WAYS-1:0];
  reg [31 - CLOG2(NUM_WAYS) - 4 - 1:0] tag_bank [NUM_WAYS-1:0];
  reg [LINE_SIZE * 8 - 1:0] data_bank [NUM_WAYS-1:0];

  reg is_write_back, _is_write_back;
  reg is_input_valid, mem_mem_read, mem_mem_write;
  reg is_input_valid;

  assign is_ready = is_data_mem_ready;
  assign is_hit = ((tag_bank[idx] == tag) && valid_bank[idx]);
  assign is_output_valid = is_ready && is_hit;
  assign dout = data_bank[idx][((bo+1) << CLOG2(32)) - 1 : bo << CLOG2(32)];
  
  always @(*) begin
    _is_write_back = 0;
    is_input_valid = 0;
    
    if (!is_hit) begin
      if (valid_bank[idx] && dirty_bank[idx]) begin
        _is_write_back = 1;
        is_input_valid = 1;
        mem_mem_read = 0;
        mem_mem_write = 1;
        is_input_valid = 1;
      end
      else begin
        _is_write_back = 0;
        is_input_valid = 1;
        mem_mem_read = 1;
        mem_mem_write = 0;
        is_input_valid = 1;
      end
    end
    else begin
      _is_write_back = 0;
      is_input_valid = 0;
      mem_mem_read = 0;
      mem_mem_write = 0;
      is_input_valid = 0;
    end
  end
  
  always @(posedge clk) begin
    if (reset) begin
      for (i = 0; i < NUM_WAYS; i = i + 1) begin
        valid_bank[i] <= 0;
        dirty_bank[i] <= 0;
        tag_bank[i] <= 0;
        data_bank[i] <= 0;
      end
      is_write_back <= 0;
    end
    else begin
      is_write_back <= _is_write_back;

      if (is_output_valid) begin
        valid_bank[idx] <= 1;
        dirty_bank[idx] <= 0;
        tag_bank[idx] <= tag;
        data_bank[idx] <= memory_dout;
        if (mem_write) begin
          dirty_bank[idx] <= 1;
          data_bank[idx][((bo+1) << CLOG2(32)) - 1 : bo << CLOG2(32)] <= din;
        end
      end
      else if (!_is_write_back && mem_write) begin
        dirty_bank[idx] <= 1;
        data_bank[idx][((bo+1) << CLOG2(32)) - 1 : bo << CLOG2(32)] <= din;
      end
      else if (is_write_back && mem_ready) begin
        dirty_bank[idx] <= 0;
      end
    end
  end

  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),

    .is_input_valid(is_input_valid),
    .addr(line_addr),        // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read(mem_mem_read),
    .mem_write(mem_mem_write),
    .din(data_bank[idx]),

    // is output from the data memory valid?
    .is_output_valid(is_output_valid),
    .dout(memory_dout),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );
endmodule
