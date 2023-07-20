function tableData=getTableData(breakpointSpecification,functionWrapper,grid)





    tableDataCreator=FunctionApproximation.internal.tabledatacreator.getCreator(breakpointSpecification);
    tableData=getData(tableDataCreator,functionWrapper,grid);
end