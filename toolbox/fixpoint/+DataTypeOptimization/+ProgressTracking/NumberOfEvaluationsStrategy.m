classdef NumberOfEvaluationsStrategy<DataTypeOptimization.ProgressTracking.TrackingStrategy








    properties
initialSolutionsCount
lastSolutionsCount
solutionsRepo
maxIterations
    end

    methods
        function this=NumberOfEvaluationsStrategy(maxIterations,solutionsRepo)

            this.maxIterations=maxIterations;


            this.solutionsRepo=solutionsRepo;
        end

        function initialize(this)

            this.lastSolutionsCount=this.getSolutionsCount();
            this.initialSolutionsCount=this.lastSolutionsCount;
        end

        function diagnostic=check(this)


            diagnostic=MSLDiagnostic.empty();
            if(this.lastSolutionsCount-this.initialSolutionsCount)>=this.maxIterations
                diagnostic=MSLDiagnostic(message('SimulinkFixedPoint:dataTypeOptimization:iterationsExceedMaxIterations'));
            end
        end

        function diagnostic=advance(this)

            this.lastSolutionsCount=this.getSolutionsCount();

            diagnostic=this.check();
        end
    end

    methods(Hidden)
        function solutionCount=getSolutionsCount(this)

            solutionCount=double(this.solutionsRepo.solutions.Count);
        end
    end
end