module Mux4 #(parameter bits = 32) (input[bits-1:0] input0,  // input1
                                    input[bits-1:0] input1,  // input2
                                    input[bits-1:0] input2,  // input3 
                                    input[bits-1:0] input3,  // input4 
                                    input[1:0] sel,      // selector
                                    input[bits-1:0] out);    // bits 
    
    wire[bits-1:0] temp0, temp1;
    assign temp0 = sel[1] ? input2 : input0;
    assign temp1 = sel[1] ? input3 : input1;
    assign out = sel[0] ? temp1 : temp0;

endmodule