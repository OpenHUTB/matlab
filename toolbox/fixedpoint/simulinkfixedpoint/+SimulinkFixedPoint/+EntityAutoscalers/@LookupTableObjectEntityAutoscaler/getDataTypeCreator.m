function dataTypeCreator=getDataTypeCreator(lookupTableObject,dimension)







    tableValues=SimulinkFixedPoint.EntityAutoscalers.LookupTableObjectEntityAutoscaler.getTableData(lookupTableObject);
    numberOfDimensions=numel(lookupTableObject.Breakpoints);
    if numberOfDimensions>1
        numberOfPoints=size(tableValues);

    else


        numberOfPoints=numel(tableValues);
    end

    if strcmp(lookupTableObject.BreakpointsSpecification,'Explicit values')

        breakpointVector=lookupTableObject.Breakpoints(dimension).Value;
        dataTypeCreator=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.ExplicitValues(breakpointVector);
    else


        firstPoint=lookupTableObject.Breakpoints(dimension).FirstPoint;
        spacing=lookupTableObject.Breakpoints(dimension).Spacing;
        dataTypeCreator=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.EvenSpacingForLookups(...
        firstPoint,...
        spacing,...
        numberOfPoints(dimension));
    end
end


