function tolValue=getToleranceFromModel(blk,portIndex,tolType)















    clients=get_param(bdroot(blk),'StreamingClients');

    tolValue=[];
    if isempty(clients)
        return
    else

        sigInfo.mdl=bdroot(blk);
        sigInfo.BlockPath=blk;
        sigInfo.OutputPortIndex=portIndex;


        [client,~,wasAdded]=Simulink.sdi.internal.Utils.getWebClient(sigInfo);
        if~wasAdded&&isfield(client.ObserverParams,'Tolerances')
            switch(tolType)
            case 'AbsTol'
                if isfield(client.ObserverParams.Tolerances,'AbsoluteTolerance')
                    tolValue=client.ObserverParams.Tolerances.AbsoluteTolerance;
                end
            case 'RelTol'
                if isfield(client.ObserverParams.Tolerances,'RelativeTolerance')
                    tolValue=client.ObserverParams.Tolerances.RelativeTolerance;
                end
            end
        end
    end

end