function printInfo(nVar,stepType,steplen,TrialState,MeritFunction,fscales)












%#codegen

    coder.allowpcode('plain');


    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(stepType,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(steplen,{'double'},{'scalar'});
    validateattributes(TrialState,{'struct'},{'scalar'});
    validateattributes(MeritFunction,{'struct'},{'scalar'});
    validateattributes(fscales,{'struct'},{'scalar'});

    coder.internal.prefer_const(nVar);


    INT_ONE=coder.internal.indexInt(1);
    RELAXED_STEP=coder.const(optim.coder.fminconsqp.step.constants.StepType('Relaxed'));
    SOC_STEP=coder.const(optim.coder.fminconsqp.step.constants.StepType('SOC'));


    iter=int32(TrialState.sqpIterations);
    funcCount=int32(TrialState.FunctionEvaluations);
    fvalDisp=TrialState.sqpFval/fscales.objective;
    nrmStep=coder.internal.blas.xnrm2(nVar,TrialState.delta_x,INT_ONE,INT_ONE);

    fprintf('%5i       %5i  %14.6e  %10.3e   %10.3e  %10.3e  %10.3e',...
    iter,funcCount,fvalDisp,MeritFunction.nlpPrimalFeasError,steplen,nrmStep,MeritFunction.firstOrderOpt);


    switch stepType
    case RELAXED_STEP
        stepType_str='Relaxed';
    case SOC_STEP
        stepType_str='SOC    ';
    otherwise
        stepType_str='Normal ';
    end

    fprintf('   %10.3e    %s',MeritFunction.penaltyParam,stepType_str);

    fprintf('\n');

end

