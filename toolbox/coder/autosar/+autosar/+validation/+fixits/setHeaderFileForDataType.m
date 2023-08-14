function outMsg=setHeaderFileForDataType(modelName,dataTypeName)






    [objExists,slObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,dataTypeName);
    assert(objExists,'Expected to find datatype object');


    if isprop(slObj,'HeaderFile')
        headerFileName=['impl_type_',lower(dataTypeName),'.h'];
        evalinGlobalScope(modelName,[dataTypeName,'.HeaderFile = ''',headerFileName,''';']);
    end
    outMsg=DAStudio.message('autosarstandard:validation:updatedHeaderFile');


