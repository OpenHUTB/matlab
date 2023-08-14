function res=detectLibraryClonesForEditTimeRedirection(~)


    modelHandle=get_param(bdroot,'handle');
    res='';
    result=Simulink.SLPIR.CloneDetection.getLibraryList(modelHandle);
    mdlName=get_param(modelHandle,'Name');
    clonedetection(mdlName);

    uiObj=get_param(mdlName,'CloneDetectionUIObj');
    settingObj=Simulink.CloneDetection.Settings();
    i=1;

    for j=1:length(result)
        for k=1:length(result(j).candidates)
            path=which(get_param(result(j).candidates(k),'Name'));
            settingObj.Libraries{i}={path};
            i=i+1;
        end
    end
    Simulink.CloneDetection.findClones(mdlName,settingObj);

end