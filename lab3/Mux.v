module Mux #(parameter bits = 32) (input[bits-1:0] input0,  // input1
                                    input[bits-1:0] input1,  // input2
                                    input sel,           // selector
                                    input[bits-1:0] out);     // output    

    assign out = sel ? input1 : input0;

endmodule