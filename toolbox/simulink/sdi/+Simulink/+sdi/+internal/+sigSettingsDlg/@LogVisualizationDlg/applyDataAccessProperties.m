function applyDataAccessProperties(this,dlg)



    instrumentSignalIfNeeded(this);

    enable=dlg.getWidgetValue('chkBoxEnable');
    callbackFcn=dlg.getWidgetValue('txtFcnCallback');
    parameter=dlg.getWidgetValue('txtFcnParam');
    includeTime=dlg.getWidgetValue('chkBoxTime');

    sigInfo=dlg.getSource.SigInfo;
    mdl=sigInfo.mdl;
    clients=get_param(sigInfo.mdl,'StreamingClients');
    if isempty(clients)
        clients=Simulink.HMI.StreamingClients(sigInfo.mdl);
    end

    [client,clientIdx,wasAdded]=Simulink.sdi.internal.Utils.getMatlabClient(sigInfo);

    client.ObserverParams.Enable=enable;
    client.ObserverParams.Function=callbackFcn;
    client.ObserverParams.Param=parameter;
    client.ObserverParams.PortIdx=num2str(get(sigInfo.portH,'PortNumber'));
    client.ObserverParams.ModelName=sigInfo.mdl;
    client.ObserverParams.IncludeTime=includeTime;

    if~isempty(callbackFcn)

        if wasAdded

            clients.add(client);
        else

            clients.set(clientIdx,client);
        end
    else

        if~wasAdded

            clients.remove(clientIdx);
        else

            clients=[];
        end


        dlg.setWidgetValue('txtFcnParam','');
    end

    if~isempty(clients)
        set_param(mdl,'StreamingClients',clients);
    end
end
