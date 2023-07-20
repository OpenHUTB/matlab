classdef MATLABLUTApproximateGenerator<FunctionApproximation.internal.approximategenerator.ApproximateGenerator





    methods
        function result=approximate(~,lutSolution,varargin)
            result=FunctionApproximation.internal.generateLUTFunction(lutSolution,varargin{:});
        end
    end
end
