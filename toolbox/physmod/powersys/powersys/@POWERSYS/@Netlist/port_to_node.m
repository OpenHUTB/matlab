function node=port_to_node(nl,port)




    port_idx=find(nl.ports==port);
    if(length(port_idx)~=1)

        node=nl.reservednode;
        nl.reservednode=nl.reservednode+1;

    else
        node=find(nl.portToNode(:,port_idx));
        node=node-1;
    end



