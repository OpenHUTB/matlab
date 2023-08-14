function dataTypeCreator=getDataTypeCreator(blockObject,dimension)













    tableValues=double(slResolve(blockObject.Table,blockObject.Handle));
    numberOfDimensions=slResolve(blockObject.NumberOfTableDimensions,blockObject.Handle);
    if numberOfDimensions>1
        numberOfPoints=size(tableValues);

    else


        numberOfPoints=numel(tableValues);
    end

    if strcmp(blockObject.BreakpointsSpecification,'Explicit values')

        parameterName=['BreakpointsForDimension',int2str(dimension)];
        breakpointVector=slResolve(get_param(blockObject.Handle,parameterName),blockObject.Handle);
        if~strcmp(blockObject.IndexSearchMethod,'Evenly spaced points')
            if isenum(breakpointVector)
                dataTypeCreator=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.ExplicitEnumerateValues(breakpointVector);
            else
                dataTypeCreator=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.ExplicitValues(breakpointVector);
            end
        else
            if isfi(breakpointVector)&&breakpointVector.isscalingslopebias
                spacing=SimulinkFixedPoint.AutoscalerUtils.subtractSlopeBiasFiValues(breakpointVector(2),breakpointVector(1));
            else
                spacing=breakpointVector(2)-breakpointVector(1);
            end
            dataTypeCreator=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.EvenSpacingForLookups(breakpointVector(1),spacing,numel(breakpointVector));
        end
    else


        parameterName=['BreakpointsForDimension',int2str(dimension)];
        breakPointParameter=[parameterName,'FirstPoint'];
        spacingParameter=[parameterName,'Spacing'];

        minimumValue=slResolve(get_param(blockObject.Handle,breakPointParameter),blockObject.Handle);
        spacing=slResolve(get_param(blockObject.Handle,spacingParameter),blockObject.Handle);

        dataTypeCreator=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.EvenSpacingForLookups(minimumValue,spacing,numberOfPoints(dimension));
    end
end
