classdef ParallelOptimizationSolver<DataTypeOptimization.OptimizationSolver





    methods
        function getHeuristicsQueue(this,options)



            this.queue={};
            this.queue{end+1}=DataTypeOptimization.HeuristicsFactory.getHeuristic('dimensionalityReduction',this.problemPrototype,'',options);
            this.queue{end+1}=DataTypeOptimization.HeuristicsFactory.getHeuristic('parallelfullscan',this.problemPrototype,this.progressTracerFirstFeasible);
            this.queue{end+1}=DataTypeOptimization.HeuristicsFactory.getHeuristic('parallelfractionlengthscan',this.problemPrototype,this.progressTracerFirstFeasible);
            if options.AdvancedOptions.PerformNeighborhoodSearch
                this.getNSHeuristicsQueue();
            end
        end

        function getNSHeuristicsQueue(this)
            this.queue{end+1}=DataTypeOptimization.HeuristicsFactory.getHeuristic('parallelrandomizeddescent',this.problemPrototype,this.progressTracer);
            this.queue{end+1}=DataTypeOptimization.HeuristicsFactory.getHeuristic('parallelguideddescent',this.problemPrototype,this.progressTracer);
            this.queue{end+1}=DataTypeOptimization.HeuristicsFactory.getHeuristic('parallelrandomized',this.problemPrototype,this.progressTracer);
        end
    end
end

