function dbUnit=getLUTDBUnitFromLUTModelData(lutModelData)




    gridCreator=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(lutModelData.InputTypes);
    gridObject=FunctionApproximation.internal.Grid(lutModelData.Data(1:end-1),gridCreator);
    dbUnit=FunctionApproximation.internal.database.LUTDBUnit();
    dbUnit.GridSize=gridObject.GridSize;
    dbUnit.ConstraintAt=[];
    dbUnit.ConstraintValue=[0,lutModelData.MemoryUsage.getBits];
    dbUnit.ObjectiveValue=lutModelData.MemoryUsage.getBits;
    dbUnit.BreakpointSpecification=lutModelData.Spacing;
    dbUnit.Grid=gridObject;
    dbUnit.StorageTypes=lutModelData.StorageTypes;
    dbUnit.SerializeableData=lutModelData;
end