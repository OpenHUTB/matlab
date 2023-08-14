function unbind(modelName,path,portIdx)



    blockPathString=[modelName,'/',path{1}];
    clients=get_param(modelName,'StreamingClients');
    if isempty(clients)||clients.Count==0
        return;
    end

    clCount=clients.Count;
    if~isempty(clients)
        for idx=1:clCount
            client=clients.get(idx);
            try
                if isequal(blockPathString,client.SignalInfo.BlockPath.getBlock(1))...
                    &&isequal(portIdx,client.SignalInfo.OutputPortIndex)
                    clients.remove(idx);
                    break;
                end
            catch me %#ok<NASGU>
            end
        end
    end

    if clients.Count==0
        set_param(modelName,'StreamingClients',[]);
    else
        set_param(modelName,'StreamingClients',clients);
    end
end
