function[Hessian,TrialState,MeritFunction,memspace,WorkingSet,QRManager,CholManager,QPObjective]=...
    normal(Hessian,grad,TrialState,MeritFunction,memspace,WorkingSet,...
    QRManager,CholManager,QPObjective,options,qpoptions)




















%#codegen

    coder.allowpcode('plain');

    validateattributes(Hessian,{'double'},{'2d','real'});
    validateattributes(grad,{'double'},{'vector','real'});
    validateattributes(TrialState,{'struct'},{'scalar'});
    validateattributes(MeritFunction,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(WorkingSet,{'struct'},{'scalar'});
    validateattributes(QRManager,{'struct'},{'scalar'});
    validateattributes(CholManager,{'struct'},{'scalar'});
    validateattributes(QPObjective,{'struct'},{'scalar'});
    validateattributes(options,{'struct'},{'scalar'});
    validateattributes(qpoptions,{'struct'},{'scalar'});

    coder.internal.prefer_const(options,qpoptions);

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));






    [TrialState,memspace,WorkingSet,QRManager,CholManager,QPObjective]=...
    optim.coder.qpactiveset.driver(Hessian,grad,TrialState,...
    memspace,WorkingSet,QRManager,CholManager,QPObjective,qpoptions,qpoptions);

    if(TrialState.state>0)

        mIneq=WorkingSet.sizes(AINEQ);
        mEq=WorkingSet.sizes(AEQ);

        MeritFunction=optim.coder.fminconsqp.MeritFunction.updatePenaltyParam(MeritFunction,...
        TrialState.sqpFval,TrialState.cIneq,INT_ONE,mIneq,TrialState.cEq,INT_ONE,mEq,...
        TrialState.sqpIterations,TrialState.fstar,TrialState.xstar,INT_ONE,INT_ZERO,options);
    end



    [TrialState.lambda,memspace.workspace_double]=...
    optim.coder.qpactiveset.parseoutput.sortLambdaQP(TrialState.lambda,WorkingSet,memspace.workspace_double,INT_ONE);




    nonlinEqRemoved=(WorkingSet.mEqRemoved>0);
    if(numel(WorkingSet.indexEqRemoved)>0)
        while(WorkingSet.mEqRemoved>0&&WorkingSet.indexEqRemoved(WorkingSet.mEqRemoved)>=TrialState.iNonEq0)
            WorkingSet=optim.coder.qpactiveset.WorkingSet.addAeqConstr(WorkingSet,WorkingSet.indexEqRemoved(WorkingSet.mEqRemoved));
            WorkingSet.mEqRemoved=WorkingSet.mEqRemoved-1;
        end
    end




    if nonlinEqRemoved
        eqNonLinStart=WorkingSet.sizes(FIXED)+TrialState.iNonEq0;
        for idx=1:TrialState.mNonlinEq
            WorkingSet.Wlocalidx(eqNonLinStart+idx-1)=TrialState.iNonEq0+idx-1;
        end

    end

end

