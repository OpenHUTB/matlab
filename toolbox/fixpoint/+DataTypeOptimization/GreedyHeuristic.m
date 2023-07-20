classdef GreedyHeuristic<DataTypeOptimization.AbstractHeuristic




    methods
        function this=GreedyHeuristic(problemPrototype,tracer)
            this.problemPrototype=problemPrototype;
            this.tracer=tracer;
        end

        function run(this,evaluationService,solutionRepo)
            bestSolution=solutionRepo.getBestSolution();
            if bestSolution.isValid&&bestSolution.isFullySpecified
                while true
                    continueSearch=false;
                    for dIndex=1:numel(this.problemPrototype.dv)


                        if this.advance()


                            currentSolution=solutionRepo.cloneSolution(bestSolution);


                            currentSolution=DataTypeOptimization.SearchOperators.NeighborhoodSearchOperators.incrementSingle(this.problemPrototype,currentSolution,dIndex,-1);

                            if~solutionRepo.solutionExists(currentSolution)

                                currentSolution=evaluationService.evaluateSolutions(currentSolution);
                            else

                                continue;
                            end


                            solutionRepo.addSolution(currentSolution,DataTypeOptimization.SolutionType.NeighborhoodSearch);


                            if currentSolution.Pass
                                if currentSolution.Cost<bestSolution.Cost
                                    bestSolution=currentSolution;
                                    continueSearch=true;
                                end
                            end
                        else
                            continueSearch=false;
                            break;
                        end
                    end

                    if~continueSearch
                        break
                    end
                end
            end
        end
    end
end
