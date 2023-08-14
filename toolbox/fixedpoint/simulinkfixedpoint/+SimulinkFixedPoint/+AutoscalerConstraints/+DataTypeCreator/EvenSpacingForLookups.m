classdef EvenSpacingForLookups<SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.EvenSpacing






    methods
        function this=EvenSpacingForLookups(firstPoint,spacing,numberOfPoints)
            this=this@SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.EvenSpacing(firstPoint,spacing,numberOfPoints);

            this.DataType=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.adjustToLookupBlockSpecification(this.DataType,this.Spacing);
        end
    end
end


