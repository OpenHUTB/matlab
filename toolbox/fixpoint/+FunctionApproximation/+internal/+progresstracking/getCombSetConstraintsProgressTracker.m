function combinationSetConsTracker=getCombSetConstraintsProgressTracker(solverObj,maxSuccessfullAttempts)







    combinationSetConsTracker=FunctionApproximation.internal.ProgressTracker();

    combinationSetConsTracker.addStrategy(FunctionApproximation.internal.progresstracking.MaxSuccessAttemptStrategy(solverObj,maxSuccessfullAttempts));

end