function addRuntimeObserver(bpath,portIdx,observers,bIsScope)






    hPort=locGetPortHandle(bpath,portIdx);
    if isempty(hPort)||~hPort
        return
    end


    if nargin<4
        bIsScope=false;
    end


    observers=locGetAllNeededObservers(observers);

    [bLogging,aq]=locIsPortStreaming(hPort,bpath,portIdx);
    if bLogging

        locAddObserversIfNeeded(hPort,bpath,portIdx,observers,bIsScope,aq);
    else

        Simulink.connectRuntimeSignalAccess(hPort,'Params',observers,'DisableRecording',~bIsScope);
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


function observers=locGetAllNeededObservers(param)
    observers.Domain='dashboard';
    if~isempty(param)
        if ischar(param)

            client=Simulink.HMI.SignalClient;
            client.ObserverType=param;
            client.ObserverParams=...
            Simulink.HMI.AsyncQueueObserverAPI.getDefaultObserverParams(param);
            observers(1).CustomClients=Simulink.HMI.StreamingClients();
            observers(1).CustomClients.add(client);
        else
            observers=param;
        end
    end
end


function[ret,q]=locIsPortStreaming(hPort,bpath,portIdx)
    q=[];
    fullBpath=bpath.convertToCell();
    mdl=Simulink.SimulationData.BlockPath.getModelNameForPath(fullBpath{1});
    bSigLogging=strcmpi(get_param(mdl,'SignalLogging'),'on');


    dlo=[];
    if bSigLogging
        dlo=simulink.hmi.signal.getLoggingOverride(mdl);
    end

    ret=bSigLogging&&simulink.hmi.signal.isSignalLogged(hPort,dlo);
    if~ret

        sigName=get(hPort,'Name');
        q=Simulink.AsyncQueue.Queue.find(...
        fullBpath,portIdx,sigName);
        ret=~isempty(q);
    end
end


function locAddObserversIfNeeded(hPort,bpath,portIdx,observers,bIsScope,aq)

    if~isempty(observers)&&isfield(observers,'CustomClients')
        obsType=observers.CustomClients.get(1).ObserverType;
        blk=bpath.getBlock(bpath.getLength());
        existingObs=Simulink.HMI.AsyncQueueObserverAPI.getQueueObservers(...
        blk,portIdx,get(hPort,'Name'));
        if~any(strcmp(existingObs,obsType))
            Simulink.addObserversToExistingQueue(hPort,observers.CustomClients);
        end
    end


    if bIsScope&&~isempty(aq)&&aq.DisableRecording
        aq.DisableRecording=false;
    end
end
