classdef GridSearch<FunctionApproximation.internal.extremastrategy.ExtremaStrategy








    properties(SetAccess=private)
Factor
    end

    properties
        DomainCount=1;
    end

    methods
        function this=GridSearch(factor)
            this.Factor=factor;
        end

        function coordinateSet=getCoordinateSet(this,lowerBound,upperbound,gridCreator)
            rangeObject=FunctionApproximation.internal.Range(lowerBound,upperbound);
            grid=getGrid(gridCreator,rangeObject,this.Factor*this.DomainCount*ones(1,rangeObject.NumberOfDimensions));
            coordinateSet=FunctionApproximation.internal.CoordinateSetCreator(grid).CoordinateSets;
        end
    end
end


