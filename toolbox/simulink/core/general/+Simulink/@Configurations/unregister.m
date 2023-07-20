function unregister(bd)





    if isa(bd,'double')
        bd=get_param(bd,'object');
    end

    node=bd.getFirstChild;
    while~isempty(node)
        if isa(node,'Simulink.Configurations')
            node.disconnect;
            return;
        end
        node=node.getNext;
    end
