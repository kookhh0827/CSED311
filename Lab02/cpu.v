// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/
  // for Program Counter
  wire [31:0] current_pc, next_pc;
  // for InstMemory output
  wire [31:0] instr;  
  // for RegisterFile outputs
  wire [31:0] rs1_dout, rs2_dout; 
  // for Control Unit outputs
  wire is_jal, is_jalr, branch, mem_read, mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, is_ecall;
  // for Immedate Generate output
  wire [31:0] imm_gen_out;
  // for ALU Control Unit output
  wire [8:0] alu_op; // 8 bits to cover <= 256 alu_ops
  // for ALU outputs
  wire [31:0] alu_result;
  wire alu_bcond;
  // for Dmem output
  wire [31:0] dmem_dout;
  // for all muxs
  wire [31:0] rd_din, alu_in_2, last_result;
  // for conditional branch
  wire [31:0] current_pc_plus_4 = current_pc + 4;
  wire [31:0] current_pc_plus_imm = current_pc + imm_gen_out;
  wire [31:0] current_pc_after_mux_prsrc_1;
  wire PCSrc_1 = (branch & alu_bcond) | is_jal;
  wire PCSrc_2 = is_jalr;
  
  /***** Register declarations *****/

  // ---------- Update program counter ----------
  
  // first mux for conditional branch
  Mux mux_pcsrc_1 (
    .input1(current_pc_plus_imm),
    .input2(current_pc_plus_4),
    .sel(PCSrc_1),
    .out(current_pc_after_mux_prsrc_1)
  );
  
  // second mux for conditional branch
  Mux mux_pcsrc_2 (
    .input1(alu_result),
    .input2(current_pc_after_mux_prsrc_1),
    .sel(PCSrc_2),
    .out(next_pc)
  );
  
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),            // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),                // input
    .next_pc(next_pc),        // input
    .current_pc(current_pc)   // output
  );
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),        // input
    .clk(clk),            // input
    .addr(current_pc),    // input
    .dout(instr)          // output
  );
  
  // mux for rd_din = mux(current_pc_plus_4, last_result; PCtoReg)
  Mux mux_pc_to_reg (
    .input1(current_pc_plus_4),
    .input2(last_result),
    .sel(pc_to_reg),
    .out(rd_din)
  );

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset(reset),                // input
    .clk(clk),                    // input
    .rs1(instr[19:15]),           // input
    .rs2(instr[24:20]),           // input
    .rd(instr[11:7]),             // input
    .rd_din(rd_din),              // input
    .write_enable(write_enable),  // input
    .rs1_dout(rs1_dout),          // output
    .rs2_dout(rs2_dout)           // output
  );

   
  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .opcode(instr[6:0]),         // input
    .is_jal(is_jal),             // output
    .is_jalr(is_jalr),           // output
    .branch(branch),             // output
    .mem_read(mem_read),         // output
    .mem_to_reg(mem_to_reg),     // output
    .mem_write(mem_write),       // output
    .alu_src(alu_src),           // output
    .write_enable(write_enable), // output
    .pc_to_reg(pc_to_reg),       // output
    .is_ecall(is_ecall)          // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .instr(instr[31:0]),         // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .opcode(instr[6:0]),   // input
    .funct3(instr[14:12]), // input
    .funct7(instr[31:25]), //input
    .alu_op(alu_op)        // output
  );
  
  // mux for alu_in_2 = mux(imm_gen_out, rs2_dout; ALUSrc)
  Mux mux_aru_src (
    .input1(imm_gen_out),
    .input2(rs2_dout),
    .sel(alu_src),
    .out(alu_in_2)
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(alu_op),         // input
    .alu_in_1(rs1_dout),     // input  
    .alu_in_2(alu_in_2),     // input
    .alu_result(alu_result), // output
    .alu_bcond(alu_bcond)    // output
  );

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset(reset),          // input
    .clk(clk),              // input
    .addr(alu_result),      // input
    .din(rs2_dout),         // input
    .mem_read(mem_read),    // input
    .mem_write(mem_write),  // input
    .dout(dmem_dout)        // output
  );
  
  // mux for last_result = mux(dmem_dout, alu_result; MemtoReg)
  Mux mux_mem_to_reg (
    .input1(dmem_dout),
    .input2(alu_result),
    .sel(mem_to_reg),
    .out(last_result)
  );
  
endmodule
