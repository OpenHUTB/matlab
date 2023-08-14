classdef(Sealed)FiWrapper<FunctionApproximation.internal.functionwrapper.OperatorWrapper




    properties(SetAccess=private)
        FiInputs={};
    end

    methods(Access=?FunctionApproximation.internal.functionwrapper.AbstractWrapper)
        function this=FiWrapper(functionWrapper,varargin)
            this=this@FunctionApproximation.internal.functionwrapper.OperatorWrapper(functionWrapper);
            this.FiInputs=varargin;
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            outputValue=evaluate(this.FunctionToEvaluate,inputs);
            outputValue=double(fi(outputValue,this.FiInputs{:}));
        end
    end
end