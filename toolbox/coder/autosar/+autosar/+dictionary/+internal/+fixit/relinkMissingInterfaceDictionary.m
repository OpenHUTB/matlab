function relinkMissingInterfaceDictionary(modelName,dictName)



    modelName=get_param(modelName,'Name');
    dictAPI=Simulink.interface.dictionary.open(dictName);
    dictHasARMapping=dictAPI.hasPlatformMapping('AUTOSARClassic');
    existingDict=get_param(modelName,'DataDictionary');
    if~isempty(existingDict)||~dictHasARMapping||~isExpectedDictionaryUUID(modelName,dictAPI)
        DAStudio.error('autosarstandard:dictionary:CannotRelinkInterfaceDict',...
        modelName);
    end

    set_param(modelName,'DataDictionary',dictAPI.DictionaryFileName);
    restoreUIState=autosar.ui.utils.closeUIAndApp(modelName,true);%#ok<NASGU>

    autosarcore.destroyLoadedM3IModel(modelName);
    autosarcore.M3IModelLoader.loadM3IModel(modelName,LoadReferencedM3IModels=true);

end

function tf=isExpectedDictionaryUUID(modelName,dictAPI)
    mappingDictUUID=autosarcore.ModelUtils.getMappingSharedDictUUID(modelName);
    sharedM3IModel=Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(dictAPI.filepath());
    dictUUID=autosar.dictionary.Utils.getDictionaryUUID(sharedM3IModel);
    tf=isequal(mappingDictUUID,dictUUID);
end


