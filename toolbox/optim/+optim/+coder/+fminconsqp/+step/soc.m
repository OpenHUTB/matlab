function[success,Hessian,TrialState,MeritFunction,memspace,WorkingSet,QRManager,CholManager,QPObjective]=...
    soc(Hessian,grad,TrialState,MeritFunction,memspace,WorkingSet,QRManager,CholManager,QPObjective,qpoptions)




















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
    validateattributes(qpoptions,{'struct'},{'scalar'});

    coder.internal.prefer_const(qpoptions);

    INT_ONE=coder.internal.indexInt(1);

    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));



    nWIneq_old=WorkingSet.nWConstr(AINEQ);
    nWLower_old=WorkingSet.nWConstr(LOWER);
    nWUpper_old=WorkingSet.nWConstr(UPPER);

    nVar=WorkingSet.nVar;
    mConstrMax=WorkingSet.mConstrMax;








    TrialState.xstarsqp=coder.internal.blas.xcopy(nVar,TrialState.xstarsqp_old,INT_ONE,INT_ONE,...
    TrialState.xstarsqp,INT_ONE,INT_ONE);











    for i=1:nVar
        TrialState.socDirection(i)=TrialState.xstar(i);
    end



    TrialState.lambdaStopTest=coder.internal.blas.xcopy(mConstrMax,TrialState.lambda,INT_ONE,INT_ONE,...
    TrialState.lambdaStopTest,INT_ONE,INT_ONE);





    [WorkingSet,TrialState.workingset_old]=...
    optim.coder.fminconsqp.step.soc.updateWorkingSet(WorkingSet,TrialState,TrialState.workingset_old);




    TrialState.xstar=coder.internal.blas.xcopy(nVar,TrialState.xstarsqp,INT_ONE,INT_ONE,...
    TrialState.xstar,INT_ONE,INT_ONE);







    [TrialState,memspace,WorkingSet,QRManager,CholManager,QPObjective]=...
    optim.coder.qpactiveset.driver(Hessian,grad,TrialState,...
    memspace,WorkingSet,QRManager,CholManager,QPObjective,qpoptions,qpoptions);




    if(numel(WorkingSet.indexEqRemoved)>0)
        while(WorkingSet.mEqRemoved>0&&WorkingSet.indexEqRemoved(WorkingSet.mEqRemoved)>=TrialState.iNonEq0)
            rm_eqIdx=WorkingSet.indexEqRemoved(WorkingSet.mEqRemoved);
            WorkingSet=optim.coder.qpactiveset.WorkingSet.addAeqConstr(WorkingSet,rm_eqIdx);
            WorkingSet.mEqRemoved=WorkingSet.mEqRemoved-1;
        end
    end



    for idx=1:nVar
        oldDirIdx=TrialState.socDirection(idx);


        TrialState.socDirection(idx)=TrialState.xstar(idx)-oldDirIdx;
        TrialState.xstar(idx)=oldDirIdx;
    end





    lenSOC=coder.internal.blas.xnrm2(nVar,TrialState.socDirection,INT_ONE,INT_ONE);
    lenQPNormal=coder.internal.blas.xnrm2(nVar,TrialState.xstar,INT_ONE,INT_ONE);






    success=(lenSOC<=2*lenQPNormal);




    WorkingSet=...
    optim.coder.fminconsqp.step.soc.restoreWorkingSet(success,nWIneq_old,nWLower_old,nWUpper_old,...
    WorkingSet,TrialState,TrialState.workingset_old);

    if~success


        TrialState.lambda=coder.internal.blas.xcopy(mConstrMax,TrialState.lambdaStopTest,INT_ONE,INT_ONE,...
        TrialState.lambda,INT_ONE,INT_ONE);
    else


        [TrialState.lambda,memspace.workspace_double]=...
        optim.coder.qpactiveset.parseoutput.sortLambdaQP...
        (TrialState.lambda,WorkingSet,memspace.workspace_double,INT_ONE);
    end

end

