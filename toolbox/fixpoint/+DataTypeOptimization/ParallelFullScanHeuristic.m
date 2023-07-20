classdef ParallelFullScanHeuristic<DataTypeOptimization.AbstractHeuristic




    methods
        function this=ParallelFullScanHeuristic(problemPrototype,tracer)
            this.problemPrototype=problemPrototype;
            this.tracer=tracer;
        end

        function run(this,evaluationService,solutionRepo)


            initialSolution=solutionRepo.getEmptySolution();
            initialSolution.definitionDomainIndex=ones(1,length(this.problemPrototype.dv));

            solutionArray=DataTypeOptimization.OptimizationSolution.empty(length(0:length(this.problemPrototype.gddm)-1),0);

            for ddmIndex=0:length(this.problemPrototype.gddm)-1

                solutionArray(ddmIndex+1)=solutionRepo.cloneSolution(initialSolution);


                solutionArray(ddmIndex+1)=DataTypeOptimization.SearchOperators.NeighborhoodSearchOperators.increment(this.problemPrototype,solutionArray(ddmIndex+1),ddmIndex*ones(1,length(this.problemPrototype.dv)));

            end


            ps=DataTypeOptimization.Parallel.ParallelEvaluationScheduler();
            overloadFactor=3;
            solutionArray=ps.evaluateSolutions(evaluationService,solutionArray,overloadFactor,...
            @(x)(DataTypeOptimization.Parallel.ParallelEvaluationScheduler.stoppingCriteria(x,this.tracer)));

            for sIndex=1:numel(solutionArray)

                solutionRepo.addSolution(solutionArray(sIndex),DataTypeOptimization.SolutionType.FirstFeasible);
            end
        end

    end

end
