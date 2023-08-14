classdef GridMapperStrategyFactory<handle




    methods
        function gridMapperStrategy=getStrategyForLeftToRightGridScan(~,interpolation)




            gridMapperStrategy=[];
            if interpolation=="Linear"
                gridMapperStrategy=FunctionApproximation.internal.gridcreator.RoundingGridMapperStrategy('previous');
            elseif interpolation=="Nearest"
                gridMapperStrategy=FunctionApproximation.internal.gridcreator.RoundingGridMapperStrategy('nearest');
            elseif interpolation=="Flat"
                gridMapperStrategy=FunctionApproximation.internal.gridcreator.RoundingGridMapperStrategy('previous');
            end
        end

        function gridMapperStrategy=getStrategyForExplicitValueSolver(~,interpolation)




            gridMapperStrategy=[];
            if interpolation=="Linear"
                gridMapperStrategy=FunctionApproximation.internal.gridcreator.GridToSegmentMapperStrategy();
            elseif interpolation=="Nearest"
                gridMapperStrategy=FunctionApproximation.internal.gridcreator.RoundingGridMapperStrategy('nearest');
            elseif interpolation=="Flat"
                gridMapperStrategy=FunctionApproximation.internal.gridcreator.RoundingGridMapperStrategy('previous');
            end
        end
    end
end
