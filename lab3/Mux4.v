module Mux4(input[31:0] input1,  // input1
            input[31:0] input2,  // input2
            input[31:0] input3,  // input3 
            input[31:0] input4,  // input4 
            input[1:0] sel,      // selector
            input[31:0] out);    // output
    
    wire[31:0] temp1, temp2;
    assign temp1 = sel[1] ? input3 : input1;
    assign temp2 = sel[1] ? input4 : input2;
    assign out = sel[0] ? temp1 : temp2;

endmodule