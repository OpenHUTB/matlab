classdef FullGridGridingStrategy<FunctionApproximation.internal.gridcreator.GridingStrategy





    methods
        function this=FullGridGridingStrategy(dataTypes)
            this=this@FunctionApproximation.internal.gridcreator.GridingStrategy(dataTypes);
        end
    end

    methods(Access=protected)
        function grid=execute(this,rangeObject,varargin)
            dataTypes=this.DataTypes;
            nDimensions=numel(dataTypes);
            numberOfGridPoints=zeros(1,nDimensions);



            for ii=1:nDimensions
                numberOfGridPoints(ii)=double(fixed.internal.utility.cardinality.getCardinality(rangeObject.Interval(ii),dataTypes(ii)));
            end
            bruteForceGridCreator=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(this.DataTypes);
            grid=bruteForceGridCreator.getGrid(rangeObject,numberOfGridPoints);
        end
    end
end