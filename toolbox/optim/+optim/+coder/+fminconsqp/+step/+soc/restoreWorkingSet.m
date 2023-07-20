function WorkingSet=restoreWorkingSet(stepSuccess,nWIneq_old,nWLower_old,nWUpper_old,...
    WorkingSet,TrialState,workspace_int)




















%#codegen

    coder.allowpcode('plain');


    validateattributes(stepSuccess,{'logical'},{'scalar'});
    validateattributes(nWIneq_old,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(nWLower_old,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(nWUpper_old,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(WorkingSet,{'struct'},{'scalar'});
    validateattributes(TrialState,{'struct'},{'scalar'});
    validateattributes(workspace_int,{coder.internal.indexIntClass},{'vector'});

    coder.internal.prefer_const(stepSuccess);

    INT_ONE=coder.internal.indexInt(1);

    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));

    mEq=WorkingSet.sizes(AEQ);
    mIneq=WorkingSet.sizes(AINEQ);
    mLB=WorkingSet.sizes(LOWER);



    if(mEq>0)


        FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));


        for idx=1:mEq
            WorkingSet.beq(idx)=-TrialState.cEq(idx);
        end


        offsetAwEq=WorkingSet.sizes(FIXED);
        WorkingSet.bwset=coder.internal.blas.xcopy(mEq,WorkingSet.beq,INT_ONE,INT_ONE,...
        WorkingSet.bwset,offsetAwEq+1,INT_ONE);
    end

    if(mIneq>0)


        for idx=1:mIneq
            WorkingSet.bineq(idx)=-TrialState.cIneq(idx);
        end

        if~stepSuccess


            WorkingSet=optim.coder.qpactiveset.WorkingSet.removeAllIneqConstr(WorkingSet);


            for idx=1:nWIneq_old
                WorkingSet=optim.coder.qpactiveset.WorkingSet.addAineqConstr(WorkingSet,workspace_int(idx));
            end


            for idx=1:nWLower_old
                WorkingSet=optim.coder.qpactiveset.WorkingSet.addLBConstr(WorkingSet,workspace_int(idx+mIneq));
            end

            for idx=1:nWUpper_old
                WorkingSet=optim.coder.qpactiveset.WorkingSet.addUBConstr(WorkingSet,workspace_int(idx+mIneq+mLB));
            end
        end

    end

end

