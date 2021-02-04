`include "Types.sv"

module IDStage(
    input [31:0] pc,
    input [31:0] ir,
    input IFID_t prev,
    output [4:0] adr1,
    output [4:0] adr2,
    input [31:0] rs1,
    input [31:0] rs2,
    output IDEX_t result
);

    CU_DCDR cu_dcdr(
        .opcode(ir[6:0]),
        .func7(ir[31:25]),
        .func3(ir[14:12]),
        
        .int_taken(int_taken),
        .br_eq(br_eq),
        .br_lt(br_lt),
        .br_ltu(br_ltu)
    );


    ImmedGen imm_gen(
        .ir(ir[31:7])
    );
        
    assign adr1 = ir[19:15];
    assign adr2 = ir[24:20];
    
    assign result.alu_a = cu_dcdr.alu_srcA
            ? imm_gen.u_type_imm 
            : rs1;
        
    always_comb case(cu_dcdr.alu_srcB)
        4'd0: result.alu_b = rs2;
        4'd1: result.alu_b = imm_gen.i_type_imm;
        4'd2: result.alu_b = imm_gen.s_type_imm;
        4'd3: result.alu_b = prev.pc;
    endcase
    
    assign result.wb.rf_wr_sel = cu_dcdr.rf_wr_sel;
    assign result.wb.rf_wr_en = cu_dcdr.rf_wr_en;
    assign result.pc = pc;
endmodule
