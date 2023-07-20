



function out=getModelBusSymbolTable(aObj,busName)

    modelSymbolTable=aObj.fModelSymbolTable;
    out=modelSymbolTable.getAllBusFieldTypeAndDim(busName);
end
