function[WorkingSet,TrialState,memspace]=assignResidualsToXSlack(nVarOrig,WorkingSet,TrialState,memspace,TolCon)






















%#codegen

    coder.allowpcode('plain');

    validateattributes(nVarOrig,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(WorkingSet,{'struct'},{'scalar'});
    validateattributes(TrialState,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(TolCon,{'double'},{'scalar'});

    coder.internal.prefer_const(nVarOrig,TolCon);

    INT_ONE=coder.internal.indexInt(1);

    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));

    mIneq=WorkingSet.sizes(AINEQ);
    mEq=WorkingSet.sizes(AEQ);
    mLBOrig=WorkingSet.sizes(LOWER)-2*mEq-mIneq;



    memspace.workspace_double=coder.internal.blas.xcopy(mIneq,WorkingSet.bineq,INT_ONE,INT_ONE,...
    memspace.workspace_double,INT_ONE,INT_ONE);
    memspace.workspace_double=coder.internal.blas.xgemv('T',nVarOrig,mIneq,...
    1.0,WorkingSet.Aineq,INT_ONE,WorkingSet.ldA,...
    TrialState.xstar,INT_ONE,INT_ONE,...
    -1.0,memspace.workspace_double,INT_ONE,INT_ONE);



    for idx=1:mIneq
        mplier=double(memspace.workspace_double(idx)>0);
        TrialState.xstar(nVarOrig+idx)=mplier*memspace.workspace_double(idx);
    end



    memspace.workspace_double=coder.internal.blas.xcopy(mEq,WorkingSet.beq,INT_ONE,INT_ONE,...
    memspace.workspace_double,INT_ONE,INT_ONE);
    memspace.workspace_double=coder.internal.blas.xgemv('T',nVarOrig,mEq,...
    1.0,WorkingSet.Aeq,INT_ONE,WorkingSet.ldA,...
    TrialState.xstar,INT_ONE,INT_ONE,...
    -1.0,memspace.workspace_double,INT_ONE,INT_ONE);




    for idx=1:mEq
        idx_positive=mIneq+idx;
        idx_negative=mIneq+mEq+idx;

        if(memspace.workspace_double(idx)<=0)

            TrialState.xstar(nVarOrig+idx_positive)=0.0;
            TrialState.xstar(nVarOrig+idx_negative)=-memspace.workspace_double(idx);


            WorkingSet=optim.coder.qpactiveset.WorkingSet.addLBConstr(WorkingSet,mLBOrig+idx_positive);
            if(memspace.workspace_double(idx)>=-TolCon)
                WorkingSet=optim.coder.qpactiveset.WorkingSet.addLBConstr(WorkingSet,mLBOrig+idx_negative);
            end

        else

            TrialState.xstar(nVarOrig+idx_positive)=memspace.workspace_double(idx);
            TrialState.xstar(nVarOrig+idx_negative)=0.0;


            WorkingSet=optim.coder.qpactiveset.WorkingSet.addLBConstr(WorkingSet,mLBOrig+idx_negative);
            if(memspace.workspace_double(idx)<=TolCon)
                WorkingSet=optim.coder.qpactiveset.WorkingSet.addLBConstr(WorkingSet,mLBOrig+idx_positive);
            end
        end

    end

end

