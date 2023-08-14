function[nActiveLBArtificial,memspace]=findActiveSlackLowerBounds(memspace,WorkingSet)





















%#codegen

    coder.allowpcode('plain');


    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(WorkingSet,{'struct'},{'scalar'});

    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));

    mIneq=WorkingSet.sizes(AINEQ);
    mEq=WorkingSet.sizes(AEQ);
    nArtificial=2*mEq+mIneq;


    mFiniteLB=WorkingSet.sizes(LOWER);


    nActiveLBArtificial=coder.internal.indexInt(0);








    for idx=1:mEq
        isPosAeqActive=coder.internal.indexInt(optim.coder.qpactiveset.WorkingSet.isActive(WorkingSet,LOWER,mFiniteLB-2*mEq+idx));
        isNegAeqActive=coder.internal.indexInt(optim.coder.qpactiveset.WorkingSet.isActive(WorkingSet,LOWER,mFiniteLB-mEq+idx));
        memspace.workspace_int(idx)=isPosAeqActive;
        memspace.workspace_int(idx+mEq)=isNegAeqActive;
        nActiveLBArtificial=nActiveLBArtificial+isPosAeqActive+isNegAeqActive;
    end

    for idx=1:mIneq
        isAineqActive=coder.internal.indexInt(optim.coder.qpactiveset.WorkingSet.isActive(WorkingSet,LOWER,mFiniteLB-nArtificial+idx));
        memspace.workspace_int(idx+2*mEq)=isAineqActive;
        nActiveLBArtificial=nActiveLBArtificial+isAineqActive;
    end

end

