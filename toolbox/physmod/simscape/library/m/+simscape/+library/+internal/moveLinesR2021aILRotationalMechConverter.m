function moveLinesR2021aILRotationalMechConverter(block)







    isLocked=get_param(bdroot,'Lock');
    set_param(bdroot,'Lock','off');

    system=get_param(block,'Parent');
    ports=get_param(block,'PortHandles');
    connections=get_param(block,'PortConnectivity');


    portLeft=ports.LConn(2);
    portRight=ports.RConn(1);


    dstPortsLeft=connections(strcmp({connections.Type},'LConn2')).DstPort;
    dstPortsRight=connections(strcmp({connections.Type},'RConn1')).DstPort;


    if any(dstPortsLeft==portRight)
        return
    end


    if~isempty(dstPortsLeft)
        delete_line(get_param(portLeft,'Line'))
    end
    if~isempty(dstPortsRight)
        delete_line(get_param(portRight,'Line'))
    end




    if~isempty(dstPortsLeft)
        add_line(system,dstPortsLeft(1),portRight,'autorouting','on')
    end
    if~isempty(dstPortsRight)
        add_line(system,dstPortsRight(1),portLeft,'autorouting','on')
    end


    set_param(bdroot,'Lock',isLocked);

end