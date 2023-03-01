module datamem_tb;
parameter width=32, addr_width = 16;
reg clk, wr, rd;
reg [addr_width-1:0] addr;

wire [width-1:0] data_pin;   // inout port
reg [width-1:0] data_drive;  // locally driven value, input
integer i;
assign data_pin = (!rd)?data_drive:{(width){1'bz}};

initial begin
 clk = 0;
 forever begin
  # 5 clk = ~clk;
 end
end

initial begin
	{wr,rd,addr,data_drive} = 0;
	repeat (2) @ (posedge clk);
	for (i=0; i<32; i=i+1) begin
	    repeat (1) @(negedge clk) addr <= i; wr<=0; rd<=1; data_drive<=i;end
	repeat (2) @ (posedge clk);
	for (i=0; i<32; i=i+1) begin
	    repeat (1) @(posedge clk) addr <= i; wr<=1; rd<=0; data_drive<=i;end
	#20 $finish;
end
data_mem datamem(.addr(addr),.clk(clk),.data(data_pin),.rd(rd),.wr(wr));
initial $monitor("At time %t, data_pin = %d", $time, data_pin);
initial
begin
  $dumpfile("datamem_tb.vcd");
  $dumpvars(0, datamem_tb);
end

endmodule
