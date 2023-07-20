function[wasSuccess,idsToUpdate,...
    filesInScenario,filesInScenarioFullFile,...
    fullScenarioFileLocationToWrite]=...
    qualifyScenarioData(modelStr,sigIds,inputSpecID,appInstanceID)










    fullScenarioFileLocationToWrite=getScenarioFileName(appInstanceID);

    if(strcmp(fullScenarioFileLocationToWrite,''))

        wasSuccess=false;
        idsToUpdate=[];
        filesInScenario=[];
        filesInScenarioFullFile=[];

    else
        [wasSuccess,idsToUpdate,...
        filesInScenario,filesInScenarioFullFile...
        ]=doUpdateAndWrite(fullScenarioFileLocationToWrite,modelStr,...
        sigIds,inputSpecID,...
        appInstanceID);


    end