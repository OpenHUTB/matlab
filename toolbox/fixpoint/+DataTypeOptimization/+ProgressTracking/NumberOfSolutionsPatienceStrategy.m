classdef NumberOfSolutionsPatienceStrategy<DataTypeOptimization.ProgressTracking.TrackingStrategy








    properties
bestSolutionID
initialSolutionsCount
lastSolutionsCount
solutionsRepo
maxPatience
    end

    methods
        function this=NumberOfSolutionsPatienceStrategy(maxPatience,solutionsRepo)

            this.maxPatience=maxPatience;


            this.solutionsRepo=solutionsRepo;
        end

        function initialize(this)

            this.lastSolutionsCount=0;
            this.initialSolutionsCount=this.getSolutionsCount();
            this.bestSolutionID=this.solutionsRepo.getBestSolution().id;
        end

        function diagnostic=check(this)


            diagnostic=MSLDiagnostic.empty();
            if this.lastSolutionsCount>this.maxPatience
                diagnostic=MSLDiagnostic(message('SimulinkFixedPoint:dataTypeOptimization:exhaustedPatience'));
            end
        end

        function diagnostic=advance(this)

            currentBestSolutionID=this.solutionsRepo.getBestSolution().id;




            if~strcmp(currentBestSolutionID,this.bestSolutionID)
                this.lastSolutionsCount=0;
                this.initialSolutionsCount=this.getSolutionsCount();
                this.bestSolutionID=currentBestSolutionID;
            else
                this.lastSolutionsCount=this.getSolutionsCount()-this.initialSolutionsCount;
            end

            diagnostic=this.check();
        end
    end

    methods(Hidden)
        function solutionCount=getSolutionsCount(this)

            solutionCount=double(this.solutionsRepo.solutions.Count);
        end
    end
end