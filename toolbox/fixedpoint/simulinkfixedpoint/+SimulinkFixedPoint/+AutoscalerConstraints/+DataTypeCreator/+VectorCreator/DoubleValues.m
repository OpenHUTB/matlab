classdef DoubleValues<SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.VectorCreator.Interface






    methods(Access=?SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.VectorCreator.Factory)
        function this=DoubleValues(firstPoint,spacing,numberOfPoints)
            values=firstPoint+(0:(numberOfPoints-1))*spacing;
            this.Vector=values;
        end
    end
end


