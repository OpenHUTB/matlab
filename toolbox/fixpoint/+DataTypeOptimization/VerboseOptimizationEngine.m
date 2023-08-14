classdef VerboseOptimizationEngine<DataTypeOptimization.OptimizationEngine&DataTypeOptimization.VerboseActions





    methods
        function this=VerboseOptimizationEngine(model,sud,opt,solver,evaluationService,logger)


            this=this@DataTypeOptimization.VerboseActions(logger);


            this=this@DataTypeOptimization.OptimizationEngine(model,sud,opt,solver,evaluationService);
        end

        function registerProperties(this,model,sud,options,solver,evaluationService)

            this.solver=solver;


            this.evaluationService=evaluationService;

            this.environmentProxy=DataTypeOptimization.EnvironmentProxy(model,sud);


            this.modelingService=DataTypeOptimization.VerboseModelingService(this.environmentProxy,this.messageLogger);


            this.solutionsRepository=DataTypeOptimization.VerboseSolutionRepository(this.messageLogger);

            [this.progressTracer,this.progressTracerFirstFeasible]=DataTypeOptimization.ProgressTracking.getProgressTracer(options,this.solutionsRepository);
            this.options=options;
        end

        function result=run(this)



            this.publish(message('SimulinkFixedPoint:dataTypeOptimization:enginePreprocessing').getString,DataTypeOptimization.VerbosityLevel.Moderate);
            prepService=this.preprocess();
            prepSimIn=prepService.exportSimulationInput(this.environmentProxy.context);


            matlab.internal.yield();
            [problemPrototype,baselineSimOut,baselineRunID]=model(this);

            [siEntriesMap,sfEntries]=DataTypeOptimization.Parallel.SimulationInputEntryCreator.getSimulationInputEntriesMap(problemPrototype);



            this.publish(message('SimulinkFixedPoint:dataTypeOptimization:engineRunningSolver').getString,DataTypeOptimization.VerbosityLevel.Moderate);
            matlab.internal.yield();
            this.runOptimization(problemPrototype,baselineSimOut,baselineRunID,siEntriesMap,prepSimIn);


            result=DataTypeOptimization.OptimizationResult(this);
            result.sfEntries=sfEntries;
            result.baselineSimOut=baselineSimOut;
            result.baselineRunID=baselineRunID;

            this.publish(message('SimulinkFixedPoint:dataTypeOptimization:engineFinished').getString,DataTypeOptimization.VerbosityLevel.Moderate);

            if~isempty(this.progressTracerFirstFeasible.tracerDiagnostic)
                for cIndex=1:numel(this.progressTracerFirstFeasible.tracerDiagnostic.cause)

                    this.publish(this.progressTracerFirstFeasible.tracerDiagnostic.cause{cIndex}.message,DataTypeOptimization.VerbosityLevel.High);
                end
            elseif~isempty(this.progressTracer)
                if~isempty(this.progressTracer.tracerDiagnostic)
                    this.publish(this.progressTracer.tracerDiagnostic.message,DataTypeOptimization.VerbosityLevel.High);
                    for cIndex=1:numel(this.progressTracer.tracerDiagnostic.cause)

                        this.publish(this.progressTracer.tracerDiagnostic.cause{cIndex}.message,DataTypeOptimization.VerbosityLevel.High);
                    end
                end
            end

            switch result.finalState.solutionOutcome
            case DataTypeOptimization.SolutionOutcome.NoValidSolutionFound
                this.publish(message('SimulinkFixedPoint:dataTypeOptimization:engineFinishedNoValidSolution').getString,DataTypeOptimization.VerbosityLevel.Moderate);
                if result.finalState.errorsMap.Count==1
                    this.publish(message('SimulinkFixedPoint:dataTypeOptimization:invalidStateSingleError').getString,...
                    DataTypeOptimization.VerbosityLevel.High);
                    errorMessage=result.finalState.errorsMap.values;
                    this.publish(errorMessage{1},DataTypeOptimization.VerbosityLevel.High);
                else
                    this.publish(message('SimulinkFixedPoint:dataTypeOptimization:invalidStateMultipleErrors').getString,...
                    DataTypeOptimization.VerbosityLevel.High);
                end
            case DataTypeOptimization.SolutionOutcome.NoFeasibleSolutionFound
                this.publish(message('SimulinkFixedPoint:dataTypeOptimization:engineFinishedNoFeasibleSolution').getString,DataTypeOptimization.VerbosityLevel.Moderate);
                this.publishSolutionMetaData(result);
            case DataTypeOptimization.SolutionOutcome.FeasibleSolutionFound
                this.publish(message('SimulinkFixedPoint:dataTypeOptimization:engineFinishedFeasibleSolution').getString,DataTypeOptimization.VerbosityLevel.Moderate);
                this.publishSolutionMetaData(result);
            end


            if~isempty(this.progressTracer)
                this.progressTracer.reset();
            end
            this.progressTracerFirstFeasible.reset();

        end

        function resume(this,result,options)
            this.publish(message('SimulinkFixedPoint:dataTypeOptimization:resumeOptimization').getString,DataTypeOptimization.VerbosityLevel.Moderate);
            this.publish(message('SimulinkFixedPoint:dataTypeOptimization:turnNSOn').getString,DataTypeOptimization.VerbosityLevel.High);
            resume@DataTypeOptimization.OptimizationEngine(this,result,options);
            switch result.finalState.solutionOutcome
            case DataTypeOptimization.SolutionOutcome.NoFeasibleSolutionFound
                this.publish(message('SimulinkFixedPoint:dataTypeOptimization:engineFinishedNoFeasibleSolution').getString,DataTypeOptimization.VerbosityLevel.Moderate);
                this.publishSolutionMetaData(result);
            case DataTypeOptimization.SolutionOutcome.FeasibleSolutionFound
                this.publish(message('SimulinkFixedPoint:dataTypeOptimization:engineFinishedFeasibleSolution').getString,DataTypeOptimization.VerbosityLevel.Moderate);
                this.publishSolutionMetaData(result);
            end

        end
    end

    methods(Hidden)
        function publishSolutionMetaData(this,optResult)
            solution=optResult.Solutions(1);
            this.publish(message('SimulinkFixedPoint:dataTypeOptimization:solutionCost',sprintf('%i',solution.Cost)).getString,DataTypeOptimization.VerbosityLevel.High);
            if solution.hasLoggedSignals(1)
                this.publish(message('SimulinkFixedPoint:dataTypeOptimization:solutionDifference',sprintf('%f',solution.MaxDifference)).getString,DataTypeOptimization.VerbosityLevel.High);
            end
            this.publish(message('SimulinkFixedPoint:dataTypeOptimization:exploreSolution').getString,DataTypeOptimization.VerbosityLevel.High);
        end
    end

end

