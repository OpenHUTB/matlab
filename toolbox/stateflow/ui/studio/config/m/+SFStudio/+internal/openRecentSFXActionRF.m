function openRecentSFXActionRF(~,action)

    sfxNames=Stateflow.App.Cdr.Runtime.InstanceIndRuntime.getRecentlyOpenSFXModels();

    if isempty(sfxNames)
        action.enabled=false;
    else
        action.enabled=true;
    end
end