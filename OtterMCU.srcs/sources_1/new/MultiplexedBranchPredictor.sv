`timescale 1ns / 1ps

import Types::*;

module MultiplexedBranchPredictor(
        BranchPredictor.Predictor bp,
        input branch_predictor_t selection
    );
    
    `define connect(ibp) always_comb begin \
        ibp.id_is_branch = bp.id_is_branch;\
        ibp.id_branch_type = bp.id_branch_type;\
        ibp.id_pc = bp.id_pc;\
        ibp.id_target = bp.id_target;\
        ibp.ex_branched = bp.ex_branched;\
        ibp.ex_pc = bp.ex_pc;\
        ibp.ex_target = bp.ex_target;\
    end
    
    BranchPredictor always_ibp(
        .clk(bp.clk),
        .reset(bp.clk)
    );
    `connect(always_ibp);
    AlwaysBranchPredictor always_bp(.bp(always_ibp));
    
    BranchPredictor never_ibp(
        .clk(bp.clk),
        .reset(bp.clk)
    );
    `connect(never_ibp);
    NeverBranchPredictor never_bp(.bp(never_ibp));
    
    BranchPredictor random_ibp(
        .clk(bp.clk),
        .reset(bp.clk)
    );
    `connect(random_ibp);
    RandomBranchPredictor random(.bp(random_ibp));
    
    BranchPredictor backwards_ibp(
        .clk(bp.clk),
        .reset(bp.clk)
    );
    `connect(backwards_ibp);
    AlwaysBackwardsPredictor backwards(.bp(backwards_ibp));
    
    always_comb case (selection)
        bp_random: 
            bp.should_branch = random_ibp.should_branch;
        bp_always: 
            bp.should_branch = always_ibp.should_branch;
        bp_never: 
            bp.should_branch = never_ibp.should_branch;
        bp_backwards: 
            bp.should_branch = backwards_ibp.should_branch;
    endcase
    
endmodule