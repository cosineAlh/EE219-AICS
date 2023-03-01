`include "v_defines.v"

module v_rvcpu(
    input                       clk,
    input                       rst,

    input   [`VINST_BUS]        inst,

    input   [`SREG_BUS ]        vec_rs1_data,
    output                      vec_rs1_r_ena,
    output  [`SREG_ADDR_BUS]    vec_rs1_r_addr,
    
    output                      vram_r_ena,
    output  [`VRAM_ADDR_BUS]    vram_r_addr,
    input   [`VRAM_DATA_BUS]    vram_r_data,

    output                      vram_w_ena,
    output  [`VRAM_ADDR_BUS]    vram_w_addr,
    output  [`VRAM_DATA_BUS]    vram_w_data,
    output  [`VRAM_DATA_BUS]    vram_w_mask
);

wire    [`VREG_BUS]         vs1_data  ;
wire                        vs1_r_ena  ;
wire    [`VREG_ADDR_BUS]    vs1_r_addr  ;

wire    [`VREG_BUS]         vs2_data  ;
wire                        vs2_r_ena  ;
wire    [`VREG_ADDR_BUS]    vs2_r_addr  ;

wire    [`VREG_BUS]         vd_w_data ;
wire                        vd_w_ena ;
wire    [`VREG_ADDR_BUS]    vd_w_addr ;

wire    [`ALU_OP_BUS]       v_alu_opcode ;
wire    [`VREG_BUS]         operand_vs1  ;
wire    [`VREG_BUS]         operand_vs2  ;
wire    [`VREG_BUS]         vexe_result ;

wire    [ 2 : 0 ]           vmac_sel ;
wire    [`VREG_BUS]         vmac_result ;

wire                        vmem_r_ena  ;
wire    [`VMEM_ADDR_BUS]    vmem_r_addr  ;
wire    [`VMEM_DATA_BUS]    vmem_r_data ;
wire                        vmem_w_ena  ;
wire    [`VMEM_ADDR_BUS]    vmem_w_addr  ; 
wire    [`VMEM_DATA_BUS]    vmem_w_data  ;

wire                        vwb_ena  ;
wire    [ 1 : 0 ]           vwb_sel  ;
wire    [`VREG_ADDR_BUS]    vwb_addr  ;

v_inst_decode V_ID_Stage(
    .rst            ( rst           ),
    .inst_i         ( inst          ),

    .rs1_data_i     ( vec_rs1_data  ),
    .rs1_r_ena_o    ( vec_rs1_r_ena ),
    .rs1_r_addr_o   ( vec_rs1_r_addr),

    .vs1_data_i     ( vs1_data      ),
    .vs1_r_ena_o    ( vs1_r_ena     ),
    .vs1_r_addr_o   ( vs1_r_addr    ),
    .vs2_data_i     ( vs2_data      ),
    .vs2_r_ena_o    ( vs2_r_ena     ),
    .vs2_r_addr_o   ( vs2_r_addr    ),

    .alu_opcode_o   ( v_alu_opcode  ),
    .operand_vs1_o  ( operand_vs1   ),
    .operand_vs2_o  ( operand_vs2   ),
    .vmac_sel_o     ( vmac_sel      ),

    .vwb_ena_o      ( vwb_ena       ),
    .vwb_sel_o      ( vwb_sel       ),
    .vwb_addr_o     ( vwb_addr      ),

    .vmem_r_ena_o   ( vmem_r_ena    ),
    .vmem_r_addr_o  ( vmem_r_addr   ),
    .vmem_w_ena_o   ( vmem_w_ena    ),
    .vmem_w_data_o  ( vmem_w_data   ),
    .vmem_w_addr_o  ( vmem_w_addr   )
);

v_alu V_ALU_Stage(
    .clk            ( clk ),
    .rst            ( rst ),
    .alu_opcode_i   ( v_alu_opcode  ),
    .operand_vs1_i  ( operand_vs1   ),
    .operand_vs2_i  ( operand_vs2   ),
    .vexe_result_o  ( vexe_result   ),

    .vmac_sel_i     ( vmac_sel      ),
    .vmac_result_o  ( vmac_result   )
);

v_mem V_MEM_Stage(
    .rst            ( rst ),

    .vmem_r_ena_i   ( vmem_r_ena ),
    .vmem_r_addr_i  ( vmem_r_addr ),
    .vmem_r_data_o  ( vmem_r_data ),

    .vmem_w_ena_i   ( vmem_w_ena ),
    .vmem_w_addr_i  ( vmem_w_addr ),
    .vmem_w_data_i  ( vmem_w_data ),

    .vram_r_ena_o   ( vram_r_ena ),
    .vram_r_data_i  ( vram_r_data ),
    .vram_r_addr_o  ( vram_r_addr ),

    .vram_w_ena_o   ( vram_w_ena ),
    .vram_w_addr_o  ( vram_w_addr ),
    .vram_w_data_o  ( vram_w_data ),
    .vram_w_mask_o  ( vram_w_mask )
);

v_write_back V_WB_Stage(
    .rst            ( rst ),

    .vwb_ena_i      ( vwb_ena ),
    .vwb_addr_i     ( vwb_addr ),
    .vwb_sel_i      ( vwb_sel ),
    
    .vexe_data_i    ( vexe_result ),
    .vmem_data_i    ( vmem_r_data ),
    .vmac_data_i    ( vmac_result ),

    .vwb_ena_o      ( vd_w_ena ),
    .vwb_addr_o     ( vd_w_addr ),
    .vwb_data_o     ( vd_w_data )       
);

v_regfile V_REGFILE(
    .clk            ( clk ),
    .rst            ( rst ),
    .w_addr_i       ( vd_w_addr ),
    .w_data_i       ( vd_w_data ),
    .w_ena_i        ( vd_w_ena ),
    .r_ena1_i       ( vs1_r_ena ),
    .r_addr1_i      ( vs1_r_addr ),
    .r_data1_o      ( vs1_data ),
    .r_ena2_i       ( vs2_r_ena ),
    .r_addr2_i      ( vs2_r_addr ),
    .r_data2_o      ( vs2_data )
);


endmodule
