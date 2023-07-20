classdef FiBinaryPoint<SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.VectorCreator.Interface






    methods(Access=?SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.VectorCreator.Factory)
        function this=FiBinaryPoint(firstPoint,spacing,numberOfPoints)






            values=firstPoint+fi(0:(numberOfPoints-1),0,32,0)*spacing;
            this.Vector=values;
        end
    end
end


