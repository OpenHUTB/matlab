function runCheckEquivalency(callbackData)




    sysHandle=SLStudio.Utils.getModelName(callbackData);
    cloneDetectionUI=get_param(sysHandle,'CloneDetectionUIObj');
    equivalencyCheckResults=Simulink.CloneDetection.checkEquivalency(cloneDetectionUI.ReplaceResults);
    cloneDetectionUI.EquivalencyCheckResults=equivalencyCheckResults;
    updatedObj=cloneDetectionUI;
    save(cloneDetectionUI.objectFile,'updatedObj');
    set_param(sysHandle,'CloneDetectionUIObj',cloneDetectionUI);
end


