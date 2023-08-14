function destination_ports=HtoIL_collect_destination_ports(block,port_list)











    blockPorts=get_param(block,'PortHandles');
    numLConns=length(blockPorts.LConn);
    for i=length(port_list):-1:1
        if port_list(i)<=numLConns
            destination_ports(i)=blockPorts.LConn(port_list(i));
        else
            destination_ports(i)=blockPorts.RConn(port_list(i)-numLConns);
        end
    end

end