module alu_tb;
parameter width=32;
reg [width-1:0] opA, opB;
reg [1:0] aluop;
wire [width-1:0] result;
wire zero;

initial
begin
	opA = 0;
	opB = 0;
	aluop = 0;
	#1 opA = 100;
	opB = 200;
	#1 aluop = 1;
	#1 opA = 32'hFFFFFFF;
        opB = 32'h01234567;
        aluop = 2;
        #1 aluop = 3;
	#1 opB = 32'hFFFFFFFF;
	#1 aluop = 1;
	#1 opB = 32'h01234567;
	#1 aluop = 0;
	#1 opA = 32'h01234567;
	aluop = 1;
	#1;
end
alu #(width) alu1(.opA(opA),.opB(opB),.aluop(aluop),.zero(zero),.result(result));
initial $monitor("At time %t, result = %d, zero = %d", $time, result, zero);
initial
begin
  $dumpfile("alu_tb.vcd");
  $dumpvars(0, alu_tb);
end

endmodule
