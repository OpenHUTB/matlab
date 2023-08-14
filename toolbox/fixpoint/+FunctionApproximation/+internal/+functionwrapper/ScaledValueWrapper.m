classdef(Sealed)ScaledValueWrapper<FunctionApproximation.internal.functionwrapper.OperatorWrapper




    properties(SetAccess=private)
        ScalingFactor=1;
    end

    methods(Access=?FunctionApproximation.internal.functionwrapper.AbstractWrapper)
        function this=ScaledValueWrapper(functionWrapper,scalingFactor)
            this=this@FunctionApproximation.internal.functionwrapper.OperatorWrapper(functionWrapper);
            this.ScalingFactor=scalingFactor;
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            outputValue=evaluate(this.FunctionToEvaluate,inputs);
            outputValue=outputValue*this.ScalingFactor;
        end
    end
end