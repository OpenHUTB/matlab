function value=getValueFromGlobalScope(modelName,varName)





    [~,value]=autosar.utils.Workspace.objectExistsInModelScope(modelName,varName);
