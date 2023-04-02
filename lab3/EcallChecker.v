`include "states.v"
`include "opcodes.v"

module EcallChecker(input [4:0] current_state,
                    input [6:0] opcode,
                    output is_ecall);
    
    assign is_ecall = (current_state == `ID && opcode == `ECALL) ? 1 : 0;
endmodule

