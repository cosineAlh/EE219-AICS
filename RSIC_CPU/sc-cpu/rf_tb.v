module rf_tb;
parameter reg_width=32, num_reg=32;
reg clk, wr;
reg [reg_width-1:0] data;
reg [4:0] reg1, reg2, reg_wr;
wire [reg_width-1:0] d1, d2;
wire [reg_width*num_reg-1:0] rf_data;

always begin
	#1 clk = ~clk;
end
initial
begin
	clk = 1'b0;
	wr =1'b0;
	reg1 = 5'b0;
	reg2 = 5'b0;
	reg_wr = 5'b0;
	data = {(reg_width){1'b0}};

	#10 wr = 1'b1;
       	data = 32'hABCDEF01;
	reg1 = 5'b00011;
	reg2 = 5'b11111;
	reg_wr = 5'b11111;
	#2 wr = 1'b0;
	data = 32'h01234567;
	reg1 = 5'b00010;
	reg2 = 5'b00011;
	reg_wr = 5'b00000;
	#2 wr = 1'b1;
        data = 32'h11234567;
        reg1 = 5'b00010;
        reg2 = 5'b00011;
        reg_wr = 5'b00010;
end
rf #(reg_width,num_reg) rf1(.clk(clk),.reg1(reg1),.reg2(reg2),.wr(wr),.data(data),.d1(d1),.d2(d2),.reg_wr(reg_wr));
initial $monitor("At time %t, d1 = %d, d2 = %d", $time, d1, d2);
initial
begin
  $dumpfile("rf_tb.vcd");
  $dumpvars(0, rf_tb);
end

endmodule
