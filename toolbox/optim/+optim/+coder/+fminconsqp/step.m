function[stepSuccess,STEP_TYPE,Hessian,TrialState,MeritFunction,memspace,WorkingSet,QRManager,CholManager,QPObjective]=...
    step(STEP_TYPE,Hessian,lb,ub,TrialState,MeritFunction,memspace,...
    WorkingSet,QRManager,CholManager,QPObjective,options,qpoptions)












%#codegen

    coder.allowpcode('plain');


    validateattributes(STEP_TYPE,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(Hessian,{'double'},{'2d'});
    validateattributes(lb,{'double'},{'2d'});
    validateattributes(ub,{'double'},{'2d'});
    validateattributes(TrialState,{'struct'},{'scalar'});
    validateattributes(MeritFunction,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(WorkingSet,{'struct'},{'scalar'});
    validateattributes(QRManager,{'struct'},{'scalar'});
    validateattributes(CholManager,{'struct'},{'scalar'});
    validateattributes(QPObjective,{'struct'},{'scalar'});
    validateattributes(options,{'struct'},{'scalar'});
    validateattributes(qpoptions,{'struct'},{'scalar'});

    coder.internal.prefer_const(lb,ub,options,qpoptions);

    stepSuccess=true;



    checkBoundViolation=true;

    nVar=WorkingSet.nVar;


    INT_ONE=coder.internal.indexInt(1);
    NON_CONVEX_QP=coder.const(optim.coder.SolutionState('IndefiniteQP'));


    NORMAL_STEP=coder.const(optim.coder.fminconsqp.step.constants.StepType('Normal'));
    RELAXED_STEP=coder.const(optim.coder.fminconsqp.step.constants.StepType('Relaxed'));
    SOC_STEP=coder.const(optim.coder.fminconsqp.step.constants.StepType('SOC'));





    if(STEP_TYPE~=SOC_STEP)
        TrialState.xstar=...
        coder.internal.blas.xcopy(nVar,TrialState.xstarsqp,INT_ONE,INT_ONE,TrialState.xstar,INT_ONE,INT_ONE);
    else
        TrialState.searchDir=...
        coder.internal.blas.xcopy(nVar,TrialState.xstar,INT_ONE,INT_ONE,TrialState.searchDir,INT_ONE,INT_ONE);
    end

    while true

        switch STEP_TYPE

        case NORMAL_STEP


            [Hessian,TrialState,MeritFunction,memspace,WorkingSet,QRManager,CholManager,QPObjective]=...
            optim.coder.fminconsqp.step.normal...
            (Hessian,TrialState.grad,TrialState,MeritFunction,memspace,...
            WorkingSet,QRManager,CholManager,QPObjective,options,qpoptions);

            if(TrialState.state<=0&&TrialState.state~=NON_CONVEX_QP)
                STEP_TYPE=coder.const(optim.coder.fminconsqp.step.constants.StepType('Relaxed'));
                continue;
            end


            TrialState.delta_x=coder.internal.blas.xcopy(nVar,TrialState.xstar,INT_ONE,INT_ONE,TrialState.delta_x,INT_ONE,INT_ONE);

        case RELAXED_STEP

            WorkingSet=optim.coder.qpactiveset.WorkingSet.removeAllIneqConstr(WorkingSet);
            [TrialState.xstar,WorkingSet]=optim.coder.fminconsqp.step.makeBoundFeasible...
            (TrialState.xstar,WorkingSet,lb,ub,options.ConstraintTolerance);



            [Hessian,TrialState,MeritFunction,memspace,WorkingSet,QRManager,CholManager,QPObjective,qpoptions]=...
            optim.coder.fminconsqp.step.relaxed...
            (Hessian,TrialState.grad,TrialState,MeritFunction,memspace,...
            WorkingSet,QRManager,CholManager,QPObjective,options,qpoptions);


            TrialState.delta_x=coder.internal.blas.xcopy(nVar,TrialState.xstar,INT_ONE,INT_ONE,TrialState.delta_x,INT_ONE,INT_ONE);

        otherwise






            [stepSuccess(:),Hessian,TrialState,MeritFunction,memspace,WorkingSet,QRManager,CholManager,QPObjective]=...
            optim.coder.fminconsqp.step.soc...
            (Hessian,TrialState.grad,TrialState,MeritFunction,memspace,...
            WorkingSet,QRManager,CholManager,QPObjective,qpoptions);

            checkBoundViolation=stepSuccess;

            if(stepSuccess&&TrialState.state~=NON_CONVEX_QP)

                for idx=1:nVar
                    TrialState.delta_x(idx)=TrialState.xstar(idx)+TrialState.socDirection(idx);
                end
            end
        end

        if(TrialState.state~=NON_CONVEX_QP)

            if checkBoundViolation





                LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
                UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));

                mLB=WorkingSet.sizes(LOWER);
                mUB=WorkingSet.sizes(UPPER);

                [TrialState.delta_x,TrialState.xstar]=...
                optim.coder.fminconsqp.step.saturateDirection...
                (TrialState.xstarsqp,TrialState.delta_x,TrialState.xstar,...
                WorkingSet.indexLB,WorkingSet.indexUB,mLB,mUB,lb,ub);










            end

            break;
        else



            Hessian=optim.coder.fminconsqp.BFGSReset(Hessian,TrialState.grad,TrialState.xstar);
        end

    end

end

