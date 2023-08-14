classdef(Sealed)NaNProtectedWrapper<FunctionApproximation.internal.functionwrapper.OperatorWrapper




    properties(SetAccess=private)
NaNCorrection
    end

    methods(Access=?FunctionApproximation.internal.functionwrapper.AbstractWrapper)
        function this=NaNProtectedWrapper(functionWrapper,nanCorrection)
            this=this@FunctionApproximation.internal.functionwrapper.OperatorWrapper(functionWrapper);
            this.NaNCorrection=nanCorrection;
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            outputValue=evaluate(this.FunctionToEvaluate,inputs);
            nanLocations=isnan(outputValue);
            outputValue(nanLocations)=this.NaNCorrection;
        end
    end
end
