classdef(Sealed)InfProtectedWrapper<FunctionApproximation.internal.functionwrapper.OperatorWrapper




    properties(SetAccess=private)
NegativeInfCorrection
PositiveInfCorrection
    end

    methods(Access=?FunctionApproximation.internal.functionwrapper.AbstractWrapper)
        function this=InfProtectedWrapper(functionWrapper,negativeInfCorrection,positiveInfCorrection)
            this=this@FunctionApproximation.internal.functionwrapper.OperatorWrapper(functionWrapper);
            this.NegativeInfCorrection=negativeInfCorrection;
            this.PositiveInfCorrection=positiveInfCorrection;
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            outputValue=evaluate(this.FunctionToEvaluate,inputs);
            infLocations=isinf(outputValue);
            negativeLocations=outputValue<0;
            postiveLocations=outputValue>=0;
            outputValue(infLocations&negativeLocations)=this.NegativeInfCorrection;
            outputValue(infLocations&postiveLocations)=this.PositiveInfCorrection;
        end
    end
end
