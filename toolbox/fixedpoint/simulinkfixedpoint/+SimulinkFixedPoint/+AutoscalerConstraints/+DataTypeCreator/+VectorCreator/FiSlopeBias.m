classdef FiSlopeBias<SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.VectorCreator.Interface






    methods(Access=?SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.VectorCreator.Factory)
        function this=FiSlopeBias(firstPoint,spacing,numberOfPoints)
            values=cast(zeros(1,numberOfPoints),'like',firstPoint);
            values(1)=firstPoint;


            for ii=1:numberOfPoints-1
                values(ii+1)=SimulinkFixedPoint.AutoscalerUtils.addSlopeBiasFiValues(values(ii),spacing);
            end
            this.Vector=values;
        end
    end
end


