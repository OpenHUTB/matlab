classdef MinimumNumberOfPointsInitializer<FunctionApproximation.internal.gridsizeinitializer.Initializer






    methods
        function gridSize=getGridSize(~,context)
            if context.FunctionType=="LUTBlock"

                breakpointGrid=context.FunctionWrapper.Data.Data(:,1:end-1);
                gridSize=cellfun(@(x)numel(x),breakpointGrid);
            else


                gridSize=ones(1,context.FunctionWrapper.NumberOfDimensions);
                gridSize=2*context.ScaleFactor*gridSize;
            end
        end
    end
end

