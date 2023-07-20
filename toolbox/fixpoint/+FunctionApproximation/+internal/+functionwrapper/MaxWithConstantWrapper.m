classdef(Sealed)MaxWithConstantWrapper<FunctionApproximation.internal.functionwrapper.OperatorWrapper




    properties(SetAccess=private)
        ConstantValue=[];
    end

    methods(Access=?FunctionApproximation.internal.functionwrapper.AbstractWrapper)
        function this=MaxWithConstantWrapper(functionWrapper,constantValue)
            this=this@FunctionApproximation.internal.functionwrapper.OperatorWrapper(functionWrapper);
            this.ConstantValue=constantValue;
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            outputValue=evaluate(this.FunctionToEvaluate,inputs);
            outputValue=max(outputValue,this.ConstantValue);
        end
    end
end