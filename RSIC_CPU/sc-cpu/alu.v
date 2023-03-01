module alu(opA, opB, aluop, result, zero);
parameter width=32;
input [1:0] aluop; input [width-1:0] opA, opB;
output reg [width-1:0] result; output reg zero;         
always @(*) zero = (result == 0);                          
always @(opA, opB, aluop) begin
case (aluop) 0: result = opA + opB; 1: result = opA - opB;
2: result = opA & opB; 3: result = opA | opB;
default: result = 0;
endcase
end
endmodule
