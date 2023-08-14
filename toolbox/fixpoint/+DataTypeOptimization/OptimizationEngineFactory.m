classdef OptimizationEngineFactory<handle




    methods(Static)
        function optimizationEngine=getEngine(model,sud,options,unsupportedBlocksExist)
            if nargin<4
                unsupportedBlocksExist=false;
            end


            runInParallel=...
            DataTypeOptimization.OptimizationEngineFactory.canRunInParallel(sud,options,unsupportedBlocksExist);

            if runInParallel
                solver=DataTypeOptimization.ParallelOptimizationSolver();
                evaluationService=DataTypeOptimization.ParallelEvaluationService();
            else
                solver=DataTypeOptimization.OptimizationSolver();
                evaluationService=DataTypeOptimization.EvaluationService();
            end

            if isequal(options.Verbosity,DataTypeOptimization.VerbosityLevel.Silent)

                optimizationEngine=DataTypeOptimization.OptimizationEngine(model,sud,options,solver,evaluationService);
            else
                logger=DataTypeOptimization.MessageLogger(options.Verbosity,options.VerbosityStream);

                evaluationService=DataTypeOptimization.VerboseEvaluationServiceDecorator(evaluationService,logger);

                optimizationEngine=DataTypeOptimization.VerboseOptimizationEngine(model,sud,options,solver,evaluationService,logger);
            end
        end

        function itCan=canRunInParallel(sud,options,unsupportedBlocksExist)
            itCan=options.UseParallel&&...
            matlab.internal.parallel.canUseParallelPool&&...
            (~DataTypeOptimization.Parallel.Utils.anySFUnderSUD(sud))&&...
            ~unsupportedBlocksExist;

        end

    end
end