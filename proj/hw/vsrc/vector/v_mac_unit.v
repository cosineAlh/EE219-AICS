`include "v_defines.v"

module v_mac_unit(
    input               clk,
    input               rst,
    input [`ALU_OP_BUS] alu_opcode_i,
    input [2 : 0]       mac_sel_i,

  	input [`VREG_BUS]   mac_op_vs1_i,
  	input [`VREG_BUS]   mac_op_vs2_i,
    output [`VREG_BUS]  mac_result_o
);

reg [`VREG_BUS] bias ;
reg [`VREG_BUS] result ;
reg [`VREG_BUS] mac_result_o_R ;

assign mac_result_o = mac_result_o_R ;
always @( posedge clk, posedge rst ) begin
    if( rst == 1'b1 ) begin
        mac_result_o_R = 0 ;
        bias = 0 ;
        result = 0 ;
    end
    else begin
        case( alu_opcode_i )
            `VALU_OP_MAC_LW: begin
                bias = mac_op_vs1_i ;
                mac_result_o_R = 0 ;
                result = result ;
            end
            `VALU_OP_MAC_SW: begin
                mac_result_o_R = result ;
                bias = bias ;
                result = result ;
            end
            `VALU_OP_MAC_EN: begin
                mac_result_o_R = mac_result_o_R ;
                bias = bias ;
                case(mac_sel_i)
                  3'b000: 
                  result[1*`SEW-1 : 0*`SEW]  
                                = mac_op_vs1_i[1*`SEW-1 : 0*`SEW] * mac_op_vs2_i[1*`SEW-1 : 0*`SEW] 
                                + mac_op_vs1_i[2*`SEW-1 : 1*`SEW] * mac_op_vs2_i[2*`SEW-1 : 1*`SEW]
                                + mac_op_vs1_i[3*`SEW-1 : 2*`SEW] * mac_op_vs2_i[3*`SEW-1 : 2*`SEW]
                                + mac_op_vs1_i[4*`SEW-1 : 3*`SEW] * mac_op_vs2_i[4*`SEW-1 : 3*`SEW]
                                + mac_op_vs1_i[5*`SEW-1 : 4*`SEW] * mac_op_vs2_i[5*`SEW-1 : 4*`SEW] 
                                + mac_op_vs1_i[6*`SEW-1 : 5*`SEW] * mac_op_vs2_i[6*`SEW-1 : 5*`SEW]
                                + mac_op_vs1_i[7*`SEW-1 : 6*`SEW] * mac_op_vs2_i[7*`SEW-1 : 6*`SEW]
                                + mac_op_vs1_i[8*`SEW-1 : 7*`SEW] * mac_op_vs2_i[8*`SEW-1 : 7*`SEW]
                                + bias[1*`SEW-1 : 0*`SEW];
                  3'b001:
                  result[2*`SEW-1 : 1*`SEW]  
                                = mac_op_vs1_i[1*`SEW-1 : 0*`SEW] * mac_op_vs2_i[1*`SEW-1 : 0*`SEW] 
                                + mac_op_vs1_i[2*`SEW-1 : 1*`SEW] * mac_op_vs2_i[2*`SEW-1 : 1*`SEW]
                                + mac_op_vs1_i[3*`SEW-1 : 2*`SEW] * mac_op_vs2_i[3*`SEW-1 : 2*`SEW]
                                + mac_op_vs1_i[4*`SEW-1 : 3*`SEW] * mac_op_vs2_i[4*`SEW-1 : 3*`SEW]
                                + mac_op_vs1_i[5*`SEW-1 : 4*`SEW] * mac_op_vs2_i[5*`SEW-1 : 4*`SEW] 
                                + mac_op_vs1_i[6*`SEW-1 : 5*`SEW] * mac_op_vs2_i[6*`SEW-1 : 5*`SEW]
                                + mac_op_vs1_i[7*`SEW-1 : 6*`SEW] * mac_op_vs2_i[7*`SEW-1 : 6*`SEW]
                                + mac_op_vs1_i[8*`SEW-1 : 7*`SEW] * mac_op_vs2_i[8*`SEW-1 : 7*`SEW]
                                + bias[2*`SEW-1 : 1*`SEW];
                  3'b010:
                  result[3*`SEW-1 : 2*`SEW]  
                                = mac_op_vs1_i[1*`SEW-1 : 0*`SEW] * mac_op_vs2_i[1*`SEW-1 : 0*`SEW] 
                                + mac_op_vs1_i[2*`SEW-1 : 1*`SEW] * mac_op_vs2_i[2*`SEW-1 : 1*`SEW]
                                + mac_op_vs1_i[3*`SEW-1 : 2*`SEW] * mac_op_vs2_i[3*`SEW-1 : 2*`SEW]
                                + mac_op_vs1_i[4*`SEW-1 : 3*`SEW] * mac_op_vs2_i[4*`SEW-1 : 3*`SEW]
                                + mac_op_vs1_i[5*`SEW-1 : 4*`SEW] * mac_op_vs2_i[5*`SEW-1 : 4*`SEW] 
                                + mac_op_vs1_i[6*`SEW-1 : 5*`SEW] * mac_op_vs2_i[6*`SEW-1 : 5*`SEW]
                                + mac_op_vs1_i[7*`SEW-1 : 6*`SEW] * mac_op_vs2_i[7*`SEW-1 : 6*`SEW]
                                + mac_op_vs1_i[8*`SEW-1 : 7*`SEW] * mac_op_vs2_i[8*`SEW-1 : 7*`SEW]
                                + bias[3*`SEW-1 : 2*`SEW];                
                  3'b011:
                  result[4*`SEW-1 : 3*`SEW]  
                                = mac_op_vs1_i[1*`SEW-1 : 0*`SEW] * mac_op_vs2_i[1*`SEW-1 : 0*`SEW] 
                                + mac_op_vs1_i[2*`SEW-1 : 1*`SEW] * mac_op_vs2_i[2*`SEW-1 : 1*`SEW]
                                + mac_op_vs1_i[3*`SEW-1 : 2*`SEW] * mac_op_vs2_i[3*`SEW-1 : 2*`SEW]
                                + mac_op_vs1_i[4*`SEW-1 : 3*`SEW] * mac_op_vs2_i[4*`SEW-1 : 3*`SEW]
                                + mac_op_vs1_i[5*`SEW-1 : 4*`SEW] * mac_op_vs2_i[5*`SEW-1 : 4*`SEW] 
                                + mac_op_vs1_i[6*`SEW-1 : 5*`SEW] * mac_op_vs2_i[6*`SEW-1 : 5*`SEW]
                                + mac_op_vs1_i[7*`SEW-1 : 6*`SEW] * mac_op_vs2_i[7*`SEW-1 : 6*`SEW]
                                + mac_op_vs1_i[8*`SEW-1 : 7*`SEW] * mac_op_vs2_i[8*`SEW-1 : 7*`SEW]
                                + bias[4*`SEW-1 : 3*`SEW];                   
                  3'b100:
                  result[5*`SEW-1 : 4*`SEW]  
                                = mac_op_vs1_i[1*`SEW-1 : 0*`SEW] * mac_op_vs2_i[1*`SEW-1 : 0*`SEW] 
                                + mac_op_vs1_i[2*`SEW-1 : 1*`SEW] * mac_op_vs2_i[2*`SEW-1 : 1*`SEW]
                                + mac_op_vs1_i[3*`SEW-1 : 2*`SEW] * mac_op_vs2_i[3*`SEW-1 : 2*`SEW]
                                + mac_op_vs1_i[4*`SEW-1 : 3*`SEW] * mac_op_vs2_i[4*`SEW-1 : 3*`SEW]
                                + mac_op_vs1_i[5*`SEW-1 : 4*`SEW] * mac_op_vs2_i[5*`SEW-1 : 4*`SEW] 
                                + mac_op_vs1_i[6*`SEW-1 : 5*`SEW] * mac_op_vs2_i[6*`SEW-1 : 5*`SEW]
                                + mac_op_vs1_i[7*`SEW-1 : 6*`SEW] * mac_op_vs2_i[7*`SEW-1 : 6*`SEW]
                                + mac_op_vs1_i[8*`SEW-1 : 7*`SEW] * mac_op_vs2_i[8*`SEW-1 : 7*`SEW]
                                + bias[5*`SEW-1 : 4*`SEW];                  
                  3'b101:
                  result[6*`SEW-1 : 5*`SEW]  
                                = mac_op_vs1_i[1*`SEW-1 : 0*`SEW] * mac_op_vs2_i[1*`SEW-1 : 0*`SEW] 
                                + mac_op_vs1_i[2*`SEW-1 : 1*`SEW] * mac_op_vs2_i[2*`SEW-1 : 1*`SEW]
                                + mac_op_vs1_i[3*`SEW-1 : 2*`SEW] * mac_op_vs2_i[3*`SEW-1 : 2*`SEW]
                                + mac_op_vs1_i[4*`SEW-1 : 3*`SEW] * mac_op_vs2_i[4*`SEW-1 : 3*`SEW]
                                + mac_op_vs1_i[5*`SEW-1 : 4*`SEW] * mac_op_vs2_i[5*`SEW-1 : 4*`SEW] 
                                + mac_op_vs1_i[6*`SEW-1 : 5*`SEW] * mac_op_vs2_i[6*`SEW-1 : 5*`SEW]
                                + mac_op_vs1_i[7*`SEW-1 : 6*`SEW] * mac_op_vs2_i[7*`SEW-1 : 6*`SEW]
                                + mac_op_vs1_i[8*`SEW-1 : 7*`SEW] * mac_op_vs2_i[8*`SEW-1 : 7*`SEW]
                                + bias[6*`SEW-1 : 5*`SEW];                   
                  3'b110:
                  result[7*`SEW-1 : 6*`SEW]  
                                = mac_op_vs1_i[1*`SEW-1 : 0*`SEW] * mac_op_vs2_i[1*`SEW-1 : 0*`SEW] 
                                + mac_op_vs1_i[2*`SEW-1 : 1*`SEW] * mac_op_vs2_i[2*`SEW-1 : 1*`SEW]
                                + mac_op_vs1_i[3*`SEW-1 : 2*`SEW] * mac_op_vs2_i[3*`SEW-1 : 2*`SEW]
                                + mac_op_vs1_i[4*`SEW-1 : 3*`SEW] * mac_op_vs2_i[4*`SEW-1 : 3*`SEW]
                                + mac_op_vs1_i[5*`SEW-1 : 4*`SEW] * mac_op_vs2_i[5*`SEW-1 : 4*`SEW] 
                                + mac_op_vs1_i[6*`SEW-1 : 5*`SEW] * mac_op_vs2_i[6*`SEW-1 : 5*`SEW]
                                + mac_op_vs1_i[7*`SEW-1 : 6*`SEW] * mac_op_vs2_i[7*`SEW-1 : 6*`SEW]
                                + mac_op_vs1_i[8*`SEW-1 : 7*`SEW] * mac_op_vs2_i[8*`SEW-1 : 7*`SEW]
                                + bias[7*`SEW-1 : 6*`SEW];                  
                  3'b111:
                  result[8*`SEW-1 : 7*`SEW]  
                                = mac_op_vs1_i[1*`SEW-1 : 0*`SEW] * mac_op_vs2_i[1*`SEW-1 : 0*`SEW] 
                                + mac_op_vs1_i[2*`SEW-1 : 1*`SEW] * mac_op_vs2_i[2*`SEW-1 : 1*`SEW]
                                + mac_op_vs1_i[3*`SEW-1 : 2*`SEW] * mac_op_vs2_i[3*`SEW-1 : 2*`SEW]
                                + mac_op_vs1_i[4*`SEW-1 : 3*`SEW] * mac_op_vs2_i[4*`SEW-1 : 3*`SEW]
                                + mac_op_vs1_i[5*`SEW-1 : 4*`SEW] * mac_op_vs2_i[5*`SEW-1 : 4*`SEW] 
                                + mac_op_vs1_i[6*`SEW-1 : 5*`SEW] * mac_op_vs2_i[6*`SEW-1 : 5*`SEW]
                                + mac_op_vs1_i[7*`SEW-1 : 6*`SEW] * mac_op_vs2_i[7*`SEW-1 : 6*`SEW]
                                + mac_op_vs1_i[8*`SEW-1 : 7*`SEW] * mac_op_vs2_i[8*`SEW-1 : 7*`SEW]
                                + bias[8*`SEW-1 : 7*`SEW];                 
                  default: begin 
                  mac_result_o_R = 0 ;
                  end
                endcase

            end
            default: begin
                mac_result_o_R = 0 ;
                result = result ;
                bias = bias;
            end
        endcase
    end
end
endmodule