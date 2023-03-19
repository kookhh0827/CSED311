`include "opcodes.v"

module Mux(input[31:0] input1,  // input1
           input[31:0] input2,  // input2
           input sel,           // selector
           input[31:0] out);     // output    

    assign out = sel ? input1 : input2;

endmodule