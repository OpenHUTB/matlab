function[lambda,workspace]=sortLambdaQP(lambda,WorkingSet,workspace,iw0)






















%#codegen

    coder.allowpcode('plain');


    validateattributes(lambda,{'double'},{'2d'});
    validateattributes(WorkingSet,{'struct'},{'scalar'});
    validateattributes(workspace,{'double'},{'2d'});
    validateattributes(iw0,{coder.internal.indexIntClass},{'2d'});

    if(isempty(lambda)||WorkingSet.nActiveConstr==0)
        return;
    end

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));

    mIneq=WorkingSet.sizes(AINEQ);
    mEq=WorkingSet.sizes(AEQ);
    mLB=WorkingSet.sizes(LOWER);
    mUB=WorkingSet.sizes(UPPER);
    mFixed=WorkingSet.sizes(FIXED);
    mAll=mFixed+mEq+mLB+mUB+mIneq;



    workspace=coder.internal.blas.xcopy(mAll,lambda,INT_ONE,INT_ONE,workspace,iw0,INT_ONE);


    lambda=coder.internal.blas.xcopy(mAll,0.0,INT_ONE,INT_ZERO,lambda,INT_ONE,INT_ONE);




    idxEq=WorkingSet.isActiveIdx(AEQ)-1;
    idxIneq=WorkingSet.isActiveIdx(AINEQ)-1;
    idxLB=WorkingSet.isActiveIdx(LOWER)-1;
    idxUB=WorkingSet.isActiveIdx(UPPER)-1;
    currentMplier=coder.internal.indexInt(0);

    idx=coder.internal.indexInt(1);
    while(idx<=WorkingSet.nActiveConstr&&WorkingSet.Wid(idx)<=AEQ)
        localIdx=WorkingSet.Wlocalidx(idx);
        switch(WorkingSet.Wid(idx))
        case FIXED
            idxOffset=INT_ZERO;
        otherwise
            idxOffset=idxEq;
        end
        lambda(idxOffset+localIdx)=workspace(iw0+currentMplier);
        currentMplier=currentMplier+1;
        idx=idx+1;
    end

    while(idx<=WorkingSet.nActiveConstr)
        localIdx=WorkingSet.Wlocalidx(idx);
        switch(WorkingSet.Wid(idx))
        case AINEQ
            idxOffset=idxIneq;
        case LOWER
            idxOffset=idxLB;
        otherwise
            idxOffset=idxUB;
        end
        lambda(idxOffset+localIdx)=workspace(iw0+currentMplier);
        currentMplier=currentMplier+1;
        idx=idx+1;
    end

end

