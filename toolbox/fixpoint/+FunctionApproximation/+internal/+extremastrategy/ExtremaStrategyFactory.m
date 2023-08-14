classdef ExtremaStrategyFactory<handle















    methods
        function strategy=getStrategy(~,useFullGrid,nDimensions)
            if useFullGrid
                strategy=FunctionApproximation.internal.extremastrategy.ExtremaStrategy.empty();
            else
                k=log2(FunctionApproximation.internal.gridcreator.MaximumPointsGridingStrategy.MAXPOINTS);
                gridRefinementFactor=floor(max(k/(ceil(nDimensions/2)),2));
                strategy=FunctionApproximation.internal.extremastrategy.GridSearch(gridRefinementFactor);
            end
        end
    end
end