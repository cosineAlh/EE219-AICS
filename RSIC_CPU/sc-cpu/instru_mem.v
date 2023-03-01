module instru_mem(pc_count, instru);
parameter width=32, pc_width = 16;
input [pc_width-1:0] pc_count;  
output [width-1:0] instru; 
reg [width-1:0] instru_memory [0:2**pc_width-1];         
initial $readmemh("instru_mem.txt", instru_memory);    
//always @(posedge clk) begin
assign instru = instru_memory[pc_count];
//end
endmodule   
