classdef(Sealed)CastToSingleWrapper<FunctionApproximation.internal.functionwrapper.OperatorWrapper





    methods(Access=?FunctionApproximation.internal.functionwrapper.AbstractWrapper)
        function this=CastToSingleWrapper(functionWrapper)
            this=this@FunctionApproximation.internal.functionwrapper.OperatorWrapper(functionWrapper);
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            outputValue=evaluate(this.FunctionToEvaluate,inputs);
            outputValue=double(single(outputValue));
        end
    end
end