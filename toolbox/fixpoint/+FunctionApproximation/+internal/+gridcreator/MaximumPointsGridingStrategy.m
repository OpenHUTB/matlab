classdef MaximumPointsGridingStrategy<FunctionApproximation.internal.gridcreator.GridingStrategy






    properties(Constant)
        MAXPOINTS=2^20;
    end

    methods
        function this=MaximumPointsGridingStrategy(dataTypes)
            this=this@FunctionApproximation.internal.gridcreator.GridingStrategy(dataTypes);
        end
    end

    methods(Access=protected)
        function grid=execute(this,rangeObject,varargin)
            n=numel(this.DataTypes);
            numberOfGridPoints=this.getNumberOfPoints(n);
            bruteForceGridCreator=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(this.DataTypes);
            grid=bruteForceGridCreator.getGrid(rangeObject,numberOfGridPoints);
        end
    end

    methods(Static,Hidden)
        function numberOfGridPoints=getNumberOfPoints(n,maxPoints)
            if nargin<2
                maxPoints=FunctionApproximation.internal.gridcreator.MaximumPointsGridingStrategy.MAXPOINTS;
            end
            log2Points=repmat(log2(maxPoints)/(2^(n-1)),1,n);
            log2Points=max(log2Points,1);
            numberOfGridPoints=floor(2.^log2Points);
        end
    end
end
