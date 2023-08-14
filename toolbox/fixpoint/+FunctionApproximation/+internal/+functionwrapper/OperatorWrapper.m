classdef(Abstract)OperatorWrapper<FunctionApproximation.internal.functionwrapper.AbstractWrapper




    methods
        function this=OperatorWrapper(functionWrapper)
            this.FunctionToEvaluate=functionWrapper;
            this.NumberOfDimensions=functionWrapper.NumberOfDimensions;
        end

        function setVectorized(this,value)
            this.FunctionToEvaluate.setVectorized(value);
        end

        function flag=getVectorized(this)
            flag=this.FunctionToEvaluate.getVectorized();
        end
    end

    methods(Hidden)
        function data=Data(this)
            if isa(this.FunctionToEvaluate,'FunctionApproximation.internal.functionwrapper.OperatorWrapper')
                data=Data(this.FunctionToEvaluate);
            elseif isa(this.FunctionToEvaluate,'FunctionApproximation.internal.functionwrapper.SerializationNeedingWrapper')
                data=this.FunctionToEvaluate.Data;
            else
                data=[];
            end
        end
    end
end
