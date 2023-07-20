function closeDictionaryUI(modelName)




    autosar_ui_close(modelName);



    sharedM3IModel=autosarcore.M3IModelLoader.loadSharedM3IModel(modelName);
    if~isempty(sharedM3IModel)
        autosar.dictionary.Utils.closeDictUIForModelsReferencingSharedM3IModel(sharedM3IModel);
    end
end


