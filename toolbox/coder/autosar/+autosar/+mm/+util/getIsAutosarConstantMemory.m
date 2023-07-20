function[isConstantMemoryParam,parameterDataObject]=getIsAutosarConstantMemory(modelName,paramName)





    try
        [~,parameterDataObject]=autosar.utils.Workspace.objectExistsInModelScope(modelName,paramName);
    catch
        parameterDataObject=[];
    end
    [isConstantMemoryParam,parameterDataObject]=autosar.mm.util.getIsAutosarConstantMemoryObject(parameterDataObject);
end



