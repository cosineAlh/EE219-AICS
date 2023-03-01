module data_mem(addr, clk, data, rd, wr);
parameter width=32, addr_width = 16, depth = 2**addr_width;
input [addr_width-1:0] addr; input clk, rd, wr; 
inout [width-1:0] data;  
reg [width-1:0] data_memory[0:depth-1]; 
reg [width-1:0] tmp_data;        
initial $readmemh("data.txt", data_memory); 
always @(posedge clk) begin
if (wr&!rd) begin data_memory[addr] <= data;end
end   
always @(wr,rd) begin
if (!wr&rd) begin tmp_data <= data_memory[addr];end
end
assign data=(rd&!wr)?tmp_data:{width{1'bz}};
//to observe the array
generate
  genvar idx;
  for(idx = 0; idx < depth; idx = idx+1) begin: register
    wire [31:0] tmp;
    assign tmp = data_memory[idx];
  end
endgenerate
endmodule
