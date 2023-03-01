`include "defines.v"

module inst_decode(
    input                       rst,
    input   [`INST_BUS]         inst_i,
    // register
    input   [`REG_BUS]          rs1_data_i,
	output                      rs1_r_ena_o,
	output  [`REG_ADDR_BUS]     rs1_r_addr_o,
    input   [`REG_BUS]          rs2_data_i,
	output                      rs2_r_ena_o,
	output  [`REG_ADDR_BUS]     rs2_r_addr_o,
    // execute
    output  [`ALU_OP_BUS]       alu_opcode_o,
	output  [`REG_BUS]          operand_rs1_o,
	output  [`REG_BUS]          operand_rs2_o,
    output                      branch_en_o,
    output  [`INST_ADDR_BUS]    branch_offset_o,
    output                      jump_en_o,
    output  [`INST_ADDR_BUS]    jump_offset_o,
    // memory
    output                      mem_r_ena_o,
    output                      mem_w_ena_o,
    output  [`MEM_DATA_BUS]     mem_w_data_o,
    // write-back
    output                      wb_ena_o,
    output                      wb_sel_o,
    output  [`REG_ADDR_BUS]     wb_addr_o
);

// ====================================================
// wire declaration
// ====================================================

wire [11 : 0]   imm_i ;
// hint: to add imm_u, imm_b, imm_j, imm_s
wire [11 : 0]   imm_s ;
wire [12 : 0]   imm_b ;
wire [20 : 0]   imm_j ;
wire [31 : 0]   imm_u ;


wire [6  : 0]   funct7 ;
wire [4  : 0]   rs2;
wire [4  : 0]   rs1;
wire [2  : 0]   funct3;
wire [4  : 0]   rd;
wire [6  : 0]   opcode;

wire op_imm ;
wire [`REG_BUS] operand_rs_imm ;


wire inst_addi ;
// hint: too add other instructions
wire inst_and ;
wire inst_add ;
wire inst_sll ;
wire inst_mul ;
wire inst_slti;
wire inst_lw  ;
wire inst_sw  ;
wire inst_blt ;
wire inst_jal ;
wire inst_lui ;

// ====================================================
// Parse
// ====================================================
assign imm_i    = inst_i[ 31 : 20 ] ;
// hint: to add imm_u, imm_b, imm_j, imm_s
assign imm_s    = {inst_i[31:25], inst_i[11:7]} ;
assign imm_b    = {inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0} ;
assign imm_j    = {inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0} ;
assign imm_u    = {inst_i[31:12], 12'b0} ;

assign funct7   = inst_i[ 31 : 25 ] ;
assign rs2      = inst_i[ 24 : 20 ] ;
assign rs1      = inst_i[ 19 : 15 ] ;
assign funct3   = inst_i[ 14 : 12 ] ;
assign rd       = inst_i[ 11 :  7 ] ;
assign opcode   = inst_i[  6 :  0 ] ;

// Scalar
assign inst_addi    =  ( opcode == `OPCODE_ADDI) & ( funct3 == `FUNCT3_ADDI) ;
// hint: to add other instructions
assign inst_and     =  ( opcode == `OPCODE_AND ) & ( funct3 == `FUNCT3_AND) & ( funct7 == `FUNCT7_AND) ;
assign inst_add     =  ( opcode == `OPCODE_ADD ) & ( funct3 == `FUNCT3_ADD) & ( funct7 == `FUNCT7_ADD) ;
assign inst_sll     =  ( opcode == `OPCODE_SLL ) & ( funct3 == `FUNCT3_SLL) & ( funct7 == `FUNCT7_SLL) ;
assign inst_mul     =  ( opcode == `OPCODE_MUL ) & ( funct3 == `FUNCT3_MUL) & ( funct7 == `FUNCT7_MUL) ;
assign inst_blt     =  ( opcode == `OPCODE_BLT ) & ( funct3 == `FUNCT3_BLT) ;
assign inst_slti    =  ( opcode == `OPCODE_SLTI) & ( funct3 == `FUNCT3_SLTI) ;  
assign inst_lw      =  ( opcode == `OPCODE_LW  ) & ( funct3 == `FUNCT3_LW ) ;  
assign inst_sw      =  ( opcode == `OPCODE_SW  ) & ( funct3 == `FUNCT3_SW ) ;
assign inst_jal     =  ( opcode == `OPCODE_JAL ) ;
assign inst_lui     =  ( opcode == `OPCODE_LUI ) ;

// Vector

// ====================================================
// Decode
// ====================================================
// hint: to finish the decoding part
// hint: no need to add new assign code.

// Control ALU Operation
assign alu_opcode_o =   ( rst == 1'b1   )                                 ?   `ALU_OP_NOP     :
                        ( inst_addi || inst_add || inst_lw || inst_sw )   ?   `ALU_OP_ADD     :
                        ( inst_and )                                      ?   `ALU_OP_AND     :
                        ( inst_sll )                                      ?   `ALU_OP_SLL     :  
                        ( inst_blt )                                      ?   `ALU_OP_BLT     : 
                        ( inst_jal )                                      ?   `ALU_OP_JAL     :
                        ( inst_lui )                                      ?   `ALU_OP_LUI     :  
                        ( inst_mul )                                      ?   `ALU_OP_MUL     :
                        ( inst_slti)                                      ?   `ALU_OP_SLTI    :
                                                                              `ALU_OP_NOP     ;

// Control the register visiting and immediate parsing
assign rs1_r_ena_o      =   ( rst != 1'b1 ) & ( inst_addi || inst_slti || inst_lw || inst_add || inst_and || inst_sll || inst_blt || inst_mul || inst_sw );
assign rs1_r_addr_o     =   ( rs1_r_ena_o ) ?   rs1 : 0 ;
assign rs2_r_ena_o      =   ( rst != 1'b1 ) & ( inst_add || inst_and || inst_sll || inst_blt || inst_mul || inst_sw );
assign rs2_r_addr_o     =   ( rs2_r_ena_o ) ?   rs2 : 0 ;
assign op_imm           =   ( inst_addi || inst_slti || inst_lw || inst_sw || inst_lui) ;
assign operand_rs_imm   =   ( inst_addi || inst_slti || inst_lw )  ?   { {(32-12){imm_i[11]}} , imm_i } :
                            ( inst_sw )                            ?   { {(32-12){imm_s[11]}} , imm_s } :
                            ( inst_lui)                            ?   { imm_u }                        :
                                                                                                      0 ;

// Control ALU operands
assign operand_rs1_o    =   ( rs1_r_ena_o   )   ?   rs1_data_i      :   0 ;
assign operand_rs2_o    =   ( op_imm        )   ?   operand_rs_imm  : 
                            ( rs2_r_ena_o   )   ?   rs2_data_i      :   0 ;

// Conditional Branching
assign branch_en_o      =   ( rst != 1'b1 ) & ( inst_blt ) ;
assign branch_offset_o  =   branch_en_o ? { {(32-13){imm_b[12]}}, imm_b } : 0 ;

// Unconditional Branching (Jumping)
assign jump_en_o        =   ( rst != 1'b1 ) & ( inst_jal ) ;
assign jump_offset_o    =   jump_en_o ? { {(32-21){imm_j[20]}}, imm_j } : 0 ;

// Control Memory Access 
assign mem_r_ena_o      =   ( inst_lw ) ;
assign mem_w_ena_o      =   ( inst_sw ) ;
assign mem_w_data_o     =   rs2_data_i  ;

// Control Write-Back
assign wb_ena_o         =   ( inst_addi || inst_slti || inst_lw || inst_add || inst_and || inst_sll || inst_mul || inst_jal || inst_lui );
assign wb_sel_o         =   ( inst_lw ) ;
assign wb_addr_o        =   ( wb_ena_o )    ?   rd  : 0 ;

endmodule
