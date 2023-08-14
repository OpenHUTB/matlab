classdef EvenSpacing<SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.Interface










    properties(Hidden,SetAccess=protected)
        FirstPoint;
        Spacing;
        NumberOfPoints;
    end
    methods
        function this=EvenSpacing(firstPoint,spacing,numberOfPoints)
            this.FirstPoint=firstPoint;
            this.Spacing=spacing;
            this.NumberOfPoints=numberOfPoints;


            vectorCreator=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.VectorCreator.Factory.getCreator(...
            firstPoint,spacing,numberOfPoints);


            this.DataType=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.getDataType(...
            vectorCreator.Vector,spacing);

            this.Values={vectorCreator.Vector};
        end
    end
end


