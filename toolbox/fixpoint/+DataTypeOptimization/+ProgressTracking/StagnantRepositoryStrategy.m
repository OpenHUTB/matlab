classdef StagnantRepositoryStrategy<DataTypeOptimization.ProgressTracking.TrackingStrategy







    properties
lastSolutionsCount
solutionsRepo
iterationsCount
maxIterations
    end

    methods
        function this=StagnantRepositoryStrategy(maxIterations,solutionsRepo)

            this.maxIterations=maxIterations;


            this.solutionsRepo=solutionsRepo;
        end

        function initialize(this)

            this.lastSolutionsCount=0;
            this.iterationsCount=0;

        end

        function diagnostic=check(this)


            diagnostic=MSLDiagnostic.empty();
            if this.iterationsCount>this.maxIterations
                diagnostic=MSLDiagnostic(message('SimulinkFixedPoint:dataTypeOptimization:stagnantRepository'));
            end
        end

        function diagnostic=advance(this)

            currentSolutionsCount=this.getSolutionsCount();



            if currentSolutionsCount>this.lastSolutionsCount
                this.lastSolutionsCount=currentSolutionsCount;
                this.iterationsCount=0;
            else


                this.iterationsCount=this.iterationsCount+1;
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