classdef(Sealed)AddWrapper<FunctionApproximation.internal.functionwrapper.OperatorWrapper




    properties(SetAccess=private)
        WrapperForAddition=[];
    end

    methods(Access=?FunctionApproximation.internal.functionwrapper.AbstractWrapper)
        function this=AddWrapper(functionWrapper1,functionWrapper2)
            this=this@FunctionApproximation.internal.functionwrapper.OperatorWrapper(functionWrapper1);
            this.WrapperForAddition=functionWrapper2;
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            outputValue1=evaluate(this.FunctionToEvaluate,inputs);
            outputValue2=evaluate(this.WrapperForAddition,inputs);
            outputValue=outputValue1+outputValue2;
        end
    end
end