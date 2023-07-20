function nl=bind_nodes(nl,node1,node2)










    node1_i=node1+1;
    node2_i=node2+1;




    a=nl.portToNode;
    a(node1_i,:)=a(node1_i,:)|a(node2_i,:);
    a(node2_i,:)=[];
    nl.portToNode=a;





    if(~isempty(nl.nodes))
        a=nl.nodes;
        a(find(a==node2))=node1;
        nl.nodes=a;
    end





    nl.check_nodes(mfilename);



