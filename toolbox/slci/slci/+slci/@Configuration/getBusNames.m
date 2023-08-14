



function out=getBusNames(aObj)

    modelSymbolTable=aObj.fModelSymbolTable;
    out=modelSymbolTable.getDefinedBusNames();
end
