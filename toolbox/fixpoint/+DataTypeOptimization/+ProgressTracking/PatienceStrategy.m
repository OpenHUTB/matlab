classdef PatienceStrategy<DataTypeOptimization.ProgressTracking.TrackingStrategy







    properties
bestSolutionID
iterationsSinceLastBest
solutionsRepo
maxPatience
    end

    methods
        function this=PatienceStrategy(maxPatience,solutionsRepo)

            this.maxPatience=maxPatience;


            this.solutionsRepo=solutionsRepo;
        end

        function initialize(this)

            this.iterationsSinceLastBest=0;
            this.bestSolutionID=this.solutionsRepo.getBestSolution().id;
        end

        function diagnostic=check(this)


            diagnostic=MSLDiagnostic.empty();
            if this.iterationsSinceLastBest>this.maxPatience
                diagnostic=MSLDiagnostic(message('SimulinkFixedPoint:dataTypeOptimization:exhaustedPatience'));
            end
        end

        function diagnostic=advance(this)

            currentBestSolutionID=this.solutionsRepo.getBestSolution().id;




            if~strcmp(currentBestSolutionID,this.bestSolutionID)
                this.iterationsSinceLastBest=0;
                this.bestSolutionID=currentBestSolutionID;
            else
                this.iterationsSinceLastBest=this.iterationsSinceLastBest+1;
            end

            diagnostic=this.check();
        end
    end
end