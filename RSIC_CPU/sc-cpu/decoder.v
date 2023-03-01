module decoder(instru, zero, aluop, reg_wr, reg_src, data_rd, data_wr, alu_src, pc_src, rs1, rs2, imm, rd);
input [31:0] instru; input zero; output reg reg_wr, reg_src, data_rd, data_wr, alu_src, pc_src; 
output reg [4:0] rs1, rs2, rd; output reg [31:0] imm; output reg [1:0] aluop; output reg [2:0] funct3; 
wire [16:0] func;    

always@(*) begin rs2 = instru[24:20]; rd = instru[11:7]; rs1 = instru[19:15]; 
funct3 = instru[14:12]; end
assign func = {instru[31:25], instru[14:12], instru[6:0]};  
always @(*) begin
casex (func) 17'b00000000000110011: begin reg_wr = 1; reg_src = 0; alu_src = 1; data_rd = 0; data_wr = 0; pc_src = 0; aluop = 0;end
17'b01000000000110011: begin reg_wr = 1; reg_src = 0; alu_src = 1; data_rd = 0; data_wr = 0; pc_src = 0; aluop = 1;end
17'b00000001110110011: begin reg_wr = 1; reg_src = 0; alu_src = 1; data_rd = 0; data_wr = 0; pc_src = 0; aluop = 2;end
17'b00000001100110011: begin reg_wr = 1; reg_src = 0; alu_src = 1; data_rd = 0; data_wr = 0; pc_src = 0; aluop = 3;end
17'bxxxxxxx0100000011: begin reg_wr = 1; reg_src = 1; alu_src = 0; data_rd = 1; data_wr = 0; imm = {{21{instru[31]}},instru[30:20]}; pc_src = 0; aluop = 0;end
17'bxxxxxxx0100100011: begin reg_wr = 0; alu_src = 0; data_rd = 0; data_wr = 1; imm = {{20{instru[31]}},instru[31:25],instru[11:7]}; pc_src = 0; aluop = 0;end
17'bxxxxxxx0001100011: begin reg_wr = 0; alu_src = 1; data_rd = 0; data_wr = 0; imm = {{20{instru[31]}},instru[31:25],instru[11:7]};/*imm = {{20{instru[31]}},instru[7],instru[30:25],instru[11:8],1'b0};*/ pc_src = zero; end
endcase
end
endmodule    

