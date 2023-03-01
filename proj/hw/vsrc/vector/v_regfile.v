`include "v_defines.v"

module v_regfile(
    input clk,
    input rst,

    input                   w_ena_i,
    input [`VREG_ADDR_BUS]  w_addr_i,
    input [`VREG_BUS]       w_data_i,

    input                   r_ena1_i,
    input [`VREG_ADDR_BUS]  r_addr1_i,
    output reg [`VREG_BUS]  r_data1_o,

    input                   r_ena2_i,
    input [`VREG_ADDR_BUS]  r_addr2_i,
    output reg [`VREG_BUS]  r_data2_o
);
// hint: you can refer to regfile

integer i ;

reg [`VREG_BUS] regv [ 31 : 0 ] ;

always @(posedge clk ) begin
    if( rst == 1'b1 ) begin
        regv[0] <= { (`VLMAX){64'h00000000_00000000} } ;

        for(i=1; i<32; i=i+1) begin
            regv[i] <= { (`VLMAX){64'h00000000_00000000} } ;
        end
    end
    else begin
        if( (w_ena_i == 1'b1) && (w_addr_i != 0) ) begin
            regv[w_addr_i] <= w_data_i ;
        end
    end
end

always @( * ) begin
    if( rst == 1'b1 ) begin
        r_data1_o = { (`VLMAX){64'h00000000_00000000} } ;
    end
    else if( r_ena1_i ) begin
        r_data1_o = regv[r_addr1_i];
    end
    else begin
        r_data1_o = { (`VLMAX){64'h00000000_00000000} } ;
    end
end

always @(*) begin
    if (rst == 1'b1)
        r_data2_o = { (`VLMAX){64'h00000000_00000000} } ;
    else if (r_ena2_i == 1'b1)
        r_data2_o = regv[r_addr2_i];
    else
        r_data2_o = { (`VLMAX){64'h00000000_00000000} } ;
end

endmodule