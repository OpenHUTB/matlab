function bindWithoutDirtyingWidget(widgetId,modelName,signalInfo)



    mdlDirty=get_param(modelName,'dirty');
    if~ischar(modelName)
        modelName=bdroot(modelName);
    end
    widget=utils.getWidget(modelName,widgetId,true);


    numSigs=length(signalInfo);
    instSigs=get_param(modelName,'InstrumentedSignals');
    if isempty(instSigs)
        instSigs=Simulink.HMI.InstrumentedSignals(modelName);
    end

    for idx=1:numSigs
        sig=signalInfo(idx);
        sigIndex=getInstSigIndex(modelName,sig,instSigs);
        if sigIndex==0
            bpath=[modelName,'/',sig.BlockPath];
            sigInfo=Simulink.HMI.SignalSpecification;
            sigInfo.BlockPath=Simulink.BlockPath(bpath);
            sigInfo.OutputPortIndex=sig.OutputPortIndex;
            sig.CachedBlockHandle_=get_param(bpath,'Handle');
            sig.CachedPortIdx_=sig.OutputPortIndex;
            instSigs.add(sigInfo);
        else
            sigInfo=instSigs.get(sigIndex);
        end
        signalInfo(idx).SignalId=sigInfo.UUID;
    end
    if~bdIsLibrary(modelName)
        set_param(modelName,'InstrumentedSignals',instSigs);
        locAddClient(modelName,signalInfo,widgetId);
        set_param(modelName,'dirty',mdlDirty);
    end
    widget.bindWithoutDirtyingWidget(signalInfo);
end


function idx=getInstSigIndex(modelName,sigInfo,instSigs)
    idx=0;
    numSigs=instSigs.Count;
    for index=1:numSigs
        sig=instSigs.get(index);
        sigBlockPath=Simulink.BlockPath([modelName,'/',sigInfo.BlockPath]);
        if isequal(sig.BlockPath,sigBlockPath)&&...
            isequal(sig.OutputPortIndex,sigInfo.OutputPortIndex)
            idx=index;
            return;
        end
    end
end


function locAddClient(modelName,signalInfo,widgetId)
    clients=get_param(modelName,'StreamingClients');
    if isempty(clients)
        clients=Simulink.HMI.StreamingClients(modelName);
    end
    clientsModified=false;
    updateColors=false;
    indicesToRemove=[];
    for i=1:length(signalInfo)
        defaultClient=signalInfo(i).DefaultColorAndStyle;
        sigInfo.mdl=modelName;
        sigInfo.OutputPortIndex=signalInfo(i).OutputPortIndex;
        sigInfo.BlockPath=[modelName,'/',signalInfo(i).BlockPath];
        [client,clientIdx,wasAdded]=Simulink.sdi.internal.Utils.getWebClient(sigInfo);
        if~defaultClient
            LSfields={'LineStyle','Color','ColorString'};
            signalInfo(i).Color=signalInfo(i).LineColor/255;
            signalInfo(i).ColorString=...
            Simulink.sdi.internal.LineSettings.colorToHexString(signalInfo(i).Color);
            for j=1:length(LSfields)
                client.ObserverParams.LineSettings.(LSfields{j})=...
                signalInfo(i).(LSfields{j});
            end
            if wasAdded
                clients.add(client);
                clientsModified=true;
            else
                clients.set(clientIdx,client);
                clientsModified=true;
                updateColors=true;
            end
        else
            if~wasAdded
                indicesToRemove(end+1)=clientIdx;%#ok
                clientsModified=true;
            end
        end
    end
    if clientsModified


        indicesToRemove=sort(indicesToRemove,'descend');
        for idx=1:length(indicesToRemove)
            clients.remove(indicesToRemove(idx));
        end
        if(clients.Count==0)
            clients=[];
        end
        set_param(modelName,'StreamingClients',clients);
    end
    if updateColors
        simulink.hmi.sdiscope.updateScopeColors(widgetId,modelName,signalInfo,true);
    end
end
