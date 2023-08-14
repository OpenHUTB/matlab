function onPCTWorkerMsg(this,msg)




    [bCreatedFile,msg]=locCopyWorkerDRM(msg);


    isCleanupNeeded=bCreatedFile||isfield(msg,'IsDMRTemporary')&&msg.IsDMRTemporary;
    switch msg.Type

    case 'new_worker'
        eng=Simulink.sdi.Instance.engine;
        eng.PCTDataQueueToWorker.insert(msg.InstanceID,msg.DataQueue);

    case 'update_runs'
        [newRuns,removedRuns,checkedSigs,workerRunIDs]=...
        updatePCTRuns(this.sigRepository,msg);
        locUpdateRunsInUI(newRuns,removedRuns,checkedSigs);
        locMarkerImportedWorkerRuns(this,msg,workerRunIDs);

    case 'update_signals'
        updatePCTSignals(this.sigRepository,msg);
        locUpdateSignalsInUI(msg.ClientRunID);

    case 'stream_data'
        firstChunkNum=updatePCTSignalData(this.sigRepository,msg);
        locUpdateSignalData(msg,firstChunkNum);

    case 'update_worker_instanceID'
        locUpdateWorkerInstanceID(this,msg);


    case 'request_signals'
        Simulink.sdi.internal.pushSignalListFromWorker(msg);

    case 'request_streaming'
        if msg.RequestData
            Simulink.sdi.internal.pushSignalDataFromWorker(msg,-inf);
        else
            Simulink.sdi.internal.unregisterWorkerStream(msg);
        end

    case 'cleanup_dmr'
        Simulink.sdi.internal.flushStreamingBackend();
        drawnow;
        sdi.Repository.clearRepositoryFile();

    case 'disable_pct_support'
        locDisablePCTSupport(this);

    case 'marker_imported_runs'
        markPCTRunsImported(this.sigRepository,msg.RunIDs);

    otherwise
        disp('** Unknown SDI PCT message');
        disp(msg);
    end
    if isCleanupNeeded
        locCleanupFile(msg)
    end
end


function locUpdateRunsInUI(newRuns,removedRuns,checkedSigs)
    eng=Simulink.sdi.Instance.engine;
    if~isempty(newRuns)||~isempty(removedRuns)
        eng.dirty=true;
    end


    numRuns=length(removedRuns);
    for idx=1:numRuns
        deleteRun(eng,removedRuns(idx));
    end


    numRuns=length(newRuns);
    for idx=1:numRuns
        Simulink.sdi.insertRowInTable(eng.sigRepository,newRuns(idx));
        notify(eng,'runAddedEvent',Simulink.sdi.internal.SDIEvent('runAddedEvent',newRuns(idx)));
    end


    for idx=1:length(checkedSigs)
        val=getSignalCheckedPlots(eng,checkedSigs(idx));
        notify(eng,'treeSignalPropertyEvent',...
        Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',checkedSigs(idx),val,'checked'));
    end


    runIDs=newRuns;
    for idx=1:length(runIDs)
        rs=eng.sigRepository.getRunStatus(runIDs(idx));
        notify(eng,'treeRunPropertyEvent',...
        Simulink.sdi.internal.SDIEvent('treeRunPropertyEvent',runIDs(idx),rs,'runStatus'));
    end
end


function locMarkerImportedWorkerRuns(this,msg,workerRunIDs)
    if~isempty(workerRunIDs)
        newMsg.Type='marker_imported_runs';
        newMsg.RunIDs=workerRunIDs;
        dc=getDataByKey(this.PCTDataQueueToWorker,msg.InstanceID);
        send(dc,newMsg);
    end
end


function locUpdateSignalsInUI(runID)
    eng=Simulink.sdi.Instance.engine;
    notify(eng,'signalsInsertedEvent',Simulink.sdi.internal.SDIEvent('signalsInsertedEvent',runID));
end


function locUpdateSignalData(msg,firstChunkNum)
drawnow
    Simulink.HMI.updateSignalDataFromWorker(msg.ClientSignalID,firstChunkNum);
end


function[bCreatedFile,msg]=locCopyWorkerDRM(msg)
    bCreatedFile=isfield(msg,'DMRData')&&~isempty(msg.DMRData);
    if bCreatedFile
        fpath=[tempname,'.dmr'];
        fid=fopen(fpath,'wb');
        fwrite(fid,msg.DMRData,'uint8');
        fclose(fid);
        msg.DMRPath=fpath;
        msg.DMRData=[];
    else


        if~isfield(msg,'DMRPath')||~exist(msg.DMRPath,'file')
            msg.DMRPath='';
        end
    end
end


function locCleanupFile(msg)
    delete(msg.DMRPath);
end


function locDisablePCTSupport(this)
    this.PCTDataQueueFromWorker=[];
    this.PCTDataQueueToWorker=[];
    this.PCTRequestedSignalStreams=[];
    Simulink.sdi.internal.isParallelPoolSetup(false);
    sdi.Repository.clearRepositoryFile();
end


function locUpdateWorkerInstanceID(this,msg)
    if~isempty(this.PCTDataQueueToWorker)&&this.PCTDataQueueToWorker.isKey(msg.OldInstanceID)
        obj=this.PCTDataQueueToWorker.getDataByKey(msg.OldInstanceID);
        this.PCTDataQueueToWorker.deleteDataByKey(msg.OldInstanceID);
        this.PCTDataQueueToWorker.insert(msg.InstanceID,obj);
    end
end
