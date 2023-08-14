function resumeOptimization(result,varargin)







    if result.isEngineLoaded()&&...
        ~isequal(result.finalState.solutionOutcome,"NoValidSolutionFound")
        p=inputParser();
        p.KeepUnmatched=true;
        p.addParameter('MaxIterations',result.OptimizationOptions.MaxIterations);
        p.addParameter('MaxTime',result.OptimizationOptions.MaxTime);
        p.addParameter('Patience',result.OptimizationOptions.Patience);
        p.parse(varargin{:});

        options=result.OptimizationOptions;
        options.MaxIterations=p.Results.MaxIterations;
        options.MaxTime=p.Results.MaxTime;
        options.Patience=p.Results.Patience;


        options.AdvancedOptions.PerformNeighborhoodSearch=true;


        optimizationEngine=result.optimizationEngine;
        optimizationEngine.resume(result,options);
    end
end