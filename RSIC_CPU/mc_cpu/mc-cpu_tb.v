module mc_cpu_tb;
reg clk,reset;
wire flag;
initial begin
 clk = 0;
 forever begin
  # 1 clk = ~clk;
 end
end
initial begin
	reset = 1'b1;
	#2  reset = 1'b0;
	#300 $finish;
end
mc_cpu risc_cpu(.clk(clk),.reset(reset),.flag(flag));
initial
begin
  $dumpfile("mc_risc_tb.vcd");
  $dumpvars(0,mc_cpu_tb);
end
endmodule