module ControlUnit(input [6:0] opcode,
                   output is_jar,
                   output is_jalr,      
                   output branch,        
                   output mem_read,        
                   output mem_to_reg,   
                   output mem_write,         
                   output alu_src,   
                   output write_enable,
                   output pc_to_reg,
                   output is_ecall);  
endmodule
