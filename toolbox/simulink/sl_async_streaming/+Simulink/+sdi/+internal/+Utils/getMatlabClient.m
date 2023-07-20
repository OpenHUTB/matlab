


function[client,clientIdx,wasAdded]=getMatlabClient(sigInfo)


    client=[];
    clientIdx=0;
    clients=get_param(sigInfo.mdl,'StreamingClients');
    if isempty(clients)
        clients=Simulink.HMI.StreamingClients(sigInfo.mdl);
    end
    [clientIdxs,wasAdded]=Simulink.sdi.internal.Utils.getClientIndex(clients,...
    sigInfo,'matlab_observer');
    for obsIdx=1:length(clientIdxs)
        clientIdx=clientIdxs{obsIdx};
        client=clients.get(clientIdx);
        if strcmp(client.ObserverType,'matlab_observer')
            return;
        end
    end
end

