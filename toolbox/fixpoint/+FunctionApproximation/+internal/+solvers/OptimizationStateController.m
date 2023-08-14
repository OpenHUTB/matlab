classdef(Sealed)OptimizationStateController<handle




    properties(Dependent)
IsPaused
IsRunning
IsStopped
IsUnset
    end

    properties(Access=private)
        State FunctionApproximation.internal.solvers.OptimizationState="Unset"
    end

    methods
        function setToRun(this)
            this.setState("Run");
        end

        function setToPause(this)
            this.setState("Pause");
        end

        function setToStop(this)
            this.setState("Stop");
        end

        function flag=get.IsRunning(this)
            flag=this.getState()=="Run";
        end

        function flag=get.IsPaused(this)
            flag=this.getState()=="Pause";
        end

        function flag=get.IsStopped(this)
            flag=this.getState()=="Stop";
        end

        function flag=get.IsUnset(this)
            flag=this.State=="Unset";
        end
    end

    methods(Hidden)
        function state=getState(this)
            state=this.State;
        end

        function setState(this,state)
            this.State=state;
        end

        function setToUnset(this)
            this.setState("Unset");
        end
    end
end