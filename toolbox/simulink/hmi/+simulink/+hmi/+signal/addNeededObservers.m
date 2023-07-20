function addNeededObservers(mdl,portHandles,observers,bInstrModel)






    if nargin<4
        bInstrModel=false;
    end
    if bInstrModel
        locLegacyAddNeededObservers(mdl,portHandles,observers);
    end
end


function locLegacyAddNeededObservers(mdl,portHandles,observers)


    bClientAdded=false;
    clients=get_param(mdl,'StreamingClients');
    if isempty(clients)
        clients=Simulink.HMI.StreamingClients(mdl);
    end


    observerMap=containers.Map('KeyType','double','ValueType','any');
    for idx=1:length(observers)
        observer.type=observers{idx};
        observer.clientExists=false;
        if isKey(observerMap,portHandles(idx))
            observerMap(portHandles(idx))=[observerMap(portHandles(idx)),observer];
        else
            observerMap(portHandles(idx))=observer;
        end
    end


    numClients=clients.Count;
    for idx=1:numClients
        c=get(clients,idx);
        if any(strcmpi(observers,c.ObserverType_))&&~isempty(c.SignalInfo)
            ph=locGetPortHandle(c.SignalInfo);
            if ph&&isKey(observerMap,ph)
                portObservers=observerMap(ph);
                for obsIdx=1:length(portObservers)
                    if strcmpi(c.ObserverType_,portObservers(obsIdx).type)


                        portObservers(obsIdx).clientExists=true;
                    end
                end
                observerMap(ph)=portObservers;
            end
        end
    end



    dv=get_param(mdl,'Dirty');
    tmp=onCleanup(@()set_param(mdl,'Dirty',dv));


    observedPorts=keys(observerMap);
    for idx=1:length(observedPorts)
        if isKey(observerMap,observedPorts(idx))

            portObservers=observerMap(observedPorts{idx});
            for obsIdx=1:length(portObservers)
                if~portObservers(obsIdx).clientExists
                    locAddClient(observedPorts{idx},portObservers(obsIdx).type,clients);
                    bClientAdded=true;
                end
            end
        end
    end


    if bClientAdded
        set_param(mdl,'StreamingClients',clients);
    end
end


function ret=locGetPortHandle(sigInfo)
    ret=0;
    sigInfo=applyRebindingRules(sigInfo);
    if~isempty(sigInfo.CachedBlockHandle_)&&sigInfo.CachedBlockHandle_&&...
        ~isempty(sigInfo.CachedPortIdx_)&&sigInfo.CachedPortIdx_>0&&...
        isempty(sigInfo.DomainType_)
        try
            ph=get_param(sigInfo.CachedBlockHandle_,'PortHandles');
            if length(ph.Outport)>=sigInfo.CachedPortIdx_
                ret=ph.Outport(sigInfo.CachedPortIdx_);
            end
        catch me %#ok<NASGU>

            return
        end
    end
end


function locAddClient(ph,observer,clients)

    bpath=get_param(ph,'Parent');
    sigInfo=Simulink.HMI.SignalSpecification;
    sigInfo.BlockPath=bpath;
    sigInfo.OutputPortIndex=get_param(ph,'PortNumber');
    try
        sigInfo.CachedBlockHandle_=get_param(bpath,'Handle');
    catch

        return;
    end


    sigInfo=Simulink.sdi.internal.ObserverInterface.instrumentModel(...
    sigInfo,false,false);


    client=Simulink.HMI.SignalClient;
    client.SignalInfo=sigInfo;
    client.ObserverType_=observer;
    add(clients,client);
end
