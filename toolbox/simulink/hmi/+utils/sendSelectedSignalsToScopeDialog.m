



function sendSelectedSignalsToScopeDialog(hBlk,selectedSigs)
    msg.action='signalsSelected';
    msg.params.id=Simulink.HMI.Utils.getAsString(hBlk);
    hModel=bdroot(hBlk);
    msg.params.Model=Simulink.HMI.Utils.getAsString(hModel);
    msg.params.signals.selected={};
    msg.params.bound.signals={};


    matchSigs=[];
    dlg=hmiblockdlg.DashboardScope.findScopeDialog(hBlk);
    mdl=get_param(hModel,'Name');
    bindingInfo=get_param(hBlk,'Binding');
    bindingClrs=get_param(hBlk,'Colors');
    numClrs=numel(bindingClrs);
    [~,sigs]=utils.getIDsForBoundSignals(mdl,bindingInfo);
    clients=get_param(hModel,'StreamingClients');
    for idx=1:length(sigs)
        msg.params.bound.signals{idx}.signalUUID=sigs(idx).UUID;
        msg.params.bound.signals{idx}.checked='true';
        msg.params.bound.signals{idx}.blockPath=...
        locRemoveModelName(mdl,sigs(idx).BlockPath.getBlock(1));
        msg.params.bound.signals{idx}.outputPortIndex=sigs(idx).OutputPortIndex;
        msg.params.bound.signals{idx}.signalName=getSignalNameFromModel(sigs(idx));
        if idx<=numClrs&&~isempty(bindingClrs(idx).Color)

            msg.params.bound.signals{idx}.isDefaultColorAndStyle='false';
            msg.params.bound.signals{idx}.lineStyle=bindingClrs(idx).LineStyle;
            msg.params.bound.signals{idx}.lineColor=...
            uint32(255.*bindingClrs(idx).Color);
        else

            client=locFindClient(sigs(idx),clients);
            if isempty(client)||isempty(client.LineSettings.Color)
                msg.params.bound.signals{idx}.isDefaultColorAndStyle='true';
                msg.params.bound.signals{idx}.lineStyle='-';
                msg.params.bound.signals{idx}.lineColor=[0,0,0];
            else
                msg.params.bound.signals{idx}.isDefaultColorAndStyle='false';
                msg.params.bound.signals{idx}.lineStyle=client.LineSettings.LineStyle;
                msg.params.bound.signals{idx}.lineColor=...
                uint32(255.*client.LineSettings.Color);
            end
        end


        curIdx=locFindSignal(dlg,msg.params.bound.signals{idx});
        if curIdx>0
            msg.params.bound.signals{idx}=dlg.SelectedSignals{curIdx};
            matchSigs(end+1)=curIdx;%#ok<AGROW>
        end
    end


    for idx=1:length(selectedSigs)
        msg.params.signals.selected{idx}.signalUUID='';
        msg.params.signals.selected{idx}.checked='false';
        msg.params.signals.selected{idx}.blockPath=...
        locRemoveModelName(mdl,selectedSigs(idx).BlockPath);

        bPath=msg.params.signals.selected{idx}.blockPath;
        msg.params.signals.selected{idx}.blockPath=...
        Simulink.SimulationData.BlockPath.manglePath(bPath);
        msg.params.signals.selected{idx}.outputPortIndex=selectedSigs(idx).OutputPortIndex;
        msg.params.signals.selected{idx}.signalName=selectedSigs(idx).SignalName;
        msg.params.signals.selected{idx}.isDefaultColorAndStyle=selectedSigs(idx).DefaultColorAndStyle;
        msg.params.signals.selected{idx}.lineStyle=selectedSigs(idx).LineStyle;
        msg.params.signals.selected{idx}.lineColor=selectedSigs(idx).LineColorTuple;


        curIdx=locFindSignal(dlg,msg.params.signals.selected{idx});
        if curIdx>0&&strcmpi(dlg.SelectedSignals{curIdx}.checked,'true')
            msg.params.signals.selected{idx}=dlg.SelectedSignals{curIdx};
            matchSigs(end+1)=curIdx;%#ok<AGROW>
        end
    end


    idxToRemove=[];
    for idx=1:length(dlg.SelectedSignals)
        if~any(matchSigs==idx)
            if strcmpi(dlg.SelectedSignals{idx}.checked,'true')
                msg.params.signals.selected{end+1}=dlg.SelectedSignals{idx};
            else
                idxToRemove(end+1)=idx;%#ok<AGROW>
            end
        end
    end
    dlg.SelectedSignals(idxToRemove)=[];


    message.publish('/sl_hmi',msg);
end


function client=locFindClient(sig,clients)
    client=[];
    if~isempty(clients)
        for idx=1:clients.Count
            c=get(clients,idx);
            if strcmp(c.SignalUUID_,sig.UUID)&&strcmp(c.ObserverType,'webclient_observer')
                client=c.ObserverParams;
                return
            end
        end
    end
end


function blockPath=locRemoveModelName(model,fullBlockPath)
    blockPath=fullBlockPath;
    if contains(fullBlockPath,model)
        blockPath=fullBlockPath(length(model)+2:end);
    end
end


function ret=locFindSignal(dlg,newSig)
    ret=0;
    for idx=1:length(dlg.SelectedSignals)
        if newSig.outputPortIndex==dlg.SelectedSignals{idx}.outputPortIndex&&...
            strcmp(newSig.blockPath,dlg.SelectedSignals{idx}.blockPath)&&...
            (isempty(newSig.signalName)||...
            isempty(dlg.SelectedSignals{idx}.signalName)||...
            strcmp(newSig.signalName,dlg.SelectedSignals{idx}.signalName))
            ret=idx;
            return
        end
    end
end
