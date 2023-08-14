



function sendScopeBindingsToDialog(hBlk,callbackID)
    msg.action=callbackID;
    msg.params.id=Simulink.HMI.Utils.getAsString(hBlk);
    hModel=bdroot(hBlk);
    msg.params.Model=Simulink.HMI.Utils.getAsString(hModel);
    msg.params.signals={};


    mdl=get_param(hModel,'Name');
    bindingInfo=get_param(hBlk,'Binding');
    bindingClrs=get_param(hBlk,'Colors');
    numClrs=numel(bindingClrs);
    [~,sigs]=utils.getIDsForBoundSignals(mdl,bindingInfo);
    clients=get_param(hModel,'StreamingClients');
    for idx=1:length(sigs)
        msg.params.signals{idx}.signalUUID=sigs(idx).UUID;
        msg.params.signals{idx}.checked='true';
        msg.params.signals{idx}.blockPath=...
        locRemoveModelName(mdl,sigs(idx).BlockPath.getBlock(1));
        msg.params.signals{idx}.outputPortIndex=sigs(idx).OutputPortIndex;
        msg.params.signals{idx}.signalName=getSignalNameFromModel(sigs(idx));
        if idx<=numClrs&&~isempty(bindingClrs(idx).Color)

            msg.params.signals{idx}.isDefaultColorAndStyle='false';
            msg.params.signals{idx}.lineStyle=bindingClrs(idx).LineStyle;
            msg.params.signals{idx}.lineColor=...
            uint32(255.*bindingClrs(idx).Color);
        else

            client=locFindClient(sigs(idx),clients);
            if isempty(client)||isempty(client.LineSettings.Color)
                msg.params.signals{idx}.isDefaultColorAndStyle='true';
                msg.params.signals{idx}.lineStyle='-';
                msg.params.signals{idx}.lineColor=[0,0,0];
            else
                msg.params.signals{idx}.isDefaultColorAndStyle='false';
                msg.params.signals{idx}.lineStyle=client.LineSettings.LineStyle;
                msg.params.signals{idx}.lineColor=...
                uint32(255.*client.LineSettings.Color);
            end
        end
    end



    dlg=hmiblockdlg.DashboardScope.findScopeDialog(hBlk);
    dlg.SelectedSignals=msg.params.signals;

    if~isempty(callbackID)
        message.publish('/sl_hmi',msg);
    end
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
