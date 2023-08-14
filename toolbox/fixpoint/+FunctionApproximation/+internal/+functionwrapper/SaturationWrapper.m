classdef(Sealed)SaturationWrapper<FunctionApproximation.internal.functionwrapper.OperatorWrapper




    properties(SetAccess=private)
MinCorrection
MaxCorrection
    end

    methods(Access=?FunctionApproximation.internal.functionwrapper.AbstractWrapper)
        function this=SaturationWrapper(functionWrapper,minCorrection,maxCorrection)
            this=this@FunctionApproximation.internal.functionwrapper.OperatorWrapper(functionWrapper);
            this.MinCorrection=double(minCorrection);
            this.MaxCorrection=double(maxCorrection);
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            outputValue=evaluate(this.FunctionToEvaluate,inputs);
            outputValue(outputValue<this.MinCorrection)=this.MinCorrection;
            outputValue(outputValue>this.MaxCorrection)=this.MaxCorrection;
        end
    end
end
