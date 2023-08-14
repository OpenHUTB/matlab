classdef IterationStrategy<DataTypeOptimization.ProgressTracking.TrackingStrategy






    properties
iterationCount
maxIter
    end
    methods
        function this=IterationStrategy(maxIter)

            this.maxIter=maxIter;
        end

        function initialize(this)

            this.iterationCount=0;
        end

        function diagnostic=check(this)


            diagnostic=MSLDiagnostic.empty();
            if this.iterationCount>this.maxIter
                diagnostic=MSLDiagnostic(message('SimulinkFixedPoint:dataTypeOptimization:iterationsExceedMaxIterations'));
            end
        end

        function diagnostic=advance(this)

            this.iterationCount=this.iterationCount+1;
            diagnostic=this.check();
        end
    end
end