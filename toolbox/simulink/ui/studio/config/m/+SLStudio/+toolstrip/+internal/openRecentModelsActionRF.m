function openRecentModelsActionRF(~,action)
    modelNames=slhistory.getMRUList();
    projectNames=slhistory.getMRUList(slhistoryListType.Projects);
    sfxNames=Stateflow.App.Cdr.Runtime.InstanceIndRuntime.getRecentlyOpenSFXModels();

    if isempty(modelNames)&&isempty(projectNames)&&isempty(sfxNames)
        action.enabled=false;
    else
        action.enabled=true;
    end
end