`include "v_defines.v"

module v_inst_decode(
    input                       rst,
    input   [`VINST_BUS]        inst_i,
    // scalar-register
    input   [`SREG_BUS]         rs1_data_i,
	output            	        rs1_r_ena_o,
	output  [`SREG_ADDR_BUS]   	rs1_r_addr_o,
    // vertco-register
    input   [`VREG_BUS]         vs1_data_i,
	output            	        vs1_r_ena_o,
	output  [`VREG_ADDR_BUS]   	vs1_r_addr_o,
    input   [`VREG_BUS]         vs2_data_i,
	output            	        vs2_r_ena_o,
	output  [`VREG_ADDR_BUS]   	vs2_r_addr_o,
    // execute
    output  [`ALU_OP_BUS]       alu_opcode_o,
	output  [`VREG_BUS]	        operand_vs1_o,
	output  [`VREG_BUS]         operand_vs2_o,
    output  [ 2 : 0 ]           vmac_sel_o,
    // memory
    output                      vmem_r_ena_o,
    output  [`VMEM_ADDR_BUS]    vmem_r_addr_o,    
    output                      vmem_w_ena_o,
    output  [`VMEM_DATA_BUS]    vmem_w_data_o,
    output  [`VMEM_ADDR_BUS]    vmem_w_addr_o,
    // write-back
    output                      vwb_ena_o,
    output  [ 1 : 0 ]           vwb_sel_o,
    output  [`VREG_ADDR_BUS]    vwb_addr_o
);


// ====================================================
// wire declaration
// ====================================================
wire [5  : 0]    funct6 ;
wire             vm ;
wire [4  : 0]    rs2;
wire [4  : 0]    imm ;
wire [4  : 0]    rs1 ;
wire [2  : 0]    funct3 ;
wire [4  : 0]    vd ;
wire [2  : 0]    sel ;
wire [6  : 0]    opcode ;

wire [`SREG_BUS] imm_ext ;

wire inst_vle32_v ;
// hint: too add other instructions
wire inst_vadd_vi ;
wire inst_vadd_vx ;
wire inst_vadd_vv ;

wire inst_vse32_v ;

wire inst_vmul_vi ;
wire inst_vmul_vx ;
wire inst_vmul_vv ;

wire inst_vmac_lw ;
wire inst_vmac_sw ;
wire inst_vmac_en ;

// ====================================================
// Parse
// ====================================================
assign {funct6, vm} = inst_i[ 31 : 25 ] ;
assign rs2          = inst_i[ 24 : 20 ] ;
assign rs1          = inst_i[ 19 : 15 ] ;
assign imm          = inst_i[ 19 : 15 ] ;
assign funct3       = inst_i[ 14 : 12 ] ;
assign vd           = inst_i[ 11 :  7 ] ;
assign sel          = inst_i[  9 :  7 ] ;
assign opcode       = inst_i[  6 :  0 ] ;

assign imm_ext      = { {(64-5){imm[4]}}, imm };

assign inst_vle32_v =  ( opcode == `OPCODE_VL   ) & ( funct6 == `FUNCT6_VLE32  ) & ( funct3 == `WIDTH_VLE32 ) ;
// hint: too add other instructions
assign inst_vadd_vi =  ( opcode == `OPCODE_OPIVV) & ( funct6 == `FUNCT6_VADD   ) & ( funct3 == `FUNCT3_VI   ) ;
assign inst_vadd_vx =  ( opcode == `OPCODE_OPIVV) & ( funct6 == `FUNCT6_VADD   ) & ( funct3 == `FUNCT3_VX   ) ;
assign inst_vadd_vv =  ( opcode == `OPCODE_OPIVV) & ( funct6 == `FUNCT6_VADD   ) & ( funct3 == `FUNCT3_VV   ) ;

assign inst_vse32_v =  ( opcode == `OPCODE_VS   ) & ( funct6 == `FUNCT6_VSE32  ) & ( funct3 == `WIDTH_VSE32 ) ; 

assign inst_vmul_vi =  ( opcode == `OPCODE_OPIVV) & ( funct6 == `FUNCT6_VMUL   ) & ( funct3 == `FUNCT3_VI   ) ;
assign inst_vmul_vx =  ( opcode == `OPCODE_OPIVV) & ( funct6 == `FUNCT6_VMUL   ) & ( funct3 == `FUNCT3_VX   ) ;
assign inst_vmul_vv =  ( opcode == `OPCODE_OPIVV) & ( funct6 == `FUNCT6_VMUL   ) & ( funct3 == `FUNCT3_VV   ) ;

assign inst_vmac_lw =  ( opcode == `OPCODE_OPIVV) & ( funct6 == `FUNCT6_VMACLW ) & ( funct3 == `FUNCT3_VV   ) ;
assign inst_vmac_sw =  ( opcode == `OPCODE_OPIVV) & ( funct6 == `FUNCT6_VMACSW ) & ( funct3 == `FUNCT3_VV   ) ;
assign inst_vmac_en =  ( opcode == `OPCODE_OPIVV) & ( funct6 == `FUNCT6_VMACEN ) & ( funct3 == `FUNCT3_VV   ) ;

// ====================================================
// Decode
// ====================================================
// hint: too finish the decoding part
// hint: no need to add new assign code.

// Control ALU Operation
assign alu_opcode_o     =   ( rst == 1'b1                                   )   ?   `VALU_OP_NOP     :
                            ( inst_vadd_vi || inst_vadd_vx || inst_vadd_vv  )   ?   `VALU_OP_ADD     :
                            ( inst_vmul_vi || inst_vmul_vx || inst_vmul_vv  )   ?   `VALU_OP_MUL     :
                            ( inst_vmac_lw                                  )   ?   `VALU_OP_MAC_LW  :
                            ( inst_vmac_sw                                  )   ?   `VALU_OP_MAC_SW  :
                            ( inst_vmac_en                                  )   ?   `VALU_OP_MAC_EN  :
                                                                                    `VALU_OP_NOP     ;

// Control the register visiting
assign rs1_r_ena_o      =   ( rst == 1'b1  )     ?   1'b0    :
                            ( inst_vle32_v )     ?   1'b1    :
                            ( inst_vadd_vx )     ?   1'b1    :
                            ( inst_vmul_vx )     ?   1'b1    :
                            ( inst_vse32_v )     ?   1'b1    :   1'b0    ;

assign rs1_r_addr_o     =   ( rst == 1'b1  )     ?   0       :
                            ( rs1_r_ena_o  )     ?   rs1     :   0       ;

assign vs1_r_ena_o      =   ( rst == 1'b1  )     ?   1'b0    :
                            ( inst_vadd_vv )     ?   1'b1    :
                            ( inst_vmul_vv )     ?   1'b1    :
                            ( inst_vse32_v )     ?   1'b1    :
                            ( inst_vmac_lw )     ?   1'b1    :
                            ( inst_vmac_en )     ?   1'b1    :   1'b0    ;

assign vs1_r_addr_o     =   ( rst == 1'b1  )     ?   0       :
                            ( inst_vse32_v )     ?   vd      :
                            ( vs1_r_ena_o  )     ?   rs1     :   0       ;

assign vs2_r_ena_o      =   ( rst == 1'b1  )     ?   1'b0    :
                            ( inst_vadd_vi )     ?   1'b1    :
                            ( inst_vadd_vx )     ?   1'b1    :
                            ( inst_vadd_vv )     ?   1'b1    :
                            ( inst_vmul_vi )     ?   1'b1    :
                            ( inst_vmul_vx )     ?   1'b1    :
                            ( inst_vmul_vv )     ?   1'b1    :
                            ( inst_vmac_en )     ?   1'b1    :   1'b0    ;

assign vs2_r_addr_o     =   ( rst == 1'b1  )     ?   0       :
                            ( vs2_r_ena_o  )     ?   rs2     :   0       ;

// Control ALU operands
assign operand_vs1_o    =   ( inst_vadd_vi )     ?  {(`VLMAX){imm_ext}}     :
                            ( inst_vmul_vi )     ?  {(`VLMAX){imm_ext}}     :
                            ( inst_vadd_vx )     ?  {(`VLMAX){rs1_data_i}}  :
                            ( inst_vmul_vx )     ?  {(`VLMAX){rs1_data_i}}  :
                            ( vs1_r_ena_o  )     ?  vs1_data_i              :   0       ;
assign operand_vs2_o    =   ( vs2_r_ena_o  )     ?  vs2_data_i              :   0       ;

assign vmac_sel_o       =   ( inst_vmac_en )     ?  sel                     :   0       ;

// Control Memory Access 
assign vmem_r_ena_o     =   ( inst_vle32_v )  ? 1'b1         : 0 ;
assign vmem_r_addr_o    =   ( inst_vle32_v )  ? rs1_data_i   : 0 ;
assign vmem_w_ena_o     =   ( inst_vse32_v )  ? 1'b1         : 0 ;
assign vmem_w_addr_o    =   ( inst_vse32_v )  ? rs1_data_i   : 0 ;
assign vmem_w_data_o    =   ( inst_vse32_v )  ? vs1_data_i   : 0 ;

// Control Write-Back
assign vwb_ena_o        =   ( inst_vle32_v || inst_vadd_vi || inst_vadd_vx || inst_vadd_vv || inst_vmul_vi || inst_vmul_vx || inst_vmul_vv || inst_vmac_sw ) ;
assign vwb_sel_o        =   ( inst_vle32_v )  ?   2'b01   :
                            ( inst_vmac_sw )  ?   2'b10   :   2'b00 ;
assign vwb_addr_o       =   ( vwb_ena_o    )  ?   vd      :   0     ;

endmodule