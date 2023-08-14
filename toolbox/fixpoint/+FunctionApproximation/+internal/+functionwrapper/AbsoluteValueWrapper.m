classdef(Sealed)AbsoluteValueWrapper<FunctionApproximation.internal.functionwrapper.OperatorWrapper




    methods(Access=?FunctionApproximation.internal.functionwrapper.AbstractWrapper)
        function this=AbsoluteValueWrapper(functionWrapper)
            this=this@FunctionApproximation.internal.functionwrapper.OperatorWrapper(functionWrapper);
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            outputValue=evaluate(this.FunctionToEvaluate,inputs);
            outputValue=abs(outputValue);
        end
    end
end