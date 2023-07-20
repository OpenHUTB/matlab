classdef ParallelRandomizedDescentHeuristic<DataTypeOptimization.AbstractHeuristic




    properties
solutionRepo
maxRunCount
    end

    properties(Hidden)
heuristicsScheduler
        workerOverloadFactor=5;
numOfBatchSolutions
    end

    methods
        function this=ParallelRandomizedDescentHeuristic(problemPrototype,tracer,runCount)
            this.problemPrototype=problemPrototype;
            this.tracer=tracer;
            this.numOfBatchSolutions=this.workerOverloadFactor*DataTypeOptimization.Parallel.Utils.getNumberOfParallelWorkers();
            this.maxRunCount=runCount;
        end

        function run(this,evaluationService,solutionRepo)

            bestSolution=solutionRepo.getBestSolution();
            if bestSolution.isValid&&bestSolution.isFullySpecified
                this.initialize(solutionRepo);
                currentCount=1;
                while currentCount<=this.maxRunCount&&this.advance()
                    bestSolution=this.solutionRepo.getBestSolution();
                    numSolutionsToEvaluate=0;
                    solutionArray=DataTypeOptimization.OptimizationSolution.empty(this.numOfBatchSolutions,0);
                    while numSolutionsToEvaluate<this.numOfBatchSolutions


                        solutionExist=true;
                        neighborTrials=0;
                        while solutionExist&&neighborTrials<30

                            perturbationVector=this.heuristicsScheduler.getHeuristic.getPerturbation();

                            newNeighbor=this.solutionRepo.cloneSolution(bestSolution);

                            newNeighbor=DataTypeOptimization.SearchOperators.NeighborhoodSearchOperators.increment(...
                            this.problemPrototype,newNeighbor,perturbationVector);



                            solutionExist=this.solutionRepo.solutionExists(newNeighbor)&&~any(contains({solutionArray.id},newNeighbor.id));

                            neighborTrials=neighborTrials+1;
                        end

                        if solutionExist







                            break;
                        end


                        numSolutionsToEvaluate=numSolutionsToEvaluate+1;
                        solutionArray(numSolutionsToEvaluate)=newNeighbor;

                    end

                    if~solutionExist

                        solutionArray=evaluationService.evaluateSolutions(solutionArray);

                        for sIndex=1:numel(solutionArray)

                            this.solutionRepo.addSolution(solutionArray(sIndex),DataTypeOptimization.SolutionType.NeighborhoodSearch);
                        end
                    end

                    currentCount=currentCount+1;
                end
            end
        end
    end

    methods(Hidden)
        function initialize(this,solutionRepo)
            this.solutionRepo=solutionRepo;



            nsHeuristics={};


            nsHeuristics{end+1}=DataTypeOptimization.MetaHeuristics.RandomPerturbation(...
            [-min(1,numel(this.problemPrototype.gddm)),0],...
            min(this.workerOverloadFactor,numel(this.problemPrototype.dv)),...
            numel(this.problemPrototype.dv));


            nsHeuristics{end+1}=DataTypeOptimization.MetaHeuristics.RandomPerturbation(...
            [-min(2,numel(this.problemPrototype.gddm)),0],...
            min(this.workerOverloadFactor,numel(this.problemPrototype.dv)),...
            numel(this.problemPrototype.dv));


            nsHeuristics{end+1}=DataTypeOptimization.MetaHeuristics.RandomPerturbation(...
            [-min(3,numel(this.problemPrototype.gddm)),0],...
            min(this.workerOverloadFactor,numel(this.problemPrototype.dv)),...
            numel(this.problemPrototype.dv));



            this.heuristicsScheduler=DataTypeOptimization.MetaHeuristics.HeuristicsScheduler(nsHeuristics);
        end

    end

end


