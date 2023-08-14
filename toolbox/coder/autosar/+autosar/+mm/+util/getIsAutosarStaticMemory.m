function[isStaticMemorySignal,signalDataObject]=getIsAutosarStaticMemory(modelName,signalName)






    try
        [~,signalDataObject]=autosar.utils.Workspace.objectExistsInModelScope(modelName,signalName);
    catch
        signalDataObject=[];
    end
    [isStaticMemorySignal,signalDataObject]=autosar.mm.util.getIsAutosarStaticMemoryObject(signalDataObject);

end


