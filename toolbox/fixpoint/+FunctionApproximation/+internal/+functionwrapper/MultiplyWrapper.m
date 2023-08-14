classdef(Sealed)MultiplyWrapper<FunctionApproximation.internal.functionwrapper.OperatorWrapper




    properties(SetAccess=private)
        WrapperForMultiplication=[];
    end

    methods(Access=?FunctionApproximation.internal.functionwrapper.AbstractWrapper)
        function this=MultiplyWrapper(functionWrapper1,functionWrapper2)
            this=this@FunctionApproximation.internal.functionwrapper.OperatorWrapper(functionWrapper1);
            this.WrapperForMultiplication=functionWrapper2;
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            outputValue1=evaluate(this.FunctionToEvaluate,inputs);
            outputValue2=evaluate(this.WrapperForMultiplication,inputs);
            outputValue=outputValue1.*outputValue2;
        end
    end
end