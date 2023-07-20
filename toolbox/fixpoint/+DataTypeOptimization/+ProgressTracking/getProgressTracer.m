function[progressTracer,progressTracerFirstFeasible]=getProgressTracer(options,solutionsRepo)






    progressTracer=DataTypeOptimization.ProgressTracer.empty();
    progressTracerFirstFeasible=DataTypeOptimization.ProgressTracer();


    externalEventController=DataTypeOptimization.ProgressTracking.ExternalEventController.getEventController();
    externalEventStrategy=externalEventController.requestEvent(options.SessionID);


    progressTracerFirstFeasible.addStrategy(externalEventStrategy);

    if options.AdvancedOptions.PerformNeighborhoodSearch

        progressTracer=DataTypeOptimization.ProgressTracer();

        progressTracer.addStrategy(externalEventStrategy);


        progressTracer.addStrategy(DataTypeOptimization.ProgressTracking.ElapsedTimeStrategy(options.MaxTime));

        if options.UseParallel


            progressTracer.addStrategy(DataTypeOptimization.ProgressTracking.NumberOfSolutionsPatienceStrategy(options.Patience,solutionsRepo));


            progressTracer.addStrategy(DataTypeOptimization.ProgressTracking.NumberOfEvaluationsStrategy(options.MaxIterations,solutionsRepo));



            progressTracer.addStrategy(DataTypeOptimization.ProgressTracking.StagnantRepositoryStrategy(options.Patience,solutionsRepo));
        else


            progressTracer.addStrategy(DataTypeOptimization.ProgressTracking.PatienceStrategy(options.Patience,solutionsRepo));


            progressTracer.addStrategy(DataTypeOptimization.ProgressTracking.IterationStrategy(options.MaxIterations));
        end
    end
end