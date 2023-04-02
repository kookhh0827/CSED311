`include "states.v"
`include "opcodes.v"

module AddressSelector(input [6:0] opcode,
                       input [4:0] cs_plus_1,
                       input [1:0] AddrCtl,
                       input alu_bcond,
                       output [4:0] next_state);
    localparam ZERO = 5'd0;
    
    wire [1:0] branch_not_taken = {2{(alu_bcond == 1'b0 && cs_plus_1 == `EX2_B) ? 1'b1 : 1'b0}};
    wire [1:0] address_select = AddrCtl & ~branch_not_taken;
    
    reg [4:0] dispatch_rom_0, dispatch_rom_1;
    
    // dispatch rom 0
    always @(*) begin
        case(opcode)
        `ARITHMETIC:      dispatch_rom_0 = `EX1_R;
        `ARITHMETIC_IMM: dispatch_rom_0 = `EX1_I;
        `LOAD,
        `STORE:           dispatch_rom_0 = `EX_LW;
        `BRANCH:          dispatch_rom_0 = `EX1_B;
        `JALR:            dispatch_rom_0 = `WB_JALR;
        `JAL:             dispatch_rom_0 = `WB_JAL;
        `ECALL:           dispatch_rom_0 = `IF1;
        default:          dispatch_rom_0 = `IF1;
        endcase
    end
    
    // dispatch rom 1
    always @(*) begin
        case(opcode)
        `ARITHMETIC,
        `ARITHMETIC_IMM: dispatch_rom_1 = `WB_R;
        `LOAD:            dispatch_rom_1 = `MEM1_RD;
        `STORE:           dispatch_rom_1 = `MEM1_WR;
        `BRANCH,
        `JALR,
        `JAL,
        `ECALL:           dispatch_rom_1 = `IF1;
        default:          dispatch_rom_1 = `IF1;
        endcase
    end
    
    Mux4 #(.bits(5)) mux_next_state(
        .input0(ZERO),
        .input1(dispatch_rom_0),
        .input2(dispatch_rom_1),
        .input3(cs_plus_1),
        .sel(address_select),
        .out(next_state)
    );
    
endmodule

