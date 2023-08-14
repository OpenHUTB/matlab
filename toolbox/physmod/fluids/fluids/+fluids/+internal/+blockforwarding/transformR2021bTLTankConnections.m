function transformR2021bTLTankConnections(block)







    system=get_param(block,'Parent');
    connections=get_param(block,'PortConnectivity');





    if numel(connections)~=10
        return
    end


    isLocked=get_param(bdroot,'Lock');
    set_param(bdroot,'Lock','off');







    num_inlets=get_param(block,'capacity_check');
    numInlets=[];
    switch num_inlets
    case '0'
        numInlets=1;
    case '1'
        numInlets=2;
    case '2'
        numInlets=3;
    end

    set_param(block,'capacity_check','1')









    vDest=connections(8).DstPort;
    lDest=connections(9).DstPort;
    tDest=connections(7).DstPort;
    hDest=connections(6).DstPort;



    set_param(block,'num_inlet',num2str(numInlets));


    ports=get_param(block,'PortHandles');


    vSource=ports.LConn(end-1);
    lSource=ports.LConn(end);
    tSource=ports.RConn(2);
    hSource=ports.RConn(1);


    reroute(system,vSource,hDest);
    reroute(system,lSource,tDest);
    reroute(system,tSource,vDest);
    reroute(system,hSource,lDest);


    set_param(bdroot,'Lock',isLocked);

end

function reroute(system,SourcePort,DestPort)
    if~isempty(DestPort)
        for i=1:length(DestPort)
            delete_line(get_param(DestPort(i),'Line'));
            add_line(system,SourcePort,DestPort(i),'autorouting','on');
        end
    end
end