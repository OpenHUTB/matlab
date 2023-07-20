classdef Factory<handle










    methods(Static)
        function vectorCreator=getCreator(firstPoint,spacing,numberOfPoints)




            typeModifier=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.VectorCreator.FirstPointAndSpacingTypeModifier(firstPoint,spacing);
            firstPoint=typeModifier.FirstPoint;
            spacing=typeModifier.Spacing;

            if isfi(firstPoint)

                if firstPoint.isscalingslopebias

                    vectorCreator=...
                    SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.VectorCreator.FiSlopeBias(...
                    firstPoint,spacing,numberOfPoints);
                else

                    vectorCreator=...
                    SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.VectorCreator.FiBinaryPoint(...
                    firstPoint,spacing,numberOfPoints);
                end
            else

                vectorCreator=...
                SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.VectorCreator.DoubleValues(...
                firstPoint,spacing,numberOfPoints);
            end
        end
    end
end


