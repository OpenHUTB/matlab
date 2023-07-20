classdef FullScanHeuristic<DataTypeOptimization.AbstractHeuristic




    methods
        function this=FullScanHeuristic(problemPrototype,tracer)
            this.problemPrototype=problemPrototype;
            this.tracer=tracer;
        end

        function run(this,evaluationService,solutionRepo)


            initialSolution=solutionRepo.getEmptySolution();
            for dIndex=1:length(this.problemPrototype.dv)
                initialSolution.definitionDomainIndex(dIndex)=1;

            end


            for ddmIndex=0:length(this.problemPrototype.gddm)-1

                bestSolution=solutionRepo.getBestSolution();
                if(bestSolution.Pass&&bestSolution.isFullySpecified)||...
                    ~this.advance()
                    break;
                end


                currentSolution=solutionRepo.cloneSolution(initialSolution);


                currentSolution=DataTypeOptimization.SearchOperators.NeighborhoodSearchOperators.increment(this.problemPrototype,currentSolution,ddmIndex*ones(1,length(this.problemPrototype.dv)));


                currentSolution=evaluationService.evaluateSolutions(currentSolution);


                solutionRepo.addSolution(currentSolution,DataTypeOptimization.SolutionType.FirstFeasible);

            end
        end

    end

end
