function stoppingCriteriaEnum=getStoppingCriteria(progressTracer)









    stoppingCriteriaEnum=DataTypeOptimization.ProgressTracking.StoppingCriteriaEnum.None;

    if~isempty(progressTracer)&&~isempty(progressTracer.tracerDiagnostic)
        for cIndex=1:numel(progressTracer.tracerDiagnostic.cause)
            currentCauseID=progressTracer.tracerDiagnostic.cause{cIndex}.identifier;
            switch currentCauseID

            case 'SimulinkFixedPoint:dataTypeOptimization:elapsedTimeExceedsMaxTime'
                stoppingCriteriaEnum(cIndex)=DataTypeOptimization.ProgressTracking.StoppingCriteriaEnum.Time;
            case 'SimulinkFixedPoint:dataTypeOptimization:iterationsExceedMaxIterations'
                stoppingCriteriaEnum(cIndex)=DataTypeOptimization.ProgressTracking.StoppingCriteriaEnum.Iterations;
            case 'SimulinkFixedPoint:dataTypeOptimization:exhaustedPatience'
                stoppingCriteriaEnum(cIndex)=DataTypeOptimization.ProgressTracking.StoppingCriteriaEnum.Patience;
            case 'SimulinkFixedPoint:dataTypeOptimization:stagnantRepository'
                stoppingCriteriaEnum(cIndex)=DataTypeOptimization.ProgressTracking.StoppingCriteriaEnum.StagnantRepository;
            case 'SimulinkFixedPoint:dataTypeOptimization:externalEvent'
                stoppingCriteriaEnum(cIndex)=DataTypeOptimization.ProgressTracking.StoppingCriteriaEnum.ExternalEvent;
            end
        end
    end
end