function[idxMinLambda,memspace]=find_neg_lambda(solution,workingset,objective,memspace,...
    options,runTimeOptions,TYPE)























%#codegen

    coder.allowpcode('plain');

    validateattributes(solution,{'struct'},{'scalar'});
    validateattributes(workingset,{'struct'},{'scalar'});
    validateattributes(objective,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(options,{'struct'},{'scalar'});
    validateattributes(runTimeOptions,{'struct'},{'scalar'});
    validateattributes(TYPE,{coder.internal.indexIntClass},{'scalar'});

    coder.internal.prefer_const(options);

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));

    PHASEONE=coder.const(optim.coder.qpactiveset.Objective.ID('PHASEONE'));

    mFixed=workingset.nWConstr(FIXED);
    mEq=workingset.nWConstr(AEQ);

    idxMinLambda=coder.internal.indexInt(0);




    minLambda=options.PricingTolerance*runTimeOptions.ProbRelTolFactor*double(TYPE~=PHASEONE);
    for idx=mFixed+mEq+1:workingset.nActiveConstr
        if(solution.lambda(idx)<minLambda)
            minLambda=solution.lambda(idx);
            idxMinLambda=idx;
        end
    end

end

