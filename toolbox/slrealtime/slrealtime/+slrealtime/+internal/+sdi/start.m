function start(runId,appName,targetName,runDate)










    hmiOpts.RecordOn=false;
    hmiOpts.VisualizeOn=true;
    hmiOpts.CommandLine=false;
    hmiOpts.StartTime=0;
    hmiOpts.StopTime=inf;
    hmiOpts.EnableRollback=false;
    hmiOpts.SnapshotInterval=10;
    hmiOpts.NumberOfSteps=1;
    hmiOpts.TargetComputer=targetName;

    eng=Simulink.sdi.Instance.engine;
    repo=sdi.Repository(true);
    repo.setRunName(runId,['Run <run_index>: <model_name> @ ',targetName]);
    if~isempty(runDate)
        repo.setDateCreated(runId,runDate);
    end

    Simulink.HMI.helperOnModelStart(appName,eng,repo,hmiOpts);
    try
        Simulink.sdi.internal.SLMenus.getSetNewDataAvailable(appName,true);
    catch

    end
end
