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
  
  /***** localparams declarations *****/
  localparam halt_register = 5'd17;
  localparam pc_increment = 31'd4;
  localparam garbage = 31'd0;
  
  /***** Wire declarations *****/
  // for Program Counter
  wire [31:0] current_pc, next_pc;
  wire write_enable_pc;
  
  // for Control Unit 
  wire PCWriteNotCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite;
  wire PCSource, ALUSrcA, RegWrite, is_ecall;
  wire [1:0] ALUOp, ALUSrcB;
  
  // for immediate generator 
  wire [31:0] imm_gen_out;
  
  // for ALU and ALU control unit 
  wire [4:0] alu_control;
  wire alu_bcond;
  
  // for Mux 
  wire [31:0] mem_addr, rs1_src, write_data, alu_src_1, alu_src_2;
  
  // current registers 
  wire [31:0] current_MDR, current_A, current_B, current_ALUOut;
  
  /***** Register declarations *****/
  reg [31:0] IR; // instruction register
  reg [31:0] MDR; // memory data register
  reg [31:0] A; // Read 1 data register
  reg [31:0] B; // Read 2 data register
  reg [31:0] ALUOut; // ALU output register
  // Do not modify and use registers declared above.
  
  // ---------- calculating a sinal for enabling PC update ----------
  assign write_enable_pc = PCWrite || (PCWriteNotCond && !alu_bcond);
  
  // ---------- Mux for selecting next PC ----------
  Mux mux_next_pc(
    .input1(ALUOut),            // input
    .input2(current_ALUOut),    // input
    .sel(PCSource),             // input
    .out(next_pc)               // output
  );

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),                      // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),                          // input
    .is_halted(is_halted),              // input
    .write_enable_pc(write_enable_pc),  // input 
    .next_pc(next_pc),                  // input
    .current_pc(current_pc)             // output
  );
  
  // ---------- Mux for Instruction or DataMemory ----------
  Mux mux_mem_addr(
    .input1(ALUOut),      // input
    .input2(current_pc),  // input 
    .sel(IorD),           // input 
    .out(mem_addr)        // output
  );
  
  // ---------- Memory ----------
  Memory memory(
    .reset(reset),         // input
    .clk(clk),             // input
    .addr(mem_addr),       // input
    .din(B),               // input
    .mem_read(MemRead),    // input
    .mem_write(MemWrite),  // input
    .dout(current_MDR)     // output
  );
  
  
  // ---------- Mux for selecting write_data ----------
  Mux mux_write_data(
    .input1(MDR),     // input
    .input2(ALUOut),  // input
    .sel(MemtoReg),   // input
    .out(write_data)  // output
  );
  
  // ---------- Mux for selecting rs1_src ----------
  Mux mux_write_data(
    .input1(halt_register),     // input
    .input2(IR[19:15]),  // input
    .sel(is_ecall),   // input
    .out(rs1_src)  // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file(
    .reset(reset),            // input
    .clk(clk),                // input
    .rs1(rs1_src),          // input
    .rs2(IR[24:20]),          // input
    .rd(IR[11:7]),            // input
    .rd_din(write_data),      // input
    .write_enable(RegWrite),  // input
    .rs1_dout(current_A),     // output
    .rs2_dout(current_B)      // output
  );
  
  // ---------- Halt Checker ----------
  HaltChecker haltchecker (
    .reset(reset),          // input
    .clk(clk),              // input
    .x17(current_A),        // input
    .is_ecall(is_ecall),    // input
    .is_halted(is_halted)   // output
  );

  // ---------- Control Unit ----------
  ControlUnit ctrl_unit(
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .instr(IR),               // input
    .imm_gen_out(imm_gen_out) // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit(
    .funct7(IR[30]),            // input
    .funct3(IR[14:12]),         // input 
    .ALUOp(ALUOp),              // input
    .alu_control(alu_control)   // output
  );
  
  // ---------- Mux for selecting alu_src_1 ----------
  Mux mux_alu_src_1(
    .input1(current_pc),  // input
    .input2(A),           // input
    .sel(ALUSrcA),        // input
    .out(alu_src_1)       // output
  );
  
  // ---------- Mux for selecting alu_src_2 ----------
  Mux4 mux_alu_src_2(
    .input1(B),             // input
    .input2(pc_increment),  // input
    .input3(imm_gen_out),   // input
    .input4(garbage),       // input
    .sel(ALUSrcB),          // input
    .out(alu_src_2)         // output
  );

  // ---------- ALU ----------
  ALU alu(
    .alu_control(alu_control),    // input
    .alu_in_1(alu_src_1),         // input  
    .alu_in_2(alu_src_2),         // input
    .alu_result(current_ALUOut),  // output
    .alu_bcond(alu_bcond)         // output
  );
  
  // ---------- updating register values ----------
  always @(posedge clk) begin
    if (reset) begin
        IR <= 0;
        MDR <= 0;
        A <= 0;
        B <= 0;
        ALUOut <= 0;
    end
    else begin
        MDR <= current_MDR;
        A <= current_A;
        B <= current_B;
        ALUOut <= current_ALUOut;
        if (IRWrite) begin
            IR <= current_MDR;
        end
    end
  end

endmodule
