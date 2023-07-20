function setToleranceInModel(blk,portIndex,tolType,tolValue)
















    Simulink.sdi.markSignalForStreaming(blk,portIndex,'on');


    mdl=bdroot(blk);


    clients=get_param(mdl,'StreamingClients');
    if isempty(clients)
        clients=Simulink.HMI.StreamingClients(mdl);
    end


    sigInfo.mdl=mdl;
    sigInfo.BlockPath=blk;
    sigInfo.OutputPortIndex=portIndex;


    [client,clientIdx,wasAdded]=Simulink.sdi.internal.Utils.getWebClient(sigInfo);

    switch(tolType)
    case 'AbsTol'
        client.ObserverParams.Tolerances.AbsoluteTolerance=tolValue;
    case 'RelTol'
        client.ObserverParams.Tolerances.RelativeTolerance=tolValue;
    end

    if wasAdded
        clients.add(client);
    else
        clients.set(clientIdx,client);
    end


    set_param(mdl,'StreamingClients',clients);
end