function modelRepo=initModel(scenarioID,mdlName,owningModelName,owningModelFullPath)





    modelRepo=sta.Model();
    modelRepo.ScenarioID=scenarioID;
    modelRepo.Name=mdlName;
    modelRepo.OwningModelName=owningModelName;

    if isempty(modelRepo.OwningModelName)
        fileNameLocation=get(get_param(modelRepo.Name,'Handle'),'FileName');
        harnessmodelFullPath='';
    else
        harnessmodelFullPath=owningModelFullPath;
        fileNameLocation=get(get_param(modelRepo.OwningModelName,'Handle'),'FileName');
    end

    modelRepo.HarnessFullPath=harnessmodelFullPath;
    modelRepo.LastKnownFileLocation=fileNameLocation;