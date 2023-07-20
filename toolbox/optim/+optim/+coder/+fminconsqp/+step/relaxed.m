function[Hessian,TrialState,MeritFunction,memspace,WorkingSet,QRManager,CholManager,QPObjective,qpoptions]=...
    relaxed(Hessian,grad,TrialState,MeritFunction,memspace,WorkingSet,...
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


    INT_ONE=coder.internal.indexInt(1);

    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));

    NORMAL_CONSTR=coder.const(optim.coder.qpactiveset.constants.ConstraintType('NORMAL'));
    REGULARIZED_CONSTR=coder.const(optim.coder.qpactiveset.constants.ConstraintType('REGULARIZED'));

    NON_CONVEX_QP=coder.const(optim.coder.SolutionState('IndefiniteQP'));

    nVarOrig=WorkingSet.nVar;
    nVarMax=WorkingSet.nVarMax;

    mIneq=WorkingSet.sizes(AINEQ);
    mEq=WorkingSet.sizes(AEQ);




    beta=0.0;
    for idx=1:nVarOrig
        beta=beta+Hessian(idx,idx);
    end
    beta=beta/double(nVarOrig);

    if(TrialState.sqpIterations<=1)


        idx_max=coder.internal.blas.ixamax(QPObjective.nvar,grad,INT_ONE,INT_ONE);
        rho=100*max(1.0,abs(grad(idx_max)));
    else

        idx_max=coder.internal.blas.ixamax(WorkingSet.mConstr,TrialState.lambdasqp,INT_ONE,INT_ONE);
        rho=abs(TrialState.lambdasqp(idx_max));
    end








    QPObjective=optim.coder.qpactiveset.Objective.setRegularized(QPObjective,true,nVarOrig,beta,rho);
    WorkingSet=optim.coder.qpactiveset.WorkingSet.setProblemType(WorkingSet,REGULARIZED_CONSTR);






    [WorkingSet,TrialState,memspace]=...
    optim.coder.fminconsqp.step.relaxed.assignResidualsToXSlack...
    (nVarOrig,WorkingSet,TrialState,memspace,options.ConstraintTolerance);




    temp=qpoptions.MaxIterations;
    qpoptions.MaxIterations=qpoptions.MaxIterations+WorkingSet.nVar-nVarOrig;




    [TrialState,memspace,WorkingSet,QRManager,CholManager,QPObjective]=...
    optim.coder.qpactiveset.driver(Hessian,grad,TrialState,...
    memspace,WorkingSet,QRManager,CholManager,QPObjective,qpoptions,qpoptions);

    qpoptions.MaxIterations=temp;





    [nActiveLBArtificial,memspace]=...
    optim.coder.fminconsqp.step.relaxed.findActiveSlackLowerBounds(memspace,WorkingSet);


    if(TrialState.state~=NON_CONVEX_QP)




        nArtificial=WorkingSet.nVarMax-nVarOrig-1;


        qpfvalLinearExcess=coder.internal.blas.xasum(nArtificial,TrialState.xstar,nVarOrig+1,INT_ONE);

        qpfvalQuadExcess=coder.internal.blas.xdot(nArtificial,TrialState.xstar,nVarOrig+1,INT_ONE,...
        TrialState.xstar,nVarOrig+1,INT_ONE);

        qpfvalOrig=TrialState.fstar-rho*qpfvalLinearExcess-beta/2*qpfvalQuadExcess;




        MeritFunction=optim.coder.fminconsqp.MeritFunction.updatePenaltyParam(MeritFunction,...
        TrialState.sqpFval,TrialState.cIneq,INT_ONE,mIneq,TrialState.cEq,INT_ONE,mEq,...
        TrialState.sqpIterations,qpfvalOrig,TrialState.xstar,nVarOrig+1,nVarMax-nVarOrig-1,options);




        iEq0=WorkingSet.isActiveIdx(AEQ);
        for idx=1:mEq
            isAeqActive=memspace.workspace_int(idx)&&memspace.workspace_int(idx+mEq);
            TrialState.lambda(iEq0+idx-1)=double(isAeqActive)*TrialState.lambda(iEq0+idx-1);
        end



        iIneq0=WorkingSet.isActiveIdx(AINEQ);
        iIneqEnd=WorkingSet.nActiveConstr;
        for idx=iIneq0:iIneqEnd
            idx_local=WorkingSet.Wlocalidx(idx);
            if(WorkingSet.Wid(idx)==AINEQ)
                isAineqActive=memspace.workspace_int(idx_local+2*mEq);
                TrialState.lambda(idx)=double(isAineqActive)*TrialState.lambda(idx);
            end
        end

    end



    [TrialState,WorkingSet]=...
    optim.coder.fminconsqp.step.relaxed.removeActiveSlackLowerBounds(nActiveLBArtificial,TrialState,WorkingSet);



    QPObjective=optim.coder.qpactiveset.Objective.setQuadratic(QPObjective,true,nVarOrig);
    WorkingSet=optim.coder.qpactiveset.WorkingSet.setProblemType(WorkingSet,NORMAL_CONSTR);



    [TrialState.lambda,memspace.workspace_double]=...
    optim.coder.qpactiveset.parseoutput.sortLambdaQP(TrialState.lambda,WorkingSet,memspace.workspace_double,INT_ONE);

end

