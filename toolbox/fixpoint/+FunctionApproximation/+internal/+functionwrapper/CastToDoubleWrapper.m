classdef(Sealed)CastToDoubleWrapper<FunctionApproximation.internal.functionwrapper.OperatorWrapper





    methods(Access=?FunctionApproximation.internal.functionwrapper.AbstractWrapper)
        function this=CastToDoubleWrapper(functionWrapper)
            this=this@FunctionApproximation.internal.functionwrapper.OperatorWrapper(functionWrapper);
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            outputValue=evaluate(this.FunctionToEvaluate,inputs);
            outputValue=double(outputValue);
        end
    end
end