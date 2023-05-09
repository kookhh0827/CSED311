// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify modules (except InstMemory, DataMemory, and RegisterFile)
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted); // Whehther to finish simulation
  /***** localparams declarations *****/
  localparam halt_register = 5'd17;
  localparam garbage = 32'd0;

  /***** Wire declarations *****/
  // for btb
  wire [4:0] = IF_bhsr;
  // for Program Counter
  wire [31:0] current_pc, next_pc;
  wire [31:0] pc_plus_4, pc_plus_imm;
  wire [1:0] pc_src;
  // for InstMemory output
  wire [31:0] instr;
  // for RegisterFile outputs
  wire [31:0] rs1_dout, rs2_dout;
  // for Control Unit outputs
  wire is_jal_in, is_jalr_in, is_branch_in, mem_read_in, mem_to_reg_in, mem_write_in, alu_src_in, write_enable_in, pc_to_reg_in, is_ecall_in;
  wire [1:0] alu_op_in;
  // for Control Unit MUX outputs
  wire is_jal_out, is_jalr_out, is_branch_out, mem_read_out, mem_to_reg_out, mem_write_out, alu_src_out, write_enable_out, pc_to_reg_out, is_ecall_out;
  wire [1:0] alu_op_out;
  // for Immedate Generate output
  wire [31:0] imm_gen_out;
  // for data dowarding
  wire [1:0] forward_rs1, forward_rs2;
  wire [31:0] foward_src_1, foward_src_2;
  // for ALU and ALU control unit 
  wire [4:0] alu_control;
  wire [31:0] alu_src_2, alu_result;
  wire alu_bcond;
  wire [31:0] alu_out; // select between alu_result or ID_EX_pc + 4
  // for Dmem output
  wire [31:0] dmem_dout;
  // for register write
  wire [31:0] write_data;
  // for halt checker
  wire [4:0] rs1_src;
  wire id_is_halted;
  // for flush or stall
  wire is_flush, is_stall;
  // for ecall data forwarding
  wire is_ecall_forward;
  wire [31:0] x17;
  
  /***** Register declarations *****/
  // You need to modify the width of registers
  // In addition, 
  // 1. You might need other pipeline registers that are not described below
  // 2. You might not need registers described below
  /***** IF/ID pipeline registers *****/
  reg [31:0] IF_ID_inst;    // will be used in ID stage
  reg [31:0] IF_ID_pc;      // will be used in EX stage
  reg [4:0] IF_ID_bhsr;

  /***** ID/EX pipeline registers *****/
  // From the control unit
  reg [1:0] ID_EX_alu_op;   // will be used in EX stage
  reg ID_EX_alu_src;        // will be used in EX stage
  reg ID_EX_mem_write;      // will be used in MEM stage
  reg ID_EX_mem_read;       // will be used in MEM stage
  reg ID_EX_mem_to_reg;     // will be used in WB stage
  reg ID_EX_reg_write;      // will be used in WB stage
  reg ID_EX_is_jal;
  reg ID_EX_is_jalr;
  reg ID_EX_is_branch;
  reg ID_EX_pc_to_reg;
  // From halt checker
  reg ID_EX_is_halted;      // will be used in WB stage
  // From others
  reg [31:0] ID_EX_pc;      // will be used in EX stage
  reg [31:0] ID_EX_rs1_data;
  reg [31:0] ID_EX_rs2_data;
  reg [31:0] ID_EX_imm;
  reg [3:0] ID_EX_ALU_ctrl_unit_input;
  reg [4:0] ID_EX_rs1;
  reg [4:0] ID_EX_rs2;
  reg [4:0] ID_EX_rd;
  reg [4:0] ID_EX_bhsr;

  /***** EX/MEM pipeline registers *****/
  // From the control unit
  reg EX_MEM_mem_write;     // will be used in MEM stage
  reg EX_MEM_mem_read;      // will be used in MEM stage
  reg EX_MEM_mem_to_reg;    // will be used in WB stage
  reg EX_MEM_reg_write;     // will be used in WB stage
  // From halt checker
  reg EX_MEM_is_halted;      // will be used in WB stage
  // From others
  reg [31:0] EX_MEM_alu_out;
  reg [31:0] EX_MEM_dmem_data;
  reg [4:0] EX_MEM_rd;

  /***** MEM/WB pipeline registers *****/
  // From the control unit
  reg MEM_WB_mem_to_reg;    // will be used in WB stage
  reg MEM_WB_reg_write;     // will be used in WB stage
  // From halt checker
  reg MEM_WB_is_halted;      // will be used in WB stage
  // From others
  reg [31:0] MEM_WB_mem_to_reg_src_1;
  reg [31:0] MEM_WB_mem_to_reg_src_2;
  reg [4:0] MEM_WB_rd;

  // ---------- Calculating PC + imm in EX stage ----------
  assign pc_plus_imm = ID_EX_pc + ID_EX_imm;

  // ---------- Branch Target Buffer ----------
  BranchTargetBuffer BTB(
    .reset(reset),
    .clk(clk),
    .current_pc(current_pc),            // input
    .IF_ID_pc(IF_ID_pc),                // input
    .ID_EX_pc(ID_EX_pc),                // input
    .EX_pc_plus_imm(pc_plus_imm),       // input
    .EX_alu_result(alu_result),         // input
    .ID_EX_is_branch(ID_EX_is_branch),  // input
    .ID_EX_is_jal(ID_EX_is_jal),        // input
    .ID_EX_is_jalr(ID_EX_is_jalr),      // input
    .EX_alu_bcond(alu_bcond),           // input
    .ID_EX_bhsr(ID_EX_bhsr),            // input
    .current_bhsr(IF_bhsr),             // input
    .is_flush(is_flush),                // output
    .next_pc(next_pc)                   // output
  );

  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),            // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),                // input
    .is_flush(is_flush),      // input
    .is_stall(is_stall),      // input
    .next_pc(next_pc),        // input
    .current_pc(current_pc)   // output
  );
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),      // input
    .clk(clk),          // input
    .addr(current_pc),  // input
    .dout(instr)        // output
  );

  // Update IF/ID pipeline registers here
  always @(posedge clk) begin
    if (reset || is_flush) begin
      IF_ID_inst <= 0;
      IF_ID_pc <= 0;
      IF_ID_bhsr <= 0;
    end
    else if(is_stall) begin
      IF_ID_inst <= IF_ID_inst;
      IF_ID_pc <= IF_ID_pc;
      IF_ID_bhsr <= IF_ID_bhsr;
    end
    else begin
      IF_ID_inst <= instr;
      IF_ID_pc <= current_pc;
      IF_ID_bhsr <= IF_bhsr;
    end
  end

  // ---------- Mux for selecting rs1_src ----------
  Mux #(.bits(5)) mux_rs1_src( 
    .input0(IF_ID_inst[19:15]),  // input
    .input1(halt_register),      // input
    .sel(is_ecall_out),          // input
    .out(rs1_src)                // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset(reset),                   // input
    .clk(clk),                       // input
    .rs1(rs1_src),                   // input
    .rs2(IF_ID_inst[24:20]),         // input
    .rd(MEM_WB_rd),                  // input
    .rd_din(write_data),             // input
    .write_enable(MEM_WB_reg_write), // input
    .rs1_dout(rs1_dout),             // output
    .rs2_dout(rs2_dout)              // output
  );

  // ------- Hazard Detection ----------
  HazardDetection hazard_detection(
    .rs1(IF_ID_inst[19:15]),            // input
    .rs2(IF_ID_inst[24:20]),            // input
    .opcode(IF_ID_inst[6:0]),           // input
    .ID_EX_mem_read(ID_EX_mem_read),    // input
    .ID_EX_rd(ID_EX_rd),                // input
    .is_ecall(is_ecall_in),             // input
    .ID_EX_reg_write(ID_EX_reg_write),  // input
    .EX_MEM_rd(EX_MEM_rd),              // input
    .EX_MEM_mem_read(EX_MEM_mem_read),  // input
    .is_stall(is_stall)                 // output
  );

  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .opcode(IF_ID_inst[6:0]),           // input
    .is_jal(is_jal_in),                 // output
    .is_jalr(is_jalr_in),               // output
    .is_branch(is_branch_in),           // output
    .mem_read(mem_read_in),             // output
    .mem_to_reg(mem_to_reg_in),         // output
    .mem_write(mem_write_in),           // output
    .alu_src(alu_src_in),               // output
    .write_enable(write_enable_in),     // output
    .pc_to_reg(pc_to_reg_in),           // output
    .alu_op(alu_op_in),                 // output
    .is_ecall(is_ecall_in)              // output (ecall inst)
  );
  
  Mux #(.bits(12)) mux_control_unit( 
    .input0({is_jal_in, is_jalr_in, is_branch_in, mem_read_in, mem_to_reg_in, mem_write_in, alu_src_in, write_enable_in, pc_to_reg_in, is_ecall_in, alu_op_in}),        // input
    .input1(12'b000000000000),                                                                                                                                          // input
    .sel(is_stall || is_flush),                                                                                                                                         // input
    .out({is_jal_out, is_jalr_out, is_branch_out, mem_read_out, mem_to_reg_out, mem_write_out, alu_src_out, write_enable_out, pc_to_reg_out, is_ecall_out, alu_op_out}) // output
  );

  // ---------- ecall data forward selector ----------
  assign is_ecall_forward = EX_MEM_reg_write && (EX_MEM_rd == 17);

  // ---------- Mux for selecting x17 ----------
  Mux mux_x17( 
    .input0(rs1_dout),        // input
    .input1(EX_MEM_alu_out),  // input
    .sel(is_ecall_forward),   // input
    .out(x17)                 // output
  );

  // ---------- Halt Checker ----------
  HaltChecker haltchecker (
    .x17(x17),                 // input
    .is_ecall(is_ecall_out),   // input
    .is_halted(id_is_halted)   // output
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .instr(IF_ID_inst[31:0]),  // input
    .imm_gen_out(imm_gen_out)  // output
  );

  // Update ID/EX pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      ID_EX_pc <= 0;
      ID_EX_alu_op <= 2'b00;
      ID_EX_alu_src <= 0;
      ID_EX_mem_write <= 0;
      ID_EX_mem_read <= 0;
      ID_EX_mem_to_reg <= 0;
      ID_EX_reg_write <= 0;
      ID_EX_is_jal <= 0;
      ID_EX_is_jalr <= 0;
      ID_EX_is_branch <= 0;
      ID_EX_pc_to_reg <= 0;
      ID_EX_is_halted <= 0;
      ID_EX_rs1_data <= 0;
      ID_EX_rs2_data <= 0;
      ID_EX_imm <= 0;
      ID_EX_ALU_ctrl_unit_input <= 0;
      ID_EX_rs1 <= 0;
      ID_EX_rs2 <= 0;
      ID_EX_rd <= 0;
      ID_EX_bhsr <= 0;
    end
    else begin
      ID_EX_pc <= IF_ID_pc;
      ID_EX_alu_op <= alu_op_out;
      ID_EX_alu_src <= alu_src_out;
      ID_EX_mem_write <= mem_write_out;
      ID_EX_mem_read <= mem_read_out;
      ID_EX_mem_to_reg <= mem_to_reg_out;
      ID_EX_reg_write <= write_enable_out;
      ID_EX_is_jal <= is_jal_out;
      ID_EX_is_jalr <= is_jalr_out;
      ID_EX_is_branch <= is_branch_out;
      ID_EX_pc_to_reg <= pc_to_reg_out;
      ID_EX_is_halted <= id_is_halted;
      ID_EX_rs1_data <= rs1_dout;
      ID_EX_rs2_data <= rs2_dout;
      ID_EX_imm <= imm_gen_out;
      ID_EX_ALU_ctrl_unit_input <= {IF_ID_inst[30], IF_ID_inst[14:12]};
      ID_EX_rs1 <= IF_ID_inst[19:15];
      ID_EX_rs2 <= IF_ID_inst[24:20];
      ID_EX_rd <= IF_ID_inst[11:7];
      ID_EX_bhsr <= IF_ID_bhsr;
    end
  end

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .funct7(ID_EX_ALU_ctrl_unit_input[3]),    // input
    .funct3(ID_EX_ALU_ctrl_unit_input[2:0]),  // input
    .alu_op(ID_EX_alu_op),                    // input
    .alu_control(alu_control)                 // output
  );

  // ---------- Forwarding Unit ----------
  ForwardingUnit fowarding_unit (
    .rs1_ex(ID_EX_rs1),                     // input
    .rs2_ex(ID_EX_rs2),                     // input
    .rd_mem(EX_MEM_rd),                     // input
    .register_write_mem(EX_MEM_reg_write),  // input
    .rd_wb(MEM_WB_rd),                      // input
    .register_write_wb(MEM_WB_reg_write),   // input
    .forward_rs1(forward_rs1),              // output
    .forward_rs2(forward_rs2)               // output
  );

  // ---------- Mux for selecting foward_src_1 ----------
  Mux4 mux_foward_src_1(
    .input0(ID_EX_rs1_data),       // input
    .input1(EX_MEM_alu_out),  // input
    .input2(write_data),      // input
    .input3(garbage),         // input
    .sel(forward_rs1),        // input
    .out(foward_src_1)        // output
  );

  // ---------- Mux for selecting foward_src_2 ----------
  Mux4 mux_foward_src_2(
    .input0(ID_EX_rs2_data),       // input
    .input1(EX_MEM_alu_out),  // input
    .input2(write_data),      // input
    .input3(garbage),         // input
    .sel(forward_rs2),        // input
    .out(foward_src_2)        // output
  );

  // ---------- Mux for selecting alu_src_2 ----------
  Mux mux_alu_src_2(
    .input0(foward_src_2),      // input
    .input1(ID_EX_imm),         // input
    .sel(ID_EX_alu_src),        // input
    .out(alu_src_2)             // output
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_control(alu_control),      // input
    .alu_in_1(foward_src_1),        // input  
    .alu_in_2(alu_src_2),           // input
    .alu_result(alu_result),        // output
    .alu_bcond(alu_bcond)           // output
  );

  Mux mux_alu_out(
    .input0(alu_result),      // input
    .input1(ID_EX_pc + 4),    // input
    .sel(ID_EX_pc_to_reg),    // input
    .out(alu_out)             // output
  );

  // Update EX/MEM pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      EX_MEM_mem_write <= 0;
      EX_MEM_mem_read <= 0;
      EX_MEM_mem_to_reg <= 0;
      EX_MEM_reg_write <= 0;
      EX_MEM_is_halted <= 0;
      EX_MEM_alu_out <= 0;
      EX_MEM_dmem_data <= 0;
      EX_MEM_rd <= 0;
    end
    else begin
      EX_MEM_mem_write <= ID_EX_mem_write;
      EX_MEM_mem_read <= ID_EX_mem_read;
      EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;
      EX_MEM_reg_write <= ID_EX_reg_write;
      EX_MEM_is_halted <= ID_EX_is_halted;
      EX_MEM_alu_out <= alu_out;
      EX_MEM_dmem_data <= foward_src_2;
      EX_MEM_rd <= ID_EX_rd;
    end
  end

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset(reset),                 // input
    .clk(clk),                     // input
    .addr(EX_MEM_alu_out),         // input
    .din(EX_MEM_dmem_data),        // input
    .mem_read(EX_MEM_mem_read),    // input
    .mem_write(EX_MEM_mem_write),  // input
    .dout(dmem_dout)               // output
  );

  // Update MEM/WB pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      MEM_WB_mem_to_reg <= 0;
      MEM_WB_reg_write <= 0;
      MEM_WB_is_halted <= 0;
      MEM_WB_mem_to_reg_src_1 <= 0;
      MEM_WB_mem_to_reg_src_2 <= 0;
      MEM_WB_rd <= 0;
    end
    else begin
      MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;
      MEM_WB_reg_write <= EX_MEM_reg_write;
      MEM_WB_is_halted <= EX_MEM_is_halted;
      MEM_WB_mem_to_reg_src_1 <= dmem_dout;
      MEM_WB_mem_to_reg_src_2 <= EX_MEM_alu_out;
      MEM_WB_rd <= EX_MEM_rd;
    end
  end

  // ---------- Mux for selecting write_data ----------
  Mux mux_write_data(
    .input0(MEM_WB_mem_to_reg_src_2),  // input
    .input1(MEM_WB_mem_to_reg_src_1),  // input
    .sel(MEM_WB_mem_to_reg),           // input
    .out(write_data)                   // output
  );
  
  // halt output 
  assign is_halted = MEM_WB_is_halted;
  
endmodule
