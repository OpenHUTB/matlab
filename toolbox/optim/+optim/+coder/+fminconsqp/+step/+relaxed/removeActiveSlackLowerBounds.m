function[TrialState,WorkingSet]=removeActiveSlackLowerBounds(nActiveLBArtificial,TrialState,WorkingSet)



















%#codegen

    coder.allowpcode('plain');


    validateattributes(nActiveLBArtificial,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(TrialState,{'struct'},{'scalar'});
    validateattributes(WorkingSet,{'struct'},{'scalar'});

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));

    mIneq=WorkingSet.sizes(AINEQ);
    mFixed=WorkingSet.sizes(FIXED);
    mEq=WorkingSet.sizes(AEQ);


    mFiniteLBOrig=WorkingSet.sizes(LOWER)-2*mEq-mIneq;





    idx=WorkingSet.nActiveConstr;
    while(idx>mFixed+mEq&&nActiveLBArtificial>0)
        if(WorkingSet.Wid(idx)==LOWER&&WorkingSet.Wlocalidx(idx)>mFiniteLBOrig)




            tmp=TrialState.lambda(WorkingSet.nActiveConstr);
            TrialState.lambda(WorkingSet.nActiveConstr)=0.0;
            TrialState.lambda(idx)=tmp;
            WorkingSet=optim.coder.qpactiveset.WorkingSet.removeConstr(WorkingSet,idx);
            nActiveLBArtificial=nActiveLBArtificial-1;
        end
        idx=idx-1;
    end

end

