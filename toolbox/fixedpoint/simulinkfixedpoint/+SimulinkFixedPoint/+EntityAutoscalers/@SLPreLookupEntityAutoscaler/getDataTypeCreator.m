function dataTypeCreator=getDataTypeCreator(blockObject)







    if strcmp(blockObject.BreakpointsSpecification,'Explicit values')
        breakpointVector=slResolve(blockObject.BreakpointsData,blockObject.Handle);
        if~strcmp(blockObject.IndexSearchMethod,'Evenly spaced points')
            dataTypeCreator=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.ExplicitValues(breakpointVector);
        else
            if isfi(breakpointVector)&&breakpointVector.isscalingslopebias
                spacing=SimulinkFixedPoint.AutoscalerUtils.subtractSlopeBiasFiValues(breakpointVector(2),breakpointVector(1));
            else
                spacing=breakpointVector(2)-breakpointVector(1);
            end
            dataTypeCreator=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.EvenSpacingForLookups(breakpointVector(1),spacing,numel(breakpointVector));
        end
    else

        firstPoint=slResolve(blockObject.BreakpointsFirstPoint,blockObject.Handle);
        spacing=slResolve(blockObject.BreakpointsSpacing,blockObject.Handle);
        numberOfPoints=slResolve(blockObject.BreakpointsNumPoints,blockObject.Handle);
        dataTypeCreator=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.EvenSpacingForLookups(firstPoint,spacing,numberOfPoints);
    end
end


