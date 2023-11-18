classdef OptimizationEngine<handle

    properties(SetAccess=protected)
environmentProxy
modelingService
evaluationService
solutionsRepository
progressTracer
progressTracerFirstFeasible
options
solver
    end

    properties(SetAccess=protected,Hidden)
        hiddenSfEntries;
        hiddenBaselineSimOut;
hiddenBaselineRunID
    end
    methods
        function this=OptimizationEngine(model,sud,opt,solver,evaluationService)

            this.registerProperties(model,sud,opt,solver,evaluationService);


            rng(1,'twister');
        end

        function result=run(this)

            prepService=this.preprocess();
            prepSimIn=prepService.exportSimulationInput(this.environmentProxy.context);


            matlab.internal.yield();
            [problemPrototype,baselineSimOut,baselineRunID]=model(this);

            [siEntriesMap,sfEntries]=DataTypeOptimization.Parallel.SimulationInputEntryCreator.getSimulationInputEntriesMap(problemPrototype);


            matlab.internal.yield();
            runOptimization(this,problemPrototype,baselineSimOut,baselineRunID,siEntriesMap,prepSimIn);

            this.hiddenSfEntries=sfEntries;
            this.hiddenBaselineSimOut=baselineSimOut;
            this.hiddenBaselineRunID=baselineRunID;
            result=this.exportResult();
        end

        function registerProperties(this,model,sud,options,solver,evaluationService)

            this.solver=solver;


            this.evaluationService=evaluationService;



            this.environmentProxy=DataTypeOptimization.EnvironmentProxy(model,sud);



            this.modelingService=DataTypeOptimization.ModelingService(this.environmentProxy);


            this.solutionsRepository=DataTypeOptimization.SolutionRepository();


            [this.progressTracer,this.progressTracerFirstFeasible]=DataTypeOptimization.ProgressTracking.getProgressTracer(options,this.solutionsRepository);


            this.options=options;
        end

        function resume(this,result,options)
            this.options=options;
            this.progressTracer=DataTypeOptimization.ProgressTracking.getProgressTracer(options,this.solutionsRepository);
            this.solver.progressTracer=this.progressTracer;


            this.solver.resetSolver();


            this.solver.run(this.evaluationService,this.solutionsRepository);

            result.updateResult(this.progressTracer,this.options);

            if~isempty(this.progressTracer)
                this.progressTracer.reset();
            end
            this.progressTracerFirstFeasible.reset();
        end
    end

    methods(Hidden)

        function result=exportResult(this)


            result=DataTypeOptimization.OptimizationResult(this);
            result.sfEntries=this.hiddenSfEntries;
            result.baselineSimOut=this.hiddenBaselineSimOut;
            result.baselineRunID=this.hiddenBaselineRunID;


            if~isempty(this.progressTracer)
                this.progressTracer.reset();
            end
            this.progressTracerFirstFeasible.reset();
        end

        function runOptimization(this,problemPrototype,baselineSimOut,baselineRunID,siEntriesMap,prepSimIn)


            this.evaluationService.initialize(...
            'BaselineSimOut',baselineSimOut,...
            'BaselineRunID',baselineRunID,...
            'OptimizationOptions',this.options,...
            'ProblemPrototype',problemPrototype,...
            'EnvironmentProxy',this.environmentProxy,...
            'SimulationInputEntriesMap',siEntriesMap,...
            'PreprocessingInput',prepSimIn);


            this.solver.initializeSolver(problemPrototype,this.options,this.progressTracer,this.progressTracerFirstFeasible)


            this.solver.run(this.evaluationService,this.solutionsRepository);
        end

        function prepService=preprocess(this)

            prepService=DataTypeOptimization.Preprocessing.PreprocessingService(this.options);


            prepService.execute(this.environmentProxy.context);
        end

        function[problemPrototype,baselineSimOut,baselineRunID]=model(this)

            [problemPrototype,baselineSimOut,baselineRunID]=this.modelingService.modelProblem(this.options);
        end

    end

end

