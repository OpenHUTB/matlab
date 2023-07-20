function allSources=getAccessibleSourcesForModel(modelName)




    allSources={};
    if strcmp(get_param(modelName,'HasAccessToBaseWorkspace'),'on')
        allSources{end+1}=slvariants.internal.manager.ui.config.VMgrConstants.BaseWorkspaceSource;
    end
    modelSource=get_param(modelName,'DataDictionary');
    if~isempty(modelSource)
        allSources{end+1}=modelSource;
    end
    allSources=[allSources,Simulink.variant.utils.slddaccess.getAllReferencedDataDictionaries(modelName)];
end
