function dataTypeCreator=getDataTypeCreator(breakpointObject)





    breakpointVector=breakpointObject.Breakpoints(1).Value;
    dataTypeCreator=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.ExplicitValues(breakpointVector);
end


