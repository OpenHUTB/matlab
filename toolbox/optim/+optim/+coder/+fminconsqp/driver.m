function[Hessian,TrialState,MeritFunction,FcnEvaluator,FiniteDifferences,memspace,WorkingSet,QRManager,CholManager,QPObjective]=...
    driver(Hessian,bineq,beq,lb,ub,TrialState,MeritFunction,FcnEvaluator,FiniteDifferences,...
    memspace,WorkingSet,QRManager,CholManager,QPObjective,fscales,options,runTimeOptions)



































%#codegen

    coder.allowpcode('plain');


    validateattributes(Hessian,{'double'},{'2d'});
    validateattributes(bineq,{'double'},{'2d'});
    validateattributes(beq,{'double'},{'2d'});
    validateattributes(lb,{'double'},{'2d'});
    validateattributes(ub,{'double'},{'2d'});

    validateattributes(TrialState,{'struct'},{'scalar'});
    validateattributes(MeritFunction,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(WorkingSet,{'struct'},{'scalar'});
    validateattributes(QRManager,{'struct'},{'scalar'});
    validateattributes(CholManager,{'struct'},{'scalar'});
    validateattributes(QPObjective,{'struct'},{'scalar'});
    validateattributes(FcnEvaluator,{'struct'},{'scalar'});
    validateattributes(FiniteDifferences,{'struct'},{'scalar'});
    validateattributes(options,{'struct'},{'scalar'});
    validateattributes(runTimeOptions,{'struct'},{'scalar'});

    coder.internal.prefer_const(bineq,beq,lb,ub,fscales,options,runTimeOptions);

    INT_ONE=coder.internal.indexInt(1);


    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));


    nVar=WorkingSet.nVar;


    mFixed=WorkingSet.sizes(FIXED);
    mEq=WorkingSet.sizes(AEQ);
    mIneq=WorkingSet.sizes(AINEQ);
    mLB=WorkingSet.sizes(LOWER);
    mUB=WorkingSet.sizes(UPPER);
    mConstr=mFixed+mEq+mIneq+mLB+mUB;

    mLinIneq=mIneq-TrialState.mNonlinIneq;
    mLinEq=mEq-TrialState.mNonlinEq;


    FEVAL_SUCCESS=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('Success'));


    NORMAL_STEP=coder.const(optim.coder.fminconsqp.step.constants.StepType('Normal'));

    SOC_STEP=coder.const(optim.coder.fminconsqp.step.constants.StepType('SOC'));




    qpoptions=optim.coder.options.createQuadprogOptionsForFmincon(options,nVar,mFixed,mIneq,mLB,mUB);



    Flags.gradOK=true;
    Flags.fevalOK=true;

    Flags.done=false;
    Flags.stepAccepted=false;
    Flags.failedLineSearch=false;
    Flags.stepType=NORMAL_STEP;

    TrialState.steplength=1.0;



    [Flags,memspace,MeritFunction,WorkingSet,TrialState,QRManager]=...
    optim.coder.fminconsqp.test_exit(Flags,memspace,MeritFunction,fscales,...
    WorkingSet,TrialState,QRManager,lb,ub,options,runTimeOptions);


    TrialState=optim.coder.fminconsqp.TrialState.saveJacobian(TrialState,nVar,mIneq,WorkingSet.Aineq,TrialState.iNonIneq0,...
    mEq,WorkingSet.Aeq,TrialState.iNonEq0,WorkingSet.ldA);


    TrialState=optim.coder.fminconsqp.TrialState.saveState(TrialState);



    latestStepType=Flags.stepType;
    if options.IterDisplaySQP


        optim.coder.fminconsqp.display.printHeader();
        optim.coder.fminconsqp.display.printInitialInfo(TrialState,MeritFunction,fscales);
    end

    if~Flags.done
        TrialState.sqpIterations=TrialState.sqpIterations+1;
    end



    while(~Flags.done)

        while~(Flags.stepAccepted||Flags.failedLineSearch)

            if~(Flags.stepType==SOC_STEP)


                WorkingSet=optim.coder.fminconsqp.internal.updateWorkingSetForNewQP...
                (TrialState.xstarsqp,WorkingSet,...
                mIneq,TrialState.mNonlinIneq,TrialState.cIneq,...
                mEq,TrialState.mNonlinEq,TrialState.cEq,mLB,lb,mUB,ub,mFixed);
            end


            [Flags.stepAccepted(:),Flags.stepType(:),...
            Hessian,TrialState,MeritFunction,memspace,WorkingSet,QRManager,CholManager,QPObjective]=...
            optim.coder.fminconsqp.step(Flags.stepType,Hessian,lb,ub,TrialState,MeritFunction,memspace,...
            WorkingSet,QRManager,CholManager,QPObjective,options,qpoptions);


            if options.IterDisplaySQP


                latestStepType=Flags.stepType;
            end


            if(Flags.stepAccepted)








                for i=1:nVar
                    TrialState.xstarsqp(i)=TrialState.xstarsqp(i)+TrialState.delta_x(i);
                end

                [TrialState.xstarsqp,TrialState.sqpFval,TrialState.cIneq,TrialState.cEq,fevalSuccess]=...
                optim.coder.utils.ObjNonlinEvaluator.evalObjAndConstr(FcnEvaluator,TrialState.xstarsqp,...
                TrialState.cIneq,TrialState.iNonIneq0,...
                TrialState.cEq,TrialState.iNonEq0,fscales);



                Flags.fevalOK=(fevalSuccess==FEVAL_SUCCESS);
                TrialState.FunctionEvaluations=TrialState.FunctionEvaluations+1;


                [TrialState.cIneq,TrialState.cEq]=...
                optim.coder.fminconsqp.internal.computeLinearResiduals...
                (TrialState.xstarsqp,nVar,TrialState.cIneq,mLinIneq,WorkingSet.Aineq,bineq,WorkingSet.ldA,...
                TrialState.cEq,mLinEq,WorkingSet.Aeq,beq,WorkingSet.ldA);


                MeritFunction.phiFullStep=...
                optim.coder.fminconsqp.MeritFunction.computeMeritFcn(MeritFunction,TrialState.sqpFval,...
                TrialState.cIneq,INT_ONE,mIneq,TrialState.cEq,INT_ONE,mEq,Flags.fevalOK);
            end



            if(Flags.stepType==NORMAL_STEP&&Flags.stepAccepted&&Flags.fevalOK&&...
                (MeritFunction.phi<MeritFunction.phiFullStep&&TrialState.sqpFval<TrialState.sqpFval_old))

                Flags.stepType=SOC_STEP;
                Flags.stepAccepted=false;

            else

                socTaken=(Flags.stepType==SOC_STEP)&&Flags.stepAccepted;
                [alpha,exitflagLnSrch,Flags.fevalOK(:),TrialState]=...
                optim.coder.fminconsqp.linesearch(Flags.fevalOK,bineq,beq,WorkingSet,TrialState,MeritFunction,...
                FcnEvaluator,socTaken,fscales,options,runTimeOptions);

                TrialState.steplength(:)=alpha;






                if(exitflagLnSrch>0)
                    Flags.stepAccepted=true;
                else
                    Flags.failedLineSearch=true;
                end
            end
        end

        if(Flags.stepAccepted&&~Flags.failedLineSearch)


            for idx=1:nVar
                TrialState.xstarsqp(idx)=TrialState.xstarsqp_old(idx)+TrialState.delta_x(idx);
            end




            for idx=1:mConstr
                TrialState.lambdasqp(idx)=TrialState.lambdasqp(idx)+TrialState.steplength*(TrialState.lambda(idx)-TrialState.lambdasqp(idx));
            end



            TrialState=optim.coder.fminconsqp.TrialState.saveState(TrialState);




            [Flags.gradOK(:),TrialState.grad,WorkingSet.Aineq,WorkingSet.Aeq,...
            TrialState.xstarsqp,FiniteDifferences]=optim.coder.utils.FiniteDifferences.computeFiniteDifferences(FiniteDifferences,...
            TrialState.sqpFval,...
            TrialState.cIneq,TrialState.iNonIneq0,...
            TrialState.cEq,TrialState.iNonEq0,...
            TrialState.xstarsqp,TrialState.grad,...
            WorkingSet.Aineq,TrialState.iNonIneq0,WorkingSet.ldA,...
            WorkingSet.Aeq,TrialState.iNonEq0,WorkingSet.ldA,...
            lb,ub,fscales,options,runTimeOptions);

            TrialState.FunctionEvaluations=TrialState.FunctionEvaluations+FiniteDifferences.numEvals;

            if(options.SpecifyObjectiveGradient||options.SpecifyConstraintGradient)

                [TrialState.xstarsqp,TrialState.sqpFval,TrialState.grad,...
                TrialState.cIneq,TrialState.cEq,...
                WorkingSet.Aineq,WorkingSet.Aeq,fevalSuccess]=optim.coder.utils.ObjNonlinEvaluator.evalObjAndConstrAndDerivatives(FcnEvaluator,...
                TrialState.xstarsqp,...
                TrialState.grad,INT_ONE,...
                TrialState.cIneq,TrialState.iNonIneq0,...
                TrialState.cEq,TrialState.iNonEq0,...
                WorkingSet.Aineq,TrialState.iNonIneq0,WorkingSet.ldA,...
                WorkingSet.Aeq,TrialState.iNonEq0,WorkingSet.ldA,fscales,options);


                TrialState.FunctionEvaluations=TrialState.FunctionEvaluations+coder.internal.indexInt(options.SpecifyObjectiveGradient);

                Flags.fevalOK=(fevalSuccess==FEVAL_SUCCESS);
            end

        else



            TrialState=optim.coder.fminconsqp.TrialState.revertSolution(TrialState);
        end




        [Flags,memspace,MeritFunction,WorkingSet,TrialState,QRManager]=...
        optim.coder.fminconsqp.test_exit(Flags,memspace,MeritFunction,fscales,WorkingSet,...
        TrialState,QRManager,lb,ub,options,runTimeOptions);



        if options.IterDisplaySQP


            if(mod(TrialState.sqpIterations,30)==0)
                optim.coder.fminconsqp.display.printHeader();
            end
            optim.coder.fminconsqp.display.printInfo(nVar,latestStepType,TrialState.steplength,TrialState,MeritFunction,fscales);
        end

        if(~Flags.done&&Flags.stepAccepted)

            Flags.stepAccepted=false;
            Flags.stepType=NORMAL_STEP;
            Flags.failedLineSearch=false;




            idxLambdaNonlinEq=mFixed+TrialState.iNonEq0;
            idxLambdaNonlinIneq=mFixed+mEq+TrialState.iNonIneq0;
            TrialState.delta_gradLag=...
            optim.coder.fminconsqp.stopping.computeDeltaLag(nVar,WorkingSet.ldA,TrialState.mNonlinIneq,TrialState.mNonlinEq,...
            TrialState.delta_gradLag,TrialState.grad,...
            WorkingSet.Aineq,TrialState.iNonIneq0,WorkingSet.Aeq,TrialState.iNonEq0,...
            TrialState.grad_old,TrialState.JacCineqTrans_old,TrialState.JacCeqTrans_old,...
            TrialState.lambdasqp,idxLambdaNonlinIneq,idxLambdaNonlinEq);


            TrialState=optim.coder.fminconsqp.TrialState.saveJacobian(TrialState,nVar,mIneq,WorkingSet.Aineq,TrialState.iNonIneq0,...
            mEq,WorkingSet.Aeq,TrialState.iNonEq0,WorkingSet.ldA);





            [~,Hessian,TrialState.delta_gradLag,memspace.workspace_double]=...
            optim.coder.fminconsqp.BFGSUpdate(nVar,Hessian,TrialState.delta_x,TrialState.delta_gradLag,...
            memspace.workspace_double);

            TrialState.sqpIterations=TrialState.sqpIterations+1;
        end

    end



    if(options.ScaleProblem)
        TrialState.sqpFval=TrialState.sqpFval/fscales.objective;
        TrialState.grad=coder.internal.blas.xscal(nVar,1/fscales.objective,TrialState.grad,INT_ONE,INT_ONE);
        Hessian=coder.internal.blas.xscal(nVar*nVar,1/fscales.objective,Hessian,INT_ONE,INT_ONE);
    end

end

