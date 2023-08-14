function[Flags,memspace,MeritFunction,WorkingSet,TrialState,QRManager]=...
    test_exit(Flags,memspace,MeritFunction,fscales,WorkingSet,TrialState,QRManager,lb,ub,options,runTimeOptions)












%#codegen

    coder.allowpcode('plain');

    validateattributes(Flags,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(MeritFunction,{'struct'},{'scalar'});
    validateattributes(fscales,{'struct'},{'scalar'});
    validateattributes(WorkingSet,{'struct'},{'scalar'});
    validateattributes(TrialState,{'struct'},{'scalar'});
    validateattributes(QRManager,{'struct'},{'scalar'});
    validateattributes(lb,{'double'},{'2d'});
    validateattributes(ub,{'double'},{'2d'});
    validateattributes(options,{'struct'},{'scalar'});
    validateattributes(runTimeOptions,{'struct'},{'scalar'});

    coder.internal.prefer_const(lb,ub,options,runTimeOptions);

    INT_ONE=coder.internal.indexInt(1);

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));

    RELAXED_STEP=coder.const(optim.coder.fminconsqp.step.constants.StepType('Relaxed'));

    nVar=WorkingSet.nVar;


    mFixed=WorkingSet.sizes(FIXED);
    mEq=WorkingSet.sizes(AEQ);
    mIneq=WorkingSet.sizes(AINEQ);
    mLB=WorkingSet.sizes(LOWER);
    mUB=WorkingSet.sizes(UPPER);
    mLambda=mFixed+mEq+mIneq+mLB+mUB;




    TrialState.lambdaStopTest=coder.internal.blas.xcopy(mLambda,TrialState.lambdasqp,...
    INT_ONE,INT_ONE,TrialState.lambdaStopTest,INT_ONE,INT_ONE);


    TrialState.gradLag=optim.coder.fminconsqp.stopping.computeGradLag(...
    TrialState.gradLag,WorkingSet.ldA,nVar,...
    TrialState.grad,mIneq,WorkingSet.Aineq,mEq,WorkingSet.Aeq,...
    WorkingSet.indexFixed,mFixed,WorkingSet.indexLB,mLB,...
    WorkingSet.indexUB,mUB,TrialState.lambdaStopTest);




    idx_max=coder.internal.blas.ixamax(nVar,TrialState.grad,INT_ONE,INT_ONE);
    gradInf=abs(TrialState.grad(idx_max));

    optimRelativeFactor=max(1.0,gradInf/fscales.objective);

    if(~optim.coder.utils.isFiniteScalar(optimRelativeFactor))
        optimRelativeFactor=1.0;
    end


    MeritFunction.nlpPrimalFeasError=...
    optim.coder.fminconsqp.stopping.computePrimalFeasError...
    (options.ScaleProblem,fscales,nVar,TrialState.xstarsqp,...
    mIneq-TrialState.mNonlinIneq,TrialState.mNonlinIneq,TrialState.cIneq,...
    mEq-TrialState.mNonlinEq,TrialState.mNonlinEq,TrialState.cEq,...
    WorkingSet.indexLB,mLB,lb,WorkingSet.indexUB,mUB,ub);


    if(TrialState.sqpIterations==0)
        MeritFunction.feasRelativeFactor=max(1.0,MeritFunction.nlpPrimalFeasError);
    end

    isFeasible=(MeritFunction.nlpPrimalFeasError<=options.ConstraintTolerance*MeritFunction.feasRelativeFactor);


    [Flags.gradOK(:),MeritFunction.nlpDualFeasError]=...
    optim.coder.fminconsqp.stopping.computeDualFeasError(fscales,nVar,TrialState.gradLag,options);



    if options.NonFiniteSupport&&~Flags.gradOK
        Flags.done=true;
        if(isFeasible)
            TrialState.sqpExitFlag=coder.const(optim.coder.fminconsqp.constants.ExitFlag('Feasible'));
        else
            TrialState.sqpExitFlag=coder.const(optim.coder.fminconsqp.constants.ExitFlag('Infeasible'));
        end

        return;
    end


    MeritFunction.nlpComplError=optim.coder.fminconsqp.stopping.computeComplError...
    (fscales,TrialState.xstarsqp,mIneq,TrialState.cIneq,...
    WorkingSet.indexLB,mLB,lb,WorkingSet.indexUB,mUB,ub,TrialState.lambdaStopTest,mFixed+mEq+1);


    MeritFunction.firstOrderOpt=max(MeritFunction.nlpDualFeasError,MeritFunction.nlpComplError);







    if(TrialState.sqpIterations>1)


        memspace.workspace_double=optim.coder.fminconsqp.stopping.computeGradLag(...
        memspace.workspace_double,WorkingSet.ldA,nVar,...
        TrialState.grad,mIneq,WorkingSet.Aineq,mEq,WorkingSet.Aeq,...
        WorkingSet.indexFixed,mFixed,WorkingSet.indexLB,mLB,...
        WorkingSet.indexUB,mUB,TrialState.lambdaStopTestPrev);


        [~,nlpDualFeasErrorTmp]=optim.coder.fminconsqp.stopping.computeDualFeasError(...
        fscales,nVar,memspace.workspace_double,options);

        nlpComplErrorTmp=optim.coder.fminconsqp.stopping.computeComplError(...
        fscales,TrialState.xstarsqp,mIneq,TrialState.cIneq,...
        WorkingSet.indexLB,mLB,lb,WorkingSet.indexUB,mUB,ub,...
        TrialState.lambdaStopTestPrev,mFixed+mEq+1);


        if max(nlpDualFeasErrorTmp,nlpComplErrorTmp)<max(MeritFunction.nlpDualFeasError,MeritFunction.nlpComplError)
            MeritFunction.nlpDualFeasError=nlpDualFeasErrorTmp;
            MeritFunction.nlpComplError=nlpComplErrorTmp;
            MeritFunction.firstOrderOpt=max(nlpDualFeasErrorTmp,nlpComplErrorTmp);

            TrialState.lambdaStopTest=coder.internal.blas.xcopy(mLambda,TrialState.lambdaStopTestPrev,INT_ONE,INT_ONE,...
            TrialState.lambdaStopTest,INT_ONE,INT_ONE);
        else



            TrialState.lambdaStopTestPrev=coder.internal.blas.xcopy(mLambda,TrialState.lambdaStopTest,INT_ONE,INT_ONE,...
            TrialState.lambdaStopTestPrev,INT_ONE,INT_ONE);
        end

    else


        TrialState.lambdaStopTestPrev=coder.internal.blas.xcopy(mLambda,TrialState.lambdaStopTest,INT_ONE,INT_ONE,...
        TrialState.lambdaStopTestPrev,INT_ONE,INT_ONE);
    end



    if isFeasible&&...
        (MeritFunction.nlpDualFeasError<=options.OptimalityTolerance*optimRelativeFactor)&&...
        (MeritFunction.nlpComplError<=options.OptimalityTolerance*optimRelativeFactor)

        Flags.done=true;
        TrialState.sqpExitFlag=coder.const(optim.coder.fminconsqp.constants.ExitFlag('Optimal'));
        return;
    else
        Flags.done=false;
    end


    Fvalue=TrialState.sqpFval/fscales.objective;
    if(isFeasible&&Fvalue<options.ObjectiveLimit)
        Flags.done=true;
        TrialState.sqpExitFlag=coder.const(optim.coder.fminconsqp.constants.ExitFlag('ObjectiveLimitReached'));
        return;
    end





    if(TrialState.sqpIterations>0)
        dxTooSmall=optim.coder.fminconsqp.stopping.isDeltaXTooSmall...
        (TrialState.xstarsqp,TrialState.delta_x,nVar,options.StepTolerance);

        if(dxTooSmall)

            if~isFeasible
                if(Flags.stepType~=RELAXED_STEP)
                    Flags.stepType=RELAXED_STEP;
                    Flags.failedLineSearch=false;
                    Flags.stepAccepted=false;
                else
                    Flags.done=true;
                    TrialState.sqpExitFlag=coder.const(optim.coder.fminconsqp.constants.ExitFlag('Infeasible'));
                    return;
                end
            else



                nActiveConstr=WorkingSet.nActiveConstr;

                if(nActiveConstr>0)






                    if(TrialState.mNonlinEq+TrialState.mNonlinIneq>0)
                        WorkingSet=optim.coder.fminconsqp.internal.updateWorkingSetForNewQP...
                        (TrialState.xstarsqp,WorkingSet,...
                        mIneq,TrialState.mNonlinIneq,TrialState.cIneq,...
                        mEq,TrialState.mNonlinEq,TrialState.cEq,mLB,lb,mUB,ub,mFixed);
                    end


                    [TrialState.lambda,QRManager,memspace.workspace_double]=...
                    optim.coder.fminconsqp.stopping.computeLambdaLSQ(nVar,nActiveConstr,QRManager,...
                    WorkingSet.ATwset,WorkingSet.ldA,...
                    TrialState.grad,TrialState.lambda,INT_ONE,memspace.workspace_double,INT_ONE);


                    for idx=mFixed+1:mFixed+mEq
                        TrialState.lambda(idx)=-TrialState.lambda(idx);
                    end



                    [TrialState.lambda,memspace.workspace_double]=...
                    optim.coder.qpactiveset.parseoutput.sortLambdaQP(TrialState.lambda,WorkingSet,memspace.workspace_double,INT_ONE);


                    memspace.workspace_double=...
                    optim.coder.fminconsqp.stopping.computeGradLag...
                    (memspace.workspace_double,WorkingSet.ldA,nVar,...
                    TrialState.grad,mIneq,WorkingSet.Aineq,mEq,WorkingSet.Aeq,...
                    WorkingSet.indexFixed,mFixed,WorkingSet.indexLB,mLB,WorkingSet.indexUB,mUB,TrialState.lambda);


                    [~,nlpDualFeasErrorLSQ]=...
                    optim.coder.fminconsqp.stopping.computeDualFeasError(fscales,nVar,memspace.workspace_double,options);

                    nlpComplErrorLSQ=...
                    optim.coder.fminconsqp.stopping.computeComplError...
                    (fscales,TrialState.xstarsqp,mIneq,TrialState.cIneq,...
                    WorkingSet.indexLB,mLB,lb,WorkingSet.indexUB,mUB,ub,TrialState.lambda,mFixed+1);



                    if(nlpDualFeasErrorLSQ<=options.OptimalityTolerance*optimRelativeFactor)&&...
                        (nlpComplErrorLSQ<=options.OptimalityTolerance*optimRelativeFactor)

                        MeritFunction.nlpDualFeasError=nlpDualFeasErrorLSQ;
                        MeritFunction.nlpComplError=nlpComplErrorLSQ;
                        MeritFunction.firstOrderOpt=max(nlpDualFeasErrorLSQ,nlpComplErrorLSQ);


                        TrialState.lambdaStopTest=coder.internal.blas.xcopy(mLambda,...
                        TrialState.lambda,INT_ONE,INT_ONE,TrialState.lambdaStopTest,INT_ONE,INT_ONE);

                        Flags.done=true;
                        TrialState.sqpExitFlag=coder.const(optim.coder.fminconsqp.constants.ExitFlag('Optimal'));
                        return;
                    else


                        Flags.done=true;
                        TrialState.sqpExitFlag=coder.const(optim.coder.fminconsqp.constants.ExitFlag('Feasible'));
                        return;
                    end

                else
                    Flags.done=true;
                    TrialState.sqpExitFlag=coder.const(optim.coder.fminconsqp.constants.ExitFlag('Feasible'));
                    return;
                end
            end
        end
    end



    if(TrialState.sqpIterations>=runTimeOptions.MaxIterations)
        Flags.done=true;
        TrialState.sqpExitFlag=coder.const(optim.coder.fminconsqp.constants.ExitFlag('MaxIterOrFunReached'));
        return;
    end


    if(TrialState.FunctionEvaluations>=runTimeOptions.MaxFunctionEvaluations)
        Flags.done=true;
        TrialState.sqpExitFlag=coder.const(optim.coder.fminconsqp.constants.ExitFlag('MaxIterOrFunReached'));
        return;
    end

end
