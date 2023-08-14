classdef OptimizationSolver<handle




    properties
queue
problemPrototype
progressTracer
progressTracerFirstFeasible
    end

    methods
        function initializeSolver(this,problemPrototype,options,progressTracer,progressTracerFirstFeasible)

            this.problemPrototype=problemPrototype;


            this.progressTracer=progressTracer;
            this.progressTracerFirstFeasible=progressTracerFirstFeasible;


            this.getHeuristicsQueue(options);

        end

        function resetSolver(this)

            this.progressTracer.initialize();


            this.resetQueue();

        end

        function run(this,evaluationService,solutionRepo)


            for sIndex=1:numel(this.queue)
                if this.queue{sIndex}.advance()
                    this.queue{sIndex}.run(evaluationService,solutionRepo);
                end

                if~this.queue{sIndex}.advance()
                    break
                end
            end
        end
    end

    methods(Hidden)
        function getHeuristicsQueue(this,options)


            this.queue={};
            this.queue{end+1}=DataTypeOptimization.HeuristicsFactory.getHeuristic('dimensionalityReduction',this.problemPrototype,'',options);
            this.queue{end+1}=DataTypeOptimization.HeuristicsFactory.getHeuristic('fullscan',this.problemPrototype,this.progressTracerFirstFeasible);
            this.queue{end+1}=DataTypeOptimization.HeuristicsFactory.getHeuristic('fractionlengthscan',this.problemPrototype,this.progressTracerFirstFeasible);



            if options.AdvancedOptions.PerformNeighborhoodSearch
                this.getNSHeuristicsQueue();
            end
        end

        function getNSHeuristicsQueue(this)
            greedyHeuristic=DataTypeOptimization.HeuristicsFactory.getHeuristic('greedy',this.problemPrototype,this.progressTracer);
            this.queue{end+1}=greedyHeuristic;

            saHeuristic=DataTypeOptimization.HeuristicsFactory.getHeuristic('randomizedSearch',this.problemPrototype,this.progressTracer);
            this.queue{end+1}=saHeuristic;
        end

        function resetQueue(this)
            this.queue={};
            this.getNSHeuristicsQueue();
        end
    end
end
