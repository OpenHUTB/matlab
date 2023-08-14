function runTimeOptions=convertFminconOptionsForSolver(options,nVar)





%#codegen


    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(options,nVar);
    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});



    coder.internal.assert(isfield(options,'SolverName'),...
    'optimlib_codegen:common:OnlyOptimoptionsSupported');
    coder.internal.assert(strcmp(options.SolverName,'fmincon'),...
    'optimlib_codegen:optimoptions:InvalidSolverOptions','fmincon');
    coder.internal.assert(strcmp(options.Algorithm,'sqp')||strcmp(options.Algorithm,'sqp-legacy'),...
    'optimlib_codegen:optimoptions:InvalidType','Algorithm','fmincon',[char(13),'''sqp'', ''sqp-legacy''']);


    runTimeOptions=struct();
    runTimeOptions.FiniteDifferenceStepSize=coder.nullcopy(ones(nVar,1,'double'));
    runTimeOptions.MaxIterations=coder.internal.indexInt(options.MaxIterations);
    runTimeOptions.MaxFunctionEvaluations=coder.internal.indexInt(options.MaxFunctionEvaluations);
    runTimeOptions.TypicalX=ones(nVar,1,'double');
    runTimeOptions.ConstrRelTolFactor=1.0;



    if isscalar(options.FiniteDifferenceStepSize)&&(options.FiniteDifferenceStepSize<0)

        if strcmpi(options.FiniteDifferenceType,'central')
            stepSize=eps('double')^(1/3);
        else
            stepSize=sqrt(eps('double'));
        end

        for idx=1:nVar
            runTimeOptions.FiniteDifferenceStepSize(idx)=stepSize;
        end

    elseif isscalar(options.FiniteDifferenceStepSize)

        runTimeOptions.FiniteDifferenceStepSize=options.FiniteDifferenceStepSize*ones(nVar,1,'double');
    else

        coder.internal.assert(numel(options.FiniteDifferenceStepSize)==nVar,...
        'optimlib:validateFinDiffRelStep:InvalidSizeFinDiffRelStep');

        runTimeOptions.FiniteDifferenceStepSize(:)=options.FiniteDifferenceStepSize;
    end


    if(runTimeOptions.MaxFunctionEvaluations<0)
        runTimeOptions.MaxFunctionEvaluations=coder.internal.indexInt(100*nVar);
    end

    if~isempty(options.TypicalX)

        coder.internal.assert(numel(options.TypicalX)==nVar,...
        'optimlib:commonMsgs:InvalidSizeOfTypicalX');

        runTimeOptions.TypicalX(:)=options.TypicalX;
    end

end