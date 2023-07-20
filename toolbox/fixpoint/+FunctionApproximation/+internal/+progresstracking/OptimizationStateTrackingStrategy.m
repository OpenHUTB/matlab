classdef(Sealed)OptimizationStateTrackingStrategy<FunctionApproximation.internal.progresstracking.TrackingStrategy




    properties(SetAccess=private)
OptimizationStateController
    end

    methods
        function this=OptimizationStateTrackingStrategy(controller)

            this.OptimizationStateController=controller;
        end

        function initialize(this)
            this.OptimizationStateController.setToRun();
        end

        function diagnostic=check(this)


            diagnostic=MException.empty();
            if this.OptimizationStateController.IsRunning
                return;
            end

            if this.OptimizationStateController.IsPaused
                waitfor(this.OptimizationStateController,'IsPaused',false);
            elseif this.OptimizationStateController.IsStopped
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:solverStoppedUsingController'));
            end
        end

        function diagnostic=advance(this)
            matlab.internal.yield();
            diagnostic=this.check();
        end

        function delete(this)


            if this.OptimizationStateController.isvalid()&&this.OptimizationStateController.IsPaused
                this.OptimizationStateController.setToStop();
            end
        end
    end
end


