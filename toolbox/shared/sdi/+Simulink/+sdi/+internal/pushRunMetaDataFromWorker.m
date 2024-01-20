function pushRunMetaDataFromWorker(varargin)

    if Simulink.sdi.internal.isParallelPoolSetup()
        Simulink.sdi.internal.flushStreamingBackend();
        eng=Simulink.sdi.Instance.engine;
        if locAutoSendRuns(eng)
            safeTransaction(eng,@locPushRunMetaDataFromWorker,eng,varargin{:});
        end
    end
end


function locPushRunMetaDataFromWorker(eng,varargin)
    runIDs=Simulink.sdi.getAllRunIDs();
    if isempty(runIDs)
        return
    end

    msg.Type='update_runs';
    bCopyDMR=false;

    idxToRemove=[];
    runsToDelete=int32.empty();
    for idx=1:length(runIDs)
        r=Simulink.sdi.getRun(runIDs(idx));
        if~isempty(varargin)&&~strcmp(varargin{1},r.Model)
            idxToRemove(end+1)=idx;%#ok<AGROW>
            continue
        end
        msg.Runs(idx).RunID=runIDs(idx);
        msg.Runs(idx).IsStreaming=...
        getRunIsActivelyStreaming(eng.sigRepository,runIDs(idx));
        msg.Runs(idx).Name=r.Name;
        msg.Runs(idx).Model=r.Model;
        if~isempty(varargin)
            msg.Runs(idx).StartTime=varargin{2};
            msg.Runs(idx).StopTime=varargin{3};
        else
            msg.Runs(idx).StartTime=r.StartTime;
            msg.Runs(idx).StopTime=r.StopTime;
        end
        if~msg.Runs(idx).IsStreaming

            bCopyDMR=true;
            runsToDelete(end+1)=runIDs(idx);%#ok<AGROW>
        end
    end

    if isfield(msg,'Runs')
        msg.Runs(idxToRemove)=[];
        if~isempty(msg.Runs)
            Simulink.sdi.internal.sendMsgFromPCTWorker(msg,bCopyDMR,eng);
        end
    end
    if~isempty(runsToDelete)&&~locIsLocalPool()
        if length(runsToDelete)==length(runIDs)
            Simulink.sdi.clear();
        else
            for idx=1:length(runsToDelete)
                Simulink.sdi.deleteRun(runsToDelete(idx));
            end
            eng.sigRepository.purgeDeletedRuns();
        end
    end
end


function bIsLocalPool=locIsLocalPool()
    c=getCurrentCluster();
    bIsLocalPool=isa(c,'parallel.cluster.Local');
end


function ret=locAutoSendRuns(eng)
    ret=strcmp(eng.PCTSupportMode,'all');
    if~ret&&locIsLocalPool()
        ret=strcmp(eng.PCTSupportMode,'local');
    end
end
