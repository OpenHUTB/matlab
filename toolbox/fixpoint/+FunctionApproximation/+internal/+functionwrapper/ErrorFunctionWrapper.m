classdef ErrorFunctionWrapper<FunctionApproximation.internal.functionwrapper.AbstractWrapper




    properties(SetAccess=private)
        Original=[];
        Approximation=[];
        RelTol;
        AbsTol;
    end

    methods
        function this=ErrorFunctionWrapper(originalFunctionWrapper,approximationFunctionWrapper,absTol,relTol)
            this.Original=copy(originalFunctionWrapper);
            this.Approximation=copy(approximationFunctionWrapper);
            this.AbsTol=absTol;
            this.RelTol=relTol;







            f1=abs(this.Original-this.Approximation);
            if this.RelTol>0
                f2=times(abs(this.Original),this.RelTol);
                this.FunctionToEvaluate=(f1-max(f2,this.AbsTol))+this.AbsTol;
            else


                this.FunctionToEvaluate=f1;
            end
            this.NumberOfDimensions=this.FunctionToEvaluate.NumberOfDimensions;
        end

        function modify(this,data)

            modify(this.Approximation,data);
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)

            outputValue=evaluate(this.FunctionToEvaluate,inputs);
        end
    end
end
