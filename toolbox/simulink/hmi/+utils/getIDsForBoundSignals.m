





function[ids,sigs]=getIDsForBoundSignals(mdl,bindingInfo)
    ids=int64.empty();
    sigs=Simulink.HMI.SignalSpecification.empty();


    instSigs=[];
    if strcmpi(get_param(mdl,'SignalLogging'),'on')
        instSigs=get_param(mdl,'InstrumentedSignals');
    end
    if isempty(instSigs)
        instSigs=Simulink.HMI.InstrumentedSignals(mdl);
    end


    bIsModelRunning=...
    ~strcmpi(get_param(mdl,'SimulationStatus'),'stopped');


    eng=Simulink.sdi.Instance.engine();
    runID=eng.getCurrentStreamingRunID(mdl);
    if runID
        runObj=Simulink.sdi.getRun(runID);
    end


    for idx=1:length(bindingInfo)
        if bIsModelRunning
            [id,sig]=locRunningSignalID(bindingInfo{idx},instSigs);
        else
            [id,sig]=locGetInstSignalID(bindingInfo{idx},instSigs);
            if isempty(id)
                if runID

                    [id,sig]=locGetInstSignalIDFromCompletedRun(bindingInfo{idx},runObj);
                end

                if isempty(sig)


                    id=int64(0);
                    sig=bindingInfo{idx};
                end
            end
        end
        if~isempty(sig)
            ids(end+1)=id;%#ok<AGROW>
            sigs(end+1)=sig;%#ok<AGROW>
        end
    end
end


function[id,ret]=locRunningSignalID(sigInfo,instSigs)

    q=Simulink.AsyncQueue.Queue.find(...
    sigInfo.BlockPath.convertToCell(),...
    sigInfo.OutputPortIndex,...
    sigInfo.getSignalNameFromModel());
    if~isempty(q)
        ret=sigInfo;
        id=q.SignalSourceID;
    else


        [id,ret]=locGetInstSignalID(sigInfo,instSigs);
    end
end


function[id,ret]=locGetInstSignalID(sigInfo,instSigs)


    ret=[];
    id=int64.empty();
    bpath=getAlignedBlockPath(sigInfo);
    numSigs=instSigs.Count;
    for idx=1:numSigs
        curSig=get(instSigs,idx);
        if isequal(curSig.OutputPortIndex,sigInfo.OutputPortIndex)
            curBlockPath=getAlignedBlockPath(curSig);
            if strcmp(curBlockPath,bpath)&&...
                strcmp(curSig.DomainType_,sigInfo.DomainType_)&&...
                isequal(curSig.DomainParams_,sigInfo.DomainParams_)
                ret=curSig;
                id=Simulink.HMI.AsyncQueueObserverAPI.getUUIdFromString(ret.UUID);
                return
            end
        end
    end
end


function[id,ret]=locGetInstSignalIDFromCompletedRun(sigInfo,r)



    ret=[];
    id=int64.empty();
    for idx=1:r.SignalCount
        sig=r.getSignalByIndex(idx);
        if sigInfo.OutputPortIndex==sig.PortIndex&&isequal(sigInfo.BlockPath,sig.FullBlockPath)
            id=sig.InstrumentedSigID;
            ret=sigInfo;
            return
        end
    end
end
