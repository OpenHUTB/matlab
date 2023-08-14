function outMsg=setDataScopeForDataType(modelName,dataTypeName)






    [objExists,slObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,dataTypeName);
    assert(objExists,'Expected to find datatype object');


    if isprop(slObj,'DataScope')
        evalinGlobalScope(modelName,[dataTypeName,'.DataScope = ''Auto'';']);
    end
    outMsg=DAStudio.message('autosarstandard:validation:updatedDataScope');


