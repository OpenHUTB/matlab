function[values,grid]=getValues(functionWrapper,dataTypes,rangeObject,nPoints)



    gridCreator=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(dataTypes);
    grid=getGrid(gridCreator,rangeObject,nPoints);
    gridObject=FunctionApproximation.internal.Grid(grid,gridCreator);
    tableData=FunctionApproximation.internal.getTableData(FunctionApproximation.BreakpointSpecification.ExplicitValues,functionWrapper,gridObject);
    values=tableData{end};
end
