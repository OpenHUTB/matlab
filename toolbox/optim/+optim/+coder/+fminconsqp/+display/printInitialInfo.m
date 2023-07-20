function printInitialInfo(TrialState,MeritFunction,fscales)












%#codegen

    coder.allowpcode('plain');


    validateattributes(TrialState,{'struct'},{'scalar'});
    validateattributes(MeritFunction,{'struct'},{'scalar'});
    validateattributes(fscales,{'struct'},{'scalar'});


    fprintf('%5i       %5i  %14.6e  %10.3e                           %10.3e\n',...
    int32(TrialState.sqpIterations),int32(TrialState.FunctionEvaluations),TrialState.sqpFval/fscales.objective,...
    MeritFunction.nlpPrimalFeasError,MeritFunction.firstOrderOpt);
end