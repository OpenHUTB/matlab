function output=fillOutputStruct(nVar,TrialState,MeritFunction)














%#codegen

    coder.allowpcode('plain');


    validateattributes(TrialState,{'struct'},{'scalar'});
    validateattributes(MeritFunction,{'struct'},{'scalar'});

    coder.internal.prefer_const(nVar);

    INT_ONE=coder.internal.indexInt(1);

    output=struct();
    output.iterations=double(TrialState.sqpIterations);
    output.funcCount=double(TrialState.FunctionEvaluations);
    output.algorithm='sqp';

    output.constrviolation=MeritFunction.nlpPrimalFeasError;
    output.stepsize=coder.internal.blas.xnrm2(nVar,TrialState.delta_x,INT_ONE,INT_ONE);
    output.lssteplength=TrialState.steplength;
    output.firstorderopt=MeritFunction.firstOrderOpt;

end

