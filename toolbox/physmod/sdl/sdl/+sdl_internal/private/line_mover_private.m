function line_mover_private(block,oldPort,newPort)











    system=get_param(block,'Parent');
    portList=get_param(block,'PortHandles');
    numLConns=length(portList.LConn);
    if newPort<=numLConns
        newPortHandle=portList.LConn(newPort);
    else
        newPortHandle=portList.RConn(newPort-numLConns);
    end
    connections=get_param(block,'PortConnectivity');
    dstPorts=connections(oldPort).DstPort;
    for i=1:length(dstPorts)
        delete_line(get_param(dstPorts(i),'Line'));
    end
    for i=1:length(dstPorts)
        add_line(system,newPortHandle,dstPorts(i),'autorouting','on');
    end