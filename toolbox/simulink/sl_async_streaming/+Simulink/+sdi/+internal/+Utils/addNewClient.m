


function addNewClient(clients,mdl,sig,observerType)


    client=Simulink.HMI.SignalClient;
    if isequal(observerType,Simulink.sdi.internal.ObserverInterface.ObserverType)
        client.ObserverType=Simulink.sdi.internal.ObserverInterface.ObserverType;
        client.ObserverParams=...
        Simulink.HMI.AsyncQueueObserverAPI.getDefaultObserverParams(client.ObserverType);
    else
        client.ObserverType=observerType;
    end

    client.SourceModel_=mdl;
    client.SignalUUID_=Simulink.sdi.internal.Utils.findInstrumentedSignal(mdl,sig);
    clients.add(client);
end
