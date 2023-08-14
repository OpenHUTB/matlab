function waitForActiveRunToStart(modelName,targetName)













    timeout=10;

    eng=Simulink.sdi.Instance.engine;
    runId=slrealtime.internal.sdi.getActiveRunId(modelName,targetName);
    if Simulink.sdi.isValidRunID(runId)
        run=eng.getRun(runId);
        tstart=tic;
        while~strcmp(run.Status,'Running')&&toc(tstart)<timeout
            pause(0.01);
        end
    end
end
