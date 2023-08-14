function refreshLaunchAUTOSARDictionary(cbinfo,action)




    modelH=cbinfo.model.Handle;

    if Simulink.CodeMapping.isMappedToAutosarSubComponent(modelH)
        action.enabled=false;
    else
        action.enabled=true;
    end
