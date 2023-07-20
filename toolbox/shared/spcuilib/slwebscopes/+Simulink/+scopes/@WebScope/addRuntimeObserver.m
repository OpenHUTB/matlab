function addRuntimeObserver(this,bpath,portIdx,uuid,observer,dataProcStrategy,frameSize,numChannels,numSignals,isComplex,usesJetStreamAsyncIOBridge,sigIndx)







    bpath=Simulink.SimulationData.BlockPath(bpath);
    hPort=locGetPortHandle(bpath,portIdx);
    if isempty(hPort)||~hPort
        return
    end


    observer=locGetAllNeededObservers(this,observer,uuid,dataProcStrategy,frameSize,numChannels,numSignals,isComplex,usesJetStreamAsyncIOBridge,sigIndx);

    bLogging=locIsPortStreaming(hPort,bpath,portIdx);
    if bLogging

        locAddObserversIfNeeded(hPort,bpath,portIdx,observer);
    else

        Simulink.connectRuntimeSignalAccess(hPort,'Params',observer);
    end
end


function hPort=locGetPortHandle(bpath,portIdx)
    hPort=0;
    if~isempty(bpath)&&bpath.getLength()>0
        blk=bpath.getBlock(bpath.getLength());
        ph=get_param(blk,'PortHandles');
        if portIdx>0&&portIdx<=numel(ph.Outport)
            hPort=ph.Outport(portIdx);
        end
    end
end


function observers=locGetAllNeededObservers(this,param,uuid,dataProcStrategy,frameSize,numChannels,numSignals,isComplex,usesJetStreamAsyncIOBridge,sigIndx)
    observers.Domain='dashboard';
    if~isempty(param)
        if ischar(param)

            observers(1).CustomClients=Simulink.HMI.StreamingClients();
            client=Simulink.HMI.SignalClient;
            client.DimensionChannel=1;
            client.ObserverType=param;
            client.ObserverParams=this.getObserverParameters(uuid,dataProcStrategy,frameSize,numChannels,numSignals,isComplex,sigIndx,usesJetStreamAsyncIOBridge,'JetStream');
            observers(1).CustomClients.add(client);
        else
            observers=param;
        end
    end
end


function ret=locIsPortStreaming(hPort,bpath,portIdx)
    fullBpath=bpath.convertToCell();
    mdl=Simulink.SimulationData.BlockPath.getModelNameForPath(fullBpath{1});
    bSigLogging=strcmpi(get_param(mdl,'SignalLogging'),'on');
    ret=bSigLogging&&strcmpi(get(hPort,'DataLogging'),'on');
    if~ret

        sigName=get(hPort,'Name');
        q=Simulink.AsyncQueue.Queue.find(...
        fullBpath,portIdx,sigName);
        ret=~isempty(q);
    end
end


function locAddObserversIfNeeded(hPort,bpath,portIdx,observers)
    if~isempty(observers)&&isfield(observers,'CustomClients')
        obsType=observers.CustomClients.get(1).ObserverType;
        blk=bpath.getBlock(bpath.getLength());
        existingObs=Simulink.HMI.AsyncQueueObserverAPI.getQueueObservers(...
        blk,portIdx,get(hPort,'Name'));
        if~any(strcmp(existingObs,obsType))
            Simulink.addObserversToExistingQueue(hPort,observers.CustomClients);
        end
    end
end
