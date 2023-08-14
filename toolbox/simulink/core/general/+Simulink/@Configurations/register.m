function configurations=register(bd)





    if isa(bd,'double')
        bd=get_param(bd,'object');
    end

    first=bd.getFirstChild;
    node=first;
    while~isempty(node)
        if isa(node,'Simulink.Configurations')
            configurations=node;
            return;
        end
        node=node.getNext;
    end

    section=Simulink.Configurations;
    configurations=section;
    if isempty(first)
        bd.addChildren(section);
    else
        first.insertBefore(section)
    end
