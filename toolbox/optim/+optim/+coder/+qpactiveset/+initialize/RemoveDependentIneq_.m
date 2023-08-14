function[workingset,qrmanager,memspace]=RemoveDependentIneq_(workingset,qrmanager,memspace,tolfactor)


























%#codegen

    coder.allowpcode('plain');


    validateattributes(workingset,{'struct'},{'scalar'});
    validateattributes(qrmanager,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(tolfactor,{'double'},{'scalar'});

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));

    nActiveConstr=workingset.nActiveConstr;
    mWorkingFixed=workingset.nWConstr(FIXED);
    mWorkingEq=workingset.nWConstr(AEQ);
    mWorkingIneq=workingset.nWConstr(AINEQ);
    mWorkingLB=workingset.nWConstr(LOWER);
    mWorkingUB=workingset.nWConstr(UPPER);
    totalWorkingIneq=mWorkingIneq+mWorkingLB+mWorkingUB;


    nFixedConstr=mWorkingEq+mWorkingFixed;
    nVar=workingset.nVar;

    if(totalWorkingIneq<=INT_ZERO)
        return;
    end

    tol=tolfactor*double(nVar)*eps('double');



    for idx=INT_ONE:nFixedConstr
        qrmanager.jpvt(idx)=INT_ONE;
    end
    for idx=nFixedConstr+1:nActiveConstr
        qrmanager.jpvt(idx)=INT_ZERO;
    end


    for idx_col=INT_ONE:workingset.nActiveConstr
        idxPosQR=INT_ONE+qrmanager.ldq*(idx_col-INT_ONE);
        idxPosATwset=INT_ONE+workingset.ldA*(idx_col-INT_ONE);
        qrmanager.QR=coder.internal.blas.xcopy(...
        nVar,workingset.ATwset,idxPosATwset,INT_ONE,qrmanager.QR,idxPosQR,INT_ONE);
    end



    qrmanager=optim.coder.QRManager.factorQRE(qrmanager,[],nVar,nActiveConstr,workingset.ldA);




    nDepIneq=INT_ZERO;
    idx=nActiveConstr;
    while(idx>nVar)
        nDepIneq=nDepIneq+1;
        memspace.workspace_int(nDepIneq)=qrmanager.jpvt(idx);
        idx=idx-1;
    end

    if(idx<=nVar)
        idxDiag=idx+qrmanager.ldq*(idx-INT_ONE);
        while(idx>nFixedConstr&&abs(qrmanager.QR(idxDiag))<tol)
            nDepIneq=nDepIneq+1;
            memspace.workspace_int(nDepIneq)=qrmanager.jpvt(idx);
            idx=idx-1;
            idxDiag=idxDiag-qrmanager.ldq-INT_ONE;
        end
    end



    startIdx=nFixedConstr+1;
    endIdx=nActiveConstr;
    [memspace.workspace_int,memspace.workspace_sort]=...
    optim.coder.utils.countsort(memspace.workspace_int,nDepIneq,memspace.workspace_sort,startIdx,endIdx);




    for idx=nDepIneq:-1:1
        workingset=optim.coder.qpactiveset.WorkingSet.removeConstr(workingset,memspace.workspace_int(idx));
    end
