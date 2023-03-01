`timescale 1ns / 1ps
module im2col #(
    parameter IMG_W = 8,
    parameter IMG_H = 8,
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 32,
    parameter FILTER_SIZE = 3,
    parameter IMG_BASE = 16'h0000,
    parameter IM2COL_BASE = 16'h2000
) (
    input clk,
    input rst,
    input [DATA_WIDTH-1:0] data_rd,
    output [DATA_WIDTH-1:0] data_wr,
    output [ADDR_WIDTH-1:0] addr_wr,
    output [ADDR_WIDTH-1:0] addr_rd,
    output reg done,
    output reg mem_wr_en
);

reg [DATA_WIDTH-1:0] read;
reg [DATA_WIDTH-1:0] write;
reg [ADDR_WIDTH-1:0] base_addr;
reg [ADDR_WIDTH-1:0] addr_wr_reg;
reg [ADDR_WIDTH-1:0] addr_rd_reg;
reg [DATA_WIDTH-1:0] filter_cntr;

assign addr_wr = addr_wr_reg;
assign addr_rd = addr_rd_reg;
assign data_wr = write;

always@(*) begin
    // Case of relative address
    // Absolute address = Base address + Relative address
    case(filter_cntr)
        0:begin addr_rd_reg = base_addr-IMG_W-1;end
        1:begin addr_rd_reg = base_addr-IMG_W;end
        2:begin addr_rd_reg = base_addr-IMG_W+1;end
        3:begin addr_rd_reg = base_addr-1;end
        4:begin addr_rd_reg = base_addr;end
        5:begin addr_rd_reg = base_addr+1;end
        6:begin addr_rd_reg = base_addr+IMG_W-1;end
        7:begin addr_rd_reg = base_addr+IMG_W;end
        8:begin addr_rd_reg = base_addr+IMG_W+1;end
        9:begin addr_rd_reg = 0;end
    endcase
end

always@(posedge clk or posedge rst) begin
    if (rst) begin
        addr_wr_reg <= IM2COL_BASE;
        //addr_rd_reg <= IMG_BASE;
        base_addr <= IMG_BASE;
        done <= 0;
        mem_wr_en <= 0;
        filter_cntr <= 0;
    end
    else begin
        read = data_rd;

        // Filter counter & Base address
        if (filter_cntr == FILTER_SIZE*FILTER_SIZE) begin
            filter_cntr <= 0;
            base_addr <= base_addr + 1;
        end
        else filter_cntr <= filter_cntr + 1;

        // write address
        if (mem_wr_en) addr_wr_reg <= addr_wr_reg + 1;
        
        // Determine Padding
        if (base_addr == 0) begin   // Left-Up corner
            if (filter_cntr == 5 || filter_cntr == 6 || filter_cntr == 8 || filter_cntr == 9) write <= read;
            else write <= 0;
        end
        else if (base_addr == IMG_W-1) begin    // Right-Up corner
            if (filter_cntr == 4 || filter_cntr == 5 || filter_cntr == 7 || filter_cntr == 8) write <= read;
            else write <= 0;
        end
        else if (base_addr == IMG_W*(IMG_H-1)) begin  // Left-Down corner
            if (filter_cntr == 2 || filter_cntr == 3 || filter_cntr == 5 || filter_cntr == 6) write <= read;
            else write <= 0;
        end
        else if (base_addr == IMG_W*IMG_H-1) begin  // Right-Down corner
            if (filter_cntr == 1 || filter_cntr == 2 || filter_cntr == 4 || filter_cntr == 5) write <= read;
            else write <= 0;

            if (filter_cntr==9) done <= 1;
        end
        else if (base_addr > 0 && base_addr < IMG_W-1) begin    // Up
            if (filter_cntr == 1 || filter_cntr == 2 || filter_cntr == 3) write <= 0;
            else write <= read;
        end
        else if (base_addr%IMG_W == 0 && base_addr > 0 && base_addr < IMG_W*(IMG_H-1)) begin    // Left
            if (filter_cntr == 1 || filter_cntr == 4 || filter_cntr == 7) write <= 0;
            else write <= read;
        end
        else if ((base_addr+1)%IMG_W == 0 && base_addr > IMG_W-1 && base_addr < IMG_W*IMG_H-1) begin // Right
            if (filter_cntr == 3 || filter_cntr == 6 || filter_cntr == 9) write <= 0;
            else write <= read;
        end
        else if (base_addr > IMG_W*(IMG_H-1) && base_addr < IMG_W*IMG_H-1) begin   // Down
            if (filter_cntr == 7|| filter_cntr == 8 || filter_cntr == 9) write <= 0;
            else write <= read;
        end
        else write <= read;

        // write enable
        if (done || filter_cntr == 0) mem_wr_en <= 0;
        else if (filter_cntr == 1) mem_wr_en <= 1;
    
    end
end
endmodule
