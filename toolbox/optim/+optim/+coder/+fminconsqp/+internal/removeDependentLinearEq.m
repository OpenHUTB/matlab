function[nDepInd,idxArray,memspace,TrialState,WorkingSet,QRManager,QPObjective,beq]=...
    removeDependentLinearEq(Aeq,beq,bnd,idxArray,memspace,TrialState,WorkingSet,QRManager,QPObjective)


















%#codegen

    coder.allowpcode('plain');



    validateattributes(Aeq,{'double'},{'2d'});
    validateattributes(beq,{'double'},{'2d'});
    validateattributes(bnd,{'double'},{'2d'});
    validateattributes(idxArray,{coder.internal.indexIntClass},{'2d'});
    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(TrialState,{'struct'},{'scalar'});
    validateattributes(WorkingSet,{'struct'},{'scalar'});
    validateattributes(QRManager,{'struct'},{'scalar'});

    coder.internal.prefer_const(Aeq,beq,bnd);

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);
    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));

    tolfactor=1e2;


    nVar=WorkingSet.nVar;
    mFixed=WorkingSet.sizes(FIXED);
    mLinEq=coder.internal.indexInt(numel(beq));
    mTotalLinEq=coder.internal.indexInt(mLinEq+mFixed);
    nDepInd=INT_ZERO;

    if(mLinEq<=INT_ZERO)

        return;
    end


    for idx_local=1:mFixed

        idx_bound=WorkingSet.indexFixed(idx_local);
        idx=INT_ONE;
        idxQR=idx_local;
        while(idx<idx_bound)
            QRManager.QR(idxQR)=0.0;
            idx=idx+1;
            idxQR=idxQR+QRManager.ldq;
        end
        QRManager.QR(idxQR)=1.0;
        idx=idx+1;
        while(idx<=nVar)
            idxQR=idxQR+QRManager.ldq;
            QRManager.QR(idxQR)=0.0;
            idx=idx+1;
        end
        WorkingSet.bwset(idx_local)=bnd(idx_bound);
    end


    for idx_local=1:mLinEq

        idx_global=coder.internal.indexInt(mFixed+idx_local);


        QRManager.QR=...
        coder.internal.blas.xcopy(WorkingSet.nVar,Aeq,idx_local,mLinEq,QRManager.QR,idx_global,QRManager.ldq);


        WorkingSet.bwset(idx_global)=beq(idx_local);
    end


    [nDepInd(:),QRManager]=...
    optim.coder.qpactiveset.initialize.ComputeNumDependentEq_...
    (QRManager,[],WorkingSet.bwset,mTotalLinEq,nVar,WorkingSet.ldA,tolfactor);


    if(nDepInd>INT_ZERO)


        for idx_local=1:mFixed

            idx_bound=WorkingSet.indexFixed(idx_local);
            idx=INT_ONE;
            offsetQR=QRManager.ldq*(idx_local-INT_ONE);
            while(idx<idx_bound)
                QRManager.QR(idx+offsetQR)=0.0;
                idx=idx+1;
            end
            QRManager.QR(idx+offsetQR)=1.0;
            idx=idx+1;
            while(idx<=nVar)
                QRManager.QR(idx+offsetQR)=0.0;
                idx=idx+1;
            end
        end


        for idx_local=1:mLinEq

            idx_global=coder.internal.indexInt(mFixed+idx_local);


            iAeq0=1+WorkingSet.ldA*(idx_local-1);
            iQR0=1+QRManager.ldq*(idx_global-1);
            QRManager.QR=coder.internal.blas.xcopy(nVar,WorkingSet.Aeq,iAeq0,INT_ONE,QRManager.QR,iQR0,INT_ONE);
        end



        [idxArray,QRManager]=...
        optim.coder.qpactiveset.initialize.IndexOfDependentEq_...
        (idxArray,mFixed,nDepInd,QRManager,[],nVar,mTotalLinEq,WorkingSet.ldA);




        startIdx=coder.internal.indexInt(1);
        [idxArray,memspace.workspace_sort]=...
        optim.coder.utils.countsort(idxArray,nDepInd,memspace.workspace_sort,startIdx,mTotalLinEq);

        for idx=nDepInd:-1:1
            rmCol=idxArray(idx);
            if(rmCol<mLinEq)
                colOffsetEqWrite=WorkingSet.ldA*(rmCol-1);
                colOffsetEqRead=WorkingSet.ldA*(mLinEq-1);
                for row=1:nVar
                    WorkingSet.Aeq(row+colOffsetEqWrite)=WorkingSet.Aeq(row+colOffsetEqRead);
                end
                beq(rmCol)=beq(mLinEq);
            end
            mLinEq=mLinEq-1;
        end



        mFixed=WorkingSet.sizes(FIXED);
        mEq=WorkingSet.sizes(AEQ)-nDepInd;
        mIneq=WorkingSet.sizes(AINEQ);
        mLB=WorkingSet.sizes(LOWER);
        mUB=WorkingSet.sizes(UPPER);

        WorkingSet.sizes=[mFixed;mEq;mIneq;mLB;mUB];
        WorkingSet.sizesNormal=[mFixed;mEq;mIneq;mLB;mUB];
        WorkingSet.sizesPhaseOne=[mFixed;mEq;mIneq;mLB+1;mUB];
        WorkingSet.sizesRegularized=[mFixed;mEq;mIneq;mLB+mIneq+2*mEq;mUB];
        WorkingSet.sizesRegPhaseOne=[mFixed;mEq;mIneq;mLB+mIneq+2*mEq+1;mUB];

        WorkingSet.isActiveIdx(:)=coder.internal.indexInt(cumsum([1;mFixed;mEq;mIneq;mLB;mUB]));
        WorkingSet.isActiveIdxNormal(:)=coder.internal.indexInt(cumsum([1;mFixed;mEq;mIneq;mLB;mUB]));
        WorkingSet.isActiveIdxPhaseOne(:)=coder.internal.indexInt(cumsum([1;mFixed;mEq;mIneq;mLB+1;mUB]));
        WorkingSet.isActiveIdxRegularized(:)=coder.internal.indexInt(cumsum([1;mFixed;mEq;mIneq;mLB+mIneq+2*mEq;mUB]));
        WorkingSet.isActiveIdxRegPhaseOne(:)=coder.internal.indexInt(cumsum([1;mFixed;mEq;mIneq;mLB+mIneq+2*mEq+1;mUB]));

        WorkingSet.nVarMax=WorkingSet.nVarMax-2*nDepInd;
        WorkingSet.mConstr=WorkingSet.mConstr-nDepInd;
        WorkingSet.mConstrMax=WorkingSet.mConstrMax-3*nDepInd;
        WorkingSet.mConstrOrig=WorkingSet.mConstrOrig-nDepInd;


        QPObjective.maxVar=QPObjective.maxVar-2*nDepInd;


        TrialState.nVarMax=TrialState.nVarMax-2*nDepInd;
        TrialState.mEq=TrialState.mEq-nDepInd;
        TrialState.iNonEq0=TrialState.iNonEq0-nDepInd;
    end


end