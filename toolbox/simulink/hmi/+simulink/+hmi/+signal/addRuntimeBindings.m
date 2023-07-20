function addRuntimeBindings(mdl,dbBlockHandles,observers)




    sw=warning('OFF','BACKTRACE');
    tmp=onCleanup(@()warning(sw));


    bSigLogging=strcmpi(get_param(mdl,'SignalLogging'),'on');


    bFastRestart=strcmpi(get_param(mdl,'FastRestart'),'on');


    dlo=simulink.hmi.signal.getLoggingOverride(mdl);


    sigMap=containers.Map('KeyType','double','ValueType','any');
    sfMap=containers.Map('KeyType','double','ValueType','any');
    numBlks=numel(dbBlockHandles);
    for dbBlkIdx=1:numBlks


        hDbBlk=dbBlockHandles(dbBlkIdx);
        binding=get_param(hDbBlk,'Binding');
        bIsScope=iscell(binding);
        bindingClrs=[];
        if bIsScope
            bindingClrs=get_param(hDbBlk,'Colors');
        end



        for bindingIdx=1:numel(binding)


            clr=struct.empty();
            if bIsScope
                sig=binding{bindingIdx};
                if bindingIdx<=numel(bindingClrs)
                    clr=bindingClrs(bindingIdx);
                end
            else
                assert(isscalar(binding));
                sig=binding;
            end


            if isa(sig,'Simulink.HMI.SignalSpecification')&&...
                Simulink.HMI.SignalSpecification.isSFSignal(sig)
                sfMap=locAddToSFMap(mdl,sig,clr,observers{dbBlkIdx},sfMap,bIsScope);
            else
                sigMap=locAddToSigMap(dlo,sig,clr,observers{dbBlkIdx},sigMap,bSigLogging,bFastRestart,bIsScope);
            end
        end
    end


    simMode=get_param(mdl,'SimulationMode');
    bIsExtMode=strcmpi(simMode,'external');
    hPorts=sigMap.keys;
    for idx=1:numel(hPorts)
        hPort=hPorts{idx};
        sigInfo=sigMap(hPort);
        locInstrumentModel(hPort,sigInfo,bIsExtMode);
    end


    for blkH=sfMap.keys
        blkSigMap=sfMap(blkH{1});
        for sigName=blkSigMap.keys
            sigInfo=blkSigMap(sigName{1});
            locObserveSFSignal(blkH{1},sigName{1},sigInfo);
        end
    end
end


function sigMap=locAddToSigMap(dlo,sig,clr,obsType,sigMap,bSigLogging,bFastRestart,bIsScope)



    hPort=locGetPortHandle(sig);
    if isempty(hPort)||~hPort
        return
    end


    [bNeedInstr,bNeedObserver]=locIsInstrumentationRequired(dlo,sig,hPort,obsType,clr,bSigLogging,bFastRestart);
    if~bNeedInstr&&~bNeedObserver
        return
    end


    sigMap=locAddSigInfoToMap(sigMap,hPort,bNeedInstr,obsType,clr,bIsScope);
end


function hPort=locGetPortHandle(sig)

    hPort=0;
    try
        if~isempty(sig.BlockPath)&&sig.BlockPath.getLength()>0
            blk=sig.BlockPath.getBlock(sig.BlockPath.getLength());
            ph=get_param(blk,'PortHandles');
            if sig.OutputPortIndex>0&&sig.OutputPortIndex<=numel(ph.Outport)
                hPort=ph.Outport(sig.OutputPortIndex);
            end
        end
    catch me %#ok<NASGU>

        hPort=0;
    end
end


function[bNeedInstr,bNeedObserver]=locIsInstrumentationRequired(dlo,sig,hPort,obsType,clr,bSigLogging,bFastRestart)

    bColorOverride=~isempty(clr)&&~isempty(clr.Color);
    bNeedObserver=~isempty(obsType)||bColorOverride;
    bNeedInstr=~bSigLogging||~simulink.hmi.signal.isSignalLogged(hPort,dlo);


    if bNeedInstr&&bFastRestart&&locIsPortStreaming(hPort)
        bNeedInstr=false;
    end


    if bNeedInstr
        return
    end


    if bNeedObserver&&~bColorOverride
        blk=sig.BlockPath.getBlock(sig.BlockPath.getLength());
        bNeedObserver=locIsObserverRequired(...
        blk,...
        sig.OutputPortIndex,...
        get(hPort,'Name'),...
        obsType);
    end
end


function bNeedObserver=locIsObserverRequired(blk,port,name,obsType)

    existingObs=Simulink.HMI.AsyncQueueObserverAPI.getQueueObservers(...
    blk,port,name);
    bNeedObserver=~any(strcmp(existingObs,obsType));
end


function ret=locIsPortStreaming(hPort)

    bpath=Simulink.SimulationData.BlockPath.manglePath(get(hPort,'Parent'));
    portIdx=get(hPort,'PortNumber');
    sigName=get(hPort,'Name');
    q=Simulink.AsyncQueue.Queue.find(bpath,portIdx,sigName);
    ret=~isempty(q);
end


function map=locAddSigInfoToMap(map,key,bNeedInstr,obsType,clr,bIsScope)

    if isKey(map,key)
        sigInfo=map(key);
        if~isempty(obsType)&&~any(strcmp(sigInfo.Observers,obsType))
            sigInfo.Observers{end+1}=obsType;
        end
        if bIsScope
            sigInfo.bIsScope=true;
        end
    else
        sigInfo.bIsScope=bIsScope;
        sigInfo.Color=struct.empty();
        sigInfo.NeedsInstrumentation=bNeedInstr;
        if~isempty(obsType)
            sigInfo.Observers={obsType};
        else
            sigInfo.Observers={};
        end
    end
    if~isempty(clr)&&~isempty(clr.Color)
        sigInfo.Color=clr;
    end
    map(key)=sigInfo;
end


function locInstrumentModel(hPort,sigInfo,bIsExtMode)


    observers=locConstructObservers(sigInfo);
    try


        if bIsExtMode&&~locIsPortStreaming(hPort)
            return
        end
        if sigInfo.NeedsInstrumentation&&~bIsExtMode
            Simulink.connectRuntimeSignalAccess(hPort,'Params',observers,'DisableRecording',~sigInfo.bIsScope);
        elseif isfield(observers,'CustomClients')
            Simulink.addObserversToExistingQueue(hPort,observers.CustomClients);
        end
    catch me
        warning(me.identifier,'%s',me.message);
    end
end


function observers=locConstructObservers(sigInfo)

    observers.Domain='dashboard';
    if~isempty(sigInfo.Observers)||~isempty(sigInfo.Color)
        observers(1).CustomClients=Simulink.HMI.StreamingClients();
        for idx=1:numel(sigInfo.Observers)
            c=Simulink.HMI.SignalClient;
            c.ObserverType=sigInfo.Observers{idx};
            c.ObserverParams=...
            Simulink.HMI.AsyncQueueObserverAPI.getDefaultObserverParams(c.ObserverType);
            observers(1).CustomClients.add(c);
        end
        if~isempty(sigInfo.Color)

            c=Simulink.HMI.SignalClient;
            c.ObserverType='webclient_observer';
            c.ObserverParams=...
            Simulink.HMI.AsyncQueueObserverAPI.getDefaultObserverParams(c.ObserverType);
            c.ObserverParams.LineSettings.Color=sigInfo.Color.Color;
            c.ObserverParams.LineSettings.LineStyle=sigInfo.Color.LineStyle;
            c.ObserverParams.LineSettings.ColorString=...
            Simulink.sdi.internal.LineSettings.colorToHexString(sigInfo.Color.Color);
            observers(1).CustomClients.add(c);
        end
    end
end


function sfMap=locAddToSFMap(mdl,sig,clr,obsType,sfMap,bIsScope)



    if isempty(sig.BlockPath)||sig.BlockPath.getLength()==0
        return
    end
    blkPath=sig.BlockPath.getBlock(sig.BlockPath.getLength());


    blkH=get_param(blkPath,'Handle');
    chartId=sfprivate('block2chart',blkH);
    chartObj=sf('IdToHandle',chartId);
    ssId=str2double(sig.DomainParams_.SSID);
    if strcmp(sig.DomainType_,'sf_chart')

        obj=chartObj;
    else

        obj=find(chartObj,'SSIdNumber',ssId);
    end
    if isempty(obj)
        return
    end




    activity=sig.DomainParams_.Activity;
    instSigs=get_param(mdl,'InstrumentedSignals');
    if isempty(instSigs)||...
        ~instSigs.isGivenSFActivityObserved(sig.SID_,ssId,activity)
        return
    end


    sigName=sfprivate('get_activity_logging_name',obj,activity);
    if isempty(obsType)
        obsType='webclient_observer';
    end
    if locIsObserverRequired(blkPath,0,sigName,obsType)
        if isKey(sfMap,blkH)
            blkSigMap=sfMap(blkH);
        else
            blkSigMap=containers.Map();
        end
        blkSigMap=locAddSigInfoToMap(blkSigMap,sigName,false,obsType,clr,bIsScope);
        sfMap(blkH)=blkSigMap;
    end
end


function locObserveSFSignal(blkH,sigName,sigInfo)

    observers=locConstructObservers(sigInfo);
    if isfield(observers,'CustomClients')
        Simulink.addSFObserversToExistingQueue(blkH,sigName,observers.CustomClients);
    end
end
