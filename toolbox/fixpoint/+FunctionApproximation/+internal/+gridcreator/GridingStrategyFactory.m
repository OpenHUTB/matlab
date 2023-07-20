classdef GridingStrategyFactory<handle





    methods
        function strategy=getMaximumPointsGridStrategy(~,useFullGrid,dataTypes)
            if useFullGrid
                strategy=FunctionApproximation.internal.gridcreator.FullGridGridingStrategy(dataTypes);
            else
                strategy=FunctionApproximation.internal.gridcreator.MaximumPointsGridingStrategy(dataTypes);
            end
        end
    end
end