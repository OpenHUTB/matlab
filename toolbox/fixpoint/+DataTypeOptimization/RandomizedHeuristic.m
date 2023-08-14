classdef RandomizedHeuristic<DataTypeOptimization.AbstractHeuristic







    properties
solutionRepo
    end

    properties(SetAccess=private,Hidden)
heuristicsScheduler

    end

    methods
        function this=RandomizedHeuristic(problemPrototype,tracer)
            this.problemPrototype=problemPrototype;
            this.tracer=tracer;

        end

        function run(this,evaluationService,solutionRepo)

            this.initialize(solutionRepo);

            bestSolution=this.solutionRepo.getBestSolution();
            if bestSolution.isValid&&bestSolution.isFullySpecified

                while this.tracer.advance


                    nsHeuristic=this.heuristicsScheduler.getHeuristic();



                    solutionExist=true;
                    neighborTrials=0;
                    while solutionExist&&neighborTrials<20

                        perturbationVector=nsHeuristic.getPerturbation();

                        newNeighbor=this.solutionRepo.cloneSolution(this.solutionRepo.getBestSolution());

                        newNeighbor=DataTypeOptimization.SearchOperators.NeighborhoodSearchOperators.increment(...
                        this.problemPrototype,newNeighbor,perturbationVector);

                        solutionExist=this.solutionRepo.solutionExists(newNeighbor);

                        neighborTrials=neighborTrials+1;
                    end


                    newNeighbor=evaluationService.evaluateSolutions(newNeighbor);



                    this.solutionRepo.addSolution(newNeighbor,nsHeuristic.solutionType);

                end
            end
        end

    end

    methods(Hidden)
        function initialize(this,solutionRepo)


            this.solutionRepo=DataTypeOptimization.MetaHeuristics.TemperatureScheduler(solutionRepo);



            nsHeuristics={...
            DataTypeOptimization.MetaHeuristics.RandomPerturbation(...
            [-min(3,numel(this.problemPrototype.gddm)),min(3,numel(this.problemPrototype.gddm))],...
            min(3,numel(this.problemPrototype.dv)),...
            numel(this.problemPrototype.dv)),...
            };



            this.heuristicsScheduler=DataTypeOptimization.MetaHeuristics.HeuristicsScheduler(nsHeuristics);
        end

    end
end
