classdef(Sealed)BruteForceMinimaFinder<FunctionApproximation.internal.extremafinders.MinimaFinder





    methods(Access=?FunctionApproximation.internal.extremafinders.ExtremaFinder)
        function[value,functionValue]=execute(~,functionWrapper,gridObject,varargin)
            coordinates=gridObject.getSets;
            outputValue=functionWrapper.evaluate(coordinates);
            [currentError,errorAt]=min(outputValue);
            value=coordinates(errorAt,:);
            functionValue=currentError;
        end
    end
end


