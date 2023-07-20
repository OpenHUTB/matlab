function allSources=getAllSourcesForModelHierarchy(modelName)






    refMdlsLoaded=slvariants.internal.manager.core.i_find_mdlrefs(modelName);

    allModels=[{modelName},refMdlsLoaded];
    allSources={};
    addBaseWorkspace=false;
    for i=1:numel(allModels)
        dataDictionary=get_param(allModels{i},'DataDictionary');
        if~isempty(dataDictionary)
            allSources{end+1}=dataDictionary;%#ok<AGROW>
        end
        allSources=[allSources,Simulink.variant.utils.slddaccess.getAllReferencedDataDictionaries(allModels{i})];%#ok<AGROW>
        if strcmp(get_param(allModels{i},'HasAccessToBaseWorkspace'),'on')
            addBaseWorkspace=true;
        end
    end
    if addBaseWorkspace

        allSources=[{slvariants.internal.manager.ui.config.VMgrConstants.BaseWorkspaceSource},allSources];
    end
    allSources=unique(allSources);
end
