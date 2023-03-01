`include "v_defines.v"

module v_alu(
    input                   clk,
    input                   rst,

    input  [`ALU_OP_BUS]    alu_opcode_i,

    input  [`VREG_BUS]      operand_vs1_i,
    input  [`VREG_BUS]      operand_vs2_i,
    output [`VREG_BUS]      vexe_result_o,

    input  [2:0]            vmac_sel_i,
    output [`VREG_BUS]      vmac_result_o
);

v_execute V_EXE_Stage(
    .rst            ( rst ),
    .alu_opcode_i   ( alu_opcode_i  ),
    .operand_vs1_i  ( operand_vs1_i ),
    .operand_vs2_i  ( operand_vs2_i ),
    .vexe_result_o  ( vexe_result_o )
);


v_mac_unit MAC_Unit(
    .clk            ( clk ),
    .rst            ( rst ),
    .alu_opcode_i   ( alu_opcode_i  ),
    .mac_sel_i      ( vmac_sel_i    ),

    .mac_op_vs1_i   ( operand_vs1_i ),
    .mac_op_vs2_i   ( operand_vs2_i ),
    .mac_result_o   ( vmac_result_o )
);

endmodule