function obj=getCustomClients(observerTypes)
    obj=[];

    if isempty(observerTypes)
        return;
    end

    obj=Simulink.HMI.StreamingClients;


    for i=1:length(observerTypes)
        obsType=observerTypes{i};
        signalClient=Simulink.HMI.SignalClient;
        signalClient.ObserverType=obsType;
        signalClient.ObserverParams=...
        Simulink.HMI.AsyncQueueObserverAPI.getDefaultObserverParams(...
        obsType);

        obj.add(signalClient)
    end

end

