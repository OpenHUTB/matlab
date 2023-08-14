classdef ElapsedTimeStrategy<FunctionApproximation.internal.progresstracking.TrackingStrategy








    properties
StartTime
ElapsedTime
MaxTime
    end

    methods
        function this=ElapsedTimeStrategy(MaxTime)

            this.MaxTime=MaxTime;
        end

        function initialize(this)

            this.StartTime=tic;
        end

        function diagnostic=check(this)

            diagnostic=MException.empty();
            if this.ElapsedTime>this.MaxTime
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:elapsedTimeExceededMaxTime'));
            end
        end

        function diagnostic=advance(this)

            this.ElapsedTime=toc(this.StartTime);
            diagnostic=this.check();
        end
    end
end


