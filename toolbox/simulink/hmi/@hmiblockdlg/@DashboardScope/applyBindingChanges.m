


function applyBindingChanges(this)
    blockHandle=get(this.getBlock(),'handle');
    mdl=get_param(bdroot(blockHandle),'Name');



    ss=get_param(mdl,'SimulationStatus');
    bModelSimulating=~strcmpi(ss,'stopped');
    isLibWidget=Simulink.HMI.isLibrary(mdl);
    if isLibWidget||utils.isLockedLibrary(mdl)
        return
    end


    bColorChanged=false;
    sigIDmap=locGetPlottedSignals(blockHandle);
    bindings={};
    clrs=struct.empty();
    for idx=1:length(this.SelectedSignals)
        if strcmpi(this.SelectedSignals{idx}.checked,'true')
            [bindings,clrs]=locAddBinding(mdl,bindings,clrs,this.SelectedSignals{idx},this.PreviousBinding,bModelSimulating);
        end
        if locApplyColorChange(this.SelectedSignals{idx},sigIDmap,bModelSimulating,mdl)
            bColorChanged=true;
        end
    end


    set_param(blockHandle,'Binding',bindings);
    set_param(blockHandle,'Colors',clrs);


    utils.sendScopeBindingsToDialog(blockHandle,'');


    if bColorChanged
        set_param(blockHandle,'RefreshPlots','on');
    end
end


function sigIDmap=locGetPlottedSignals(blockHandle)
    sigIDmap=containers.Map;
    plottedSig=get_param(blockHandle,'PlottedSignals');
    for idx=1:length(plottedSig)
        sigIDmap(plottedSig(idx).InstrumentedSignalID)=plottedSig(idx).SignalID;
    end
end


function[bindings,clrs]=locAddBinding(mdl,bindings,clrs,sigInfo,prevBinding,bModelSimulating)



    sigSpec=locFindExistingBinding(mdl,sigInfo,prevBinding);
    if isempty(sigSpec)
        sigSpec=Simulink.HMI.SignalSpecification;
        sigSpec.BlockPath=[mdl,'/',sigInfo.blockPath];
        sigSpec.OutputPortIndex=sigInfo.outputPortIndex;
    end
    bindings{end+1}=sigSpec;


    if strcmpi(sigInfo.isDefaultColorAndStyle,'true')
        clrs(end+1).Color=[];
        clrs(end).LineStyle='';
    else
        clrs(end+1).Color=double(sigInfo.lineColor)/255;
        clrs(end).LineStyle=sigInfo.lineStyle;
    end


    if bModelSimulating
        observers=locConstructRuntimeObserver(sigInfo);
        simulink.hmi.signal.addRuntimeObserver(...
        sigSpec.BlockPath,...
        sigSpec.OutputPortIndex,...
        observers,...
        true);
    end
end


function sigSpec=locFindExistingBinding(mdl,sigInfo,prevBinding)
    sigSpec=[];
    blockPath=[mdl,'/',sigInfo.blockPath];
    for idx=1:length(prevBinding)
        if prevBinding{idx}.OutputPortIndex_==sigInfo.outputPortIndex&&...
            strcmp(prevBinding{idx}.BlockPath_,blockPath)&&...
            strcmp(prevBinding{idx}.SignalName_,sigInfo.signalName)
            sigSpec=prevBinding{idx};
            return;
        end
    end
end


function ret=locConstructRuntimeObserver(sigInfo)
    ret=[];
    if~strcmpi(sigInfo.isDefaultColorAndStyle,'true')
        c=Simulink.HMI.SignalClient;
        c.ObserverType='webclient_observer';
        c.ObserverParams=...
        Simulink.HMI.AsyncQueueObserverAPI.getDefaultObserverParams(c.ObserverType);
        c.ObserverParams.LineSettings.Color=double(sigInfo.lineColor)/255;
        c.ObserverParams.LineSettings.LineStyle=sigInfo.lineStyle;
        c.ObserverParams.LineSettings.ColorString=...
        Simulink.sdi.internal.LineSettings.colorToHexString(c.ObserverParams.LineSettings.Color);

        ret(1).CustomClients=Simulink.HMI.StreamingClients();
        ret(1).CustomClients.add(c);
    end
end


function bColorChanged=locApplyColorChange(sigInfo,idMap,bModelSimulating,mdl)

    bColorChanged=false;
    if strcmpi(sigInfo.isDefaultColorAndStyle,'false')
        if isKey(idMap,sigInfo.signalUUID)
            sig=Simulink.sdi.getSignal(idMap(sigInfo.signalUUID));
            sig.LineDashed=sigInfo.lineStyle;
            sig.LineColor=double(sigInfo.lineColor)/255;
            bColorChanged=true;
        elseif bModelSimulating
            q=Simulink.AsyncQueue.Queue.find([mdl,'/',sigInfo.blockPath],sigInfo.outputPortIndex);
            if~isempty(q)
                keys=idMap.keys;
                for idx=1:length(keys)
                    idVal=Simulink.HMI.AsyncQueueObserverAPI.getUUIdFromString(keys{idx});
                    if idVal==q.SignalSourceID
                        sig=Simulink.sdi.getSignal(idMap(keys{idx}));
                        sig.LineDashed=sigInfo.lineStyle;
                        sig.LineColor=double(sigInfo.lineColor)/255;
                        bColorChanged=true;
                        return
                    end
                end
            end
        end
    end
end
