function syncScopeColors(mdl,hScope,hOtherScopes)








    clients=get_param(mdl,'StreamingClients');
    bClientsChanged=false;


    clrs=get_param(hScope,'Colors');
    bindings=get_param(hScope,'Binding');
    numBindings=numel(bindings);


    for idx=1:numel(clrs)
        if idx<=numBindings
            [clients,bClientsChanged]=locSyncColor(bindings{idx},clrs(idx),clients,bClientsChanged,hOtherScopes);
        end
    end


    if bClientsChanged
        set_param(mdl,'StreamingClients',clients);
    end
end


function[clients,bClientsChanged]=locSyncColor(binding,clr,clients,bClientsChanged,hOtherScopes)

    if isempty(clr.Color)

        return
    end



    [client,clientIdx]=locFindClient(binding,clients);
    if~isempty(client)&&...
        (~isequal(client.ObserverParams.LineSettings.LineStyle,clr.LineStyle)||...
        ~isequal(client.ObserverParams.LineSettings.Color,clr.Color))
        client.ObserverParams.LineSettings.LineStyle=clr.LineStyle;
        client.ObserverParams.LineSettings.Color=clr.Color;
        client.ObserverParams.LineSettings.ColorString=...
        Simulink.sdi.internal.LineSettings.colorToHexString(clr.Color);
        clients.set(clientIdx,client);
        bClientsChanged=true;
    end


    for idx=1:numel(hOtherScopes)
        locUpdateOtherScope(binding,clr,hOtherScopes(idx));
    end
end


function[client,clientIdx]=locFindClient(binding,clients)

    client=[];
    clientIdx=0;
    if~isempty(clients)
        for idx=1:clients.Count
            c=clients.get(idx);
            si=c.SignalInfo;
            if~isempty(si)&&...
                strcmpi(c.ObserverType,'webclient_observer')&&...
                si.OutputPortIndex==binding.OutputPortIndex&&...
                isequal(si.BlockPath,binding.BlockPath)
                client=c;
                clientIdx=idx;
                return
            end
        end
    end
end


function locUpdateOtherScope(binding,clr,hOtherScope)

    clrs=get_param(hOtherScope,'Colors');
    bindings=get_param(hOtherScope,'Binding');
    numBindings=numel(bindings);
    bChanged=false;

    for idx=1:numel(clrs)
        if idx<=numBindings&&...
            bindings{idx}.OutputPortIndex==binding.OutputPortIndex&&...
            isequal(bindings{idx}.BlockPath,binding.BlockPath)&&...
            ~isequal(clrs(idx),clr)
            clrs(idx)=clr;
            bChanged=true;
        end
    end

    if bChanged
        set_param(hOtherScope,'Colors',clrs);
        set_param(hOtherScope,'RefreshPlots','on')
    end
end
