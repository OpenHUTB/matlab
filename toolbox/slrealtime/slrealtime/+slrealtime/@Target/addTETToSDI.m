function addTETToSDI(this)






    return;

    currentDir=pwd;
    try
        cd(this.mldatxMiscFolder);
        [taskInfos,numTasks,~]=eval('slrealtime_task_info');
    catch e
        cd(currentDir);
        rethrow(e);
    end
    cd(currentDir);

    repository=sdi.Repository(true);

    tetRunId=this.SDIRunId;
    if isempty(tetRunId)
        modelName=this.tc.ModelProperties.ModelName;
        tetRunId=repository.createRun(modelName);
        try
            slrealtime.internal.sdi.setRunMetaData(tetRunId,...
            modelName,this.TargetSettings.name,this.slrtApp);
        catch e
            if strcmp(e.identifier,'slrealtime:application:packageNotFound')


                xcpExtractFromApp(this,appName);
                slrealtime.internal.sdi.setRunMetaData(tetRunId,...
                modelName,this.TargetSettings.name,this.slrtApp);
            else
                rethrow(e);
            end
        end

        slrealtime.internal.sdi.start(tetRunId,...
        modelName,this.TargetSettings.name,[]);
    end
    assert(~isempty(tetRunId));

    run=Simulink.sdi.getRun(tetRunId);
    tetSig=run.createSignal('Name','TET','DataType','double');
    this.tetSDISigIds=[];
    for nTask=1:numTasks
        tetRateSig=run.createSignal('Name',taskInfos(nTask).taskName,'DataType','double');
        repository.setParent(tetRateSig.ID,tetSig.ID);

        tetRateSigMin=run.createSignal('Name','minimum','DataType','double');
        repository.setParent(tetRateSigMin.ID,tetRateSig.ID);
        this.tetSDISigIds(end+1)=tetRateSigMin.ID;

        tetRateSigMax=run.createSignal('Name','maximum','DataType','double');
        repository.setParent(tetRateSigMax.ID,tetRateSig.ID);
        this.tetSDISigIds(end+1)=tetRateSigMax.ID;

        tetRateSigAvg=run.createSignal('Name','average','DataType','double');
        repository.setParent(tetRateSigAvg.ID,tetRateSig.ID);
        this.tetSDISigIds(end+1)=tetRateSigAvg.ID;
    end
end
