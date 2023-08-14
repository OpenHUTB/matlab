function[alpha,exitflag,evalWellDefined,TrialState]=linesearch(evalWellDefined,bineq,beq,WorkingSet,...
    TrialState,MeritFunction,FcnEvaluator,socTaken,fscales,options,runTimeOptions)











































%#codegen

    coder.allowpcode('plain');

    validateattributes(bineq,{'double'},{'2d'});
    validateattributes(beq,{'double'},{'2d'});
    validateattributes(WorkingSet,{'struct'},{'scalar'});
    validateattributes(TrialState,{'struct'},{'scalar'});
    validateattributes(MeritFunction,{'struct'},{'scalar'});
    validateattributes(FcnEvaluator,{'struct'},{'scalar'});
    validateattributes(socTaken,{'logical'},{'scalar'});
    validateattributes(fscales,{'struct'},{'scalar'});
    validateattributes(options,{'struct'},{'scalar'});
    validateattributes(runTimeOptions,{'struct'},{'scalar'});

    coder.internal.prefer_const(bineq,beq,options,runTimeOptions);

    INT_ONE=coder.internal.indexInt(1);
    SUCCESS=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('Success'));

    nVar=WorkingSet.nVar;
    mEq=TrialState.mEq;
    mIneq=TrialState.mIneq;
    mLinIneq=mIneq-TrialState.mNonlinIneq;
    mLinEq=mEq-TrialState.mNonlinEq;

    alpha=1.0;
    rho=1e-4;
    exitflag=coder.const(optim.coder.fminconsqp.constants.ExitFlag('Optimal'));
    phi_alpha=MeritFunction.phiFullStep;






    TrialState.searchDir=coder.internal.blas.xcopy(nVar,TrialState.delta_x,INT_ONE,INT_ONE,...
    TrialState.searchDir,INT_ONE,INT_ONE);

    while(TrialState.FunctionEvaluations<runTimeOptions.MaxFunctionEvaluations)

        if(evalWellDefined&&phi_alpha<=MeritFunction.phi+alpha*rho*MeritFunction.phiPrimePlus)
            return;
        end


        alpha=0.7*alpha;


        for idx=1:nVar
            TrialState.delta_x(idx)=alpha*TrialState.xstar(idx);
        end

        if socTaken

            alpha_squared=alpha*alpha;
            TrialState.delta_x=coder.internal.blas.xaxpy(nVar,alpha_squared,...
            TrialState.socDirection,INT_ONE,INT_ONE,...
            TrialState.delta_x,INT_ONE,INT_ONE);
        end




        tooSmallX=optim.coder.fminconsqp.stopping.isDeltaXTooSmall...
        (TrialState.xstarsqp,TrialState.delta_x,nVar,options.StepTolerance);

        if tooSmallX
            exitflag=coder.const(optim.coder.fminconsqp.constants.ExitFlag('Infeasible'));
            return;
        end



        for idx=1:nVar
            TrialState.xstarsqp(idx)=TrialState.xstarsqp_old(idx)+TrialState.delta_x(idx);
        end


        [TrialState.xstarsqp,TrialState.sqpFval,TrialState.cIneq,TrialState.cEq,evalStatus]=...
        optim.coder.utils.ObjNonlinEvaluator.evalObjAndConstr(FcnEvaluator,TrialState.xstarsqp,...
        TrialState.cIneq,TrialState.iNonIneq0,...
        TrialState.cEq,TrialState.iNonEq0,fscales);



        [TrialState.cIneq,TrialState.cEq]=...
        optim.coder.fminconsqp.internal.computeLinearResiduals...
        (TrialState.xstarsqp,nVar,TrialState.cIneq,mLinIneq,WorkingSet.Aineq,bineq,WorkingSet.ldA,...
        TrialState.cEq,mLinEq,WorkingSet.Aeq,beq,WorkingSet.ldA);

        TrialState.FunctionEvaluations=TrialState.FunctionEvaluations+1;


        evalWellDefined=(evalStatus==SUCCESS);
        phi_alpha=optim.coder.fminconsqp.MeritFunction.computeMeritFcn(MeritFunction,TrialState.sqpFval,TrialState.cIneq,INT_ONE,mIneq,...
        TrialState.cEq,INT_ONE,mEq,evalWellDefined);

    end


    exitflag=coder.const(optim.coder.fminconsqp.constants.ExitFlag('MaxIterOrFunReached'));

end

