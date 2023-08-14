classdef(Sealed)CastToTypeWrapper<FunctionApproximation.internal.functionwrapper.OperatorWrapper





    properties(SetAccess=private)
        DataType=[];
    end

    methods(Access=?FunctionApproximation.internal.functionwrapper.AbstractWrapper)
        function this=CastToTypeWrapper(functionWrapper,dataType)
            this=this@FunctionApproximation.internal.functionwrapper.OperatorWrapper(functionWrapper);
            this.DataType=dataType;
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            outputValue=evaluate(this.FunctionToEvaluate,inputs);
            outputValue=double(fixed.internal.math.castUniversal(outputValue,this.DataType));
        end
    end
end
