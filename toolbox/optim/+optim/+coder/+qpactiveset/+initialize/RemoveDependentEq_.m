function[nDepInd,memspace,workingset,qrmanager]=RemoveDependentEq_(memspace,workingset,qrmanager,tolfactor)

























%#codegen

    coder.allowpcode('plain');



    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(workingset,{'struct'},{'scalar'});
    validateattributes(qrmanager,{'struct'},{'scalar'});
    validateattributes(tolfactor,{'double'},{'scalar'});

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));


    nVar=workingset.nVar;
    mWorkingFixed=workingset.nWConstr(FIXED);
    mWorkingEq=workingset.nWConstr(AEQ);
    mTotalWorkingEq=coder.internal.indexInt(mWorkingEq+mWorkingFixed);
    nDepInd=INT_ZERO;

    if(mTotalWorkingEq<=INT_ZERO)



        return;
    end





    for idx_row=1:mTotalWorkingEq
        for idx_col=1:nVar
            idxPosQR=idx_row+qrmanager.ldq*(idx_col-INT_ONE);
            idxPosATwset=idx_col+workingset.ldA*(idx_row-INT_ONE);
            qrmanager.QR(idxPosQR)=workingset.ATwset(idxPosATwset);
        end
    end

    [nDepInd(:),qrmanager]=...
    optim.coder.qpactiveset.initialize.ComputeNumDependentEq_...
    (qrmanager,[],workingset.bwset,mTotalWorkingEq,nVar,workingset.ldA,tolfactor);

    if(nDepInd>INT_ZERO)



        for idx_col=1:mTotalWorkingEq
            offsetQR=INT_ONE+qrmanager.ldq*(idx_col-INT_ONE);
            offsetATw=INT_ONE+workingset.ldA*(idx_col-INT_ONE);
            qrmanager.QR=coder.internal.blas.xcopy(nVar,workingset.ATwset,offsetATw,INT_ONE,qrmanager.QR,offsetQR,INT_ONE);
        end


        [memspace.workspace_int,qrmanager]=...
        optim.coder.qpactiveset.initialize.IndexOfDependentEq_...
        (memspace.workspace_int,mWorkingFixed,nDepInd,qrmanager,[],nVar,mTotalWorkingEq,workingset.ldA);




        startIdx=coder.internal.indexInt(1);
        [memspace.workspace_int,memspace.workspace_sort]=...
        optim.coder.utils.countsort(memspace.workspace_int,nDepInd,memspace.workspace_sort,startIdx,mTotalWorkingEq);












        for idx=nDepInd:-1:1
            workingset=optim.coder.qpactiveset.WorkingSet.removeEqConstr(workingset,memspace.workspace_int(idx));
        end

    end

end
