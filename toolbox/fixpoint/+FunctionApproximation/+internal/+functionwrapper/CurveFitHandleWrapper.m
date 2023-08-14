classdef(Sealed)CurveFitHandleWrapper<FunctionApproximation.internal.functionwrapper.AbstractWrapper







    properties(SetAccess=private)
        TempDirHandler=[]
        FileDependencies={}
    end

    methods
        function this=CurveFitHandleWrapper(functionToApproximate)
            functionHandle=@(x)feval(functionToApproximate,x);
            generator=FunctionApproximation.internal.StandardFunctionHandleGenerator(functionHandle);
            this.FunctionToEvaluate=generator.FunctionHandle;
            this.NumberOfDimensions=generator.NumberOfDimensions;
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            outputValue=this.FunctionToEvaluate(inputs);
        end
    end
end
