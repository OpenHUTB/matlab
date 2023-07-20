classdef ElapsedTimeStrategy<DataTypeOptimization.ProgressTracking.TrackingStrategy








    properties
startTime
elapsedTime
maxTime
    end

    methods
        function this=ElapsedTimeStrategy(maxTime)

            this.maxTime=maxTime;
        end

        function initialize(this)

            this.startTime=tic;
        end

        function diagnostic=check(this)

            diagnostic=MSLDiagnostic.empty();
            if this.elapsedTime>this.maxTime
                diagnostic=MSLDiagnostic(message('SimulinkFixedPoint:dataTypeOptimization:elapsedTimeExceedsMaxTime'));
            end
        end

        function diagnostic=advance(this)

            this.elapsedTime=toc(this.startTime);
            diagnostic=this.check();
        end
    end
end