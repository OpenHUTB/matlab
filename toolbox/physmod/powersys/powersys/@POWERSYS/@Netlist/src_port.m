function port=src_port(nl,node,idx)

    node_i=node+1;
    k=find(nl.portToNode(node_i,:));
    port=nl.ports(k(idx));



