classdef DerivativeObject<FunctionApproximation.internal.functionwrapper.AbstractWrapper






    properties(SetAccess=private)
        DerivativeStartegy;
        LastOutputDerivatives;
    end

    methods
        function obj=DerivativeObject(derivativeStrategy,functionWrapper)
            obj.FunctionToEvaluate=functionWrapper;
            obj.NumberOfDimensions=functionWrapper.NumberOfDimensions;
            obj.DerivativeStartegy=derivativeStrategy;
        end

        function derivatives=getDerivativeVector(this,inputValue)

            derivatives=calculate(this.DerivativeStartegy.FiniteDifference,...
            this.FunctionToEvaluate,...
            this.DerivativeStartegy.StepSize,...
            this.DerivativeStartegy.Order,...
            inputValue);


            this.LastOutputDerivatives=derivatives;
        end
    end

    methods(Access=protected)
        function totalDerivative=execute(this,inputValue)

            derivatives=getDerivativeVector(this,inputValue);
            totalDerivative=sum(derivatives,2);
            this.LastOutput=totalDerivative;
        end
    end
end


