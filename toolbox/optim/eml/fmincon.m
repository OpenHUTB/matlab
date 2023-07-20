function[x,fval,exitflag,output,lambda,grad,Hessian]=fmincon(fun,x0,Aineq,bineq,Aeq,beq,lb,ub,nonlcon,options)












































%#codegen


    coder.columnMajor;
    coder.allowpcode('plain');
    coder.internal.prefer_const(fun,x0,Aineq,bineq,Aeq,beq,lb,ub,nonlcon,options)







    numOutputs=nargout();
    numInputs=nargin();


    optim.coder.validate.checkProducts();



    coder.internal.errorIf(numInputs==1&&isstruct(fun),'optimlib_codegen:common:NoProbStructSupport');

    coder.internal.errorIf(numInputs<10,'optimlib_codegen:common:TooFewInputs','FMINCON',10,'sqp');


    optim.coder.validate.checkX0(x0);
    nVar=coder.internal.indexInt(numel(x0));


    optim.coder.validate.checkLinearInputs(nVar,Aineq,bineq,Aeq,beq,lb,ub);


    runTimeOptions=optim.coder.options.convertFminconOptionsForSolver(options,nVar);


    [mNonlinIneq,mNonlinEq]=optim.coder.fminconsqp.parseinput.checkNonlinearInputs(x0,fun,nonlcon,options);


    INT_ONE=coder.internal.indexInt(1);

    mLinEq=coder.internal.indexInt(numel(beq));
    mLinIneq=coder.internal.indexInt(numel(bineq));
    mLinOrigEq=coder.internal.indexInt(numel(beq));
    mLinOrigIneq=coder.internal.indexInt(numel(bineq));
    mEq=mLinEq+mNonlinEq;
    mIneq=mLinIneq+mNonlinIneq;
    mLB=coder.internal.indexInt(numel(lb));
    mUB=coder.internal.indexInt(numel(ub));



    nVar=coder.internal.indexInt(numel(x0));


    mConstrMax=coder.internal.indexInt(mIneq+mEq+mLB+mUB+2*mEq+mIneq+1);
    nVarMax=coder.internal.indexInt(nVar+2*mEq+mIneq+1);
    maxDims=max(nVarMax,mConstrMax);




    Hessian=eye(nVar,'double');





    TrialState=optim.coder.fminconsqp.TrialState.factoryConstruct(nVarMax,mConstrMax,mIneq,mEq,x0,mNonlinIneq,mNonlinEq);
    TrialState.xstarsqp=coder.internal.blas.xcopy(nVar,x0,INT_ONE,INT_ONE,TrialState.xstarsqp,INT_ONE,INT_ONE);

    if isempty(fun)

        INT_ZERO=coder.internal.indexInt(0);
        TrialState.grad=coder.internal.blas.xcopy(nVar,0.0,INT_ONE,INT_ZERO,TrialState.grad,INT_ONE,INT_ONE);
    end



    FcnEvaluator=optim.coder.utils.ObjNonlinEvaluator.factoryConstruct(fun,nonlcon,nVar,mNonlinIneq,mNonlinEq,options);
    FiniteDifferences=optim.coder.utils.FiniteDifferences.factoryConstruct(fun,nonlcon,nVar,mNonlinIneq,mNonlinEq,lb,ub,options);


    QRManager=optim.coder.QRManager.factoryConstruct(maxDims,maxDims);
    CholManager=optim.coder.CholManager.factoryConstruct(maxDims);


    QPObjective=optim.coder.qpactiveset.Objective.factoryConstruct(nVarMax);
    QPObjective=optim.coder.qpactiveset.Objective.setQuadratic(QPObjective,true,nVar);




    memspace.workspace_double=coder.nullcopy(realmax*ones(maxDims,max(2,nVarMax),'double'));
    memspace.workspace_int=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(maxDims,1,coder.internal.indexIntClass));
    memspace.workspace_sort=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(maxDims,1,coder.internal.indexIntClass));


    fscales.objective=1.0;
    fscales.lineq_constraint=ones(mLinIneq,1,'double');
    fscales.cineq_constraint=ones(mNonlinIneq,1,'double');
    fscales.leq_constraint=ones(mLinEq,1,'double');
    fscales.ceq_constraint=ones(mNonlinEq,1,'double');






    if(options.ScaleProblem)



        [Aeq,beq,fscales.leq_constraint]=...
        optim.coder.utils.scaling.computeAndApplyLinearScales(Aeq,beq,mLinEq,nVar,fscales.leq_constraint);


        [Aineq,bineq,fscales.lineq_constraint]=...
        optim.coder.utils.scaling.computeAndApplyLinearScales(Aineq,bineq,mLinIneq,nVar,fscales.lineq_constraint);
    end






    WorkingSet=optim.coder.qpactiveset.WorkingSet.factoryConstruct(mIneq,mEq,nVar,nVarMax,mConstrMax);


    [WorkingSet.indexLB,mLB,WorkingSet.indexUB,mUB,WorkingSet.indexFixed,mFixed]=...
    optim.coder.qpactiveset.initialize.compressBounds(nVar,WorkingSet.indexLB,WorkingSet.indexUB,WorkingSet.indexFixed,lb,ub,...
    eml_option('NonFinitesSupport'),options.ConstraintTolerance);

    WorkingSet=optim.coder.qpactiveset.WorkingSet.loadProblem(WorkingSet,mIneq,mLinIneq,Aineq,[],...
    mEq,mLinEq,Aeq,[],...
    mLB,[],...
    mUB,[],...
    mFixed,mConstrMax);





    beqFiltered=coder.nullcopy(realmax*ones(mLinEq,1));
    beqFiltered=coder.internal.blas.xcopy(mLinEq,beq,INT_ONE,INT_ONE,beqFiltered,INT_ONE,INT_ONE);





    idxDepEq=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(nVar+mLinEq,1,coder.internal.indexIntClass));



    [nDepEq,idxDepEq,memspace,TrialState,WorkingSet,QRManager,QPObjective,beqFiltered]=...
    optim.coder.fminconsqp.internal.removeDependentLinearEq(Aeq,beqFiltered,ub,idxDepEq,...
    memspace,TrialState,WorkingSet,QRManager,QPObjective);

    if(nDepEq<0)




        nDepEq(:)=0;
    end


    mEq=mEq-nDepEq;
    mLinEq=mLinEq-nDepEq;





    if~isempty(lb)
        for idx=1:mLB
            idx_local=WorkingSet.indexLB(idx);
            TrialState.xstarsqp(idx_local)=max(TrialState.xstarsqp(idx_local),lb(idx_local));
        end
    end
    if~isempty(ub)
        for idx=1:mUB
            idx_local=WorkingSet.indexUB(idx);
            TrialState.xstarsqp(idx_local)=min(TrialState.xstarsqp(idx_local),ub(idx_local));
        end
        for idx=1:mFixed
            idx_local=WorkingSet.indexFixed(idx);
            TrialState.xstarsqp(idx_local)=ub(idx_local);
        end
    end







    [TrialState.xstarsqp,TrialState.sqpFval,TrialState.grad,...
    TrialState.cIneq,TrialState.cEq,WorkingSet.Aineq,WorkingSet.Aeq,fevalSuccess]=...
    optim.coder.utils.ObjNonlinEvaluator.evalObjAndConstrAndDerivatives(FcnEvaluator,...
    TrialState.xstarsqp,...
    TrialState.grad,INT_ONE,...
    TrialState.cIneq,TrialState.iNonIneq0,...
    TrialState.cEq,TrialState.iNonEq0,...
    WorkingSet.Aineq,TrialState.iNonIneq0,WorkingSet.ldA,...
    WorkingSet.Aeq,TrialState.iNonEq0,WorkingSet.ldA,fscales,options);


    FEVAL_SUCCESS=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('Success'));
    coder.internal.assert(fevalSuccess==FEVAL_SUCCESS,'optim_codegen:fmincon:UndefAtX0');




    [derivOK,TrialState.grad,WorkingSet.Aineq,WorkingSet.Aeq,...
    TrialState.xstarsqp,FiniteDifferences]=optim.coder.utils.FiniteDifferences.computeFiniteDifferences(FiniteDifferences,...
    TrialState.sqpFval,...
    TrialState.cIneq,TrialState.iNonIneq0,...
    TrialState.cEq,TrialState.iNonEq0,...
    TrialState.xstarsqp,TrialState.grad,...
    WorkingSet.Aineq,TrialState.iNonIneq0,WorkingSet.ldA,...
    WorkingSet.Aeq,TrialState.iNonEq0,WorkingSet.ldA,...
    lb,ub,fscales,options,runTimeOptions);

    if~derivOK

    end


    TrialState.FunctionEvaluations=FiniteDifferences.numEvals+1;





    [TrialState.cIneq,TrialState.cEq]=...
    optim.coder.fminconsqp.internal.computeLinearResiduals...
    (TrialState.xstarsqp,nVar,TrialState.cIneq,mLinIneq,WorkingSet.Aineq,bineq,WorkingSet.ldA,...
    TrialState.cEq,mLinEq,WorkingSet.Aeq,beqFiltered,WorkingSet.ldA);


    if options.ScaleProblem





        [TrialState.grad,TrialState.sqpFval,fscales.objective]=...
        optim.coder.utils.scaling.computeAndApplyNonlinearScales...
        (TrialState.grad,TrialState.sqpFval,INT_ONE,nVar,INT_ONE,nVarMax,fscales.objective);


        [WorkingSet.Aeq,TrialState.cEq,fscales.ceq_constraint]=...
        optim.coder.utils.scaling.computeAndApplyNonlinearScales...
        (WorkingSet.Aeq,TrialState.cEq,mLinEq+1,nVar,mEq,nVarMax,fscales.ceq_constraint);


        [WorkingSet.Aineq,TrialState.cIneq,fscales.cineq_constraint]=...
        optim.coder.utils.scaling.computeAndApplyNonlinearScales...
        (WorkingSet.Aineq,TrialState.cIneq,mLinIneq+1,nVar,mIneq,nVarMax,fscales.cineq_constraint);

    end




    WorkingSet=optim.coder.fminconsqp.internal.updateWorkingSetForNewQP...
    (x0,WorkingSet,mIneq,TrialState.mNonlinIneq,TrialState.cIneq,...
    mEq,TrialState.mNonlinEq,TrialState.cEq,mLB,lb,mUB,ub,mFixed);


    QP_NORMAL_PROB_ID=coder.const(optim.coder.qpactiveset.constants.ConstraintType('NORMAL'));
    WorkingSet=optim.coder.qpactiveset.WorkingSet.initActiveSet(WorkingSet,QP_NORMAL_PROB_ID);



    MeritFunction=optim.coder.fminconsqp.MeritFunction.factoryConstruct...
    (TrialState.sqpFval,TrialState.cIneq,INT_ONE,mIneq,TrialState.cEq,INT_ONE,mEq,~isempty(fun));



    [Hessian,TrialState,MeritFunction,FcnEvaluator,FiniteDifferences,...
    memspace,WorkingSet,QRManager,CholManager,QPObjective]=...
    optim.coder.fminconsqp.driver(Hessian,bineq,beqFiltered,lb,ub,TrialState,MeritFunction,FcnEvaluator,FiniteDifferences,...
    memspace,WorkingSet,QRManager,CholManager,QPObjective,fscales,options,runTimeOptions);%#ok<ASGLU>




    x=TrialState.xstarsqp;

    if numOutputs>=2

        fval=TrialState.sqpFval;

        if numOutputs>=3

            exitflag=double(TrialState.sqpExitFlag);

            if numOutputs>=4

                output=optim.coder.fminconsqp.parseoutput.fillOutputStruct(nVar,TrialState,MeritFunction);

                if numOutputs>=5

                    lambda=optim.coder.fminconsqp.parseoutput.fillLambdaStruct...
                    (nVar,options.ScaleProblem,fscales,mLinOrigIneq,mNonlinIneq,mLinOrigEq,mNonlinEq,...
                    TrialState,WorkingSet,idxDepEq,nDepEq);

                    if numOutputs>=6

                        grad=coder.nullcopy(zeros(nVar,1,'double'));
                        grad=coder.internal.blas.xcopy(nVar,TrialState.grad,INT_ONE,INT_ONE,grad,INT_ONE,INT_ONE);
                    end
                end
            end
        end
    end


end
