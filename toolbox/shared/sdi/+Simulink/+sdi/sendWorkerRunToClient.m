function sendWorkerRunToClient(run)
    if~Simulink.sdi.isPCTDataTransferSupported()
        error(message('SDI:sdi:PCTTransferNotSupported'));
    end

    if nargin<1
        Simulink.sdi.internal.flushStreamingBackend();
        runIDs=Simulink.sdi.getAllRunIDs();
        if isempty(runIDs)
            return
        else
            run=runIDs(end);
        end
    end
    if isa(run,'Simulink.sdi.Run')
        run=run.ID;
    end
    validateattributes(run,{'numeric'},{'scalar','>=',0});
    Simulink.sdi.internal.flushStreamingBackend();
    eng=Simulink.sdi.Instance.engine();
    if Simulink.sdi.internal.isParallelPoolSetup()
        if strcmp(eng.PCTSupportMode,'manual')||...
            (strcmp(eng.PCTSupportMode,'local')&&~locIsLocalPool())
            locCleanupDMR(eng,run);
            locManuallyPushRun(eng,run);
        end
    end
end


function locCleanupDMR(eng,runToSend)

    if~locIsLocalPool()

        runIDs=Simulink.sdi.getAllRunIDs();
        runsToDelete=int32.empty();
        for idx=1:length(runIDs)
            curRunID=runIDs(idx);
            if(curRunID~=runToSend)&&~getRunIsActivelyStreaming(eng.sigRepository,curRunID)
                runsToDelete(end+1)=curRunID;%#ok<AGROW>
            end
        end

        for idx=1:length(runsToDelete)
            Simulink.sdi.deleteRun(runsToDelete(idx));
        end
        eng.sigRepository.purgeDeletedRuns();
    end
end


function locManuallyPushRun(eng,runID)

    msg.Type='update_runs';

    r=Simulink.sdi.getRun(runID);
    msg.Runs.RunID=runID;
    msg.Runs.IsStreaming=...
    getRunIsActivelyStreaming(eng.sigRepository,runID);
    msg.Runs.Name=r.Name;
    msg.Runs.Model=r.Model;
    msg.Runs.StartTime=r.StartTime;
    msg.Runs.StopTime=r.StopTime;

    bCopyDMR=~msg.Runs.IsStreaming;
    Simulink.sdi.internal.sendMsgFromPCTWorker(msg,bCopyDMR);
end


function bIsLocalPool=locIsLocalPool()
    c=getCurrentCluster();
    bIsLocalPool=isa(c,'parallel.cluster.Local');
end
