function nl=add_block_to_list(nl,block)






    ports=get_param(block,'PortHandles');
    P=[ports.LConn,ports.RConn];

    for i=1:length(P)
        NouveauNoeud=nl.port_to_node(P(i));
        if isempty(NouveauNoeud)
            disp('Empty node found in add_block_to_list file')
        else
            Newnodes(i)=NouveauNoeud;
        end
    end

    if(isempty(nl.nodes))
        nl.nodes={Newnodes};
    else
        nl.nodes=[nl.nodes;{Newnodes}];
    end

    if(strcmp(get_param(block,'MaskType'),'InnerPowersysBlock'))
        block=get_param(get_param(block,'Parent'),'Handle');
    end

    if(isempty(nl.elements))
        nl.elements=block;
    else
        nl.elements=[nl.elements;block];
    end