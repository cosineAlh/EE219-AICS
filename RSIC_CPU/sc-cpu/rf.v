module rf(reg1, reg2, wr, data, reg_wr, d1, d2, clk);
parameter reg_width=32, num_reg=32;
input [4:0] reg1, reg2, reg_wr; input wr, clk; input [reg_width-1:0] data; output reg [reg_width-1:0] d1, d2; 
reg [reg_width-1:0] reg_file [0:num_reg-1];          
always @(*) begin d1 = reg_file[reg1]; d2 = reg_file[reg2];end
always @(posedge clk) begin
if (wr) reg_file[reg_wr] <= data;
end
initial $readmemh("rf.txt",reg_file);
generate
  genvar idx;
  for(idx = 0; idx < 32; idx = idx+1) begin: register
    wire [31:0] tmp;
    assign tmp = reg_file[idx];
  end
endgenerate

endmodule
