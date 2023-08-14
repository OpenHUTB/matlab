function[workingset,memspace]=...
    updateWorkingSet(workingset,memspace,A,b,Aeq,beq,lb,ub,tolcon)






































%#codegen

    coder.allowpcode('plain');

    validateattributes(workingset,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(A,{'double'},{'2d'});
    validateattributes(b,{'double'},{'2d'});
    validateattributes(Aeq,{'double'},{'2d'});
    validateattributes(beq,{'double'},{'2d'});
    validateattributes(lb,{'double'},{'2d'});
    validateattributes(ub,{'double'},{'2d'});
    validateattributes(tolcon,{'double'},{'scalar'});

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);

    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));
    QP_NORMAL_PROB_ID=coder.const(optim.coder.qpactiveset.constants.ConstraintType('NORMAL'));

    mIneq=coder.internal.indexInt(numel(b));
    mIneqOld=workingset.sizes(AINEQ);
    mLBOld=workingset.sizes(LOWER);
    mUBOld=workingset.sizes(UPPER);
    mEq=coder.internal.indexInt(numel(beq));
    nVar=workingset.nVar;
    mConstrMax=workingset.mConstrMax;





    [memspace.workspace_int,memspace.workspace_compareIneq,memspace.workspace_sort,memspace.workspace_double]=...
    optim.coder.warmstart.qpactiveset.orderDuplicateConstr(memspace.workspace_int,...
    A,b,workingset.Aineq,workingset.bineq,workingset.ldA,nVar,mIneqOld,...
    memspace.workspace_compareIneq,memspace.workspace_sort,memspace.workspace_double);



    mIneqActiveOffset=workingset.isActiveIdx(AINEQ)-INT_ONE;
    mIneqStayActive=INT_ZERO;
    for idx=INT_ONE:mIneqOld
        idxPerm=memspace.workspace_int(mIneq+idx);
        if(idxPerm<=mIneq&&workingset.isActiveConstr(mIneqActiveOffset+idx))

            mIneqStayActive=mIneqStayActive+INT_ONE;
            memspace.workspace_sort(mIneqStayActive)=idxPerm;
        end
    end





    mLBStayActive=INT_ZERO;
    workspaceLBOffset=mIneqStayActive;
    if~isempty(lb)
        mLBActiveOffset=workingset.isActiveIdx(LOWER)-INT_ONE;
        for idx=INT_ONE:mLBOld
            idxOld=workingset.indexLB(idx);
            reltol=tolcon*max(1.0,abs(lb(idxOld)));
            if(abs(workingset.lb(idxOld)+lb(idxOld))<=reltol&&...
                workingset.isActiveConstr(mLBActiveOffset+idx))

                mLBStayActive=mLBStayActive+INT_ONE;
                memspace.workspace_sort(workspaceLBOffset+mLBStayActive)=idxOld;
            end
        end
    end



    mUBStayActive=INT_ZERO;
    workspaceUBOffset=mIneqStayActive+mLBStayActive;
    if~isempty(ub)
        mUBActiveOffset=workingset.isActiveIdx(UPPER)-INT_ONE;
        for idx=INT_ONE:mUBOld
            idxOld=workingset.indexUB(idx);
            reltol=tolcon*max(1.0,abs(ub(idxOld)));
            if(abs(workingset.ub(idxOld)-ub(idxOld))<=reltol&&...
                workingset.isActiveConstr(mUBActiveOffset+idx))

                mUBStayActive=mUBStayActive+INT_ONE;
                memspace.workspace_sort(workspaceUBOffset+mUBStayActive)=idxOld;
            end
        end
    end





    workingset=optim.coder.qpactiveset.WorkingSet.removeAllIneqConstr(workingset);

    [workingset.indexLB,mLB,workingset.indexUB,mUB,workingset.indexFixed,mFixed]=...
    optim.coder.qpactiveset.initialize.compressBounds(...
    nVar,workingset.indexLB,workingset.indexUB,workingset.indexFixed,...
    lb,ub,eml_option('NonFinitesSupport'),tolcon);

    workingset=optim.coder.qpactiveset.WorkingSet.loadProblem(workingset,mIneq,mIneq,A,b,...
    mEq,mEq,Aeq,beq,...
    mLB,lb,...
    mUB,ub,...
    mFixed,mConstrMax);

    workingset=optim.coder.qpactiveset.WorkingSet.initActiveSet(workingset,QP_NORMAL_PROB_ID);












    idx=INT_ONE;
    while(idx<=mIneqStayActive&&workingset.nActiveConstr<nVar)
        workingset=optim.coder.qpactiveset.WorkingSet.addAineqConstr(workingset,memspace.workspace_sort(idx));
        idx=idx+INT_ONE;
    end







    if~isempty(lb)
        idx_local=INT_ONE;
        idx=INT_ONE;
        while(idx<=mLBStayActive&&idx_local<=mLB&&workingset.nActiveConstr<nVar)
            if(memspace.workspace_sort(workspaceLBOffset+idx)==workingset.indexLB(idx_local))
                workingset=optim.coder.qpactiveset.WorkingSet.addLBConstr(workingset,idx_local);
                idx_local=idx_local+INT_ONE;
                idx=idx+INT_ONE;
            elseif(memspace.workspace_sort(workspaceLBOffset+idx)<workingset.indexLB(idx_local))
                idx=idx+INT_ONE;
            else
                idx_local=idx_local+INT_ONE;
            end
        end
    end

    if~isempty(ub)
        idx_local=INT_ONE;
        idx=INT_ONE;
        while(idx<=mUBStayActive&&idx_local<=mUB&&workingset.nActiveConstr<nVar)
            if(memspace.workspace_sort(workspaceUBOffset+idx)==workingset.indexUB(idx_local))
                workingset=optim.coder.qpactiveset.WorkingSet.addUBConstr(workingset,idx_local);
                idx_local=idx_local+INT_ONE;
                idx=idx+INT_ONE;
            elseif(memspace.workspace_sort(workspaceUBOffset+idx)<workingset.indexUB(idx_local))
                idx=idx+INT_ONE;
            else
                idx_local=idx_local+INT_ONE;
            end
        end
    end

end

