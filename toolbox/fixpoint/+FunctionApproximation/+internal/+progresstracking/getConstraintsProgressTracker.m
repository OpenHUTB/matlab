function[softConsTracker,hardConsTracker]=getConstraintsProgressTracker(dataBase,options)






    softConsTracker=FunctionApproximation.internal.ProgressTracker();
    hardConsTracker=FunctionApproximation.internal.ProgressTracker();


    softConsTracker.addStrategy(FunctionApproximation.internal.progresstracking.MinFeasibleSolutionsStrategy(dataBase,...
    options.MinFeasibleSolutions,...
    options.MinFractionFeasibleSolutions));


    upperBound=FunctionApproximation.internal.progresstracking.ConsecutiveTrivialSolutionsStrategy.getUpperBound(numel(options.WordLengths));
    softConsTracker.addStrategy(FunctionApproximation.internal.progresstracking.ConsecutiveTrivialSolutionsStrategy(dataBase,upperBound));

    if~isinf(options.MaxTime)

        hardConsTracker.addStrategy(FunctionApproximation.internal.progresstracking.ElapsedTimeStrategy(options.MaxTime));
    end

    optimizationStateController=options.getOptimizationStateController();
    optimizationStateTrackingStrategy=FunctionApproximation.internal.progresstracking.OptimizationStateTrackingStrategy(optimizationStateController);
    hardConsTracker.addStrategy(optimizationStateTrackingStrategy);
end
